# Save format

Two independent JSON documents, each a single string under a key of the storage abstraction
(`app/Storage.qml`): **`progress`** (campaign, records, achievements, statistics) and
**`settings`** (user preferences). Shapes, defaults, parsing and migrations live in
`app/scripts/Save.js`; progression rules in `app/scripts/Campaign.js`.

## Storage

| Platform | Backend | Location |
|---|---|---|
| Desktop | `QtCore.Settings` (QSettings, `category: ironfang`) | platform-native: macOS `~/Library/Preferences/com.qtmesh-games.Ironfang.plist`, Linux `~/.config/QtMesh Games/Ironfang.conf`, Windows registry `HKCU\Software\QtMesh Games\Ironfang`. QSettings writes atomically (temp file + rename). |
| WebAssembly | `QtCore.Settings` → Qt's `WebLocalStorageFormat` | `window.localStorage` of the game's origin, synchronous. Cleared with site data; private windows do not persist. |
| QtMesh Games shell | `Storage.adapter = { read(key), write(key, text), remove(key) }` | the shell decides (cloud sync, Steam Cloud, per-profile folders). The game never sees the difference. |

Reads never throw: unreadable storage yields `null`, which `Save.parse` turns into a fresh
default document (logged as a warning). Writes report failure through `Storage.lastError`.

## `progress` (schema 1)

```json
{
  "version": 1,
  "savedAt": "2026-09-06T12:00:00.000Z",
  "campaign": {
    "completed": { "m1_embers": true },
    "best": { "m1_embers": { "warrior": { "medal": "gold", "time": 612.4, "optional": 1 } } },
    "lastMission": "m2_stolen_mine",
    "lastDifficulty": "warrior",
    "started": true
  },
  "tutorial": { "completed": false, "skipped": false },
  "survival": { "bestWave": 0, "bestScore": 0 },
  "achievements": { "unlocked": { "the_clan_survives": "2026-09-06T12:00:00Z" }, "progress": { "hammer_time": 3 } },
  "stats": { "units_produced": 41 },
  "seenNarrative": [ "m1.intro" ]
}
```

* `campaign.completed` — mission ids finished at least once (any difficulty). Unlocks derive from
  it (`Campaign.isUnlocked`: the first mission is open, each next one opens when its predecessor
  is complete). Scenarios (`classic_siege`) never appear here.
* `campaign.best[mission][difficulty]` — best medal, then best time at that medal; optional
  objectives completed in that run. Skirmish scenarios record bests too.
* `tutorial`, `survival`, `achievements`, `stats`, `seenNarrative` — written by later milestones;
  the shapes are reserved now so no migration is needed for them.

Written automatically after every finished mission (`IronfangGame.endMatch`) and after
Reset Progress. Checkpoint saves (M5) will add a `checkpoint` section.

## `settings` (schema 1)

```json
{
  "version": 1, "savedAt": "...",
  "language": "pt_BR",
  "audio": { "master": 1.0, "music": 0.35, "effects": 0.8, "voice": 1.0, "muteUnfocused": true },
  "controls": { "cameraSpeed": 1.0, "zoomSensitivity": 1.0, "edgeScroll": true, "cameraShake": true },
  "accessibility": { "subtitles": true, "textSpeed": 1.0, "uiScale": 1.0, "reducedShake": false, "highContrastSelection": false, "colorBlindIndicators": false },
  "display": { "mode": "windowed", "preset": "high" }
}
```

`language: ""` means follow the system locale (Portuguese → `pt_BR`, otherwise `en`). Written
whenever a setting changes in the Settings screen. Reset Progress does not touch settings.

## Parsing rules (`Save.parse(text, kind)`)

| Input | Result |
|---|---|
| `null` / empty | fresh defaults, `ok: true`, `empty: true` |
| invalid JSON, non-object | fresh defaults, `ok: false`, `error` set, warning logged; the bad document is overwritten on the next save |
| `version` newer than the game | fresh defaults in memory, `ok: false`; the on-disk document is **not** overwritten until the player finishes a mission (documented limitation; M7 adds a backup copy) |
| older `version` | migrated step by step through `Save.MIGRATIONS[kind][version]`, then saved back |
| missing fields | filled from the defaults (deep); wrong-typed sections replaced |

## Adding a migration

1. Bump `Save.SCHEMA`.
2. Add `MIGRATIONS.progress[old]` / `MIGRATIONS.settings[old]` functions that transform the
   document to `old + 1` and set `version`.
3. Add a test in `tests/tst_save.qml` that feeds an old document and checks the result.
