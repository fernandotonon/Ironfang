# Ironfang: First Siege — Milestone 0 plan (Clayground feasibility spike)

> Built with Clayground. Forged with QtMeshEditor.

This document is the implementation plan for Milestone 0 only. It records what was
inspected, the decisions taken, and the exact list of things the spike must prove.
Gameplay (economy, production, combat, AI) does not start until the acceptance gate in
`docs/feasibility-report.md` passes on desktop **and** WebAssembly.

## 1. What was inspected (2026-09-03)

### Clayground (v2026.6, MIT)

| Fact | Consequence for Ironfang |
|---|---|
| Hard minimum **Qt 6.10.0** (`CMakeLists.txt`, `CLAY_QT_MIN_VERSION`; configure fails otherwise). CI uses 6.10.1, README uses 6.11.1. | Installed **Qt 6.11.1** (`~/Qt/6.11.1/macos`, `~/Qt/6.11.1/wasm_multithread`). Qt 6.9.x on this machine cannot be used. |
| No `install()`/`export()`/`find_package(Clayground)`. Apps are consumed **in-tree** with `add_subdirectory` + `clay_app()` (`cmake/clayapp.cmake`). | Clayground is vendored as a **git submodule** at `external/clayground`, pinned to `v2026.6`. Ironfang's `CMakeLists.txt` adds it as a subdirectory with tools/examples switched off. |
| `clay_app(NAME VERSION LINK_LIBS QML_FILES RES_FILES ...)` generates `main.cpp`, calls `qt_add_qml_module(URI <NAME>)`, and requires the entry point to be **`Main.qml`**. It also auto-registers a headless smoke test. | Ironfang app target `ironfang`, `Main.qml` entry, QML module URI `ironfang`. |
| Plugins live under URI `Clayground.<Name>`. Relevant: **Canvas3D** (`OrbitCamera3D`, `OrbitInput3D`, `Box3D`, `LabelBatch3D`, `PerfHud`), **Algorithm** (`GridPathfinder` A*), **Lab** (`SelectionFrame3D`), **GameController**, **Storage** (`KeyValueStore`), **World** (`ClayWorld3d` + SVG `SceneLoader3d`). | Camera/input: use `OrbitCamera3D` + `OrbitInput3D` directly in our own `View3D`. They were written to an RTS brief (left button always belongs to the scene, right-click emits `cancelled()`, `groundAt(x,y)`, `pickAt(x,y)`, `panLeash`, `minHeight`). `ClayWorld3d` hard-codes its own camera controllers and imports `QtQuick3D.Physics`, so it is **not** used. |
| **No external model loading anywhere** (no glTF/GLB, no `RuntimeLoader`, no balsam, no `Skeleton`/`Skin`). All 3D is primitives/procedural. | The model + skeletal-animation path is greenfield. It is pure Qt Quick 3D and does not need framework changes, but it is the #1 risk and is tested first. |
| `qtquick3dphysics` is excluded from Clayground's WASM CI ("crashes browser"). | No physics for gameplay; RTS movement is grid + steering anyway. |
| Multithreaded WASM is required for Qt Quick 3D demos; needs `Cross-Origin-Opener-Policy: same-origin` + `Cross-Origin-Embedder-Policy: require-corp`. Clayground ships `docs/coi-serviceworker.js` for hosts that cannot set headers (GitHub Pages). | Use `wasm_multithread`; ship the COI service worker in the deploy directory. Also verify a single-thread build as a fallback. |
| Tests: `clay_add_qml_test(Name DIRECTORY dir)` → `qmltestrunner`, headless (`QT_QPA_PLATFORM=minimal`), `tests/tst_*.qml`; `clay_add_node_test` for pure JS; every `clay_app` is a ctest smoke test. | Same macros for Ironfang tests. |
| `skills/clay-lab/references/pitfalls.md`: `Box3D` origin is bottom-centre; `Repeater3D` copies plain JS objects (needs a revision counter); `mapFrom3DScene` bindings must depend on `camera.scenePosition/sceneRotation`; **every imported QML directory needs a `qmldir` or it fails only in WASM**; `View3D` needs an explicit `camera:`. | Followed throughout. |
| A Homebrew Qt 6.11.1 in `/usr/local` shadows `CMAKE_PREFIX_PATH`. | Every configure passes `-DCMAKE_IGNORE_PREFIX_PATH=/usr/local`. |

### Qt for WebAssembly

Qt 6.11 requires **Emscripten 4.0.7** (verified in `wasm_multithread/mkspecs/qconfig.pri`).
Installed in a separate checkout `~/emsdk-qt6` so the existing `~/emsdk` (3.1.25, used for
Qt 6.6 projects) is untouched.

### QtMeshEditor asset workflow (verified on the real Orc model)

* `qtmesh generate3d <img> --backend trellis2 --preset high --target-tris 10000 --texture-size 1024 --remove-bg` — 24 static GLBs already produced (see `docs/asset-manifest.md`).
* `qtmesh rig <glb> --skeleton humanoid --skin --algo pinocchio -o rigged.glb` — offline auto-rig, 19-bone Mixamo-style skeleton (`Hips, Spine, Chest, Neck, Head, Left/Right Shoulder|Arm|ForeArm|Hand|UpLeg|Leg|Foot`), seconds on CPU.
* `qtmesh anim <glb> --generate "<action>" --duration N -o out.glb` — retargets a clip from the bundled permissive motion library; `idle`, `walk`, `attack`, `hit`, `death` all exist as actions; for the worker's `Gather` use `farmloop`/`working`/`pickup`. Clips accumulate across calls. **Do not pass `--variant`** (it indexes the whole library, every prompt then resolves to the same clip).
* `qtmesh anim <glb> --rename generated_walk Walk -o out.glb` — one rename per call.
* Output GLB carries `skins`, `JOINTS_0/WEIGHTS_0`, named `animations`; textures stay **external PNGs** referenced by relative URI.
* Qt `balsam` imports the TRELLIS GLB cleanly (mesh + PrincipledMaterial + base color/roughness/normal maps) — verified.
* Draco is a no-op on skinned meshes; no KTX2 support; texture downsizing is done with a script after the bake.

## 2. Decisions

1. **Repository layout** — Ironfang is its own application repo; Clayground is a submodule (`external/clayground`).
2. **Runtime model format** — Qt Quick 3D can load glTF/GLB either at runtime with `QtQuick3D.AssetUtils.RuntimeLoader` or ahead of time with `balsam` (GLB → `.mesh` + generated QML). The spike tests **both** and the feasibility report picks one. Working hypothesis: balsam at build time (a CMake custom command) because it avoids parsing glTF in the browser, gives compiled QML, and keeps the original GLB untouched in `assets/exported/`.
3. **Asset indirection** — every unit/building type is described in `config/assets.js` (model file, scale, yaw offset, animation clip names, status placeholder/final). Gameplay code only ever refers to the type id.
4. **Placeholders** — Clayground `Box3D` primitives are used for anything without a final model, so the whole spike runs even if rigging fails on a given mesh.
5. **Genuine external rigged test model** — the Orc, rigged and animated entirely through QtMeshEditor (the intended pipeline), plus Clayground/Qt behaviour cross-checked with a second rigged asset if the first fails.
6. **WebAssembly flavour** — `wasm_multithread` first (Qt Quick 3D recommendation). GitHub Pages hosting uses the COI service worker.

## 3. Spike deliverables (what gets built)

```
Ironfang/
├── CMakeLists.txt               # project; add_subdirectory(external/clayground); add_subdirectory(app)
├── CMakePresets.json            # desktop / wasm presets pointing at ~/Qt/6.11.1
├── external/clayground/         # submodule, v2026.6
├── app/
│   ├── CMakeLists.txt           # clay_app(ironfang ...)
│   ├── Main.qml                 # window + Spike scene
│   ├── qmldir                   # required for WASM directory imports
│   ├── spike/                   # Milestone 0 scene (kept as the asset showcase seed later)
│   │   ├── SpikeScene.qml       # View3D, ground, camera rig, input
│   │   ├── RtsCamera.qml        # OrbitCamera3D + OrbitInput3D wrapper, WASD, wheel, map leash
│   │   ├── UnitView.qml         # model/placeholder + animation switching + marker + health bar
│   │   ├── SelectionBox.qml     # drag rectangle
│   │   ├── NavGrid.js           # world<->grid, static obstacles, A* via Clayground GridPathfinder
│   │   └── Mover.js             # follow path, separation
│   └── config/assets.js
├── assets/
│   ├── source-images/           # the 24 concept PNGs
│   ├── exported/<Name>/         # QtMeshEditor GLB + textures + .material (as generated)
│   ├── rigged/<Name>/           # rigged + animated GLBs from qtmesh rig/anim
│   ├── runtime/                 # balsam output consumed by the app (generated, may be committed)
│   └── qtmesh-projects/         # *_source.qtm3d full-res sidecars (gitignored, 20 MB each)
├── scripts/
│   ├── generate-models.sh       # image -> GLB batch (the recipe used)
│   ├── rig-unit.sh              # GLB -> rigged + Idle/Walk/Attack/Hit/Death[/Gather]
│   ├── import-runtime.sh        # balsam conversion
│   ├── build-wasm.sh            # emsdk env + qt-cmake + deploy dir
│   └── serve.py                 # static server with COOP/COEP + wasm MIME
├── tests/                       # QML TestCase: grid conversion, A*, selection math
└── docs/
    ├── milestone-0-plan.md      # this file
    ├── feasibility-report.md    # measurements + gate result
    ├── asset-pipeline.md
    └── asset-manifest.md
```

## 4. Spike checklist (maps 1:1 to the acceptance gate)

| # | Requirement | How it is proven |
|---|---|---|
| 1 | Ground plane + RTS camera | `SpikeScene.qml`: `Model #Rectangle` ground, `OrbitCamera3D` with pitch clamp, `minHeight`, `panLeash`; WASD/arrows + wheel via `OrbitInput3D` |
| 2 | QtMeshEditor model loads | Orc GLB via balsam (`assets/runtime`) and via `RuntimeLoader`; screenshot |
| 3 | Rigged model plays Idle/Walk/Attack | Orc rigged with `qtmesh rig` + `qtmesh anim --generate`, clips renamed; balsam-generated `Timeline`s / `RuntimeLoader.animations` |
| 4 | Runtime animation switching | `UnitView.play("Walk")`; key 1/2/3 in the spike toggles clips |
| 5 | Click / ray pick a unit | `View3D.pick` through `OrbitInput3D.pickAt` on left click |
| 6 | Drag-rectangle multi select | screen-space rectangle vs `mapFrom3DScene` of each unit |
| 7 | Right-click move order | `OrbitInput3D.groundAt` → `NavGrid` path → `Mover` |
| 8 | Navigate around a static building | a blocked rectangle in `NavGrid`, A* via `Clayground.Algorithm.GridPathfinder` |
| 9 | World-space marker + health bar | `SelectionFrame3D` decal + billboard bar following the unit |
| 10 | ~40 animated units | spawn key `+`; `PerfHud` FPS at 1 / 20 / 40 |
| 11 | WebAssembly build | `scripts/build-wasm.sh` (multithread), served with `scripts/serve.py` |
| 12 | Browser mouse/keyboard | manual check in Chrome/Safari, console log captured |
| 13 | Load time / FPS acceptable | measured and recorded in the report |
| 14 | Static hosting | served from a directory over HTTP, not `file://`; GitHub Pages notes (COI service worker) |

## 5. Measurements to record (`docs/feasibility-report.md`)

Build instructions (desktop + wasm), initial download size, load time, FPS at 1/20/40
units, memory if available, model format + conversion, texture format/size, animation
behaviour, picking behaviour, console warnings, known limitations, threads / COOP-COEP
requirement, hosting headers / MIME / compression / cache.

## 6. Out of scope for Milestone 0

Economy, production, combat, enemy AI, HUD, audio, save state, final art for buildings.
