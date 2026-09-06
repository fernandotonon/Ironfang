# Localization

Languages: **English** (`en`, source) and **Brazilian Portuguese** (`pt_BR`).

## How it works

* Tables: `app/i18n/en.js`, `app/i18n/pt_BR.js` — plain `var strings = { "key": "text" }`
  modules. One complete sentence per key; placeholders `{name}`; no sentence assembly from
  fragments.
* Access: the `Loc` QML singleton (`app/Loc.qml`): `Loc.tr("menu.campaign")`,
  `Loc.tr("hud.iron", { n: 150 })`. Bindings re-evaluate when `Loc.language` changes, so
  switching the language in Settings updates every screen live.
* Mission texts (objectives, messages, dialogue, outcome, briefing) are keys as well;
  `Loc.trOr(keyOrText)` resolves a key and passes a literal through, so older or test
  definitions with literal text still work.
* Unit/building names: `unit.<typeId>`, `building.<typeId>` (the `name` fields in
  `balance.js` are the untranslated fallback).
* Language selection: Settings → Language, persisted in the `settings` document. With no saved
  choice the system locale decides (`pt*` → `pt_BR`).

## Key naming

`<area>.<item>[.<detail>]`: `menu.*`, `campaign.*`, `briefing.*`, `results.*`, `settings.*`,
`pause.*`, `hud.*`, `difficulty.*`, `medal.*`, `unit.*`, `building.*`, `mission.m<N>.*`,
`scenario.<id>.*`, `<missionId>.*` for mission content, `achievement.*` (M6), `codex.*` (M6),
`tutorial.*` (M3), `dialogue.*` (M5).

## Completeness check

`scripts/check-i18n.py` (also the `IronfangLocalization` ctest) fails when:

* a key used as `tr("...")` in `app/**/*.qml|js`, or as a mission text key, is missing from `en`;
* `en` and another language have different key sets (missing or stray keys);
* a translation is empty or its `{placeholders}` differ from the English ones;
* the enumerated dynamic keys (`difficulty.<name>`, `medal.<name>`, `unit.<type>`,
  `building.<type>`, campaign `titleKey`/`taglineKey`) are missing.

Run it by hand: `python3 scripts/check-i18n.py`.

## Not yet localized (tracked for M7)

Flash messages built inside `IronfangGame.qml` (order feedback such as "destination
unreachable", production refusals from `Production.js`), the asset showcase, and the web loading
shell (`web/index.template.html`). They are English literals today and will move to keys in the
commercial polish milestone.
