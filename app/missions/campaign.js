// The Broken Crown campaign: ordered mission list, skirmish scenarios, unlock rules.
// Titles/briefings are localisation keys (app/i18n). `definition` is the mission module's
// `mission` object; null means "not authored yet" (shown as in development, never playable).
.pragma library
.import "classic_siege.js" as ClassicSiege
.import "m1_embers.js" as M1
.import "m2_stolen_mine.js" as M2
.import "m3_hold.js" as M3

var missions = [
    { id: "m1_embers",     number: 1, titleKey: "mission.m1.title", taglineKey: "mission.m1.tagline", definition: M1.mission },
    { id: "m2_stolen_mine",number: 2, titleKey: "mission.m2.title", taglineKey: "mission.m2.tagline", definition: M2.mission },
    { id: "m3_hold",       number: 3, titleKey: "mission.m3.title", taglineKey: "mission.m3.tagline", definition: M3.mission },
    { id: "m4_ashlands",   number: 4, titleKey: "mission.m4.title", taglineKey: "mission.m4.tagline", definition: null },
    { id: "m5_hammerfall", number: 5, titleKey: "mission.m5.title", taglineKey: "mission.m5.tagline", definition: null },
    { id: "m6_traitors_gate", number: 6, titleKey: "mission.m6.title", taglineKey: "mission.m6.tagline", definition: null },
    { id: "m7_broken_crown",  number: 7, titleKey: "mission.m7.title", taglineKey: "mission.m7.tagline", definition: null }
]

var scenarios = [
    { id: "classic_siege", titleKey: "scenario.classic_siege.title", taglineKey: "scenario.classic_siege.tagline", definition: ClassicSiege.mission }
]

var unlocks = {
    survival: "m3_hold"           // completing this mission unlocks Survival mode
}
