# Third-party licenses

Ironfang's own code, documentation and generated 3D assets are MIT (see `LICENSE`).
Everything below is redistributed or depended upon and keeps its own license.

| Component | Where | License | Notes |
|---|---|---|---|
| **Clayground** (v2026.6) | `external/clayground` (git submodule) | MIT | Framework. Its `LICENSE` carries a Qt-dependency notice; see below. |
| qml-box2d, simple-svg-writer, jsonata, csv-parser, earcut | `external/clayground/thirdparty` | MIT / MIT / MIT / MIT / ISC | Pulled in by Clayground; only earcut and the SVG writer are linked into the 3D plugins Ironfang uses. |
| **Qt 6.11** (Core, Qml, Quick, Quick3D, Quick3DHelpers, Quick3DAssetUtils, QuickTimeline, Multimedia) | build dependency; embedded in the WebAssembly binary | LGPL-3.0 / **GPL-3.0** / commercial | **Qt Quick 3D and Qt Quick Timeline are GPL-3.0 (or commercial) for open-source users.** The WebAssembly and desktop binaries therefore contain GPL-3.0 code, and Ironfang is distributed under a GPL-compatible license (MIT) with source available. The Clayground Web Runtime bundle carries the same obligation (`LICENSES/` in the starter bundle). |
| **Emscripten** 4.0.7 | build toolchain | MIT / UIUC | Not redistributed; the generated JS glue is MIT. |
| coi-serviceworker.js | `deploy/*/coi-serviceworker.js` (copied from Clayground `docs/`) | MIT | Header shim for static hosts. |
| **QtMeshEditor** 3.36.1 | asset tool (not redistributed) | MIT | Used to generate, rig, animate and export every model. |
| TRELLIS.2 (Microsoft) code + TRELLIS.2-4B weights, trellis.cpp fork | asset tool (not redistributed) | MIT | Image-to-3D backend inside QtMeshEditor. |
| DINOv3 image encoder (Meta) | asset tool (not redistributed) | DINOv3 License | Commercial use permitted; attribution: **"Built with DINOv3."** |
| U²-Net (background matte) | asset tool | Apache-2.0 | |
| **Motion library clips** retargeted onto the rigged units (`Idle`, `Walk`, `Attack`, `Hit`, `Death`, `Gather`) | `assets/rigged/*`, `assets/runtime/*/animations/*.qad` | CC0 and **CC-BY-3.0/4.0** | QtMeshEditor's bundled template-clip library is derived from a CC0/CC-BY corpus (Sketchfab, OpenGameArt, Quaternius). CC-BY sources must be credited wherever derived output is redistributed: the full credit list is `docs/licenses/QTMESHEDITOR_MOTION_ATTRIBUTION.md` and is shown in the game's credits screen. |
| Concept images | `assets/source-images/` | project (MIT) | Original artwork made for Ironfang. |

## Qt licensing summary (from Clayground's `LICENSE` and the Web Runtime `NOTICE`)

* 2D-only Clayground games may be closed source (Qt LGPL).
* A game using the 3D API (Qt Quick 3D) must be under a GPL-compatible license or use a Qt
  commercial license. Ironfang is MIT and open source, which qualifies.
* Hosting the WebAssembly runtime is redistribution: the deploy directory keeps the license
  texts (`LICENSES/`) and `RUNTIME-MANIFEST.json` next to the binary.

This file is a good-faith summary, not legal advice. Review before public distribution.
