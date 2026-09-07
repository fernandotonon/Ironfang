// Frontend: every screen outside the match - main menu, campaign map, briefing, results,
// settings, credits, pause. Pure presentation over `progress` / `settings` documents and the
// game's counters; it emits requests, the game (IronfangGame) acts and saves.
// `screen`: menu | campaign | briefing | results | settings | credits | paused | ""
import QtQuick
import "scripts/Campaign.js" as Campaign
import "scripts/Mission.js" as Mission
import "config/balance.js" as Balance

Item {
    id: fe
    property var game: null
    property var progress: null              // Save progress document
    property var settings: null              // Save settings document
    property string screen: "menu"
    property string selectedMission: ""      // campaign map -> briefing
    property string selectedDifficulty: progress ? progress.campaign.lastDifficulty : "warrior"
    property var lastResult: null            // set by the game after a match
    property int progressRev: 0              // bump to refresh bindings on the plain progress object
    visible: screen !== ""

    signal startMissionRequested(string missionId, string difficulty)
    signal resumeRequested()
    signal restartRequested()
    signal quitToMenuRequested()
    signal showcaseRequested()
    signal exitRequested()
    signal settingsEdited()
    signal resetProgressRequested()

    readonly property color gold: "#e0b24a"
    readonly property color ink: "#f2e2c4"
    readonly property color faint: "#9aa0a6"
    readonly property color dim: "#6f7580"
    readonly property color red: "#c9432e"
    readonly property color green: "#5fae3c"
    readonly property color panel: "#e61b1d22"
    readonly property color edge: "#7a5a2a"
    readonly property bool desktop: Qt.platform.os !== "wasm"

    function medalColor(m) { return m === "gold" ? "#e6c14a" : m === "steel" ? "#b8c4d0" : m === "iron" ? "#8d8f96" : dim }
    function medalName(m) { return m ? Loc.tr("medal." + m) : Loc.tr("medal.none") }
    function difficultyName(d) { return Loc.tr("difficulty." + d) }
    function missionTitle(info) { return info ? Loc.tr(info.titleKey) : "" }
    function loadedMission(id) {
        const info = Campaign.info(id)
        if (!info || !info.definition) return null
        try { return Mission.load(info.definition, selectedDifficulty) } catch (e) { console.warn("briefing:", e); return null }
    }
    readonly property var briefingMission: (void progressRev, void selectedDifficulty, loadedMission(selectedMission))
    readonly property var briefingInfo: Campaign.info(selectedMission)

    Rectangle { anchors.fill: parent; color: fe.screen === "paused" || fe.screen === "results" ? "#a814161a" : "#f214161a" }
    MouseArea { anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.AllButtons; onWheel: (w) => w.accepted = true }

    // ---- shared components -------------------------------------------------------------------
    component MenuButton: Rectangle {
        id: mb
        property string label: ""
        property string note: ""
        property bool primary: false
        property bool usable: true
        signal clicked()
        width: 320; height: note !== "" ? 34 + noteText.implicitHeight + 10 : 42; radius: 5
        color: !usable ? "#221f1c" : ma.pressed ? "#7d5a2a" : (ma.containsMouse ? "#5a4222" : (primary ? "#4a3620" : "#2b2418"))
        border.color: !usable ? "#4a4038" : primary ? fe.gold : fe.edge; border.width: 1
        opacity: usable ? 1 : 0.75
        Column {
            anchors.centerIn: parent; spacing: 2; width: mb.width - 24
            Text { width: parent.width; horizontalAlignment: Text.AlignHCenter; fontSizeMode: Text.HorizontalFit; minimumPixelSize: 11; text: mb.label; color: mb.usable ? fe.ink : fe.dim; font.pixelSize: 15; font.letterSpacing: 1 }
            Text { id: noteText; visible: mb.note !== ""; width: parent.width; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; text: mb.note; color: fe.dim; font.pixelSize: 11; lineHeight: 1.1 }
        }
        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; enabled: mb.usable; onClicked: mb.clicked() }
    }
    component Heading: Text { color: fe.gold; font.pixelSize: 40; font.bold: true; font.letterSpacing: 6; anchors.horizontalCenter: parent.horizontalCenter; horizontalAlignment: Text.AlignHCenter }
    component Body: Text { color: fe.ink; font.pixelSize: 14; wrapMode: Text.WordWrap; lineHeight: 1.3 }
    component Small: Text { color: fe.faint; font.pixelSize: 12; wrapMode: Text.WordWrap }
    component Footer: Text {
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 14 }
        text: Loc.tr("credits.footer"); color: fe.dim; font.pixelSize: 12
    }
    component Slider: Item {
        id: sl
        property real value: 0.5
        property string label: ""
        signal moved(real v)
        width: 320; height: 34
        Text { text: sl.label; color: fe.ink; font.pixelSize: 13; anchors { left: parent.left; verticalCenter: parent.verticalCenter } }
        Rectangle {
            id: track; width: 150; height: 8; radius: 4; color: "#2a2620"; border.color: fe.edge
            anchors { right: pct.left; rightMargin: 10; verticalCenter: parent.verticalCenter }
            Rectangle { width: parent.width * sl.value; height: parent.height; radius: 4; color: fe.gold }
            MouseArea {
                anchors.fill: parent; anchors.margins: -8
                onPressed: (m) => sl.moved(Math.max(0, Math.min(1, (m.x - 8) / track.width)))
                onPositionChanged: (m) => { if (pressed) sl.moved(Math.max(0, Math.min(1, (m.x - 8) / track.width))) }
            }
        }
        Text { id: pct; text: Math.round(sl.value * 100) + "%"; color: fe.faint; font.pixelSize: 12; width: 38; horizontalAlignment: Text.AlignRight; anchors { right: parent.right; verticalCenter: parent.verticalCenter } }
    }
    component Toggle: Item {
        id: tg
        property bool checked: false
        property string label: ""
        signal toggled(bool v)
        width: 320; height: 30
        Text { text: tg.label; color: fe.ink; font.pixelSize: 13; anchors { left: parent.left; verticalCenter: parent.verticalCenter } }
        Rectangle {
            width: 44; height: 22; radius: 11; color: tg.checked ? "#4a3620" : "#2a2620"; border.color: tg.checked ? fe.gold : fe.edge
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            Rectangle { width: 16; height: 16; radius: 8; color: tg.checked ? fe.gold : fe.dim; anchors.verticalCenter: parent.verticalCenter; x: tg.checked ? parent.width - width - 3 : 3 }
            MouseArea { anchors.fill: parent; onClicked: tg.toggled(!tg.checked) }
        }
    }
    component MedalDot: Rectangle {
        property string medal: ""
        width: 14; height: 14; radius: 7
        color: medal ? fe.medalColor(medal) : "transparent"; border.color: medal ? Qt.darker(fe.medalColor(medal), 1.4) : fe.dim
    }

    // ---- main menu -------------------------------------------------------------------------------
    Item {
        anchors.fill: parent; visible: fe.screen === "menu"
        Column {
            anchors.centerIn: parent; spacing: 8; width: 320
            Heading { text: "IRONFANG"; font.pixelSize: 64; font.letterSpacing: 8 }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: Loc.tr("game.subtitle"); color: fe.ink; font.pixelSize: 22; font.letterSpacing: 6 }
            Small { anchors.horizontalCenter: parent.horizontalCenter; width: fe.width - 40; horizontalAlignment: Text.AlignHCenter; text: Loc.tr("game.tagline") }
            Item { width: 1; height: 16 }
            MenuButton {
                readonly property string next: (void fe.progressRev, fe.progress ? Campaign.nextMission(fe.progress) : "")
                visible: fe.progress && fe.progress.campaign.started && next !== ""
                label: Loc.tr("menu.continue"); primary: true
                note: next ? Loc.tr("menu.continue_note", { mission: fe.missionTitle(Campaign.info(next)) }) : ""
                onClicked: { fe.selectedMission = next; fe.screen = "briefing" }
            }
            MenuButton { label: Loc.tr("menu.campaign"); primary: !(fe.progress && fe.progress.campaign.started); onClicked: fe.screen = "campaign" }
            MenuButton {
                readonly property bool unlocked: (void fe.progressRev, fe.progress ? Campaign.survivalUnlocked(fe.progress) : false)
                label: Loc.tr("menu.survival"); usable: false
                note: unlocked ? Loc.tr("menu.coming_later") : Loc.tr("menu.survival_locked")
            }
            MenuButton { label: Loc.tr("menu.skirmish"); note: Loc.tr("scenario.classic_siege.title"); onClicked: { fe.selectedMission = "classic_siege"; fe.screen = "briefing" } }
            MenuButton { label: Loc.tr("menu.codex"); usable: false; note: Loc.tr("menu.coming_later") }
            MenuButton { label: Loc.tr("menu.showcase"); onClicked: fe.showcaseRequested() }
            MenuButton { label: Loc.tr("menu.settings"); onClicked: fe.screen = "settings" }
            MenuButton { label: Loc.tr("menu.credits"); onClicked: fe.screen = "credits" }
            MenuButton { visible: fe.desktop; label: Loc.tr("menu.exit"); onClicked: fe.exitRequested() }
        }
        Footer {}
    }

    // ---- campaign map (list form until the illustrated map exists - docs/asset-requests.md) -------
    Item {
        anchors.fill: parent; visible: fe.screen === "campaign"
        Column {
            anchors { top: parent.top; topMargin: 40; horizontalCenter: parent.horizontalCenter }
            spacing: 10; width: Math.min(parent.width - 40, 760)
            Heading { text: Loc.tr("campaign.title") }
            Small { anchors.horizontalCenter: parent.horizontalCenter; text: Loc.tr("campaign.subtitle") }
            Item { width: 1; height: 6 }
            Repeater {
                model: Campaign.missions()
                Rectangle {
                    id: card
                    required property var modelData
                    readonly property bool unlocked: (void fe.progressRev, fe.progress ? Campaign.isUnlocked(fe.progress, modelData.id) : modelData.number === 1)
                    readonly property bool completed: (void fe.progressRev, fe.progress ? Campaign.isCompleted(fe.progress, modelData.id) : false)
                    readonly property bool authored: !!modelData.definition
                    readonly property bool playable: unlocked && authored
                    readonly property string bestMedal: (void fe.progressRev, fe.progress ? Campaign.bestMedalAnyDifficulty(fe.progress, modelData.id) : "")
                    width: parent.width; height: 56; radius: 6
                    color: cma.containsMouse && playable ? "#3b2d19" : (playable ? "#2b2418" : "#1e1c1a")
                    border.color: completed ? fe.gold : playable ? fe.edge : "#3a3530"
                    Row {
                        anchors { fill: parent; margins: 10 }
                        spacing: 14
                        Rectangle {
                            width: 36; height: 36; radius: 18; anchors.verticalCenter: parent.verticalCenter
                            color: card.completed ? "#4a3620" : "#24211d"; border.color: card.playable ? fe.gold : "#4a4038"
                            Text { anchors.centerIn: parent; text: card.modelData.number; color: card.playable ? fe.gold : fe.dim; font.pixelSize: 16; font.bold: true }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter; spacing: 2
                            Text { text: Loc.tr(card.modelData.titleKey); color: card.playable ? fe.ink : fe.dim; font.pixelSize: 16; font.bold: true }
                            Small { text: !card.unlocked ? Loc.tr("campaign.locked", { n: card.modelData.number - 1 })
                                          : !card.authored ? Loc.tr("campaign.in_development")
                                          : Loc.tr(card.modelData.taglineKey) }
                        }
                    }
                    Row {
                        anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                        spacing: 8
                        Small { visible: card.completed; text: fe.medalName(card.bestMedal); anchors.verticalCenter: parent.verticalCenter }
                        MedalDot { visible: card.completed; medal: card.bestMedal; anchors.verticalCenter: parent.verticalCenter }
                        Text { visible: !card.unlocked; text: "🔒"; color: fe.dim; font.pixelSize: 16 }
                    }
                    MouseArea { id: cma; anchors.fill: parent; hoverEnabled: true; enabled: card.playable; onClicked: { fe.selectedMission = card.modelData.id; fe.screen = "briefing" } }
                }
            }
            Item { width: 1; height: 10 }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter; spacing: 10
                MenuButton { width: 200; label: Loc.tr("common.back"); onClicked: fe.screen = "menu" }
                MenuButton { width: 200; visible: fe.progress && fe.progress.campaign.started; label: Loc.tr("campaign.reset"); onClicked: confirmReset.visible = true }
            }
        }
        Rectangle {
            id: confirmReset
            visible: false; anchors.centerIn: parent; width: 420; height: 160; radius: 8; color: fe.panel; border.color: fe.red
            Column {
                anchors.centerIn: parent; spacing: 12
                Body { width: 380; horizontalAlignment: Text.AlignHCenter; text: Loc.tr("campaign.reset_confirm") }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter; spacing: 10
                    MenuButton { width: 160; label: Loc.tr("campaign.reset_yes"); onClicked: { confirmReset.visible = false; fe.resetProgressRequested() } }
                    MenuButton { width: 160; label: Loc.tr("common.cancel"); primary: true; onClicked: confirmReset.visible = false }
                }
            }
        }
    }

    // ---- briefing -------------------------------------------------------------------------------
    Item {
        anchors.fill: parent; visible: fe.screen === "briefing"
        readonly property var m: fe.briefingMission
        readonly property var info: fe.briefingInfo
        Row {
            id: briefRow
            anchors.horizontalCenter: parent.horizontalCenter
            y: Math.max(28, (fe.height - height) / 2 - 20)
            spacing: 28
            // illustration (mission art) or a labelled dummy panel until it exists (docs/asset-requests.md)
            Rectangle {
                width: 340; height: 220; radius: 8; color: "#24211d"; border.color: fe.edge; clip: true
                readonly property string art: fe.briefingMission && fe.briefingMission.briefing.illustration ? fe.briefingMission.briefing.illustration : ""
                Image {
                    anchors.fill: parent; anchors.margins: 1
                    visible: parent.art !== ""
                    source: parent.art === "" ? "" : (fe.game && fe.game.assetBase ? fe.game.assetBase + parent.art : Qt.resolvedUrl(parent.art))
                    fillMode: Image.PreserveAspectCrop; asynchronous: true; smooth: true
                }
                Column {
                    visible: parent.art === ""
                    anchors.centerIn: parent; spacing: 6
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: parent.parent.parent.parent.info && parent.parent.parent.parent.info.number ? parent.parent.parent.parent.info.number : "⚔"; color: fe.gold; font.pixelSize: 56; font.bold: true }
                    Small { anchors.horizontalCenter: parent.horizontalCenter; text: Loc.tr("briefing.illustration_placeholder") }
                }
            }
            Column {
                width: 440; spacing: 10
                Text { text: parent.parent.parent.info ? Loc.tr(parent.parent.parent.info.titleKey) : ""; color: fe.gold; font.pixelSize: 30; font.bold: true; font.letterSpacing: 2 }
                Body {
                    width: parent.width
                    text: { const m = parent.parent.parent.m; return m ? (m.briefing.intro ? Loc.trOr(m.briefing.intro) : Loc.trOr(m.description)) : Loc.tr("briefing.unavailable") }
                }
                Text { text: Loc.tr("briefing.objectives"); color: fe.gold; font.pixelSize: 13; font.bold: true; topPadding: 6 }
                Repeater {
                    model: parent.parent.parent.m ? parent.parent.parent.m.objectives.filter(o => !o.hidden) : []
                    Small { required property var modelData; width: 440; text: (modelData.optional ? "◇ " + Loc.tr("objective.optional_prefix") + " " : "◆ ") + Loc.trOr(modelData.text); color: modelData.optional ? fe.faint : fe.ink }
                }
                Text { text: Loc.tr("briefing.medals"); color: fe.gold; font.pixelSize: 13; font.bold: true; topPadding: 6 }
                Column {
                    readonly property var crit: parent.parent.parent.m ? Campaign.criteria(parent.parent.parent.m, fe.selectedDifficulty) : { steel: [], gold: [] }
                    spacing: 2
                    Row { spacing: 8; MedalDot { medal: "iron"; anchors.verticalCenter: parent.verticalCenter } Small { text: Loc.tr("medal.iron") + " — " + Loc.tr("medal.criteria.complete") } }
                    Row { spacing: 8; MedalDot { medal: "steel"; anchors.verticalCenter: parent.verticalCenter }
                          Small { text: Loc.tr("medal.steel") + " — " + (parent.parent.crit.steel.length ? parent.parent.crit.steel.map(c => Loc.tr(c.key, c.args)).join(", ") : Loc.tr("medal.criteria.none")) } }
                    Row { spacing: 8; MedalDot { medal: "gold"; anchors.verticalCenter: parent.verticalCenter }
                          Small { text: Loc.tr("medal.gold") + " — " + (parent.parent.crit.gold.length ? parent.parent.crit.gold.map(c => Loc.tr(c.key, c.args)).join(", ") : Loc.tr("medal.criteria.none")) } }
                }
                Text { text: Loc.tr("briefing.difficulty"); color: fe.gold; font.pixelSize: 13; font.bold: true; topPadding: 6 }
                Row {
                    spacing: 8
                    Repeater {
                        model: Balance.difficultyOrder
                        Rectangle {
                            required property string modelData
                            width: 156; height: 56; radius: 5
                            color: fe.selectedDifficulty === modelData ? "#4a3620" : "#2b2418"
                            border.color: fe.selectedDifficulty === modelData ? fe.gold : fe.edge
                            Column {
                                anchors.centerIn: parent; spacing: 1
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: fe.difficultyName(parent.parent.modelData); color: fe.ink; font.pixelSize: 14 }
                                Small { anchors.horizontalCenter: parent.horizontalCenter; text: Loc.tr("difficulty." + parent.parent.modelData + ".note"); font.pixelSize: 10; width: 146; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; lineHeight: 1.05 }
                            }
                            MouseArea { anchors.fill: parent; onClicked: fe.selectedDifficulty = parent.modelData }
                        }
                    }
                }
                Small {
                    readonly property var best: (void fe.progressRev, fe.progress ? Campaign.bestFor(fe.progress, fe.selectedMission, fe.selectedDifficulty) : null)
                    visible: best !== null
                    text: best ? Loc.tr("briefing.best", { medal: fe.medalName(best.medal), time: Loc.fmtTime(best.time) }) : ""
                }
                Item { width: 1; height: 8 }
                Row {
                    spacing: 10
                    MenuButton { width: 220; primary: true; usable: parent.parent.parent.parent.m !== null; label: Loc.tr("briefing.start"); onClicked: fe.startMissionRequested(fe.selectedMission, fe.selectedDifficulty) }
                    MenuButton { width: 160; label: Loc.tr("common.back"); onClicked: fe.screen = Campaign.isCampaignMission(fe.selectedMission) ? "campaign" : "menu" }
                }
            }
        }
    }

    // ---- results ---------------------------------------------------------------------------------
    Item {
        anchors.fill: parent; visible: fe.screen === "results"
        readonly property var r: fe.lastResult
        Rectangle {
            anchors.centerIn: parent; width: 560; height: col.implicitHeight + 40; radius: 8; color: fe.panel; border.color: parent.r && parent.r.victory ? fe.gold : fe.red
            Column {
                id: col
                anchors { top: parent.top; topMargin: 20; horizontalCenter: parent.horizontalCenter }
                spacing: 8; width: 500
                readonly property var r: fe.lastResult
                Heading { text: col.r ? (col.r.victory ? Loc.tr("results.victory") : Loc.tr("results.defeat")) : ""; color: col.r && col.r.victory ? fe.gold : fe.red }
                Small { anchors.horizontalCenter: parent.horizontalCenter; text: col.r ? col.r.missionTitle + "  ·  " + fe.difficultyName(col.r.difficulty) : "" }
                Body { anchors.horizontalCenter: parent.horizontalCenter; horizontalAlignment: Text.AlignHCenter; width: 480; text: col.r ? Loc.trOr(col.r.outcomeText) : "" }
                Row {
                    visible: col.r && col.r.victory
                    anchors.horizontalCenter: parent.horizontalCenter; spacing: 10
                    MedalDot { medal: col.r ? col.r.medal : ""; width: 22; height: 22; radius: 11; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: col.r ? Loc.tr("results.medal", { medal: fe.medalName(col.r.medal) }) : ""; color: col.r ? fe.medalColor(col.r.medal) : fe.ink; font.pixelSize: 18; font.bold: true }
                }
                Item { width: 1; height: 4 }
                Grid {
                    columns: 2; columnSpacing: 30; rowSpacing: 4; anchors.horizontalCenter: parent.horizontalCenter
                    component Stat: Row { property string k: ""; property string v: ""; spacing: 8; width: 230
                        Small { text: k; width: 150 } Text { text: v; color: fe.ink; font.pixelSize: 12; font.bold: true } }
                    Stat { k: Loc.tr("results.time"); v: col.r ? Loc.fmtTime(col.r.time) : "" }
                    Stat { k: Loc.tr("results.iron_gathered"); v: col.r ? String(col.r.ironGathered) : "" }
                    Stat { k: Loc.tr("results.units_produced"); v: col.r ? String(col.r.unitsProduced) : "" }
                    Stat { k: Loc.tr("results.units_lost"); v: col.r ? String(col.r.unitsLost) : "" }
                    Stat { k: Loc.tr("results.enemies_defeated"); v: col.r ? String(col.r.unitsKilled) : "" }
                    Stat { k: Loc.tr("results.buildings_destroyed"); v: col.r ? String(col.r.buildingsDestroyed) : "" }
                    Stat { k: Loc.tr("results.optional"); v: col.r ? col.r.optionalComplete + " / " + col.r.optionalTotal : "" }
                    Stat { k: Loc.tr("results.previous_best"); v: col.r && col.r.previousBest ? fe.medalName(col.r.previousBest.medal) + " · " + Loc.fmtTime(col.r.previousBest.time) : Loc.tr("results.none") }
                }
                Small { visible: col.r && col.r.newlyUnlocked.length > 0; anchors.horizontalCenter: parent.horizontalCenter; color: fe.gold
                        text: col.r ? Loc.tr("results.unlocked", { mission: col.r.newlyUnlocked.map(id => fe.missionTitle(Campaign.info(id))).join(", ") }) : "" }
                Small { visible: col.r && col.r.survivalUnlocked; anchors.horizontalCenter: parent.horizontalCenter; color: fe.gold; text: Loc.tr("results.survival_unlocked") }
                Item { width: 1; height: 8 }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter; spacing: 10
                    MenuButton {
                        readonly property string next: (void fe.progressRev, fe.progress && col.r && col.r.victory && col.r.campaign ? Campaign.nextMission(fe.progress) : "")
                        visible: next !== ""; width: 160; primary: true; label: Loc.tr("results.next_mission")
                        onClicked: { fe.selectedMission = next; fe.screen = "briefing" }
                    }
                    MenuButton { width: 160; primary: !(col.r && col.r.victory); label: Loc.tr("results.replay"); onClicked: fe.restartRequested() }
                    MenuButton { width: 160; label: col.r && col.r.campaign ? Loc.tr("results.campaign_map") : Loc.tr("results.main_menu")
                                 onClicked: fe.quitToMenuRequested() }
                }
            }
        }
    }

    // ---- settings (persisted independently from progress) ------------------------------------------
    Item {
        anchors.fill: parent; visible: fe.screen === "settings"
        Column {
            anchors.centerIn: parent; spacing: 10; width: 320
            Heading { text: Loc.tr("settings.title") }
            Item { width: 1; height: 8 }
            Text { text: Loc.tr("settings.language"); color: fe.gold; font.pixelSize: 13; font.bold: true }
            Row {
                spacing: 8
                Repeater {
                    model: Loc.languages
                    MenuButton {
                        required property var modelData
                        width: 156; label: modelData.name; primary: Loc.language === modelData.code
                        onClicked: { Loc.setLanguage(modelData.code); fe.settings.language = modelData.code; fe.settingsEdited() }
                    }
                }
            }
            Text { text: Loc.tr("settings.audio"); color: fe.gold; font.pixelSize: 13; font.bold: true; topPadding: 8 }
            Slider { label: Loc.tr("settings.master"); value: fe.settings ? fe.settings.audio.master : 1; onMoved: (v) => { fe.settings.audio.master = v; fe.settingsEdited() } }
            Slider { label: Loc.tr("settings.music"); value: fe.settings ? fe.settings.audio.music : 0.35; onMoved: (v) => { fe.settings.audio.music = v; fe.settingsEdited() } }
            Slider { label: Loc.tr("settings.effects"); value: fe.settings ? fe.settings.audio.effects : 0.8; onMoved: (v) => { fe.settings.audio.effects = v; fe.settingsEdited() } }
            Text { text: Loc.tr("settings.controls"); color: fe.gold; font.pixelSize: 13; font.bold: true; topPadding: 8 }
            Toggle { label: Loc.tr("settings.camera_shake"); checked: fe.settings ? fe.settings.controls.cameraShake : true; onToggled: (v) => { fe.settings.controls.cameraShake = v; fe.settingsEdited() } }
            Toggle { label: Loc.tr("settings.high_contrast"); checked: fe.settings ? fe.settings.accessibility.highContrastSelection : false; onToggled: (v) => { fe.settings.accessibility.highContrastSelection = v; fe.settingsEdited() } }
            Small { width: 320; text: Loc.tr("settings.more_later") }
            Item { width: 1; height: 8 }
            MenuButton { label: Loc.tr("common.back"); primary: true; onClicked: fe.screen = fe.game && fe.game.phase === "paused" ? "paused" : "menu" }
        }
    }

    // ---- credits ----------------------------------------------------------------------------------
    Item {
        anchors.fill: parent; visible: fe.screen === "credits"
        Column {
            anchors.centerIn: parent; spacing: 14
            Heading { text: Loc.tr("menu.credits") }
            Text {
                width: Math.min(fe.width - 60, 720); wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
                color: fe.ink; font.pixelSize: 14; lineHeight: 1.3
                text: Loc.tr("credits.body")
            }
            MenuButton { anchors.horizontalCenter: parent.horizontalCenter; label: Loc.tr("common.back"); primary: true; onClicked: fe.screen = "menu" }
        }
    }

    // ---- pause -----------------------------------------------------------------------------------
    Item {
        anchors.fill: parent; visible: fe.screen === "paused"
        Column {
            anchors.centerIn: parent; spacing: 8; width: 320
            Heading { text: Loc.tr("pause.title"); font.pixelSize: 48 }
            Item { width: 1; height: 10 }
            MenuButton { label: Loc.tr("pause.resume"); primary: true; onClicked: fe.resumeRequested() }
            MenuButton { label: Loc.tr("pause.restart"); onClicked: fe.restartRequested() }
            MenuButton { label: Loc.tr("menu.settings"); onClicked: fe.screen = "settings" }
            MenuButton { label: Loc.tr("pause.quit"); onClicked: fe.quitToMenuRequested() }
        }
    }
}
