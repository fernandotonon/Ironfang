# Feasibility report — Milestone 0 (Clayground technical spike)

**Result: the spike passes the acceptance gate on desktop and in the browser.**
Measured 2026-09-04 on the environment below. Numbers come from the app's scripted
self-test (`ironfang --autotest`, or `index.html?args=--autotest` in the browser), which
spawns 1 → 20 → 40 QtMeshEditor Orcs, box-selects them, orders them around a building,
switches animation clips and logs FPS / simulation-step cost.

## Environment

| | Version / path |
|---|---|
| Clayground | v2026.6 (submodule `external/clayground`), MIT |
| Qt desktop | 6.11.1 `~/Qt/6.11.1/macos` (aqtinstall; modules qtquick3d, qtquick3dphysics, qtquicktimeline, qtmultimedia, qtshadertools) |
| Qt WebAssembly | 6.11.1 `~/Qt/6.11.1/wasm_multithread` |
| Emscripten | **4.0.7** — the version Qt 6.11 requires (`QT_EMCC_VERSION` in the kit's `mkspecs/qconfig.pri`); installed in `~/emsdk-qt6` |
| CMake / Ninja | 4.2.2 (Intel binary under Rosetta — see quirks) / 1.x; tests run with Qt's universal CMake 3.24 |
| QtMeshEditor | 3.36.1 (`qtmesh` CLI), TRELLIS.2 via trellis.cpp (Metal) |
| Host | macOS 26.3, Apple Silicon (arm64), 120 Hz display |
| Browser | Chrome 152 (headless, DevTools-protocol driven by `scripts/browser-check.mjs`), Metal-backed WebGL |

Clayground gates hard on Qt ≥ 6.10.0; the Qt 6.9.x kits on this machine could not be used.

## Build instructions

### Desktop (macOS)

```bash
git clone --recursive https://github.com/fernandotonon/Ironfang.git && cd Ironfang
export QT_ROOT=~/Qt/6.11.1/macos
cmake --preset desktop              # Release, tests on; ~20 min first time (builds Clayground + its deps)
cmake --build --preset desktop
./build-desktop/bin/ironfang.app/Contents/MacOS/ironfang [--autotest] [--no-models]
~/Qt/Tools/CMake/CMake.app/Contents/bin/ctest --test-dir build-desktop   # 2 tests: QML suite + app smoke test
```

### WebAssembly

```bash
scripts/build-wasm.sh                          # multithread kit -> deploy/multithread/
python3 scripts/serve.py deploy/multithread    # COOP/COEP headers + wasm MIME, no cache
open http://localhost:8080/                    # ?args=--autotest runs the self-test
node scripts/browser-check.mjs "http://localhost:8080/index.html?args=--autotest" --seconds 40
```

Build quirks found and fixed (all captured in `CMakePresets.json` / `CMakeLists.txt`):

* `/usr/local` holds a Homebrew Qt 6.11.1 that shadows `CMAKE_PREFIX_PATH` → `CMAKE_IGNORE_PREFIX_PATH=/usr/local`.
* `/usr/local/bin/cmake` is an Intel binary; under Rosetta it defaults the build to x86_64 (Homebrew's arm64 OpenSSL then fails to link) → `CMAKE_OSX_ARCHITECTURES=arm64`, `OPENSSL_ROOT_DIR=/opt/homebrew/opt/openssl`, `GGML_NATIVE=OFF` (llama.cpp inside `clay_ai` emits `-mcpu=native`, unsupported in that mix). An Intel `ctest` likewise launches the universal `qmltestrunner` as x86_64; use a native/universal ctest.
* Clayground's `clayinit.cmake` sets `CMAKE_MODULE_PATH` and the output directories in its own directory scope only; an external app must repeat both (`CMakeLists.txt`), otherwise `include(clayapp)` fails and `clay_app`'s post-link copy of `bin/qml` into the bundle has an empty source. **Candidate upstream fix** (small): make those `CACHE INTERNAL`/use `CMAKE_BINARY_DIR` in `clayinit.cmake` and `clayapp.cmake`.
* `XMLHttpRequest` cannot read `qrc:/` → asset config is a JS module (`app/config/assets.js`).

## Model format and conversion

* Source of truth: QtMeshEditor GLB (`assets/exported`, `assets/rigged`), textures external PNG.
* Runtime: **balsam** (ships with Qt) → `.mesh` + `maps/*.png` + `animations/*.qad` + a QML
  `Node` with `Skin` (19 joints), joint `Node`s and one `QtQuick.Timeline` per clip.
  `scripts/import-runtime.py` runs it and patches the QML: `clip` property (only the selected
  Timeline is enabled/running, one-shot clips emit `clipFinished`), `clips` list, `pickable`.
* Conversion verified on the static Orc (mesh + PBR material) and the rigged Orc (19 joints,
  5 clips → 90 `.qad` keyframe files, 4.7 MB runtime folder), no balsam warnings.
* `QtQuick3D.AssetUtils.RuntimeLoader` (GLB parsed at runtime) is linked into both builds as
  the alternative path but not used: balsam gives compiled QML, per-clip control and no
  glTF parsing in the browser.
* Runtime assets are compiled into the binary as Qt resources (`qrc:/assets/runtime/...`); the
  same relative layout works when the QML is served next to the Clayground Web Runtime.

## Texture format and size

PNG, 1024×1024 × 4 maps per model (base color RGBA, tangent normal, roughness, metallic ≈ 3.7 MB
per unit). balsam binds base color, roughness and normal. No KTX2/Basis in the pipeline;
QtMeshEditor has no texture compression, so a `toktx`/`gltf-transform` step would be an extra.

## Animation behaviour

* Clip switching at runtime through `UnitView.play(name)` → the patched asset's `clip` property:
  Idle ⇄ Walk ⇄ Attack switched instantly on 40 units (keys 1/2/3, HUD buttons, autotest).
* Walk plays while a unit follows its path and returns to Idle on arrival; one-shot clips
  (Attack, Hit, Death) fire `clipFinished`, Attack/Hit return to Idle, Death holds the last frame.
* All 5 balsam Timelines are instantiated per unit; only one is `enabled` at a time.
  40 units × 19 joints animate at 60 FPS in the browser with ~1 ms of JS per simulation step.
* Quality: QtMeshEditor's auto-rig + retargeted library clips read correctly on the Orc (see
  `assets/rigged/Orc` turntables); poses are coherent, no exploded limbs. Idle/Walk are not
  guaranteed seamless loops — acceptable for M0, tune later with `--duration`/clip choice.

## Picking behaviour

* `OrbitInput3D.pickAt(x, y)` → `View3D.pick()` on the pickable balsam mesh (works on the
  Orc at all zoom levels tested), with a screen-space capsule fallback (`mapFrom3DScene` of feet
  and head) for placeholders and clicks between limbs.
* Box selection: `mapFrom3DScene` of each unit's body centre against the drag rectangle;
  autotest selected 40/40 with a full-screen rectangle.
* Ground orders: `OrbitInput3D.groundAt` (analytic ray/plane) → `NavGrid` → A*
  (`Clayground.Algorithm.GridPathfinder`, diagonal) → 40/40 paths found around the 8×6 m
  building; separation keeps units apart; 0 units ended inside an obstacle footprint.
* Right-click = order comes from `OrbitInput3D.cancelled` (a right press that did not drag);
  right-drag orbits; the left button never belongs to the camera — as designed by Clayground.

## Measurements

| Metric | Desktop (Metal, 120 Hz) | Browser (Chrome 152, wasm_multithread) |
|---|---|---|
| Initial download | n/a | **40.0 MB** wasm + 0.35 MB js (17.9 MB gzip, 15.1 MB brotli); assets are inside the wasm |
| Load time to first frame (local server) | < 1 s | **≈ 2.4 s** (first log line after navigation; includes wasm compile) |
| FPS, 1 unit | 120 (cap) | 60 (cap) |
| FPS, 20 units | 117–120 | 60 |
| FPS, 40 units idle / attacking | 120 | 60 |
| FPS, 40 units walking (pathing + separation) | 115–120 | 60 |
| Simulation step (40 units walking) | ≈ 1.0 ms | ≈ 1.0–1.5 ms |
| Frame time (40 units) | 8.3–9.2 ms | 16.7 ms (vsync) |
| Memory | not measured (Instruments later) | JS heap 7 MB (wasm heap not exposed); `QT_WASM_INITIAL_MEMORY` 64 MB set by Clayground |
| Console warnings / errors | none (QML) | none, except the deliberate `Qt.quit()` abort at the end of the first autotest run (Qt for WASM cannot exit; now skipped on wasm) |

Frame rates sit on the display/vsync cap in both cases, so the true headroom is unknown but
≥ 2× at 40 units (frame 8–9 ms at 120 Hz desktop). The earlier 6–12 FPS readings during
development were caused by hung app instances sharing the GPU, not by the scene.

## Static hosting requirements

| Requirement | Value |
|---|---|
| Threads | Qt Quick 3D on WebAssembly uses the multithreaded build → `SharedArrayBuffer` → the page must be **cross-origin isolated** (`window.crossOriginIsolated === true`, verified) |
| Headers | `Cross-Origin-Opener-Policy: same-origin`, `Cross-Origin-Embedder-Policy: require-corp` (+ `Cross-Origin-Resource-Policy: same-origin` on assets) |
| Hosts without header control (GitHub Pages) | ship `coi-serviceworker.js` (from Clayground, MIT); it registers a service worker that injects the headers and reloads once on the first visit. `scripts/deploy-pages.sh` publishes `deploy/multithread` to the `gh-pages` branch with `.nojekyll`. |
| MIME | `.wasm` → `application/wasm` (GitHub Pages does this); `.js` → `text/javascript`; if assets are served as files: `.mesh`/`.qad` → `application/octet-stream`, `.qml` → `text/plain` |
| Compression | gzip cuts the wasm to 17.9 MB, brotli to 15.1 MB. GitHub Pages gzips on the wire; hosts with brotli should pre-compress. |
| Cache | `index.html` no-cache; `ironfang.js/.wasm` are immutable per build — add a content hash to the file names when the deploy target is final (not yet done) |
| `file://` | not supported (fetch + workers); test over HTTP (`scripts/serve.py`) |
| Same origin | all assets from the game's origin (isolation blocks cross-origin resources without CORP) |

## Clayground Web Runtime (no-local-toolchain path)

The prebuilt runtime (`clayground-starter.zip`, v2026.6 = Qt 6.10.1) can host everything in
this spike except skeletal animation: it links `QtQuick3D` + `QtQuick3D.Helpers` but neither
`QtQuick.Timeline` (balsam clips) nor `QtQuick3D.AssetUtils` (`RuntimeLoader`).
Candidate upstream change (two lines each in `tools/webdojo/CMakeLists.txt` `LINK_LIBS` and
`tools/webdojo/QmlModules.qml`). Until then Ironfang ships its own runtime build (this report);
the game QML stays runtime-loadable (Item-rooted `IronfangGame.qml`, `qmldir`, relative asset URLs).

## Known limitations

* Runtime assets are baked into the 40 MB wasm; every new unit type adds ~4.7 MB. Serving
  `assets/runtime` as separate files (lazy fetch) is the obvious next step for load time.
* Textures are PNG (no KTX2); a texture-compression pass is an external tool.
* Idle/Walk loop seams and clip timing are untuned; `Death` holds the last frame (no fade).
* Only the multithreaded WASM flavour was built and measured; single-threaded (no COI headers
  needed) is untested — it would also lose Qt Quick 3D's threaded renderer.
* Memory was not profiled beyond the JS heap; Qt's wasm heap and Instruments on desktop are TODO.
* `ctest` needs a native/universal binary on Apple Silicon (documented, not fixable from this repo).
* Browser input was verified for the scripted path (selection/orders driven from QML) and by
  the cross-origin-isolated boot; pointer/keyboard events in a real browser session are on the
  manual checklist and not yet ticked.

## Acceptance gate

| # | Criterion | Result |
|---|---|---|
| 1 | Desktop and browser builds run | ✅ `build-desktop/bin/ironfang.app`, `deploy/multithread` served over HTTP |
| 2 | Externally authored animated model renders | ✅ Orc: image → TRELLIS.2 → `qtmesh rig` → `qtmesh anim` → balsam; renders on both targets |
| 3 | Idle/Walk/Attack switch programmatically | ✅ `UnitView.play()`; verified by autotest on 40 units, both targets |
| 4 | Click, box selection, move orders | ✅ pick + capsule fallback, rectangle 40/40, right-click orders with distributed destinations |
| 5 | Navigation around an obstacle | ✅ A* over 60×60 grid, 40/40 paths around the building, 0 units in obstacles |
| 6 | Forty representative units usable in the browser | ✅ 60 FPS (cap) with 40 animated Orcs walking, ≈1 ms/step |
| 7 | Static hosting documented | ✅ headers, MIME, compression, cache, COI shim, Pages script |
| 8 | No architectural blocker | ✅ none found; upstream niceties: clayinit scope, Web Runtime modules |

**Recommendation: proceed to Milestone 1** (interaction prototype) after review. Suggested
first tasks: serve runtime assets as files instead of baking them in, add a real-browser manual
pass of the input checklist, then rig Goblin / Orc Archer / Ogre with `scripts/rig-unit.sh`.
