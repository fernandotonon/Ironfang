// Tutorial manager + campaign missions 1-3: definitions validate, steps advance through the shared
// event vocabulary, already-performed actions are recognised, polled steps, skip, and the
// objective mechanics the missions rely on (timer progress, counters, internal helpers,
// objectives resolved at victory).
import QtQuick
import QtTest
import "../app/scripts/Mission.js" as Mission
import "../app/scripts/Objectives.js" as Objectives
import "../app/scripts/Triggers.js" as Triggers
import "../app/scripts/Tutorial.js" as Tutorial
import "../app/missions/m1_embers.js" as M1
import "../app/missions/m2_stolen_mine.js" as M2
import "../app/missions/m3_hold.js" as M3
import "../app/missions/campaign.js" as CampaignDef

TestCase {
    name: "Tutorial"

    function test_campaign_missions_validate_and_load() {
        for (const def of [M1.mission, M2.mission, M3.mission]) {
            compare(Mission.validate(def), [], def.id)
            for (const d of ["story", "warrior", "warchief"]) {
                const m = Mission.load(def, d)
                verify(m.entities.length > 5, def.id + " " + d)
                verify(m.tags.player_fortress !== undefined, def.id + " needs player_fortress")
            }
        }
        compare(CampaignDef.missions[0].definition.id, "m1_embers")
        compare(CampaignDef.missions[2].definition.id, "m3_hold")
        compare(CampaignDef.missions[3].definition, null, "Mission 4 is not authored yet")
        const m1 = Mission.load(M1.mission, "warrior")
        compare(m1.tutorial.length, 10); compare(m1.enemy, null)
        compare(m1.tags.player_foundry.productionEnabled, false); compare(m1.tags.player_fortress.hpFraction, 0.6)
        compare(Mission.load(M1.mission, "story").player.iron, 32, "20 iron x Story scale 1.6")
        const m2 = Mission.load(M2.mission, "story")
        compare(Mission.enemyConfig(m2).firstWaveDelay, 320); compare(Mission.enemyConfig(m2).productionOrder, ["orc_warrior", "orc_archer"])
        const m3 = Mission.load(M3.mission, "warchief")
        compare(Mission.enemyConfig(m3).ogreEveryNthWave, 3); compare(m3.enemy.target, "player_foundry")
        verify(m3.objectives.some(o => o.id === "leader" && o.progress.tag === "assault_leader"), "a tag spawned by a trigger is a valid reference")
    }

    function test_steps_advance_on_events_and_recognise_past_actions() {
        const m = Mission.load(M1.mission, "warrior")
        const t = Tutorial.create(m.tutorial, false)
        compare(Tutorial.current(t).id, "camera"); compare(Tutorial.total(t), 10)
        // the player selects and moves before ever touching the camera
        verify(!Tutorial.handle(t, { type: "entitySelected", tag: "rukhar" }))
        verify(!Tutorial.handle(t, { type: "orderIssued", kind: "move" }))
        compare(Tutorial.current(t).id, "camera", "wrong-order events do not skip the current step")
        verify(Tutorial.handle(t, { type: "cameraMoved" }))
        compare(Tutorial.current(t).id, "locate", "select and move were already done -> skipped straight to locate")
        compare(Tutorial.drain(t).map(e => e.id), ["camera", "select", "move"])
        verify(!Tutorial.handle(t, { type: "orderIssued", kind: "gather" }), "gather order does not complete 'locate'")
        verify(Tutorial.handle(t, { type: "objectiveCompleted", id: "locate" }))
        compare(Tutorial.current(t).id, "deposit", "the gather order seen earlier completed 'gather' immediately")
        verify(Tutorial.handle(t, { type: "resourceDeposited", amount: 10 }))
        compare(Tutorial.current(t).id, "forge")
        Tutorial.handle(t, { type: "objectiveCompleted", id: "gather" })
        verify(!Tutorial.handle(t, { type: "productionQueued", unitType: "goblin_worker" }), "unitType filter")
        verify(Tutorial.handle(t, { type: "productionQueued", unitType: "orc_warrior" }))
        Tutorial.handle(t, { type: "orderIssued", kind: "attack" })
        compare(Tutorial.current(t).id, "finish"); verify(!t.finished)
        Tutorial.handle(t, { type: "objectiveCompleted", id: "scouts" })
        verify(t.finished); verify(!t.skipped)
        compare(Tutorial.drain(t).slice(-1)[0], { type: "tutorialFinished", skipped: false })
        compare(Tutorial.current(t), null)
    }

    function test_polled_and_timed_steps_and_skip() {
        const steps = [
            { id: "wait", text: "t", doneWhen: { type: "timerElapsed", seconds: 3 } },
            { id: "rich", text: "t", doneWhen: { type: "resourceReached", amount: 50 } },
            { id: "never", text: "t", doneWhen: { type: "waveLaunched" } }
        ]
        const world = { iron: 0 }
        const q = { iron: () => world.iron, countUnits: () => 0, units: () => [], entityByTag: () => null }
        const t = Tutorial.create(steps, true)
        verify(t.replay)
        verify(!Tutorial.step(t, 2.9, q)); verify(Tutorial.step(t, 0.2, q))
        compare(Tutorial.current(t).id, "rich")
        verify(!Tutorial.step(t, 1, q)); world.iron = 60; verify(Tutorial.step(t, 1, q))
        compare(Tutorial.current(t).id, "never")
        Tutorial.skip(t)
        verify(t.finished); verify(t.skipped)
        compare(Tutorial.drain(t).slice(-1)[0], { type: "tutorialFinished", skipped: true })
        Tutorial.skip(t); compare(Tutorial.drain(t), [], "skipping twice emits nothing")
        compare(Tutorial.create([], false).finished, true, "missions without steps have no tutorial")
    }

    // ---- objective mechanics used by missions 2 and 3 ----------------------------------------------
    function test_timer_counter_internal_and_victory_resolution() {
        const o = Objectives.create([
            { id: "prepare", text: "p", progress: { type: "timer", seconds: 10 } },
            { id: "protect", text: "x", completeOnVictory: true },
            { id: "survive", text: "s", target: 3 },
            { id: "hp", text: "h", optional: true, completeOnVictory: { type: "entityHpAtLeast", tag: "f", fraction: 0.5 } },
            { id: "losses", text: "l", optional: true, completeOnVictory: { type: "unitsLostAtMost", n: 5 } },
            { id: "fast", text: "f", optional: true, completeOnVictory: { type: "timeAtMost", seconds: 100 } },
            { id: "helper", text: "internal", internal: true, optional: true, target: 2 }
        ])
        compare(Objectives.visible(o).length, 6, "internal helpers are never shown")
        compare(Objectives.summary(o).optionalTotal, 3, "…and never counted")
        const q = { entityByTag: () => null, countUnits: () => 0, iron: () => 0 }
        Objectives.step(o, q, 100); Objectives.step(o, q, 104)
        compare(Objectives.get(o, "prepare").current, 4); compare(Objectives.primaryText(o), "p (4/10)")
        Objectives.step(o, q, 110.5)
        compare(Objectives.get(o, "prepare").state, "complete", "timer objectives complete on their own")
        Objectives.addProgress(o, "survive", 1); Objectives.addProgress(o, "survive", 1)
        compare(Objectives.get(o, "survive").current, 2); compare(Objectives.get(o, "survive").state, "active")
        verify(!Objectives.allPrimaryComplete(o))
        Objectives.addProgress(o, "survive", 1)
        verify(Objectives.allPrimaryComplete(o), "'protect' is resolved at victory and does not block it")
        Objectives.addProgress(o, "helper", 1); Objectives.addProgress(o, "helper", 1)
        compare(Objectives.get(o, "helper").state, "complete")
        // victory at t=120 with the foundry at 40 % and 3 units lost
        const foundry = { alive: true, hp: 400, maxHp: 1000 }
        Objectives.resolveAtVictory(o, { entityByTag: (tag) => tag === "f" ? foundry : null, unitsLost: 3, buildingsLost: 0, timerScale: 1.0 }, 120)
        compare(Objectives.get(o, "protect").state, "complete")
        compare(Objectives.get(o, "hp").state, "failed")
        compare(Objectives.get(o, "losses").state, "complete")
        compare(Objectives.get(o, "fast").state, "failed")
        compare(Objectives.summary(o), { complete: 4, failed: 2, optionalComplete: 1, optionalTotal: 3 }, "prepare, protect, survive, losses complete; hp, fast failed; helper excluded")
        // Story stretches time targets for the victory check as well
        const o2 = Objectives.create([ { id: "fast", text: "f", optional: true, completeOnVictory: { type: "timeAtMost", seconds: 100 } } ])
        Objectives.resolveAtVictory(o2, { entityByTag: () => null, unitsLost: 0, buildingsLost: 0, timerScale: 1.5 }, 120)
        compare(Objectives.get(o2, "fast").state, "complete")
    }

    function test_unit_count_le_progress_and_region_clearing() {
        const o = Objectives.create([ { id: "scouts", text: "s", hidden: true, progress: { type: "unitCount", team: "enemy", op: "<=", count: 0 } } ])
        const world = { enemies: 3 }
        const q = { entityByTag: () => null, countUnits: (team) => team === "enemy" ? world.enemies : 0, iron: () => 0 }
        Objectives.step(o, q, 1)
        compare(Objectives.get(o, "scouts").state, "hidden", "hidden objectives are not evaluated")
        Objectives.add(o, { id: "scouts" })
        Objectives.step(o, q, 2)
        compare(Objectives.get(o, "scouts").current, 3); compare(Objectives.get(o, "scouts").state, "active")
        compare(Objectives.primaryText(o), "s (3)")
        world.enemies = 0; Objectives.step(o, q, 3)
        compare(Objectives.get(o, "scouts").state, "complete")
        // Mission 2 capture: a "no enemy left in the region" trigger fires once per mine
        const m2 = Mission.load(M2.mission, "warrior")
        const t = Triggers.create(m2.triggers)
        const o2 = Objectives.create(m2.objectives)
        const units = m2.entities.filter(e => e.kind === "unit").map(e => ({ team: e.team, type: e.type, x: e.x, z: e.z }))
        const ctx = { query: { iron: () => 0, countUnits: () => 0, units: (team) => units.filter(u => !team || u.team === team), entityByTag: () => null },
                      objectiveComplete: () => false,
                      actions: { progressObjective: (a) => Objectives.addProgress(o2, a.id, a.delta), message: () => {}, showDialogue: () => {}, addObjective: (a) => Objectives.add(o2, a), startWave: () => {} } }
        Triggers.step(t, 1, ctx)
        compare(Objectives.get(o2, "capture").current, 0, "garrisons still on the mines")
        // kill the mine_a garrison (region 20..32 x 28..40)
        for (const u of units) if (u.team === "enemy" && u.x >= 20 && u.x <= 32 && u.z >= 28 && u.z <= 40) u.team = "dead"
        Triggers.step(t, 1, ctx); Triggers.step(t, 1, ctx)
        compare(Objectives.get(o2, "capture").current, 1, "one mine cleared, counted once")
        for (const u of units) if (u.team === "enemy") u.team = "dead"
        Triggers.step(t, 1, ctx)
        compare(Objectives.get(o2, "capture").state, "complete")
        for (const e of Objectives.drain(o2)) if (e.type === "objectiveCompleted") Triggers.handle(t, e, ctx)
        compare(Objectives.get(o2, "control").state, "active", "capturing all three reveals the hold objective")
    }
}
