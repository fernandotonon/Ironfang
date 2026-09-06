# Balancing

All numbers live in `app/config/balance.js`. This page explains the intent behind them and how
to tune. Target: a readable **10–15 minute** match on Normal.

## Units

| Unit | Cost | Build | HP | Damage | Range | Cooldown | Speed | Notes |
|---|---:|---:|---:|---:|---|---:|---:|---|
| Goblin Worker | 50 | 7 s | 45 | 3 | melee | 1.2 s | 3.4 | carries 10 iron, 2.6 s per load |
| Orc Warrior | 80 | 9 s | 110 | 14 | melee | 1.1 s | 3.2 | frontline (~12.7 dps) |
| Orc Archer | 110 | 11 s | 65 | 10 | 7 m | 1.5 s | 3.0 | arrow projectile, keeps ~5.5 m |
| Ironhide Ogre | 280 | 20 s | 400 | 40 | melee | 2.0 s | 2.3 | ×2.5 vs buildings (50 dps siege) |

Buildings: Clan Fortress 2500 HP, War Foundry 1400 HP, Enemy Fortress 2500 HP. Iron deposits
hold 600 iron each (three near the player: 1800 total).

## Economy

A worker round trip at the nearest deposit is ~12 s (walk + 2.6 s gather) for 10 iron, so
three workers yield **~150 iron/min**. Start: 150 iron, 3 workers, 1 warrior.
Expected: 2 warriors/min from the foundry once the economy runs; the first ogre around
minute 5–6 if saved for.

## Enemy

The enemy has no workers. It receives **passive income** (`enemy.passiveIncomePerSecond`,
2.4/s ≈ 145/min on Normal, scaled by difficulty) and buys warriors, warriors, archer in
rotation, plus an ogre every third wave when affordable. Waves: first after 110 s, then every
85 s, size 3 growing by 1 per wave (max 12); a garrison of 2 always stays home.
This is a deliberate simplification: the only "hidden" resource injection is that one line.

## Match shape (Normal)

1. 0–2 min: gather, first 2–3 warriors.
2. ~2 min: wave 1 (3 units) hits the base; the starting warrior + new recruits hold.
3. 2–6 min: waves of 4–6 every 85 s; the player alternates warriors/archers, saves for an ogre.
4. 6–10 min: with ~8 units and an ogre the player marches; the enemy garrison + a wave in
   the making defend. The fortress (2500 HP) falls in ~40 s under an ogre and four warriors.
5. Defeat happens when waves are ignored: 4 warriors kill the Clan Fortress in ~50 s.

## Tuning knobs

* Too easy → raise `enemy.passiveIncomePerSecond` or `waveGrowth`, lower `waveInterval`.
* Too hard early → raise `firstWaveDelay`, lower `waveBaseSize`.
* Matches too long → lower building HP or raise `ironhide_ogre.buildingDamageMultiplier`.
* Use the sim-speed keys (`]` up to 8×) and `--autotest` to watch a match shape quickly;
  `AUTOTEST` log lines report iron, unit counts and the AI state.

## Difficulty presets (`Balance.difficulty`)

| | enemy income × | wave growth | wave interval | first wave × | start iron × | enemy hp × | enemy damage × | timer targets × |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Story | 0.7 | 0 | 110 s | 1.4 | 1.6 | 0.8 | 0.75 | 1.5 |
| Warrior | 1.0 | 1 | 85 s | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 |
| Warchief | 1.35 | 2 | 70 s | 0.8 | 0.7 | 1.1 | 1.15 | 0.85 |

Missions may override any enemy wave value per difficulty (`difficulty.<name>` block in the
definition); Missions 2 and 3 do (first wave delay, wave size caps, ogre cadence).

## Campaign missions (first pass, before external playtesting)

| Mission | Map | Player start | Enemy | Primary chain | Optional | Gold time |
|---|---|---|---|---|---|---|
| 1 Embers of Ironfang | 48 m | 20 iron, 3 workers, Rukhar; fortress 60 %, foundry 50 % and disabled; 2 deposits × 400 | none; 2 scripted warriors after the 2nd produced warrior | locate outpost → 100 iron → 2 warriors → kill scouts; protect workers | lose no workers | 10:00 |
| 2 The Stolen Mine | 64 m (First Siege terrain) | 200 iron, 3 workers, Rukhar + warrior + archer, home deposit 350 | outpost (900 HP, produces warrior/archer, income 1.2/s, raids from 4:00 every 2:00, 2→6 units), 12 garrison units on 3 mines | clear 3 mines → hold 2:00 → destroy outpost | finish in 15:00; keep 2 of 3 original workers | 15:00 |
| 3 Hold the Foundry | 64 m | 300 iron, 4 workers, Rukhar + 2 warriors + 2 archers; 3 deposits (700/700/500) | fortress (income 3.0/s, waves from 2:30 every 1:30, 3 + 2n up to 12, ogre every 4th), west flank 20 s after wave 1, east flank 200 s later, ogre leader + escort after wave 5 | prepare 2:30 → survive 5 waves → kill the leader; protect the Foundry | Foundry ≥ 50 %; ≤ 5 units lost | 18:00 |

Story: ×1.6 iron, later and smaller waves (M2 first raid 5:20, cap 4; M3 first wave 3:30, growth 1,
cap 8). Warchief: ×0.7 iron, earlier and bigger waves (M2 3:20, 3→8; M3 2:00, 4 + 2n, ogre every 3rd).

Measured with `--autotest-m1` (8×, Warrior): Mission 1 chain completes in ~76 match seconds of
scripted play with the scouts arriving ~35 s after the Foundry is relit. Missions 2 and 3 have
only been smoke-loaded (`--smoke`) and need human play for pacing.
