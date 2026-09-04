# Asset pipeline — QtMeshEditor → Clayground

Every 3D asset in Ironfang is produced by QtMeshEditor from a single concept image and
consumed by Qt Quick 3D through a Qt-supported conversion. Nothing proprietary sits in the
chain, and every step is a documented command that can be re-run.

```
assets/source-images/<Name>.png            concept art (1024-1500 px, opaque background)
        │  qtmesh generate3d --backend trellis2          scripts/generate-models.sh
        ▼
assets/exported/<Name>/<Name>.glb           static mesh, ~10k tris, 4 PBR maps (1024²), .material
assets/qtmesh-projects/sources/*.qtm3d      full-res TRELLIS.2 generation (gitignored, 20 MB each)
        │  qtmesh rig --skin  +  qtmesh anim --generate/--rename     scripts/rig-unit.sh
        ▼
assets/rigged/<Name>/<Name>_rigged.glb      19-bone humanoid skin + named clips
        │  balsam (Qt) + runtime patch                    scripts/import-runtime.py
        ▼
assets/runtime/<name>/<Name>.qml            Qt Quick 3D: .mesh + maps/ + animations/*.qad
        │  app/config/assets.js                            (asset indirection)
        ▼
UnitView.qml  →  Loader3D { source: typeDef.model }      gameplay never names a file
```

## 1. Image → static model (`scripts/generate-models.sh`)

```bash
qtmesh generate3d "<Name>.png" -o assets/exported/<Name>/<Name>.glb \
    --backend trellis2 --preset high --target-tris 10000 --texture-size 1024 \
    --remove-bg --seed 42
```

| Setting | Value | Why |
|---|---|---|
| backend | TRELLIS.2 via trellis.cpp (Metal) | highest-quality tier in QtMeshEditor; MIT code + weights |
| preset | `high` (falls back to the 512 pipeline: only 512 GGUFs installed) | |
| `--target-tris` | 10 000 | game-ready weld + debris cull + meshopt simplify, detail re-baked into normal map |
| `--texture-size` | 1024 | xatlas packs to ~1324-1452 px; `scripts/resize-textures-1024.py` brings every map to exactly 1024² (UVs are normalised, so this is lossless for the mesh) |
| `--remove-bg` | on | concept images have no alpha; QtMeshEditor's own U²-Net matte is used |
| `--seed` | 42 | reproducible |

Output per model: `<Name>.glb` (external PNG textures referenced by relative URI),
`<Name>.material` (Ogre sidecar), `*_diffuse/_normal/_roughness/_metallic.png`.
Time: 3-6 min per model on an M-series Mac (up to 30 min under memory pressure).

## 2. Static → rigged + animated (`scripts/rig-unit.sh <Name> [action:Clip ...]`)

```bash
qtmesh rig  Orc.glb --skeleton humanoid --skin --algo pinocchio --up-axis y -o r0.glb
qtmesh anim r0.glb --generate "idle"   --duration 3   -o a1.glb   # then walk, attack, hit, death
qtmesh anim a5.glb --rename generated_idle Idle -o a6.glb          # one rename per call
```

* Skeleton: QtMeshEditor's 19-bone humanoid template, Mixamo-style names
  (`Hips, Spine, Chest, Neck, Head, Left/Right{Shoulder,Arm,ForeArm,Hand,UpLeg,Leg,Foot}`).
  Offline, seconds on CPU. Works best on upright single-component A/T-pose meshes (all
  TRELLIS.2 characters here qualify).
* Clips come from QtMeshEditor's bundled permissive motion library (CMU/CC0/CC-BY clips
  retargeted through its 22-joint canonical skeleton). Actions used: `idle walk attack hit
  death`; for the worker's `Gather` use `farmloop` / `working` / `pickup`.
  List all actions with `qtmesh anim x.glb --generate zzz` (the error prints them).
* **Do not pass `--variant`**: it indexes the whole library, so every prompt gets the same clip.
* Clip names in the game are fixed: `Idle Walk Attack Hit Death` (+ `Gather`, `HeavyAttack`).
  Attack/Hit/Death/Gather are one-shot, the rest loop.
* Output GLB: `skins[0]` with 19 joints, `JOINTS_0/WEIGHTS_0`, named `animations`. Draco is a
  no-op on skinned meshes (QtMeshEditor refuses to corrupt them), so no `--compress`.
* Check visually: `qtmesh turntable X_rigged.glb --animation Walk --frames 8 -o walk.png`.

## 3. GLB → Qt Quick 3D runtime asset (`scripts/import-runtime.py`)

Qt Quick 3D can load glTF two ways; Ironfang uses **balsam at asset-build time**:

| | balsam (chosen) | `QtQuick3D.AssetUtils.RuntimeLoader` |
|---|---|---|
| when | offline, once per asset | in the browser on every load |
| output | `.qml` + `.mesh` + `maps/` + `animations/*.qad` | none (parses the GLB in place) |
| control | full: we patch the QML (clip switching, pickable) | animations exposed as a list of `Animation` objects |
| web runtime | needs `QtQuick.Timeline` linked | needs `QtQuick3D.AssetUtils` linked |
| cost | build step (`balsam` ships with Qt) | glTF parse + texture decode at runtime |

```bash
python3 scripts/import-runtime.py assets/rigged/Orc/Orc_rigged.glb assets/runtime/orc --name Orc
```

The script runs `balsam`, then patches the generated `Orc.qml`:

* `property string clip` — set it to a clip name to play it; every `Timeline` is
  `enabled`/`running` only while selected, one-shot clips have `loops: 1` and emit
  `clipFinished(name)`.
* `readonly property var clips` — the names balsam found.
* the mesh `Model` gets `pickable: true` so `View3D.pick()` can select it.

The original GLB is untouched; re-run the script whenever the GLB changes. The output is
committed (it is what the app and the static web deployment load).

## 4. Asset indirection (`app/config/assets.js`)

```js
"orc_warrior": { model: "assets/runtime/orc/Orc.qml", status: "qtmesheditor",
                 scale: 1.8, footOffset: 0.49, yawOffset: 0, radius: 0.55, speed: 3.2,
                 clips: { idle: "Idle", walk: "Walk", attack: "Attack", hit: "Hit", death: "Death" } }
```
(A JS module rather than JSON: `XMLHttpRequest` cannot read `qrc:/` resources by default,
while a JS import works from resources, disk and HTTP alike.)

`UnitView` loads `model` through `Loader3D` and falls back to a toon-shaded `Box3D`
placeholder while it loads or when `model` is empty. Replacing a placeholder with a final asset
is editing this entry — selection, navigation, combat and production code never see file names.

Conventions:

* **Scale** — TRELLIS.2 output is normalised to a ~1-unit bounding box centred at the origin;
  `scale` gives metres of height, `footOffset` (half the model height, in model units) lifts
  the feet to y = 0.
* **Orientation** — Y up; `yawOffset` (degrees) fixes models that face −Z.
* **Origin/pivot** — unit Node origin is at the feet on the ground plane.
* **Textures** — PNG, 1024², base color / normal (tangent) / roughness / metallic, referenced
  by relative URI so the same folder works from `qrc:/` and over HTTP.

## 5. Web deployment paths

Assets are addressed relative to the QML files that use them (`Qt.resolvedUrl`), so the
same tree works compiled into the desktop/WASM binary (`qrc:/assets/runtime/...`) and copied
next to `Main.qml` for the Clayground Web Runtime (`https://host/game/assets/runtime/...`).
Directory imports over HTTP need a `qmldir` (present in `app/`).
