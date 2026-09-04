# Manual test checklist

Tick every item on desktop **and** in the browser build served over HTTP before a milestone
is called done. Items marked *(M1+)* are not exercised by the Milestone 0 spike yet.

## Startup
- [ ] Desktop: `build-desktop/bin/ironfang.app` opens a 1280×800 window, ground + obstacles visible, one Orc standing at the centre, HUD top-left, no QML warnings in the terminal.
- [ ] Browser: `python3 scripts/serve.py deploy/multithread` → http://localhost:8080/ shows the Qt loading screen, then the same scene. Console has the boot banner and no red errors.
- [ ] Browser: `window.crossOriginIsolated` is `true` in the console (threads available).
- [ ] Browser refresh: reload → scene comes back, state reset, no stale-cache errors.
- [ ] Browser focus loss: switch tab for 30 s, come back → units still where they were / arrive normally, FPS recovers, no runaway catch-up.

## Camera
- [ ] W/A/S/D and arrow keys pan; speed feels constant when zoomed in vs out.
- [ ] Mouse wheel zooms toward the cursor; cannot pass through the ground; zoom-out stops at the map scale.
- [ ] Right-drag orbits; pitch clamps (cannot go below ~28° or over the top).
- [ ] Pan leash: panning far off the map springs back softly.

## Selection
- [ ] Left-click on an Orc selects it (gold frame on the ground, health bar appears).
- [ ] Left-click on empty ground clears the selection.
- [ ] Hover shows the thin hover frame; it disappears when the cursor leaves.
- [ ] Shift-click adds / removes a unit from the selection.
- [ ] Drag a rectangle: every unit whose body centre is inside gets selected; a tiny drag counts as a click.
- [ ] Esc clears the selection.

## Movement & navigation
- [ ] Right-click on ground with units selected: gold ring flashes, units walk (Walk clip), stop (Idle) at distinct nearby spots.
- [ ] Right-click with nothing selected: "nothing selected" message, no ring.
- [ ] Order a unit to the far side of the building at (30,22): it walks around it, never through it.
- [ ] Order a unit *onto* the building: it stops at the nearest reachable edge.
- [ ] Two groups crossing paths separate rather than overlap.
- [ ] Units cannot be pushed into the obstacle footprint.

## Animation
- [ ] Keys 1/2/3 (or HUD buttons) switch selected units to Idle / Walk / Attack immediately.
- [ ] 4 (Hit) and 5 (Death) play once; Hit returns to Idle, Death holds the last frame.
- [ ] Toggle "models" (M): placeholders and Orc models swap; selection/orders still work on boxes.

## Performance
- [ ] "to 40" button: 40 Orcs animate; FPS in HUD stays ≥ 30 on desktop and in the browser (record the numbers in `docs/feasibility-report.md`).
- [ ] "+20" to 60 units: still usable (report FPS).
- [ ] `F` toggles Clayground's PerfHud (render stats).

## Gathering & economy
- [ ] Select workers, right-click an iron deposit: they walk there, play Gather, carry a cube of iron back to the Clan Fortress, iron counter rises by 10 per trip, deposit's "Iron left" decreases.
- [ ] Deposit depletes: it fades, workers move to the next deposit or go idle when none is left.
- [ ] "Return iron" with a carrying worker sends it home; empty-handed workers ignore it.
- [ ] Right-click the fortress with carrying workers → they return.

## Production
- [ ] Select the Clan Fortress: a Goblin Worker button (50 iron) appears; select the War Foundry: Warrior 80 / Archer 110 / Ogre 280.
- [ ] Buttons disable when iron is short; clicking one deducts iron, the progress bar fills, "X ready" appears and the unit spawns at the rally point.
- [ ] Queue up to 5; Cancel refunds the last item.

## Combat
- [ ] Right-click an enemy: units walk there and attack (Attack clip, red hit flash, enemy health bar).
- [ ] Archers fire visible arrows and keep distance; arrows to a dead target land harmlessly.
- [ ] Idle warriors auto-engage enemies within ~9 m and return after a leash of 16 m.
- [ ] Ogre deals ×2.5 to buildings.
- [ ] Killed units play Death, fade, and are removed; a dead target is dropped by attackers.
- [ ] Destroying the Enemy Fortress → Victory overlay with stats; losing the Clan Fortress → Defeat.

## Enemy & match flow
- [ ] First wave marches about 2 minutes in (message shown); later waves grow.
- [ ] P / Esc pause; Resume continues without a time jump.
- [ ] Play Again / Restart resets iron, units, buildings and camera without reloading the page.
- [ ] Easy / Normal / Hard change wave pressure.

## Static deployment
- [ ] `deploy/multithread/` copied to a plain static host (GitHub Pages) loads with `coi-serviceworker.js` (one automatic reload on first visit), and assets (`.mesh`, `.png`, `.qad`) all load (no 404s in the network tab).
- [ ] Optional: the same QML + `assets/` next to the Clayground Web Runtime starter (`clayground-starter.zip`) — expected to fail on skeletal animation until the runtime links `QtQuick.Timeline` / `QtQuick3D.AssetUtils` (see feasibility report).
