# Ironfang: First Siege

**A micro-RTS forged with QtMeshEditor.**
*Built with Clayground. Forged with QtMeshEditor.*

A small (10–15 minute) fantasy real-time-strategy game for the browser and the desktop, and
an end-to-end demonstration of an asset workflow: every model is generated from a concept
image, rigged and animated with [QtMeshEditor](https://github.com/fernandotonon/QtMeshEditor),
then played by a game built on [Clayground](https://github.com/MisterGC/clayground)
(Qt 6 / QML / Qt Quick 3D).

> **Project status: playable vertical slice** (Milestones 0–4 done, 5 in progress). Play it at
> **https://fernandotonon.github.io/Ironfang/** — feasibility: [`docs/feasibility-report.md`](docs/feasibility-report.md),
> design: [`docs/architecture.md`](docs/architecture.md), numbers: [`docs/balancing.md`](docs/balancing.md).

**The match:** select goblin workers and send them to an iron deposit; spend iron at the Clan
Fortress (workers) and the War Foundry (warriors, archers, an ogre); hold off the enemy waves;
destroy the Enemy Fortress. Victory/defeat overlay, Play Again without reloading.

## Requirements

| Tool | Version | Notes |
|---|---|---|
| Qt | **6.10.0 or newer** (developed with 6.11.1) | Clayground's hard minimum. Desktop kit with Qt Quick 3D, Quick 3D Physics, Quick Timeline, Multimedia, Shader Tools. For the web: the `wasm_multithread` kit of the same version. |
| Emscripten | **exactly the version your Qt requires** (4.0.7 for Qt 6.11) | `grep QT_EMCC_VERSION <wasm kit>/mkspecs/qconfig.pri` |
| CMake ≥ 3.25, Ninja, Python 3 | | |
| QtMeshEditor | 3.36+ | only to (re)generate assets; not needed to build or run |

Install Qt with the Maintenance Tool or [aqtinstall](https://github.com/miurahr/aqtinstall):

```bash
python3 -m aqt install-qt mac desktop 6.11.1 clang_64 -O ~/Qt \
    -m qtquick3d qtquick3dphysics qtquicktimeline qtmultimedia qtshadertools
python3 -m aqt install-qt all_os wasm 6.11.1 wasm_multithread -O ~/Qt \
    -m qtquick3d qtquicktimeline qtmultimedia qtshadertools
git clone https://github.com/emscripten-core/emsdk.git ~/emsdk-qt6
~/emsdk-qt6/emsdk install 4.0.7 && ~/emsdk-qt6/emsdk activate 4.0.7
```

## Build & run

```bash
git clone --recursive https://github.com/fernandotonon/Ironfang.git
cd Ironfang
git submodule update --init --recursive        # if you forgot --recursive

# Desktop
export QT_ROOT=~/Qt/6.11.1/macos
cmake --preset desktop && cmake --build --preset desktop
./build-desktop/bin/ironfang.app/Contents/MacOS/ironfang     # macOS bundle
ctest --preset desktop                                        # tests (headless)

# WebAssembly + static deploy directory
scripts/build-wasm.sh                 # -> deploy/multithread/
python3 scripts/serve.py deploy/multithread
open http://localhost:8080/
```

Clayground is vendored as a git submodule (`external/clayground`) and built in-tree; there
is nothing to install. If CMake picks a stray Qt (e.g. Homebrew's in `/usr/local`), the
presets already pass `-DCMAKE_IGNORE_PREFIX_PATH=/usr/local`. On Apple Silicon the desktop
preset pins `CMAKE_OSX_ARCHITECTURES=arm64` (an Intel `cmake` running under Rosetta would
otherwise silently produce an x86_64 build that cannot link Homebrew's arm64 OpenSSL) and
`OPENSSL_ROOT_DIR=/opt/homebrew/opt/openssl` for Clayground's networking dependency.
Use a native (or universal) CMake for `ctest` as well: an Intel `ctest` launches Qt's universal
`qmltestrunner` as x86_64, which then cannot load the arm64 plugins. The universal CMake that
ships with Qt works: `~/Qt/Tools/CMake/CMake.app/Contents/bin/ctest --test-dir build-desktop`.

## Controls

| Input | Action |
|---|---|
| Left click / drag | select a unit or building / box-select units · Shift adds or removes |
| Right click on ground / enemy / deposit / fortress | move · attack · gather (workers) · return iron |
| W A S D / arrows, wheel, right-drag | pan, zoom toward the cursor, orbit |
| HUD buttons | produce units (cost · time), cancel, Return iron, Stop |
| P / Esc | pause / clear selection · Space centres on the fortress |
| F, N, M, `[` `]` | render stats · sound on/off · models/boxes · sim speed (debug) |

Command line: `--autotest` (scripted match at 8×, logs `AUTOTEST` lines), `--showcase`,
`--no-models`, `--mute`. In the browser: `index.html?args=--autotest`.

## Repository layout

```
app/            QML game (Main.qml entry, IronfangGame.qml root Item, scripts/*.js modules)
assets/         source-images → exported (GLB) → rigged (GLB) → runtime (balsam .mesh/.qad + QML)
scripts/        generate-models.sh · rig-unit.sh · import-runtime.py · build-wasm.sh · serve.py
tests/          QML TestCase suites (ctest)
docs/           plan, feasibility report, asset pipeline, asset manifest, test checklist
external/       clayground submodule
```

## Asset showcase & audio

The title screen's **Asset Showcase** puts every unit, building and prop on a turntable with
clip switching and the asset-contract data (triangles, bones, clips, textures, formats, status).
All sound is synthesized by `scripts/gen-audio.py` (original, no external samples).

## Asset workflow in one line each

```bash
scripts/generate-models.sh Orc                     # image -> static GLB (TRELLIS.2, 10k tris, 1024² PBR)
scripts/rig-unit.sh Orc                            # -> rigged GLB with Idle/Walk/Attack/Hit/Death
python3 scripts/import-runtime.py assets/rigged/Orc/Orc_rigged.glb assets/runtime/orc --name Orc
```

Then point `app/config/assets.js` at `assets/runtime/orc/Orc.qml`. Details:
[`docs/asset-pipeline.md`](docs/asset-pipeline.md), inventory:
[`docs/asset-manifest.md`](docs/asset-manifest.md).

## Web hosting

The WebAssembly build is multithreaded (required by Qt Quick 3D), so the page must be
cross-origin isolated: send `Cross-Origin-Opener-Policy: same-origin` and
`Cross-Origin-Embedder-Policy: require-corp`, or — on GitHub Pages, which cannot set headers —
keep the bundled `coi-serviceworker.js`. `.wasm` must be served as `application/wasm`.
Opening `index.html` from disk does not work. Full list: `docs/feasibility-report.md`.

## License

MIT (see `LICENSE`). Qt Quick 3D is GPL-3.0 for open-source users, which this project's MIT
license is compatible with; third-party notices and the CC-BY motion-clip credits are in
[`THIRD_PARTY_LICENSES.md`](THIRD_PARTY_LICENSES.md).

Built with Clayground. Assets created and processed with QtMeshEditor. Built with DINOv3.
