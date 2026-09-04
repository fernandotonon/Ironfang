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

## Gameplay *(M1+)*
- [ ] Gathering, production, combat, enemy waves, victory, defeat, restart, asset showcase.

## Static deployment
- [ ] `deploy/multithread/` copied to a plain static host (GitHub Pages) loads with `coi-serviceworker.js` (one automatic reload on first visit), and assets (`.mesh`, `.png`, `.qad`) all load (no 404s in the network tab).
- [ ] Optional: the same QML + `assets/` next to the Clayground Web Runtime starter (`clayground-starter.zip`) — expected to fail on skeletal animation until the runtime links `QtQuick.Timeline` / `QtQuick3D.AssetUtils` (see feasibility report).
