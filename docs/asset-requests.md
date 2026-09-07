# Asset requests — The Broken Crown

Everything the expansion needs that does not exist yet. Until an asset arrives the game shows a
**documented placeholder** (a labelled dummy panel in the UI, a `Box3D` with a tinted colour in
the world through `config/assets.js`). Source images are produced by the project owner; models
are then generated with QtMeshEditor (`scripts/generate-models.sh`), rigged/imported with
`scripts/refresh-runtime.sh`.

Status: ☐ requested · ◐ source image available · ● generated and in game (2026-09-07: the eight Bloodmaw-set models were generated with QtMeshEditor 3.37.7 / TRELLIS.2 from the new concept images)

## 2D — illustrations and portraits

| Asset | Used by | Placeholder today | Status |
|---|---|---|---|
| Mission illustrations ×7 (`m1`…`m7`, 16:9, ≥ 1280 px) | briefing screen, loading narration | dark panel with the mission number (`Frontend.qml`, briefing) | m1 ● (`assets/runtime/illustrations/m1_embers.jpg`), m4 ◐ (`m4_ashlands.jpg`, mission not authored yet), m2 m3 m5 m6 m7 ☐ |
| Epilogue illustration (Rukhar restoring the fractured crown) | campaign end | — (M5) | ☐ |
| Campaign map background (Karag Vorn / Ashlands region) | campaign map screen | vertical mission list | ☐ |
| Portraits: Rukhar, Gorvak, Bloodmaw commander, goblin foreman, ogre matriarch (square, ≥ 512 px) | dialogue (M5), codex | speaker name prefix in the HUD flash | ☐ |
| Main-menu key art (optional) | main menu background | radial gradient | ☐ |
| Medal icons iron / steel / gold (optional) | results, campaign map | coloured dots | ☐ |

## 3D — new models (concept image → QtMeshEditor)

| Asset | Type id (planned) | Missions | Placeholder | Status |
|---|---|---|---|---|
| Bloodmaw Outpost (small hostile structure, ~6×6 m) | `enemy_outpost` | 2, 6 | — | ● |
| Watchtower (tall, ~3×3 m) | `watchtower` | 5, 6, 7 | — | ● |
| Wooden/iron gate segment (destructible, ~8×2 m) | `gate` | 5, 6, 7 | — | ● (gameplay: M4) |
| Prisoner cage (rescue objective, ~3×3 m) | `prisoner_cage` | 4, 5 | — | ● (gameplay: M4) |
| Steam vent (hazard, ~4×4 m) | `steam_vent` | 4 | — | ● (hazard logic: M4) |
| Ruined outpost / broken foundry (Mission 1 start) | `ruined_foundry` | 1 | — | ● (`war_foundry` swaps to it while `productionEnabled` is false) |
| Bloodmaw Fortress (distinct from the Clan Fortress) | `enemy_fortress` | 2–7 | — | ● |
| Iron Crown prop (epilogue / codex) | `iron_crown` | epilogue | — | ● (showcase; epilogue scene: M5) |

Existing and in game (●): Goblin Worker, Orc Warrior, Orc Archer, Ironhide Ogre, Clan Fortress,
War Foundry, Iron Deposit, Rocks (large/small), Dead Ironwood, Broken Cart, Arrow, weapons and
props from the First Siege set.

## Audio

Synthesized cues exist for the MVP set (`scripts/gen-audio.py`). Still needed (M7): main-menu
theme, campaign-map ambience, unit voice responses (select/move/attack, 2–3 variations each),
ability activations, Ground Smash, objective update, achievement unlock, repair loop. If real
recordings are preferred over synthesis, they must be original, CC0 or explicitly compatible,
with the source recorded in `THIRD_PARTY_LICENSES.md`.

## How a placeholder is replaced

1. Drop the source image in `assets/source-images/<Name>.png`.
2. `scripts/generate-models.sh "<Name>"` → `assets/exported/<Name>/`.
3. Add the type to `scripts/refresh-runtime.sh` (static or rig) and run it.
4. Point `config/assets.js` at `assets/runtime/<folder>/<Type>.qml`; delete the placeholder note
   here and in the mission that used it.
