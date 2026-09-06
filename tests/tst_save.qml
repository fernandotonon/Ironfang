// Save documents: defaults, round trip, tolerant parsing (corrupt, wrong shape, newer schema),
// migrations, and campaign progression rules (unlocks, medals, best results, reset).
import QtQuick
import QtTest
import "../app/scripts/Save.js" as Save
import "../app/scripts/Campaign.js" as Campaign
import "../app/scripts/Mission.js" as Mission
import "../app/missions/classic_siege.js" as ClassicSiege
import "../app/missions/campaign.js" as CampaignDef
import "../app/config/balance.js" as Balance

TestCase {
    name: "Save"

    function test_round_trip_and_defaults() {
        const p = Save.emptyProgress()
        compare(p.version, Save.SCHEMA); verify(!p.campaign.started); compare(p.survival.bestWave, 0)
        p.campaign.completed["m1_embers"] = true
        p.achievements.unlocked["the_clan_survives"] = "2026-09-06T00:00:00Z"
        const text = Save.serialize(p)
        verify(text.indexOf('"savedAt"') > 0)
        const back = Save.parse(text, "progress")
        verify(back.ok); verify(!back.migrated); verify(!back.empty)
        verify(back.data.campaign.completed.m1_embers)
        compare(back.data.achievements.unlocked.the_clan_survives, "2026-09-06T00:00:00Z")
        const s = Save.emptySettings()
        compare(s.audio.music, 0.35); compare(s.language, "")
        const sb = Save.parse(Save.serialize(s), "settings")
        verify(sb.ok); compare(sb.data.controls.cameraShake, true)
    }

    function test_missing_and_corrupt_saves_fall_back_to_defaults() {
        let r = Save.parse(null, "progress"); verify(r.ok); verify(r.empty); compare(r.data.version, Save.SCHEMA)
        r = Save.parse("", "settings"); verify(r.ok); verify(r.empty)
        r = Save.parse("{ not json", "progress"); verify(!r.ok); verify(r.error.indexOf("invalid JSON") === 0); compare(r.data.campaign.lastMission, "")
        r = Save.parse("[1,2,3]", "progress"); verify(!r.ok); compare(r.error, "not an object")
        r = Save.parse('{"version": 99}', "progress"); verify(!r.ok); verify(r.error.indexOf("newer version") >= 0)
        // partial document: missing sections are filled, wrong-typed sections replaced
        r = Save.parse('{"version": 1, "campaign": { "completed": { "m1_embers": true } }, "survival": "nope" }', "progress")
        verify(r.ok); verify(r.data.campaign.completed.m1_embers); compare(r.data.campaign.best, ({})); compare(r.data.survival.bestWave, 0)
        compare(r.data.tutorial.completed, false)
    }

    function test_migration_from_unversioned() {
        const r = Save.parse('{"campaign": { "completed": {}, "best": {}, "lastMission": "classic_siege" } }', "progress")
        verify(r.ok); verify(r.migrated, "version 0 -> 1")
        compare(r.data.version, Save.SCHEMA); compare(r.data.campaign.lastMission, "classic_siege")
        compare(r.data.campaign.lastDifficulty, "warrior", "new field filled from defaults")
    }

    // ---- campaign progression ---------------------------------------------------------------------
    function test_unlock_order_and_next_mission() {
        const p = Save.emptyProgress()
        const ids = CampaignDef.missions.map(m => m.id)
        compare(ids.length, 7)
        verify(Campaign.isUnlocked(p, ids[0])); verify(!Campaign.isUnlocked(p, ids[1])); verify(!Campaign.isUnlocked(p, ids[6]))
        verify(!Campaign.survivalUnlocked(p)); verify(!Campaign.campaignComplete(p))
        p.campaign.completed[ids[0]] = true
        verify(Campaign.isUnlocked(p, ids[1])); verify(!Campaign.isUnlocked(p, ids[2]))
        p.campaign.completed[ids[1]] = true; p.campaign.completed[ids[2]] = true
        verify(Campaign.survivalUnlocked(p), "Mission 3 unlocks Survival")
        for (const id of ids) p.campaign.completed[id] = true
        verify(Campaign.campaignComplete(p))
        compare(Campaign.nextMission(p), "", "nothing left to play")
        verify(!Campaign.isCampaignMission("classic_siege")); verify(Campaign.isCampaignMission(ids[0]))
        compare(Campaign.info("classic_siege").definition.id, "classic_siege")
        compare(Campaign.info("nope"), null)
    }

    function test_medals_follow_published_criteria() {
        const def = Mission.load(Object.assign({}, ClassicSiege.mission, {
            objectives: [ { id: "a", text: "A", primary: true }, { id: "b", text: "B", optional: true } ], triggers: [],
            medals: { steel: { optionalAll: true }, gold: { optionalAll: true, time: 600, maxUnitsLost: 3 } }
        }), "warrior")
        const base = { victory: true, time: 500, optionalComplete: 1, optionalTotal: 1, unitsLost: 2, buildingsLost: 0 }
        compare(Campaign.medalFor(def, base, "warrior"), "gold")
        compare(Campaign.medalFor(def, Object.assign({}, base, { unitsLost: 4 }), "warrior"), "steel")
        compare(Campaign.medalFor(def, Object.assign({}, base, { time: 601 }), "warrior"), "steel")
        compare(Campaign.medalFor(def, Object.assign({}, base, { time: 601 }), "story"), "gold", "Story stretches time targets by timerScale")
        compare(Campaign.medalFor(def, Object.assign({}, base, { time: 520 }), "warchief"), "steel", "Warchief tightens them (600 * 0.85 = 510)")
        compare(Campaign.medalFor(def, Object.assign({}, base, { optionalComplete: 0 }), "warrior"), "iron")
        compare(Campaign.medalFor(def, Object.assign({}, base, { victory: false }), "warrior"), "")
        const c = Campaign.criteria(def, "warrior")
        compare(c.steel.map(x => x.key), ["medal.criteria.optional_all"])
        compare(c.gold.map(x => x.key), ["medal.criteria.optional_all", "medal.criteria.time", "medal.criteria.units_lost"])
        compare(c.gold[1].args.time, "10:00")
        compare(Campaign.criteria(def, "story").gold[1].args.time, "15:00")
    }

    function test_record_result_unlocks_and_keeps_the_best() {
        const p = Save.emptyProgress()
        const m1 = CampaignDef.missions[0].id, m2 = CampaignDef.missions[1].id
        const mission = Mission.load(ClassicSiege.mission, "warrior")
        // a defeat records nothing but the last mission
        let rec = Campaign.recordResult(p, m1, "warrior", { mission: mission, victory: false, time: 300, optionalComplete: 0, optionalTotal: 0, unitsLost: 9, buildingsLost: 1 })
        compare(rec.medal, ""); compare(rec.newlyUnlocked, []); verify(!Campaign.isCompleted(p, m1)); verify(p.campaign.started)
        compare(p.campaign.lastMission, m1)
        // a victory completes, records the best and unlocks the next mission
        rec = Campaign.recordResult(p, m1, "warrior", { mission: mission, victory: true, time: 700, optionalComplete: 0, optionalTotal: 0, unitsLost: 2, buildingsLost: 0 })
        compare(rec.medal, "gold", "classic siege has no extra criteria -> gold on victory")
        compare(Campaign.criteria(mission, "warrior").gold, [], "no optional objectives -> the optional-all criterion is not advertised")
        verify(rec.improved); compare(rec.previousBest, null)
        compare(rec.newlyUnlocked, [m2]); verify(!rec.survivalUnlocked)
        compare(Campaign.bestFor(p, m1, "warrior").time, 700)
        compare(Campaign.nextMission(p), CampaignDef.missions[1].definition ? m2 : "", "next is Mission 2 when authored")
        // a slower replay does not overwrite the best; a faster one does
        rec = Campaign.recordResult(p, m1, "warrior", { mission: mission, victory: true, time: 900, optionalComplete: 0, optionalTotal: 0, unitsLost: 0, buildingsLost: 0 })
        verify(!rec.improved); compare(rec.previousBest.time, 700); compare(Campaign.bestFor(p, m1, "warrior").time, 700)
        rec = Campaign.recordResult(p, m1, "warrior", { mission: mission, victory: true, time: 650, optionalComplete: 0, optionalTotal: 0, unitsLost: 0, buildingsLost: 0 })
        verify(rec.improved); compare(Campaign.bestFor(p, m1, "warrior").time, 650)
        compare(rec.newlyUnlocked, [], "replaying unlocks nothing new")
        // per-difficulty bests are separate
        compare(Campaign.bestFor(p, m1, "warchief"), null)
        compare(Campaign.bestMedalAnyDifficulty(p, m1), "gold")
        // scenarios record bests but never count as campaign completion
        Campaign.recordResult(p, "classic_siege", "story", { mission: mission, victory: true, time: 400, optionalComplete: 0, optionalTotal: 0, unitsLost: 0, buildingsLost: 0 })
        verify(!Campaign.isCompleted(p, "classic_siege")); compare(Campaign.bestFor(p, "classic_siege", "story").medal, "gold")
        // reset wipes progress but not the document shape
        Campaign.resetProgress(p)
        verify(!p.campaign.started); compare(p.campaign.best, ({})); verify(!Campaign.isUnlocked(p, m2))
    }
}
