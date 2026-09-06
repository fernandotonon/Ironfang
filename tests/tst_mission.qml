// Mission foundation: loader/validation, difficulty merge, objectives, triggers (one-shot,
// repeat, polled, delayed, gated), and the Classic Siege victory/defeat flow driven end to end
// through the same modules the game uses (with stub actions instead of a 3D world).
import QtQuick
import QtTest
import "../app/scripts/Mission.js" as Mission
import "../app/scripts/Objectives.js" as Objectives
import "../app/scripts/Triggers.js" as Triggers
import "../app/missions/classic_siege.js" as ClassicSiege
import "../app/config/balance.js" as Balance

TestCase {
    name: "Mission"

    // ---- loader ---------------------------------------------------------------------------------
    function test_classic_siege_loads_like_the_mvp_level() {
        compare(Mission.validate(ClassicSiege.mission), [])
        const m = Mission.load(ClassicSiege.mission, "normal")
        compare(m.id, "classic_siege"); compare(m.difficultyName, "normal")
        compare(m.map.size, 64); compare(m.map.camera.x, 18); compare(m.map.camera.pitch, 52)
        compare(m.player.iron, 150)
        // the MVP had 3 + 16 buildings/props (2 player, 1 enemy, 5 deposits, 11 obstacles) and 4 + 3 units
        compare(Mission.countEntities(m, "building"), 19)
        compare(Mission.countEntities(m, "building", "player"), 2)
        compare(Mission.countEntities(m, "unit", "player"), 4)
        compare(Mission.countEntities(m, "unit", "enemy"), 3)
        compare(m.entities.filter(e => e.type === "iron_deposit").length, 5)
        // defaults filled in
        compare(m.entities.filter(e => e.type === "iron_deposit")[0].team, "neutral")
        compare(m.entities.filter(e => e.type === "iron_deposit")[0].iron, Balance.buildings.iron_deposit.iron)
        compare(m.tags.player_fortress.type, "clan_fortress"); compare(m.tags.player_fortress.rally.x, 24)
        compare(m.tags.enemy_fortress.team, "enemy")
        compare(m.enemy.producer, "enemy_fortress"); compare(m.enemy.target, "player_fortress")
        compare(Mission.enemyConfig(m).firstWaveDelay, Balance.enemy.firstWaveDelay)
        compare(m.objectives.length, 1); verify(m.objectives[0].primary); verify(!m.objectives[0].optional)
        compare(m.triggers.length, 4); verify(!m.triggers[0].repeat); verify(m.triggers[3].repeat)
        verify(m.victory.auto)
        compare(m.difficulty, undefined, "difficulty table is consumed by the loader")
    }

    function test_loader_does_not_mutate_the_definition() {
        const before = JSON.stringify(ClassicSiege.mission)
        Mission.load(ClassicSiege.mission, "hard")
        compare(JSON.stringify(ClassicSiege.mission), before)
    }

    function test_validation_reports_problems() {
        const bad = {
            id: "", map: { size: 10 },
            entities: [ { type: "dragon", x: 1, z: 1 }, { tag: "a", type: "orc_warrior", x: 1, z: 1 },
                        { tag: "a", type: "orc_warrior", x: 50, z: 1, team: "purple" } ],
            objectives: [ { id: "o1", text: "x" }, { id: "o1", text: "y" }, { text: "no id" } ],
            triggers: [ { when: { type: "sneeze" }, actions: [ { type: "message", text: "" } ] },
                        { id: "t", when: { type: "entityDestroyed", tag: "ghost" }, actions: [ { type: "completeObjective", id: "nope" }, { type: "explode" } ] },
                        { when: { type: "missionStarted" } },
                        { when: { type: "missionStarted" }, actions: [ { type: "endMission", result: "draw" } ] } ],
            enemy: { producer: "ghost" }
        }
        const e = Mission.validate(bad)
        const has = (frag) => verify(e.some(x => x.indexOf(frag) >= 0), "expected an error mentioning '" + frag + "' in " + JSON.stringify(e))
        has("missing id"); has("unknown type 'dragon'"); has("duplicate tag 'a'"); has("outside the map"); has("bad team 'purple'")
        has("duplicate id 'o1'"); has("objectives[2]: missing id")
        has("unknown condition 'sneeze'"); has("tag 'ghost' not found"); has("objective 'nope' not found"); has("unknown action 'explode'")
        has("no actions"); has("endMission.result"); has("enemy.producer tag 'ghost' not found")
        compare(Mission.validate(null).length, 1)
        let threw = false
        try { Mission.load(bad, "normal") } catch (err) { threw = true; verify(String(err).indexOf("mission ''") >= 0) }
        verify(threw, "load throws on an invalid definition")
    }

    function test_difficulty_overrides_merge_deeply() {
        const def = {
            id: "d", map: { size: 20 }, player: { iron: 100 },
            enemy: { producer: "ef", target: "pf", waves: { waveBaseSize: 3, firstWaveDelay: 100 } },
            entities: [ { tag: "pf", type: "clan_fortress", team: "player", x: 5, z: 5 }, { tag: "ef", type: "enemy_fortress", team: "enemy", x: 15, z: 15 } ],
            difficulty: { easy: { player: { iron: 300 }, enemy: { waves: { firstWaveDelay: 200 } } },
                          hard: { player: { iron: 60 } } }
        }
        const easy = Mission.load(def, "easy"), hard = Mission.load(def, "hard"), normal = Mission.load(def, "normal")
        compare(easy.player.iron, 300); compare(hard.player.iron, 60); compare(normal.player.iron, 100)
        compare(easy.enemy.waves.firstWaveDelay, 200); compare(easy.enemy.waves.waveBaseSize, 3, "sibling keys survive the merge")
        compare(hard.enemy.waves.firstWaveDelay, 100)
        compare(Mission.enemyConfig(easy).firstWaveDelay, 200)
        compare(Mission.enemyConfig(easy).waveMaxSize, Balance.enemy.waveMaxSize, "unset fields fall back to Balance.enemy")
        const noEnemy = Mission.load({ id: "n", map: { size: 8 }, entities: [ { type: "orc_warrior", x: 1, z: 1 } ] }, "normal")
        compare(noEnemy.enemy, null); compare(Mission.enemyConfig(noEnemy), null)
        compare(noEnemy.player.iron, Balance.match.startIron)
    }

    // ---- objectives -------------------------------------------------------------------------------
    function test_objective_progression_and_events() {
        const o = Objectives.create([
            { id: "gather", text: "Gather iron", progress: { type: "resource", amount: 100 } },
            { id: "army", text: "Train warriors", progress: { type: "unitCount", team: "player", unitType: "orc_warrior", count: 2 } },
            { id: "bonus", text: "Lose nobody", optional: true },
            { id: "later", text: "Hidden until added", hidden: true }
        ])
        compare(Objectives.visible(o).length, 3)
        compare(Objectives.activePrimary(o).id, "gather")
        compare(Objectives.drain(o).map(e => e.type), ["objectiveAdded", "objectiveAdded", "objectiveAdded"])
        const world = { iron: 40, warriors: 0 }
        const q = { entityByTag: () => null, countUnits: (team, t) => t === "orc_warrior" ? world.warriors : 0, iron: () => world.iron }
        Objectives.step(o, q, 1)
        compare(Objectives.get(o, "gather").current, 40); compare(Objectives.get(o, "gather").state, "active")
        compare(Objectives.primaryText(o), "Gather iron (40/100)")
        world.iron = 120; Objectives.step(o, q, 2)
        compare(Objectives.get(o, "gather").state, "complete"); compare(Objectives.get(o, "gather").completedAt, 2)
        compare(Objectives.drain(o), [{ type: "objectiveCompleted", id: "gather", primary: true }])
        compare(Objectives.activePrimary(o).id, "army")
        verify(!Objectives.allPrimaryComplete(o))
        world.warriors = 2; Objectives.step(o, q, 3)
        verify(!Objectives.allPrimaryComplete(o), "the hidden primary objective still counts")
        Objectives.add(o, { id: "later" })                       // reveal
        compare(Objectives.get(o, "later").state, "active"); compare(Objectives.visible(o).length, 4)
        verify(Objectives.complete(o, "later", 4)); verify(!Objectives.complete(o, "later", 5), "completing twice is a no-op")
        verify(Objectives.allPrimaryComplete(o), "optional objectives do not block victory")
        verify(Objectives.fail(o, "bonus", 6)); verify(!Objectives.anyPrimaryFailed(o))
        compare(Objectives.summary(o), { complete: 3, failed: 1, optionalComplete: 0, optionalTotal: 1 })
        verify(!Objectives.fail(o, "gather"), "a complete objective cannot fail")
        compare(Objectives.drain(o).map(e => e.type), ["objectiveCompleted", "objectiveAdded", "objectiveCompleted", "objectiveFailed"],
                "army completed, later revealed, later completed, bonus failed")
    }

    function test_entity_hp_progress_is_display_only() {
        const o = Objectives.create([ { id: "fort", text: "Destroy the fortress", progress: { type: "entityHp", tag: "ef" } } ])
        const fort = { hp: 0, maxHp: 2500, alive: false }
        Objectives.step(o, { entityByTag: () => fort, countUnits: () => 0, iron: () => 0 }, 1)
        compare(Objectives.get(o, "fort").current, 0); compare(Objectives.get(o, "fort").target, 2500)
        compare(Objectives.get(o, "fort").state, "active", "HP progress never completes by itself; a trigger does")
        compare(Objectives.primaryText(o), "Destroy the fortress (0 HP)")
    }

    // ---- triggers ------------------------------------------------------------------------------
    function makeCtx(world) {
        const log = []
        return { log: log, ctx: {
            query: { iron: () => world.iron, countUnits: (team, t) => world.units.filter(u => u.team === team && (!t || u.type === t)).length,
                     units: (team, t) => world.units.filter(u => (!team || u.team === team) && (!t || u.type === t)), entityByTag: () => null },
            objectiveComplete: (id) => world.done.indexOf(id) >= 0,
            actions: { message: (a) => log.push("message:" + a.text), endMission: (a) => log.push("end:" + a.result) }
        } }
    }

    function test_triggers_fire_once_or_repeat() {
        const world = { iron: 0, units: [], done: [] }
        const h = makeCtx(world)
        const t = Triggers.create([
            { id: "once", when: { type: "entityDestroyed", tag: "ef" }, actions: [ { type: "message", text: "once" } ] },
            { id: "again", when: { type: "waveLaunched" }, repeat: true, actions: [ { type: "message", text: "wave" } ] },
            { id: "typed", when: { type: "unitProduced", unitType: "orc_archer", team: "player" }, actions: [ { type: "message", text: "archer" } ] },
            { id: "odd", when: { type: "missionStarted" }, actions: [ { type: "teleport" } ] }
        ])
        compare(Triggers.handle(t, { type: "entityDestroyed", tag: "pf" }, h.ctx), 0, "tag must match")
        compare(Triggers.handle(t, { type: "entityDestroyed", tag: "ef" }, h.ctx), 1)
        compare(Triggers.handle(t, { type: "entityDestroyed", tag: "ef" }, h.ctx), 0, "one-shot")
        Triggers.handle(t, { type: "waveLaunched" }, h.ctx); Triggers.handle(t, { type: "waveLaunched" }, h.ctx); Triggers.handle(t, { type: "waveLaunched" }, h.ctx)
        compare(Triggers.firedCount(t, "again"), 3)
        Triggers.handle(t, { type: "unitProduced", unitType: "orc_warrior", team: "player" }, h.ctx)
        Triggers.handle(t, { type: "unitProduced", unitType: "orc_archer", team: "enemy" }, h.ctx)
        compare(Triggers.firedCount(t, "typed"), 0, "unitType and team filters")
        Triggers.handle(t, { type: "unitProduced", unitType: "orc_archer", team: "player" }, h.ctx)
        compare(Triggers.firedCount(t, "typed"), 1)
        Triggers.handle(t, { type: "missionStarted" }, h.ctx)
        compare(t.unknownActions, ["teleport"], "unknown actions are reported, not thrown")
        compare(h.log, ["message:once", "message:wave", "message:wave", "message:wave", "message:archer"])
    }

    function test_polled_conditions_timer_resource_count_region() {
        const world = { iron: 0, units: [], done: [] }
        const h = makeCtx(world)
        const t = Triggers.create([
            { id: "t5", when: { type: "timerElapsed", seconds: 5 }, actions: [ { type: "message", text: "5s" } ] },
            { id: "after", when: { type: "timerElapsed", seconds: 2, after: "t5" }, actions: [ { type: "message", text: "7s" } ] },
            { id: "rich", when: { type: "resourceReached", amount: 100 }, actions: [ { type: "message", text: "rich" } ] },
            { id: "army", when: { type: "unitCountReached", team: "player", unitType: "orc_warrior", count: 2 }, actions: [ { type: "message", text: "army" } ] },
            { id: "wiped", when: { type: "unitCountReached", team: "player", count: 0, op: "<=" }, actions: [ { type: "end", result: "defeat" }, { type: "endMission", result: "defeat" } ] },
            { id: "gate", when: { type: "unitEnteredRegion", region: { x: 10, z: 10, w: 4, d: 4 }, team: "player" }, repeat: true, actions: [ { type: "message", text: "enter" } ] }
        ])
        // t=0: "wiped" is true immediately (no units) -> rising edge fires it once
        Triggers.step(t, 1, h.ctx)
        compare(h.log, ["end:defeat"]); compare(t.unknownActions, ["end"])
        world.units.push({ team: "player", type: "orc_warrior", x: 0, z: 0 })
        for (let i = 0; i < 4; ++i) Triggers.step(t, 1, h.ctx)          // t=5
        compare(Triggers.firedCount(t, "t5"), 1); compare(Triggers.firedCount(t, "after"), 0)
        Triggers.step(t, 2, h.ctx)                                      // t=7
        compare(Triggers.firedCount(t, "after"), 1)
        world.iron = 99; Triggers.step(t, 0.1, h.ctx); compare(Triggers.firedCount(t, "rich"), 0)
        world.iron = 100; Triggers.step(t, 0.1, h.ctx); compare(Triggers.firedCount(t, "rich"), 1)
        world.units.push({ team: "player", type: "orc_warrior", x: 0, z: 0 }); Triggers.step(t, 0.1, h.ctx)
        compare(Triggers.firedCount(t, "army"), 1)
        // region: fires on entry, not every step; again after leaving and re-entering
        world.units[0].x = 11; world.units[0].z = 11
        Triggers.step(t, 0.1, h.ctx); Triggers.step(t, 0.1, h.ctx); Triggers.step(t, 0.1, h.ctx)
        compare(Triggers.firedCount(t, "gate"), 1, "rising edge only")
        world.units[0].x = 0; Triggers.step(t, 0.1, h.ctx)
        world.units[0].x = 12; Triggers.step(t, 0.1, h.ctx)
        compare(Triggers.firedCount(t, "gate"), 2)
    }

    function test_delay_and_requires_gates() {
        const world = { iron: 0, units: [], done: [] }
        const h = makeCtx(world)
        const t = Triggers.create([
            { id: "late", when: { type: "missionStarted" }, delay: 3, actions: [ { type: "message", text: "late" } ] },
            { id: "gated", when: { type: "waveLaunched" }, requires: ["o1"], actions: [ { type: "message", text: "gated" } ] }
        ])
        Triggers.handle(t, { type: "missionStarted" }, h.ctx)
        compare(h.log, [], "delayed trigger has not fired yet")
        Triggers.step(t, 2.9, h.ctx); compare(h.log, [])
        Triggers.step(t, 0.2, h.ctx); compare(h.log, ["message:late"])
        Triggers.handle(t, { type: "waveLaunched" }, h.ctx); compare(Triggers.firedCount(t, "gated"), 0, "objective o1 not complete")
        world.done.push("o1")
        Triggers.handle(t, { type: "waveLaunched" }, h.ctx); compare(Triggers.firedCount(t, "gated"), 1)
    }

    // ---- end-to-end: Classic Siege victory / defeat / restart through the real definition --------
    function siegeHarness() {
        const m = Mission.load(ClassicSiege.mission, "normal")
        const o = Objectives.create(m.objectives)
        const t = Triggers.create(m.triggers)
        const h = { result: "", messages: [], sounds: [], phase: "playing", o: o, t: t, m: m }
        const ctx = {
            query: { entityByTag: () => null, countUnits: () => 0, units: () => [], iron: () => 0 },
            objectiveComplete: (id) => { const x = Objectives.get(o, id); return !!x && x.state === "complete" },
            actions: {
                message: (a) => h.messages.push(a.text), playAudio: (a) => h.sounds.push(a.sound),
                completeObjective: (a) => Objectives.complete(o, a.id, t.time),
                endMission: (a) => { if (h.phase === "playing") { h.phase = a.result; h.result = a.result } }
            }
        }
        h.event = (type, payload) => {
            Triggers.handle(t, Object.assign({ type: type }, payload || {}), ctx)
            for (const e of Objectives.drain(o)) if (e.type === "objectiveCompleted" || e.type === "objectiveFailed") Triggers.handle(t, e, ctx)
            if (h.phase === "playing" && m.victory.auto && Objectives.allPrimaryComplete(o)) { h.phase = "victory"; h.result = "victory" }
        }
        h.step = (dt) => { Triggers.step(t, dt, ctx); Objectives.step(o, ctx.query, t.time) }
        return h
    }

    function test_classic_siege_victory_flow() {
        const h = siegeHarness()
        h.event("missionStarted", { id: "classic_siege" })
        compare(h.messages, ["Send your goblins to the iron. Forge an army. Break the enemy fortress."])
        h.event("waveLaunched", { size: 3 }); h.event("waveLaunched", { size: 4 })
        compare(h.messages.length, 3); compare(h.sounds, ["wave_incoming", "wave_incoming"], "the wave warning repeats")
        h.event("entityDestroyed", { tag: "", entityType: "orc_warrior", team: "enemy" })
        compare(h.phase, "playing")
        h.event("entityDestroyed", { tag: "enemy_fortress", entityType: "enemy_fortress", team: "enemy" })
        compare(Objectives.get(h.o, "destroy_fortress").state, "complete")
        compare(h.phase, "victory")
        h.event("entityDestroyed", { tag: "player_fortress", entityType: "clan_fortress", team: "player" })
        compare(h.phase, "victory", "the match does not flip after it ended")
    }

    function test_classic_siege_defeat_and_restart() {
        let h = siegeHarness()
        h.event("missionStarted"); h.step(10)
        h.event("entityDestroyed", { tag: "player_fortress", entityType: "clan_fortress", team: "player" })
        compare(h.phase, "defeat"); compare(h.result, "defeat")
        compare(Objectives.get(h.o, "destroy_fortress").state, "active")
        // restart = fresh state from the same definition: intro fires again, nothing carried over
        h = siegeHarness()
        compare(h.t.time, 0); compare(Triggers.firedCount(h.t, "intro"), 0)
        h.event("missionStarted")
        compare(h.messages.length, 1); compare(h.phase, "playing")
        compare(Objectives.visible(h.o).length, 1); compare(Objectives.get(h.o, "destroy_fortress").state, "active")
    }
}
