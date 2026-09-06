# Story and campaign — Ironfang: The Broken Crown

## Premise

For generations the Ironfang Clan protected the volcanic frontier of **Karag Vorn**. Its power
came from the iron veins beneath its stronghold and from the **Iron Crown**, an ancestral symbol
that united the frontier clans.

During a gathering of the clans, the rival **Bloodmaw Clan** betrayed Warchief **Gorvak**.
Bloodmaw forces shattered the Iron Crown, occupied the Ironfang mines and scattered the survivors
across the **Ashlands**.

The player commands **Rukhar**, captain of the surviving Ironfang warband. Beginning with a
ruined outpost and a few Goblin Workers, Rukhar must recover the mines, rescue the scattered
clan, rebuild its army and defeat the Bloodmaw leader responsible for the betrayal.

At the end Rukhar restores the Iron Crown but deliberately preserves its fracture.

> Let the clans remember what division costs.

## Delivery

Illustrated mission introductions (static art + text), short loading-screen narration, dialogue
portraits, in-game objective conversations, short victory/defeat text, a final illustrated
epilogue. No pre-rendered or fully animated cinematics.

Characters (portraits): Rukhar (player captain), Gorvak (fallen Warchief, remembered), Bloodmaw
commander (antagonist; named in Mission 5), a goblin foreman (tutorial voice), an ogre matriarch
(Mission 5 rescue).

## Missions

| # | Title | Purpose | Primary objectives | Optional | New concepts | Unlocks |
|---|---|---|---|---|---|---|
| 1 | Embers of Ironfang | contextual tutorial | locate outpost → gather iron to reactivate the Foundry → produce 2 warriors → defeat Bloodmaw scouts → protect the workers | lose no workers | camera, selection, movement, gathering, deposit, production, combat | Mission 2, achievement `the_clan_survives` |
| 2 | The Stolen Mine | resource control, small assaults | capture 3 occupied deposits → control the mining region → destroy the enemy outpost | target time; ≥ 2 original workers alive | multiple deposits, enemy defensive groups, archers, prioritisation | Mission 3, `reclaimed` |
| 3 | Hold the Foundry | defence (existing wave system) | prepare before wave 1 → protect the War Foundry → survive all waves → defeat the assault leader | foundry ≥ 50 % HP; lose ≤ 5 units | wave countdown, attack directions, positioning, repair, medals | Mission 4, **Survival mode** |
| 4 | Through the Ashlands | escort and rescue | escort workers → rescue prisoners → reach the abandoned fortress | rescue all; lose no escort worker | patrols, ambushes, hazards (steam vents, rockfalls, blocked routes), moving objectives, exploration | Mission 5, `no_orc_left_behind` |
| 5 | Hammerfall | ogre centrepiece | rescue the captured ogre → destroy the Bloodmaw gates → eliminate the fortified position | destroy every watchtower; ogre ≥ 50 % HP | ogre siege damage, Ground Smash, destructible gates, fortifications | Mission 6 |
| 6 | The Traitor's Gate | multi-stage assault | secure forward deposits → survive the counterattack → destroy the outer gate → establish a reinforcement point → break the inner defences | lose no ogres; capture both deposits | checkpoints between phases | Mission 7 |
| 7 | The Broken Crown | finale | defeat outer defenders → disable reinforcement structures → break the final gate → defeat the commander → destroy or capture the Bloodmaw fortress | all secondary objectives; strike force alive; Gold time | reuse of ordinary systems; no separate boss framework | epilogue, `warchief` |

Hazards must be telegraphed and deterministic. The finale reuses ordinary units, buildings,
gates and waves.

## Where the MVP level goes

The current *First Siege* map (64 × 64 m, player base south-west with Fortress + Foundry + 3
deposits, enemy fortress north-east with 2 deposits, wave AI, "destroy the Enemy Fortress") is
kept verbatim as the **Classic Siege** scenario (the first skirmish scenario and the regression
baseline). Mission 2 reuses the same terrain layout with different entity placement (enemy groups
on the deposits, an outpost instead of a fortress, no or delayed waves); Mission 3 reuses the wave
system on a map where the Foundry is exposed. Mission 1 needs a smaller, more linear map with a
ruined outpost and is authored fresh. Rationale in `docs/broken-crown-plan.md`.

## Difficulty flavour

* **Story** — more starting iron, longer wave gaps, weaker enemies, forgiving timers.
* **Warrior** — intended balance (today's *normal*).
* **Warchief** — less iron, stronger/more frequent waves, aggressive composition, stricter medals.

Values live in `app/config/balance.js` (`difficulty`) and per-mission overrides; mission logic is
never forked by difficulty unless a mission needs different placement or wave composition.

## Medals

* **Iron** — complete the mission.
* **Steel** — the published optional/efficiency targets of the mission.
* **Gold** — the published Gold requirements (usually time + all optional objectives).

Criteria are printed in the briefing and the results screen. Nothing is hidden.
