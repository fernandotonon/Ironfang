# Asset manifest

All models generated 2026-09-03/04 with **QtMeshEditor 3.36.1** (`qtmesh` CLI, Homebrew cask) using the recipe in `docs/asset-pipeline.md`. Source images are original
concept art for this project (`assets/source-images/`).

Legend — **Status**: `static` = TRELLIS.2 GLB only · `rigged` = skeleton + clips ·
`runtime` = balsam-imported and used by the app · `placeholder` = Box3D in game.

## Units

| Asset | Source image | Tris | Verts | Textures | Skeleton | Clips | Status | Game type |
|---|---|---:|---:|---|---|---|---|---|
| Orc | Orc.png | 9 952 | 10 623 | 4 × 1024² PNG | 19-bone humanoid (Pinocchio) | Idle 2.97 s · Walk 0.97 s · Attack 1.47 s · Hit 0.77 s · Death 2.47 s | **runtime** (`assets/runtime/orc/Orc.qml`) | Orc Warrior |
| Orc Archer | Orc Archer.png | 9 918 | 10 539 | 4 × 1024² | — | — | static | Orc Archer |
| Goblin | Goblin.png | 9 964 | 10 906 | 4 × 1024² | — | — | static | Goblin Worker |
| Ogre | Ogre.png | 9 908 | 10 657 | 4 × 1024² | — | — | static | Ironhide Ogre |

## Buildings and props

| Asset | Source image | Tris | Verts | Status | Intended use |
|---|---|---:|---:|---|---|
| Clan Fortress | Clan Fortress.png | 9 788 | 15 926 | static | Clan Fortress |
| War Foundry | War Foundry.png | 9 918 | 15 331 | static | War Foundry |
| Iron Deposit | Iron Deposit.png | 9 994 | 11 554 | static | Iron Deposit |
| Anvil | Anvil.png | 9 920 | 11 210 | static | foundry prop |
| Fire | Fire.png | 9 956 | 11 079 | static | foundry/camp prop |
| Weapons | Weapons.png | 9 900 | 12 176 | static | weapon rack prop |
| Clan Banner | Clan Banner.png | 9 998 | 9 391 | static | fortress decoration |
| Ironfang emblem | Ironfang emblem.png | 9 958 | 10 599 | static | menu / HUD |
| Ironfang | Ironfang.png | 10 000 | 9 440 | static | title / logo prop |
| Broken Cart | Broken Cart.png | 9 866 | 13 482 | static | map obstacle |
| Dead Ironwood tree | Dead Ironwood tree.png | 9 058 | 12 859 | static | map obstacle |
| Large Rocks | Large Rocks.png | 9 998 | 8 988 | static | map obstacle |
| Small Rocks | Small Rocks.png | 9 990 | 8 453 | static | map decoration |
| Basket | Basket.png | 9 828 | 14 616 | static | prop |

## Weapons (hand-held, attach later)

| Asset | Source image | Tris | Verts | Status |
|---|---|---:|---:|---|
| Arrow | Arrow.png | 10 000 | 8 784 | static (archer projectile) |
| Bow | Bow.png | 9 942 | 9 738 | static |
| Cleaver | Cleaver.png | 10 000 | 9 613 | static |
| Hammer | Hammer.png | 9 992 | 9 030 | static |
| Pickaxe | Pickaxe.png | 9 996 | 8 719 | static (worker tool) |
| Shield | Shield.png | 10 000 | 10 119 | static |

## Common properties

| Property | Value |
|---|---|
| Export format | glTF 2.0 binary (`.glb`), textures external PNG |
| Runtime format | balsam `.mesh` + `.qad` keyframes + QML (Qt 6.11) |
| Coordinate system | Y up, right-handed, metres after `scale` |
| Bounding box | normalised to ≈1 unit, centred at origin (TRELLIS.2) |
| Texture maps | `*_diffuse` (base color RGBA), `*_normal` (tangent), `*_roughness`, `*_metallic` — 1024×1024 PNG |
| Material naming | `qtmesh_gen3d_<n>_<timestamp>_mesh_mat` (QtMeshEditor generated) |
| Collision | none in 3D; navigation uses `NavGrid.blockRect` footprints (1 m cells) |
| LOD | none yet (`qtmesh lod --algo meshopt` available) |
| Validation | `qtmesh validate <glb>`; turntable renders in `assets/exported/<Name>/<Name>_turntable.png` |
| License | generated assets: project MIT; motion clips: see `THIRD_PARTY_LICENSES.md` |

Regenerate a turntable: `qtmesh turntable assets/exported/<Name>/<Name>.glb -o <Name>_turntable.png --frames 8 --size 512x512`.
