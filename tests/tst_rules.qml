// Gameplay rules: economy, production queues, combat maths, worker loop, enemy wave AI.
import QtQuick
import QtTest
import "../app/scripts/Economy.js" as Economy
import "../app/scripts/Production.js" as Production
import "../app/scripts/Combat.js" as Combat
import "../app/scripts/Gather.js" as Gather
import "../app/scripts/EnemyAI.js" as EnemyAI
import "../app/scripts/Touch.js" as Touch
import "../app/config/balance.js" as Balance

TestCase {
    name: "Rules"

    // ---- economy ----------------------------------------------------------------------------
    function test_economy_deposit_spend_refund() {
        const e = Economy.create(100)
        verify(Economy.canAfford(e, 100)); verify(!Economy.canAfford(e, 101))
        verify(Economy.spend(e, 80)); compare(e.iron, 20); compare(e.spent, 80)
        verify(!Economy.spend(e, 50), "insufficient iron is refused"); compare(e.iron, 20)
        Economy.deposit(e, 10); compare(e.iron, 30); compare(e.gathered, 10)
        Economy.refund(e, 80); compare(e.iron, 110); compare(e.spent, 0)
        const node = { iron: 15 }
        compare(Economy.takeFromNode(node, 10), 10); compare(node.iron, 5)
        compare(Economy.takeFromNode(node, 10), 5); compare(node.iron, 0)
        compare(Economy.takeFromNode(node, 10), 0, "depleted node yields nothing")
    }

    // ---- production ----------------------------------------------------------------------------
    function test_production_costs_and_queue() {
        const e = Economy.create(200)
        const q = Production.createQueue(2)
        let r = Production.enqueue(q, "war_foundry", "orc_warrior", e)
        verify(r.ok); compare(e.iron, 120); compare(q.items.length, 1)
        r = Production.enqueue(q, "war_foundry", "goblin_worker", e)
        verify(!r.ok, "foundry cannot make workers"); compare(e.iron, 120)
        r = Production.enqueue(q, "war_foundry", "ironhide_ogre", e)
        verify(!r.ok, "not enough iron for an ogre"); compare(e.iron, 120)
        r = Production.enqueue(q, "war_foundry", "orc_archer", e)
        verify(r.ok); compare(e.iron, 10); compare(q.items.length, 2)
        r = Production.enqueue(q, "war_foundry", "orc_warrior", e)
        verify(!r.ok, "queue full")
        // progress: warrior takes buildTime seconds
        const bt = Balance.units.orc_warrior.buildTime
        compare(Production.step(q, bt - 0.5), null)
        fuzzyCompare(Production.headProgress(q), (bt - 0.5) / bt, 1e-9)
        compare(Production.step(q, 0.6), "orc_warrior")
        compare(q.items.length, 1); compare(q.progress, 0)
        compare(Production.cancelLast(q, e), "orc_archer"); compare(e.iron, 120); compare(q.items.length, 0)
        compare(Production.step(q, 5), null)
    }

    // ---- combat --------------------------------------------------------------------------------
    function test_damage_death_and_ogre_bonus() {
        const warrior = Balance.units.orc_warrior, ogre = Balance.units.ironhide_ogre
        const enemy = { alive: true, hp: 28, maxHp: 110, team: "enemy", isBuilding: false }
        compare(Combat.damageFor(warrior, enemy), 14)
        verify(!Combat.applyDamage(enemy, 14)); compare(enemy.hp, 14)
        verify(Combat.applyDamage(enemy, 14), "second hit kills"); compare(enemy.hp, 0); verify(!enemy.alive)
        verify(!Combat.applyDamage(enemy, 14), "dead targets take no more damage")
        const fort = { alive: true, hp: 1500, maxHp: 1500, team: "enemy", isBuilding: true }
        compare(Combat.damageFor(ogre, fort), 100, "ogre x2.5 against buildings")
        compare(Combat.damageFor(ogre, enemy), 40, "no bonus against units")
        compare(Combat.damageFor(warrior, fort), 14)
    }

    function test_target_validity_and_acquisition() {
        const me = { x: 0, z: 0, radius: 0.5, team: "player", alive: true }
        const far = { x: 30, z: 0, radius: 0.5, team: "enemy", alive: true }
        const near = { x: 4, z: 0, radius: 0.5, team: "enemy", alive: true }
        const dead = { x: 1, z: 0, radius: 0.5, team: "enemy", alive: false }
        const friend = { x: 1, z: 1, radius: 0.5, team: "player", alive: true }
        const rock = { x: 1, z: -1, radius: 1, team: "neutral", alive: true, untargetable: true, isBuilding: true, footW: 2, footD: 2 }
        compare(Combat.acquireTarget(me, [far, near, dead, friend, rock], 9), near)
        compare(Combat.acquireTarget(me, [far], 9), null)
        verify(!Combat.isValidTarget(dead)); verify(!Combat.isValidTarget(rock)); verify(Combat.isValidTarget(near))
        // a unit about as close as a building is preferred over the building
        const bld = { x: 3, z: 0, radius: 2, team: "enemy", alive: true, isBuilding: true, footW: 4, footD: 4 }
        const nearUnit = { x: 2.2, z: 0, radius: 0.5, team: "enemy", alive: true }
        compare(Combat.acquireTarget(me, [bld, nearUnit], 9), nearUnit)
        compare(Combat.acquireTarget(me, [bld, near], 9), bld, "a much farther unit does not win")
    }

    function test_rectangle_gap_and_approach() {
        const b = { x: 10, z: 10, isBuilding: true, footW: 10, footD: 6, radius: 3 }
        const u = { x: 10, z: 20, radius: 0.5 }
        fuzzyCompare(Combat.gap(u, b), 20 - 13 - 0.5, 1e-9)          // south edge at z=13
        const corner = { x: 18, z: 16, radius: 0.5 }
        fuzzyCompare(Combat.gap(corner, b), Math.sqrt(9 + 9) - 0.5, 1e-9)
        const p = Combat.approachPoint(u, b, 0.5)
        fuzzyCompare(p.x, 10, 1e-9); fuzzyCompare(p.z, 14, 1e-9)       // 0.5 radius + 0.5 standoff outside the edge
        verify(!Combat.inRange(u, Balance.units.orc_warrior, b))
        verify(Combat.inRange({ x: 10, z: 13.9, radius: 0.5 }, Balance.units.orc_warrior, b))
        verify(Combat.inRange({ x: 10, z: 19.5, radius: 0.5 }, Balance.units.orc_archer, b), "archer range 7")
    }

    // ---- gathering -----------------------------------------------------------------------------
    function makeWorker(x, z) {
        return { x: x, z: z, radius: 0.45, alive: true, carried: 0, gatherState: "idle", gatherNode: null,
                 gatherTimer: 0, gatherArrived: false, path: [], clips: [],
                 moveTo: function(p) { this.path = [p]; this.lastMove = p },
                 play: function(c) { this.clips.push(c) }, lookAt: function() {} }
    }
    function test_gather_loop_deposits_iron() {
        const stats = Balance.units.goblin_worker
        const node = { x: 20, z: 0, iron: 25, isBuilding: true, footW: 4, footD: 4, radius: 2 }
        const home = { x: 0, z: 0, isBuilding: true, footW: 10, footD: 10, radius: 5 }
        const econ = Economy.create(0)
        const w = makeWorker(8, 0)
        const ctx = { stats: stats, gap: Combat.gap, approach: (a, b) => Combat.approachPoint(a, b, 0.25),
                      findDropOff: () => home, findDeposit: () => node.iron > 0 ? node : null,
                      deposit: (wk, amount) => Economy.deposit(econ, amount) }
        Gather.start(w, node)
        compare(w.gatherState, "toDeposit")
        Gather.step(w, 0.1, ctx)
        verify(w.lastMove !== undefined, "worker walks to the node")
        // teleport next to the node and finish the walk
        w.x = node.x - 2 - 0.45 - 0.2; w.path = []
        Gather.step(w, 0.1, ctx)
        compare(w.gatherState, "gathering"); compare(w.clips[w.clips.length - 1], "Gather")
        Gather.step(w, stats.gatherTime + 0.01, ctx)
        compare(w.carried, stats.carry); compare(node.iron, 15); compare(w.gatherState, "toDropOff")
        Gather.step(w, 0.1, ctx)                     // walks home
        w.x = home.x + 5 + 0.45 + 0.5; w.path = []
        Gather.step(w, 0.1, ctx)
        compare(econ.iron, stats.carry); compare(w.carried, 0); compare(w.gatherState, "toDeposit")
        // deplete the node: last trip carries the remainder, then the worker goes idle at home
        node.iron = 4
        w.x = node.x - 2 - 0.45 - 0.2; w.path = []
        Gather.step(w, 0.1, ctx); Gather.step(w, stats.gatherTime + 0.01, ctx)
        compare(w.carried, 4); compare(node.iron, 0); compare(w.gatherState, "toDropOff")
        w.x = home.x + 5 + 0.9; w.path = []
        Gather.step(w, 0.1, ctx)
        compare(econ.iron, stats.carry + 4)
        compare(w.gatherState, "idle", "no deposits left -> idle")
        verify(!Gather.isActive(w))
    }

    function test_return_home_only_when_carrying() {
        const w = makeWorker(0, 0)
        verify(!Gather.returnHome(w))
        w.carried = 5
        verify(Gather.returnHome(w)); compare(w.gatherState, "toDropOff")
    }

    // ---- enemy AI -----------------------------------------------------------------------------
    function test_enemy_ai_produces_and_launches_waves() {
        const cfg = Balance.enemy
        const ai = EnemyAI.create(cfg, "normal")
        const produced = [], waves = []
        let time = 0, idle = [], queueBusy = false
        const world = {
            get time() { return time }, get enemyUnits() { return idle },
            playerFortress: { alive: true },
            canProduce: () => !queueBusy,
            produce: (t) => { produced.push(t); idle.push({ type: t }) },
            launchWave: (list, target) => { waves.push(list.length); idle = idle.slice(list.length) }
        }
        compare(ai.state, "building")
        // 30 simulated seconds: income accrues, a first unit gets bought
        for (let i = 0; i < 300; ++i) { time += 0.1; EnemyAI.step(ai, 0.1, cfg, world) }
        verify(produced.length >= 1, "produced something in 30 s: " + produced.join(","))
        verify(ai.economy.iron < cfg.startIron + 30 * ai.incomePerSecond, "iron was spent")
        compare(waves.length, 0, "no wave before firstWaveDelay")
        // run to the first wave
        for (let i = 0; i < 1200 && waves.length === 0; ++i) { time += 0.1; EnemyAI.step(ai, 0.1, cfg, world) }
        compare(waves.length, 1); compare(ai.wavesLaunched, 1); compare(ai.state, "attacking")
        verify(waves[0] >= 1 && waves[0] <= cfg.waveBaseSize)
        verify(ai.nextWaveAt > time, "next wave scheduled in the future")
        // second wave is at least as large
        for (let i = 0; i < 2000 && waves.length < 2; ++i) { time += 0.1; EnemyAI.step(ai, 0.1, cfg, world) }
        compare(waves.length, 2)
        verify(waves[1] >= waves[0])
    }

    function test_enemy_ai_difficulty_scaling() {
        const easy = EnemyAI.create(Balance.enemy, "easy"), hard = EnemyAI.create(Balance.enemy, "hard")
        verify(easy.incomePerSecond < hard.incomePerSecond)
        verify(easy.waveInterval > hard.waveInterval)
    }

    // ---- touch smart tap --------------------------------------------------------------------------
    function test_smart_tap_decisions() {
        const myUnit = { isUnit: true, team: "player", alive: true }
        const myOther = { isUnit: true, team: "player", alive: true }
        const fortress = { isBuilding: true, team: "player", alive: true, stats: { dropOff: true }, queue: {} }
        const foundry = { isBuilding: true, team: "player", alive: true, stats: {}, queue: {} }
        const enemy = { isUnit: true, team: "enemy", alive: true }
        const deposit = { isBuilding: true, team: "neutral", alive: true, stats: { resource: true } }
        const none = { units: 0, producer: null, soleUnit: null }
        const one = { units: 1, producer: null, soleUnit: myUnit }
        const many = { units: 3, producer: null, soleUnit: null }
        const prod = { units: 0, producer: foundry, soleUnit: null }
        // nothing selected: own things select, everything else is a no-op (never an accidental clear)
        compare(Touch.decide(myUnit, none, true).action, "select")
        compare(Touch.decide(null, none, true).action, "none")
        compare(Touch.decide(enemy, none, true).action, "none")
        compare(Touch.decide(deposit, none, true).action, "none")
        // units selected: targets are orders, own units switch selection, same unit deselects
        compare(Touch.decide(null, many, true).action, "order")
        compare(Touch.decide(enemy, many, true).action, "order")
        compare(Touch.decide(deposit, many, true).action, "order")
        compare(Touch.decide(fortress, many, true).action, "order", "tapping the fortress with units = return iron")
        compare(Touch.decide(foundry, many, true).action, "select", "tapping another own building selects it")
        compare(Touch.decide(myOther, one, true).action, "select")
        compare(Touch.decide(myUnit, one, true).action, "deselect")
        // producer selected: ground / deposit set the rally point
        compare(Touch.decide(null, prod, true).action, "rally")
        compare(Touch.decide(deposit, prod, true).action, "rally")
        compare(Touch.decide(enemy, prod, true).action, "none")
        compare(Touch.decide(myUnit, prod, true).action, "select")
    }
}
