// Ironfang: First Siege - game root (an Item, so it runs both inside the desktop Window
// and when loaded by the Clayground Web Runtime from static files).
// Composition: GameWorld (3D scene) + entities (UnitView/BuildingView/Projectile, created
// imperatively) + JS rule modules (Economy, Production, Combat, Gather, EnemyAI, NavGrid,
// Steering) + Hud + Frontend (menus, briefing, results). A fixed 30 Hz simulation step drives all rules; rendering is
// frame-driven.
import QtQuick
import QtQuick3D
import Clayground.Canvas3D
import Clayground.Algorithm
import "scripts/NavGrid.js" as Nav
import "scripts/Steering.js" as Steer
import "scripts/Economy.js" as Economy
import "scripts/Production.js" as Production
import "scripts/Combat.js" as Combat
import "scripts/Gather.js" as Gather
import "scripts/EnemyAI.js" as EnemyAI
import "scripts/Touch.js" as Touch
import "config/assets.js" as Assets
import "config/balance.js" as Balance
import "scripts/Mission.js" as Mission
import "scripts/Objectives.js" as Objectives
import "scripts/Triggers.js" as Triggers
import "missions/classic_siege.js" as ClassicSiege
import "scripts/Save.js" as Save
import "scripts/Campaign.js" as Campaign

Item {
    id: game
    focus: true

    // ---- configuration ---------------------------------------------------------------------
    property real mapSize: 64                   // set from mission.map.size in startMatch
    readonly property real navCell: 1.0
    readonly property real simStep: Balance.match.simStep
    property int simSpeed: 1                    // debug: steps per step (keys [ ])
    property bool useModels: Qt.application.arguments.indexOf("--no-models") < 0
    // Model files: qrc:/ (relative) on desktop; on WebAssembly they are preloaded into the
    // in-memory filesystem under /game/ (own build: Qt loader `preload`; Clayground Web Runtime:
    // its app shell + assets-manifest.json).
    property string assetBase: Qt.platform.os === "wasm" ? "file:///game/" : ""
    property string difficulty: Balance.defaultDifficulty

    // ---- mission ---------------------------------------------------------------------------
    // The match is built from a declarative mission definition (docs/mission-format.md).
    // Objectives and triggers drive victory/defeat and the HUD; the controller only feeds events.
    property var missionDef: ClassicSiege.mission     // definition to load (title screen default)
    property string currentMissionId: "classic_siege" // campaign/scenario id of the running match
    property var mission: null                        // Mission.load() result of the running match
    property var objectives: null                     // Objectives.create() state
    property var triggers: null                       // Triggers.create() state
    property string objectiveText: ""                 // HUD: active primary objective line
    property var objectiveRows: []                    // HUD: visible objectives (plain rows)
    property int _objRev: -1

    // ---- match state -----------------------------------------------------------------------
    property string phase: "title"              // title | playing | paused | victory | defeat | showcase | credits
    property real matchTime: 0
    property int tick: 0                        // bumps every sim step; HUD bindings depend on it
    property var economy: Economy.create(0)
    property real iron: 0
    property var enemyAI: null
    property var units: []
    property var buildings: []
    property var projectiles: []
    property var selection: []
    property var hoveredEntity: null
    property var playerFortress: null
    property var playerFoundry: null
    property var enemyFortress: null
    property int nextEntityId: 1
    property string message: ""
    property real fps: 0
    property int unitsLost: 0
    property int unitsKilled: 0
    property int unitsProduced: 0
    property int buildingsLost: 0
    property int buildingsDestroyed: 0

    // ---- persistence (docs/save-format.md) ----------------------------------------------------
    property var progress: Save.emptyProgress()
    property var settings: Save.emptySettings()
    property var lastResult: null
    Storage { id: storage }
    function loadSaves() {
        const p = Save.parse(storage.read("progress"), "progress")
        if (!p.ok) console.warn("progress save unreadable (" + p.error + "), starting fresh")
        progress = p.data
        console.log("save: progress " + (p.empty ? "empty (new player)" : "loaded, last mission " + p.data.campaign.lastMission) + (storage.usingAdapter ? " via shell adapter" : ""))
        const st = Save.parse(storage.read("settings"), "settings")
        if (!st.ok) console.warn("settings unreadable (" + st.error + "), using defaults")
        settings = st.data
        if (p.migrated) saveProgress()
        if (st.migrated) saveSettings()
        frontend.progressRev++
    }
    function saveProgress() { if (!storage.write("progress", Save.serialize(progress))) console.warn("saving progress failed:", storage.lastError); frontend.progressRev++ }
    function saveSettings() { if (!storage.write("settings", Save.serialize(settings))) console.warn("saving settings failed:", storage.lastError) }
    function applySettings() {
        if (settings.language && Loc.tables[settings.language]) Loc.setLanguage(settings.language)
        else if (Qt.locale().name.indexOf("pt") === 0) Loc.setLanguage("pt_BR")
        const a = settings.audio
        audio.sfxVolume = a.master * a.effects
        audio.musicVolume = a.master * a.music
        audio.soundOn = audio.platformSupported && a.master > 0 && Qt.application.arguments.indexOf("--mute") < 0 && !autotest
    }
    function resetProgress() { Campaign.resetProgress(progress); saveProgress() }

    // ---- startup ---------------------------------------------------------------------------
    Component.onCompleted: {
        loadSaves()
        applySettings()
        if (autotest) startMission("classic_siege", Balance.defaultDifficulty)
        else if (Qt.application.arguments.indexOf("--showcase") >= 0) phase = "showcase"
    }

    // ---- campaign flow -------------------------------------------------------------------------
    function startMission(id, diff) {
        const info = Campaign.info(id)
        if (!info || !info.definition) { console.warn("mission not available:", id); return }
        currentMissionId = id
        startMatch(diff, info.definition)
    }
    function quitToMenu() {
        clearWorld()
        phase = "title"
        frontend.screen = Campaign.isCampaignMission(currentMissionId) ? "campaign" : "menu"
    }
    Timer {   // --showcase: screenshot the showcase after the model loaded, then quit (desktop)
        running: Qt.application.arguments.indexOf("--showcase") >= 0 && game.phase === "showcase"
        interval: 4000; repeat: false
        onTriggered: { game.screenshot("showcase"); if (Qt.platform.os !== "wasm") Qt.callLater(function() { quitTimer.start() }) }
    }
    Timer { id: quitTimer; interval: 800; onTriggered: Qt.quit() }

    function startMatch(diff, def) {
        difficulty = diff || Balance.defaultDifficulty
        if (def) missionDef = def
        mission = Mission.load(missionDef, difficulty)
        clearWorld()
        mapSize = mission.map.size
        Nav.init(mapSize, mapSize, navCell)
        pathfinder.columns = Nav.cols
        pathfinder.rows = Nav.rows
        economy = Economy.create(mission.player.iron)
        iron = economy.iron
        matchTime = 0
        tick = 0
        unitsLost = 0; unitsKilled = 0; unitsProduced = 0; buildingsLost = 0; buildingsDestroyed = 0
        message = ""
        objectives = Objectives.create(mission.objectives)
        triggers = Triggers.create(mission.triggers)
        _objRev = -1
        buildLevel()
        pathfinder.walkableData = Nav.walkableData()
        enemyCfg = mission.enemy ? Mission.enemyConfig(mission) : null
        enemyAI = enemyCfg ? EnemyAI.create(enemyCfg, difficulty) : null
        const cam = mission.map.camera
        world.rig.applyState({ px: cam.x, py: 0, pz: cam.z, yaw: cam.yaw, pitch: cam.pitch, distance: cam.distance })
        phase = "playing"
        audio.startMusic()
        refreshObjectives()
        gameEvent("missionStarted", { id: mission.id })
    }
    onPhaseChanged: {
        if (phase === "paused") audio.pauseMusic()
        else if (phase === "playing") audio.resumeMusic()
        else if (phase !== "victory" && phase !== "defeat") audio.stopMusic()
        if (phase === "playing" || phase === "showcase") frontend.screen = ""
        else if (phase === "paused") frontend.screen = "paused"
        else if (phase === "victory" || phase === "defeat") frontend.screen = "results"
        else if (phase === "title" && frontend.screen === "") frontend.screen = "menu"
    }

    function restartMatch() { startMatch(difficulty) }

    function clearWorld() {
        for (const p of projectiles) p.destroy()
        for (const u of units) u.destroy()
        for (const b of buildings) b.destroy()
        projectiles = []; units = []; buildings = []
        selection = []; hoveredEntity = null
        playerFortress = null; playerFoundry = null; enemyFortress = null
    }

    // Instantiates the mission's entity list. Buildings first (they block navigation cells),
    // then units. Reserved tags player_fortress / player_foundry / enemy_fortress fill the
    // convenience properties the HUD, autotest and keyboard shortcuts use.
    function buildLevel() {
        for (const e of mission.entities) {
            if (e.kind !== "building") continue
            const b = spawnBuilding(e.type, e.team, e.x, e.z, e)
            if (e.tag === "player_fortress") playerFortress = b
            else if (e.tag === "player_foundry") playerFoundry = b
            else if (e.tag === "enemy_fortress") enemyFortress = b
        }
        for (const e of mission.entities) if (e.kind === "unit") spawnUnit(e.type, e.team, e.x, e.z, e)
        if (!playerFortress) playerFortress = buildings.find(b => b.team === "player" && b.stats.dropOff) || null
    }

    function entityByTag(tag) {
        if (!tag) return null
        for (const b of buildings) if (b.tag === tag) return b
        for (const u of units) if (u.tag === tag) return u
        return null
    }

    // ---- entities --------------------------------------------------------------------------
    Component {
        id: unitComp
        UnitView { camYaw: world.rig.yaw; camPitch: world.rig.pitch; useModel: game.useModels; assetBase: game.assetBase }
    }
    Component {
        id: buildingComp
        BuildingView { camYaw: world.rig.yaw; camPitch: world.rig.pitch; useModel: game.useModels; assetBase: game.assetBase }
    }
    Component {
        id: projectileComp
        Projectile { assetBase: game.assetBase; typeDef: Assets.projectiles.arrow }
    }

    function spawnUnit(typeId, team, x, z, def) {
        const u = unitComp.createObject(world.unitRoot, {
            entityId: nextEntityId++, typeId: typeId, team: team, tag: (def && def.tag) || "",
            typeDef: Assets.unit(typeId), stats: unitStatsFor(typeId, team),
            x: x, z: z, heading: team === "enemy" ? 200 : 20
        })
        u.moveRequested.connect(onMoveRequested)
        const list = units.slice(); list.push(u); units = list
        return u
    }

    // Enemy units carry the difficulty's hp/damage scale (Story softer, Warchief harder).
    function unitStatsFor(typeId, team) {
        const base = Balance.units[typeId] || {}
        if (team !== "enemy" || !mission) return base
        const d = mission.difficultyValues
        if (d.enemyHpScale === 1 && d.enemyDamageScale === 1) return base
        const out = Object.assign({}, base)
        out.hp = Math.round(base.hp * d.enemyHpScale); out.damage = Math.round(base.damage * d.enemyDamageScale * 10) / 10
        return out
    }

    function spawnBuilding(typeId, team, x, z, def) {
        const stats = Balance.buildings[typeId] || {}
        const b = buildingComp.createObject(world.buildingRoot, {
            entityId: nextEntityId++, typeId: typeId, team: team, tag: (def && def.tag) || "",
            typeDef: Assets.building(typeId) || {}, stats: stats,
            x: x, z: z, hp: stats.hp || 0, maxHp: stats.hp || 0,
            iron: def && def.iron !== undefined ? def.iron : (stats.iron || 0),
            rally: def && def.rally ? { x: def.rally.x, z: def.rally.z } : null,
            queue: (stats.produces && stats.produces.length) || typeId === "enemy_fortress" ? Production.createQueue(5) : null
        })
        if (stats.footprint) Nav.blockRect(x - stats.footprint.w / 2, z - stats.footprint.d / 2,
                                           x + stats.footprint.w / 2, z + stats.footprint.d / 2)
        const list = buildings.slice(); list.push(b); buildings = list
        return b
    }

    function onMoveRequested(unit, point) {
        if (!point) { unit.moveAlong([]); return }
        unit.moveAlong(Nav.findPath(pathfinder, unit.x, unit.z, point.x, point.z))
    }

    function removeEntity(e) {
        if (e.isUnit) { units = units.filter(u => u !== e) }
        else { buildings = buildings.filter(b => b !== e) }
        if (selection.indexOf(e) >= 0) setSelection(selection.filter(s => s !== e))
        if (hoveredEntity === e) hoveredEntity = null
        for (const u of units) if (u.target === e) { u.target = null; if (u.order === "attack") u.order = "idle" }
        e.destroy()
    }

    // ---- helpers for the HUD ---------------------------------------------------------------
    function unitName(t) { return Loc.has("unit." + t) ? Loc.tr("unit." + t) : (Balance.units[t] ? Balance.units[t].name : t) }
    function entityName(e) {
        if (!e) return ""
        const key = (e.isUnit ? "unit." : "building.") + e.typeId
        return Loc.has(key) ? Loc.tr(key) : (e.typeDef && e.typeDef.displayName) || e.typeId
    }
    function unitCost(t) { return Balance.units[t] ? Balance.units[t].cost : 0 }
    function unitBuildTime(t) { return Balance.units[t] ? Balance.units[t].buildTime : 0 }
    function queueProgress(b) { void tick; return b && b.queue ? Production.headProgress(b.queue) : 0 }
    function queueLength(b) { void tick; return b && b.queue ? b.queue.items.length : 0 }

    // ---- selection & picking -----------------------------------------------------------------
    function entityOf(obj) {
        let o = obj
        for (let guard = 0; o && guard < 12; ++guard) {
            if (o.isUnit === true || o.isBuilding === true) return o
            o = o.parent
        }
        return null
    }

    function entityAtScreen(sx, sy) {
        const p = nav.pickAt(sx, sy)
        if (p && p.object) {
            const hit = entityOf(p.object)
            if (hit && (hit.isUnit ? hit.alive : true)) return hit
        }
        // screen-space capsule fallback for units (placeholders, gaps between limbs)
        let best = null, bestD = 1e9
        for (const u of units) {
            if (!u.alive) continue
            const feet = world.mapFrom3DScene(u.scenePosition)
            const head = world.mapFrom3DScene(Qt.vector3d(u.scenePosition.x, u.scenePosition.y + u.bodyHeight, u.scenePosition.z))
            const halfW = Math.max(8, Math.abs(feet.y - head.y) * 0.28)
            const cx = (feet.x + head.x) / 2
            const top = Math.min(feet.y, head.y) - 4, bottom = Math.max(feet.y, head.y) + 4
            if (Math.abs(sx - cx) <= halfW && sy >= top && sy <= bottom) {
                const d = Math.abs(sx - cx) + Math.abs(sy - (top + bottom) / 2) * 0.2
                if (d < bestD) { bestD = d; best = u }
            }
        }
        return best
    }

    function setSelection(list) {
        for (const e of selection) e.selected = false
        selection = list
        for (const e of selection) e.selected = true
        if (list.length) audio.play("select", 0.6)
        if (list.length === 1 && triggers) gameEvent("entitySelected", { tag: list[0].tag, entityType: list[0].typeId, team: list[0].team })
    }

    function selectAt(sx, sy, additive) {
        const e = entityAtScreen(sx, sy)
        if (!additive) { setSelection(e ? [e] : []); return }
        if (!e) return
        const idx = selection.indexOf(e)
        const list = selection.slice()
        if (idx >= 0) list.splice(idx, 1); else if (!e.isBuilding) list.push(e)
        setSelection(list)
    }

    function selectInRect(x0, y0, x1, y1, additive) {
        const left = Math.min(x0, x1), right = Math.max(x0, x1)
        const top = Math.min(y0, y1), bottom = Math.max(y0, y1)
        const list = additive ? selection.filter(e => e.isUnit) : []
        for (const u of units) {
            if (!u.alive || u.team !== "player") continue
            const s = world.mapFrom3DScene(Qt.vector3d(u.scenePosition.x, u.scenePosition.y + 0.9, u.scenePosition.z))
            if (s.x >= left && s.x <= right && s.y >= top && s.y <= bottom && list.indexOf(u) < 0) list.push(u)
        }
        if (list.length === 0 && !additive) { selectAt(x1, y1, false); return }
        setSelection(list)
    }

    function updateHover(sx, sy) {
        const e = entityAtScreen(sx, sy)
        if (hoveredEntity === e) return
        if (hoveredEntity) hoveredEntity.hovered = false
        hoveredEntity = e
        if (e) e.hovered = true
    }

    readonly property var selectedPlayerUnits: selection.filter(e => e.isUnit && e.team === "player" && e.alive)

    // ---- touch ----------------------------------------------------------------------------
    // Set when the first touch-synthesized press arrives (or on phone/tablet platforms):
    // taps become "smart taps", the HUD grows touch buttons. Mouse users are unaffected.
    property bool touchMode: Qt.platform.os === "android" || Qt.platform.os === "ios"

    // A single tap on the world: select own things, otherwise do the obvious order.
    function smartTap(sx, sy) {
        const tapped = entityAtScreen(sx, sy)
        const info = {
            units: selectedPlayerUnits.length,
            producer: selectedProducer,
            soleUnit: selection.length === 1 && selection[0].isUnit && selection[0].team === "player" ? selection[0] : null
        }
        const d = Touch.decide(tapped, info, nav.groundAt(sx, sy) !== null)
        switch (d.action) {
        case "select":   setSelection([d.entity]); break
        case "deselect": setSelection([]); break
        case "order":    issueOrder(sx, sy); break
        case "rally":    setRally(selectedProducer, tapped, nav.groundAt(sx, sy)); break
        default: break
        }
    }

    function selectArmy() {
        setSelection(units.filter(u => u.alive && u.team === "player" && u.typeId !== "goblin_worker"))
        if (selection.length === 0) flash("no army yet - produce warriors at the War Foundry")
    }
    function selectWorkers() {
        setSelection(units.filter(u => u.alive && u.team === "player" && u.typeId === "goblin_worker"))
    }

    // ---- commands ----------------------------------------------------------------------------
    readonly property var selectedProducer: {
        for (const e of selection) if (e.isBuilding && e.team === "player" && e.queue) return e
        return null
    }

    function issueOrder(sx, sy) {
        const target = entityAtScreen(sx, sy)
        const g = nav.groundAt(sx, sy)
        const mine = selectedPlayerUnits
        if (mine.length === 0) {
            if (selectedProducer) setRally(selectedProducer, target, g)
            return
        }
        if (target && target.team === "enemy") { orderAttack(mine, target); return }
        if (target && target.isBuilding && target.stats.resource) { orderGather(mine, target, g); return }
        if (target && target.isBuilding && target.team === "player" && target.stats.dropOff) { orderReturn(mine, g); return }
        if (g) orderMove(mine, g)
    }

    // Rally point of a producer: where finished units go. A deposit as target means new
    // workers start gathering there (or at the next deposit once it is depleted).
    function setRally(b, target, g) {
        if (target && target.isBuilding && target.stats.resource) {
            b.rallyTarget = target
            b.rally = Combat.approachPoint(b, target, 1.0)
            flash(b.typeDef.displayName + ": new " + (b.typeId === "clan_fortress" ? "workers gather at this deposit" : "units rally at the deposit"))
        } else if (target === b) {
            b.rallyTarget = null; b.rally = null
            flash(b.typeDef.displayName + ": rally point cleared")
        } else if (g) {
            b.rallyTarget = null
            b.rally = { x: Math.max(1, Math.min(mapSize - 1, g.x)), z: Math.max(1, Math.min(mapSize - 1, g.z)) }
            flash(b.typeDef.displayName + ": rally point set")
        } else return
        b.rallyRev++
        world.moveMarker.showAt(b.rally ? b.rally.x : b.x, b.rally ? b.rally.z : b.z, "#e0b24a")
        audio.play("move")
    }

    function orderMove(list, g) {
        const dests = Nav.distribute(g.x, g.z, list.length, 1.5)
        let unreachable = 0
        for (let i = 0; i < list.length; ++i) {
            const u = list[i]
            Gather.stop(u); u.target = null; u.order = "move"; u.orderPoint = dests[i]
            const path = Nav.findPath(pathfinder, u.x, u.z, dests[i].x, dests[i].z)
            if (path.length === 0) { unreachable++; u.order = "idle"; continue }
            u.moveAlong(path)
        }
        world.moveMarker.showAt(g.x, g.z, unreachable === 0 ? "#e0b24a" : "#c9432e")
        if (unreachable) { flash(unreachable + " unit(s): destination unreachable"); audio.play("invalid") }
        else audio.play("move")
    }

    function orderAttack(list, target) {
        for (const u of list) {
            Gather.stop(u)
            u.order = "attack"; u.target = target; u.chaseOrigin = null; u.repathTimer = 0
            u.moveTo(Combat.approachPoint(u, target, attackStandoff(u)))
        }
        world.moveMarker.showAt(target.x, target.z, "#c9432e")
        target.hitFlash = Math.max(target.hitFlash, 0.5)
        audio.play("attack_order")
    }

    function orderGather(list, node, g) {
        let workers = 0
        for (const u of list) {
            if (u.typeId !== "goblin_worker") { if (g) { u.order = "move"; u.target = null; u.moveTo(Nav.distribute(g.x, g.z, 1, 1)[0]) }; continue }
            u.order = "gather"; u.target = null
            Gather.start(u, node)
            workers++
        }
        world.moveMarker.showAt(node.x, node.z, "#9ab0c0")
        if (workers === 0) { flash("only goblin workers can gather iron"); audio.play("invalid") }
        else audio.play("move")
    }

    function orderReturn(list, g) {
        let returning = 0
        for (const u of list) {
            if (u.typeId === "goblin_worker" && Gather.returnHome(u)) { u.order = "gather"; returning++ }
            else if (g) { Gather.stop(u); u.order = "move"; u.target = null; u.moveTo(g) }
        }
        if (returning) flash(returning + " worker(s) returning iron")
    }

    function orderStop(list) {
        for (const u of list) { Gather.stop(u); u.target = null; u.order = "idle"; u.stop(); u.play("Idle") }
    }

    function produce(building, typeId) {
        if (!building || !building.queue) return
        if (!building.productionEnabled) { flash(building.typeDef.displayName + " is not operational yet"); audio.play("invalid"); return }
        const r = Production.enqueue(building.queue, building.typeId, typeId, economy)
        iron = economy.iron
        if (!r.ok) { flash(r.reason); audio.play("invalid") } else audio.play("select", 0.5)
        tick++
    }

    function cancelProduction(building) {
        if (!building || !building.queue) return
        Production.cancelLast(building.queue, economy)
        iron = economy.iron
        tick++
    }

    function attackStandoff(u) {
        const s = u.stats
        return s.range > 0 ? (s.preferredRange || s.range * 0.8) : Balance.meleeReach * 0.6
    }

    function flash(text) { message = text; messageTimer.restart() }
    Timer { id: messageTimer; interval: 2600; onTriggered: game.message = "" }

    // ---- simulation --------------------------------------------------------------------------
    property real _acc: 0
    property int _frames: 0
    property real _fpsClock: 0
    property real stepMs: 0
    property real frameMs: 0

    FrameAnimation {
        running: game.phase === "playing"
        onTriggered: {
            const dt = Math.min(frameTime, 0.25)
            game._acc += dt
            let guard = 0
            while (game._acc >= game.simStep && guard++ < 8) {
                const t0 = Date.now()
                for (let s = 0; s < game.simSpeed; ++s) game.step(game.simStep)
                game.stepMs = game.stepMs * 0.9 + (Date.now() - t0) * 0.1
                game._acc -= game.simStep
            }
            if (guard >= 8) game._acc = 0
            game.frameMs = game.frameMs * 0.9 + dt * 1000 * 0.1
            world.rig.tickKeyboard(dt)
            game._frames++; game._fpsClock += dt
            if (game._fpsClock >= 0.5) { game.fps = game._frames / game._fpsClock; game._frames = 0; game._fpsClock = 0 }
        }
    }
    FrameAnimation {   // camera keys keep working while paused / in menus
        running: game.phase !== "playing" && game.phase !== "title"
        onTriggered: world.rig.tickKeyboard(Math.min(frameTime, 0.1))
    }

    function step(dt) {
        matchTime += dt
        tick++
        Steer.step(units, dt)
        stepWorkers(dt)
        stepCombat(dt)
        stepProduction(dt)
        stepEnemy(dt)
        stepProjectiles(dt)
        stepDeaths(dt)
        for (const e of units) if (e.hitFlash > 0) e.hitFlash = Math.max(0, e.hitFlash - dt * 3)
        for (const e of buildings) if (e.hitFlash > 0) e.hitFlash = Math.max(0, e.hitFlash - dt * 3)
        iron = economy.iron
        stepMission(dt)
    }

    // ---- mission logic: events -> triggers -> actions; objectives -> victory --------------------
    readonly property var missionQuery: ({
        entityByTag: (tag) => game.entityByTag(tag),
        countUnits: (team, type) => game.units.filter(u => u.alive && u.team === team && (!type || u.typeId === type)).length,
        units: (team, type) => game.units.filter(u => u.alive && (!team || u.team === team) && (!type || u.typeId === type)),
        iron: () => game.economy.iron
    })
    readonly property var triggerContext: ({
        query: missionQuery,
        objectiveComplete: (id) => { const o = game.objectives && Objectives.get(game.objectives, id); return !!o && o.state === "complete" },
        actions: {
            message:           (a) => flash(Loc.trOr(a.text)),
            showDialogue:      (a) => flash((a.speaker ? Loc.trOr(a.speaker) + ": " : "") + Loc.trOr(a.text)),   // portrait dialogue arrives in M5
            playAudio:         (a) => audio.play(a.sound, a.volume === undefined ? 1 : a.volume),
            completeObjective: (a) => Objectives.complete(objectives, a.id, matchTime),
            failObjective:     (a) => Objectives.fail(objectives, a.id, matchTime),
            addObjective:      (a) => Objectives.add(objectives, a),
            progressObjective: (a) => Objectives.setProgress(objectives, a.id, a.current, a.target, matchTime),
            addResources:      (a) => { Economy.deposit(economy, a.amount); iron = economy.iron },
            spawnUnits:        (a) => spawnGroup(a),
            startWave:         (a) => { if (enemyAI) enemyAI.nextWaveAt = matchTime },
            endMission:        (a) => endMatch(a.result),
            revealArea:        (a) => {},                       // no fog of war yet (documented no-op)
            enableProduction:  (a) => setProductionEnabled(a.tag, a.enabled !== false),
            unlockAbility:     (a) => console.log("unlockAbility: abilities arrive in milestone 4"),
            activateCheckpoint:(a) => console.log("activateCheckpoint: checkpoints arrive in milestone 5")
        }
    })

    function gameEvent(type, payload) {
        if (!triggers) return
        const ev = Object.assign({ type: type, time: matchTime }, payload || {})
        Triggers.handle(triggers, ev, triggerContext)
        pumpObjectiveEvents()
    }

    // objective state changes are game events too (triggers can chain on them)
    function pumpObjectiveEvents() {
        if (!objectives) return
        let guard = 0
        while (objectives.events.length && guard++ < 20) {
            const evs = Objectives.drain(objectives)
            for (const e of evs) if (e.type === "objectiveCompleted" || e.type === "objectiveFailed") Triggers.handle(triggers, Object.assign({ time: matchTime }, e), triggerContext)
        }
    }

    function stepMission(dt) {
        if (!triggers || !objectives) return
        Triggers.step(triggers, dt, triggerContext)
        Objectives.step(objectives, missionQuery, matchTime)
        pumpObjectiveEvents()
        if (objectives.rev !== _objRev) refreshObjectives()
        if (phase === "playing" && mission.victory.auto && Objectives.allPrimaryComplete(objectives)) endMatch("victory")
        else if (phase === "playing" && Objectives.anyPrimaryFailed(objectives)) endMatch("defeat")
    }

    function refreshObjectives() {
        _objRev = objectives.rev
        objectiveText = Objectives.primaryText(objectives, (k) => Loc.trOr(k))
        objectiveRows = Objectives.visible(objectives).map(o => ({ id: o.id, text: o.text, state: o.state, optional: o.optional,
                                                                   current: o.current, target: o.target, showCount: !!(o.target > 0 && !(o.progress && o.progress.type === "entityHp")) }))
    }

    function spawnGroup(a) {
        const target = entityByTag(a.attack)
        for (const s of a.units) {
            const u = spawnUnit(s.type, s.team || a.team || "enemy", s.x !== undefined ? s.x : a.x, s.z !== undefined ? s.z : a.z, s)
            if (target && u.team !== target.team) { u.inWave = u.team === "enemy"; u.order = "attackMove"; u.primaryTarget = target; u.target = target; u.repathTimer = 0 }
        }
    }

    function setProductionEnabled(tag, on) {
        const b = entityByTag(tag)
        if (b && b.isBuilding) b.productionEnabled = on
    }

    // workers
    readonly property var gatherCtx: ({
        stats: Balance.units.goblin_worker,
        gap: Combat.gap,
        approach: (w, node) => Combat.approachPoint(w, node, 0.25),
        findDropOff: (w) => game.playerFortress && game.playerFortress.alive ? game.playerFortress : null,
        findDeposit: (w) => game.nearestDeposit(w),
        deposit: (w, amount) => { Economy.deposit(game.economy, amount); game.iron = game.economy.iron; audio.play("deposit", 0.7) }
    })
    function nearestDeposit(w) {
        let best = null, bestD = 1e9
        for (const b of buildings) {
            if (!b.stats.resource || b.iron <= 0) continue
            const d = Combat.gap(w, b)
            if (d < bestD) { bestD = d; best = b }
        }
        return best
    }
    function stepWorkers(dt) {
        for (const u of units) {
            if (!u.alive || u.typeId !== "goblin_worker" || u.team !== "player") continue
            if (Gather.isActive(u)) Gather.step(u, dt, gatherCtx)
            if (u.gatherState === "gathering" && u.prevGatherState !== "gathering") audio.play("gather", 0.5)
            u.prevGatherState = u.gatherState
        }
    }

    // combat
    function hostilesFor(u) {
        const out = []
        for (const o of units) if (o.alive && o.team !== u.team) out.push(o)
        for (const b of buildings) if (b.alive && b.team !== "neutral" && b.team !== u.team && !b.untargetable) out.push(b)
        return out
    }
    property real _aggroClock: 0
    function stepCombat(dt) {
        _aggroClock += dt
        const doAggro = _aggroClock >= 0.4
        if (doAggro) _aggroClock = 0
        for (const u of units) {
            if (!u.alive) continue
            if (u.cooldown > 0) u.cooldown -= dt
            // drop dead / invalid targets
            if (u.target && !Combat.isValidTarget(u.target)) {
                u.target = null
                if (u.order === "attack") { u.order = "idle"; u.stop() }
                if (u.order === "attackMove" && u.primaryTarget && Combat.isValidTarget(u.primaryTarget)) u.target = u.primaryTarget
            }
            // auto-acquire (not workers, not while moving on a plain move order)
            const canAuto = u.typeId !== "goblin_worker" && (u.order === "idle" || u.order === "attackMove")
            if (doAggro && canAuto) {
                const near = Combat.acquireTarget(u, hostilesFor(u), Balance.match.aggroRadius)
                if (near && near !== u.target && !(near.isBuilding && u.order === "attackMove" && u.target && !u.target.isBuilding)) {
                    if (u.order === "idle") { u.order = "attack"; u.chaseOrigin = { x: u.x, z: u.z }; u.autoAcquired = true }
                    u.target = near; u.repathTimer = 0
                }
            }
            if (!u.target) continue
            const stats = u.stats
            if (Combat.inRange(u, stats, u.target)) {
                if (u.path.length) u.stop()
                u.lookAt(u.target)
                if (u.cooldown <= 0) {
                    u.cooldown = stats.cooldown
                    u.play("Attack")
                    if (stats.range > 0) { fireProjectile(u, u.target); audio.play("arrow_shot", 0.6) }
                    else { dealDamage(u, u.target, Combat.damageFor(stats, u.target)); audio.play(u.typeId === "ironhide_ogre" ? "ogre_hit" : "melee_hit", 0.7) }
                }
            } else {
                u.repathTimer -= dt
                if (u.repathTimer <= 0 || u.path.length === 0) {
                    u.repathTimer = Balance.match.repathInterval
                    u.moveTo(Combat.approachPoint(u, u.target, attackStandoff(u)))
                }
                if (u.autoAcquired && u.chaseOrigin && Combat.dist(u, u.chaseOrigin) > Balance.match.leashRadius) {
                    u.target = null; u.order = "idle"; u.autoAcquired = false
                    u.moveTo(u.chaseOrigin)
                }
            }
        }
    }

    function dealDamage(attacker, target, amount) {
        if (!target || !target.alive) return
        const killed = Combat.applyDamage(target, amount)
        target.hitFlash = 1
        if (target.isUnit && target.clip !== "Attack" && !killed) target.play("Hit")
        if (killed) onKilled(target, attacker)
    }

    function onKilled(target, attacker) {
        if (target.isUnit) {
            target.die()
            audio.play("death", 0.7)
            if (target.team === "player") unitsLost++; else unitsKilled++
            if (selection.indexOf(target) >= 0) setSelection(selection.filter(s => s !== target))
        } else {
            target.hitFlash = 1
            audio.play("building_destroyed")
            if (target.team === "player") { buildingsLost++; flash(target.typeDef.displayName + " destroyed!") }
            else { buildingsDestroyed++; flash("Enemy " + target.typeDef.displayName + " destroyed!") }
        }
        gameEvent("entityDestroyed", { tag: target.tag, entityType: target.typeId, team: target.team, isUnit: target.isUnit === true,
                                       byTeam: attacker ? attacker.team : "", byType: attacker ? attacker.typeId : "" })
    }

    function fireProjectile(shooter, target) {
        const p = projectileComp.createObject(world.projectileRoot, {
            x: shooter.x, z: shooter.z, y_: 1.4, target: target, shooter: shooter,
            damage: Combat.damageFor(shooter.stats, target), speed: shooter.stats.projectileSpeed || 20
        })
        p.aim = Qt.vector3d(target.x, 1.0, target.z)
        p.hit.connect((t, dmg, s) => { game.dealDamage(s, t, dmg); audio.play("arrow_hit", 0.5) })
        const list = projectiles.slice(); list.push(p); projectiles = list
    }

    function stepProjectiles(dt) {
        let finished = false
        for (const p of projectiles) { p.step(dt); if (p.done) finished = true }
        if (finished) {
            const keep = [], gone = []
            for (const p of projectiles) (p.done ? gone : keep).push(p)
            projectiles = keep
            for (const p of gone) p.destroy()
        }
    }

    function stepDeaths(dt) {
        const gone = []
        for (const u of units) if (!u.alive) { u.deathTimer += dt; if (u.deathTimer >= Balance.match.deathLinger) gone.push(u) }
        for (const b of buildings) if (!b.alive && b.maxHp > 0) { b.hitFlash = Math.max(b.hitFlash, 0.3) }
        for (const u of gone) removeEntity(u)
    }

    // production
    function stepProduction(dt) {
        for (const b of buildings) {
            if (!b.alive || !b.queue) continue
            const done = Production.step(b.queue, dt)
            if (done) {
                // spawn at the building's edge, then walk to the rally point / start gathering
                const door = { x: b.x, z: b.z + b.footD / 2 + 1.2 }
                const spawnSpots = Nav.distribute(door.x, door.z, 6, 1.2)
                const sp = spawnSpots[Math.floor(Math.random() * spawnSpots.length)]
                const u = spawnUnit(done, b.team, sp.x, sp.z)
                if (b.team === "player") {
                    if (b.rallyTarget && done === "goblin_worker") {
                        const node = (b.rallyTarget.alive !== false && b.rallyTarget.iron > 0) ? b.rallyTarget : nearestDeposit(u)
                        if (node) { u.order = "gather"; Gather.start(u, node) }
                    } else if (b.rally) {
                        const spots = Nav.distribute(b.rally.x, b.rally.z, 8, 1.4)
                        const d = spots[Math.floor(Math.random() * spots.length)]
                        u.order = "move"; u.moveTo(d)
                    }
                    unitsProduced++
                    flash(unitName(done) + " ready"); audio.play("produced")
                } else if (b.rally) {
                    const spots = Nav.distribute(b.rally.x, b.rally.z, 8, 1.4)
                    u.moveTo(spots[Math.floor(Math.random() * spots.length)])
                }
                gameEvent("unitProduced", { unitType: done, team: b.team, tag: b.tag })
            }
        }
    }

    // enemy
    // Producer and wave target come from the mission (enemy.producer / enemy.target tags).
    function enemyProducer() { const b = mission && mission.enemy ? entityByTag(mission.enemy.producer) : null; return b && b.alive && b.queue ? b : null }
    function enemyTarget() { const b = mission && mission.enemy ? entityByTag(mission.enemy.target) : null; return b && b.alive ? b : null }
    readonly property var enemyWorld: ({
        get time() { return game.matchTime },
        get enemyUnits() { return game.units.filter(u => u.alive && u.team === "enemy" && !u.inWave && u.order !== "attack") },
        get playerFortress() { return game.enemyTarget() },
        canProduce: (t) => { const p = game.enemyProducer(); return !!p && p.queue.items.length === 0 },
        produce: (t) => { game.enemyProducer().queue.items.push(t) },
        launchWave: (list, target) => {
            for (const u of list) { u.inWave = true; u.order = "attackMove"; u.primaryTarget = target; u.target = target; u.repathTimer = 0 }
            game.gameEvent("waveLaunched", { size: list.length, wave: game.enemyAI.wavesLaunched + 1 })
        }
    })
    property var enemyCfg: null
    function stepEnemy(dt) {
        if (!enemyAI || !enemyProducer()) return
        if (!enemyCfg) enemyCfg = Mission.enemyConfig(mission)
        EnemyAI.step(enemyAI, dt, enemyCfg, enemyWorld)
        // idle wave units that lost their target head for the wave target again
        const target = enemyTarget()
        for (const u of units) if (u.alive && u.team === "enemy" && u.inWave && !u.target && target) {
            u.order = "attackMove"; u.primaryTarget = target; u.target = target
        }
    }

    function endMatch(result) {
        if (phase !== "playing") return
        setSelection([])
        const summary = Objectives.summary(objectives)
        const r = {
            missionId: currentMissionId, missionTitle: missionTitleText(), campaign: Campaign.isCampaignMission(currentMissionId),
            victory: result === "victory", time: matchTime, difficulty: difficulty,
            unitsProduced: unitsProduced, unitsLost: unitsLost, unitsKilled: unitsKilled,
            buildingsDestroyed: buildingsDestroyed, buildingsLost: buildingsLost, ironGathered: Math.floor(economy.gathered),
            optionalComplete: summary.optionalComplete, optionalTotal: summary.optionalTotal,
            outcomeText: result === "victory" ? mission.outcome.victory : mission.outcome.defeat,
            mission: mission, medal: "", previousBest: null, newlyUnlocked: [], survivalUnlocked: false
        }
        const rec = Campaign.recordResult(progress, currentMissionId, difficulty, r)
        r.medal = rec.medal; r.previousBest = rec.previousBest; r.newlyUnlocked = rec.newlyUnlocked; r.survivalUnlocked = rec.survivalUnlocked
        delete r.mission
        lastResult = r
        saveProgress()
        gameEvent("missionEnded", { result: result, medal: r.medal })
        phase = result
        audio.play(result === "victory" ? "victory" : "defeat")
    }
    function missionTitleText() {
        const info = Campaign.info(currentMissionId)
        return info ? Loc.tr(info.titleKey) : (mission ? Loc.trOr(mission.title) : "")
    }

    // ---- 3D scene ----------------------------------------------------------------------------
    GameWorld {
        id: world; anchors.fill: parent; mapSizeX: game.mapSize; mapSizeZ: game.mapSize; visible: game.phase !== "showcase"
        // rally flag of the selected producer building
        Node {
            id: rallyFlag
            readonly property var b: game.selectedProducer
            readonly property var rp: b ? (void b.rallyRev, b.rally) : null
            visible: rp !== null && game.phase === "playing"
            x: rp ? rp.x : 0
            z: rp ? rp.z : 0
            Box3D { width: 0.08; height: 2.2; depth: 0.08; color: "#3a2a1a"; showEdges: false }
            Box3D { width: 0.9; height: 0.55; depth: 0.05; x: 0.45; y: 1.6; color: "#e0b24a"; useToonShading: true; showEdges: true; edgeColor: "#7a5a2a" }
            Model {
                source: "#Cylinder"; y: 0.02
                scale: Qt.vector3d(0.016, 0.0006, 0.016)
                materials: PrincipledMaterial { baseColor: "#e0b24a"; opacity: 0.35; alphaMode: PrincipledMaterial.Blend; lighting: PrincipledMaterial.NoLighting }
                pickable: false
            }
        }
    }
    AudioController { id: audio }
    GridPathfinder { id: pathfinder; diagonal: true }

    // ---- input -------------------------------------------------------------------------------
    OrbitInput3D {
        id: nav
        rig: world.rig
        view: world
        groundY: 0
        onCancelled: if (game.phase === "playing") game.issueOrder(mouse.rmbX, mouse.rmbY)
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: game.phase === "playing" || game.phase === "paused"
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        hoverEnabled: true
        cursorShape: nav.cursorShape
        property bool boxing: false
        property real x0: 0
        property real y0: 0
        property real rmbX: 0
        property real rmbY: 0
        property bool touchPress: false
        onPressed: (m) => {
            game.forceActiveFocus()
            touchPress = m.source === Qt.MouseEventSynthesizedByQt || m.source === Qt.MouseEventSynthesizedBySystem
            if (touchPress) game.touchMode = true
            if (m.button === Qt.RightButton) { rmbX = m.x; rmbY = m.y }
            if (nav.begin(m.x, m.y, m.button, m.modifiers) !== "") return
            if (m.button === Qt.LeftButton && game.phase === "playing") {
                boxing = true; x0 = m.x; y0 = m.y
                selBox.set(x0, y0, m.x, m.y); selBox.visible = false
            }
        }
        onCanceled: { boxing = false; selBox.visible = false; nav.cancel() }
        onPositionChanged: (m) => {
            if (nav.move(m.x, m.y)) return
            if (boxing) {
                selBox.set(x0, y0, m.x, m.y)
                selBox.visible = Math.abs(m.x - x0) > 3 || Math.abs(m.y - y0) > 3
            } else if (!pressed && game.phase === "playing") {
                game.updateHover(m.x, m.y)
            }
        }
        onReleased: (m) => {
            nav.end()
            if (!boxing) return
            boxing = false
            const additive = (m.modifiers & Qt.ShiftModifier) !== 0
            if (selBox.visible) game.selectInRect(x0, y0, m.x, m.y, additive)
            else if (touchPress) game.smartTap(m.x, m.y)
            else game.selectAt(m.x, m.y, additive)
            selBox.visible = false
        }
        onWheel: (w) => nav.wheel(w.angleDelta.y, w.x, w.y)
    }
    // Two fingers: pan (translation) and zoom (scale). Grabs the points away from the MouseArea,
    // which then gets onCanceled and drops any box selection in progress.
    PinchHandler {
        id: pinch
        enabled: game.phase === "playing" || game.phase === "paused"
        target: null
        minimumPointCount: 2
        property real lastScale: 1
        property point lastT: Qt.point(0, 0)
        onActiveChanged: { lastScale = 1; lastT = Qt.point(0, 0); if (active) game.touchMode = true }
        onActiveScaleChanged: {
            if (!active) return
            const f = lastScale / activeScale               // fingers apart -> closer -> smaller distance
            if (f > 0.5 && f < 2) world.rig.zoomBy(f)
            lastScale = activeScale
        }
        onActiveTranslationChanged: {
            if (!active) return
            const dx = activeTranslation.x - lastT.x, dy = activeTranslation.y - lastT.y
            lastT = activeTranslation
            const perPx = world.rig.worldPerPixel(game.height)
            world.rig.panBy(-dx * perPx, dy * perPx)
        }
    }

    Rectangle {
        id: selBox
        visible: false
        color: "#33e0b24a"; border.color: "#e0b24a"; border.width: 1
        function set(ax, ay, bx, by) { x = Math.min(ax, bx); y = Math.min(ay, by); width = Math.abs(bx - ax); height = Math.abs(by - ay) }
    }

    Keys.onPressed: (e) => {
        const rig = world.rig
        switch (e.key) {
        case Qt.Key_W: case Qt.Key_Up:    rig.keyAway = 1; break
        case Qt.Key_S: case Qt.Key_Down:  if (e.modifiers & Qt.ShiftModifier) { orderStop(selectedPlayerUnits) } else rig.keyAway = -1; break
        case Qt.Key_A: case Qt.Key_Left:  rig.keyRight = -1; break
        case Qt.Key_D: case Qt.Key_Right: rig.keyRight = 1; break
        case Qt.Key_Escape:
            if (phase === "playing") { if (selection.length) setSelection([]); else phase = "paused" }
            else if (phase === "paused") phase = "playing"
            break
        case Qt.Key_P: if (phase === "playing") phase = "paused"; else if (phase === "paused") phase = "playing"; break
        case Qt.Key_F: hud.showFps = !hud.showFps; perf.visible = !perf.visible; break
        case Qt.Key_M: useModels = !useModels; break
        case Qt.Key_N:
            if (!audio.platformSupported) { flash("audio is not available in the browser build yet (Clayground #216)"); break }
            audio.soundOn = !audio.soundOn; if (!audio.soundOn) audio.stopMusic(); else if (phase === "playing") audio.startMusic(); flash(audio.soundOn ? "sound on" : "sound off"); break
        case Qt.Key_BracketLeft: simSpeed = Math.max(1, simSpeed / 2); flash("speed x" + simSpeed); break
        case Qt.Key_BracketRight: simSpeed = Math.min(8, simSpeed * 2); flash("speed x" + simSpeed); break
        case Qt.Key_Space: if (playerFortress) rig.focusOn(Qt.vector3d(playerFortress.x, 0, playerFortress.z)); break
        case Qt.Key_F12: screenshot(); break
        default: return
        }
        e.accepted = true
    }
    Keys.onReleased: (e) => {
        switch (e.key) {
        case Qt.Key_W: case Qt.Key_Up: case Qt.Key_S: case Qt.Key_Down: world.rig.keyAway = 0; break
        case Qt.Key_A: case Qt.Key_Left: case Qt.Key_D: case Qt.Key_Right: world.rig.keyRight = 0; break
        default: return
        }
        e.accepted = true
    }

    // ---- overlays ----------------------------------------------------------------------------
    Hud {
        id: hud
        anchors.fill: parent
        visible: game.phase === "playing" || game.phase === "paused"
        game: game
        selection: game.selection
        iron: game.iron
        message: game.message
        fps: game.fps
        matchTime: game.matchTime
        enemyWave: game.enemyAI ? (void game.tick, game.enemyAI.wavesLaunched) : 0
        objective: game.objectiveText
        objectiveRows: game.objectiveRows
        title: game.missionTitleText()
        onProduceRequested: (b, t) => game.produce(b, t)
        onCancelProductionRequested: (b) => game.cancelProduction(b)
        touchMode: game.touchMode
        onPauseRequested: game.phase = "paused"
        onStopRequested: game.orderStop(game.selectedPlayerUnits)
        onReturnIronRequested: game.orderReturn(game.selectedPlayerUnits, null)
        onDeselectRequested: game.setSelection([])
        onSelectArmyRequested: game.selectArmy()
        onSelectWorkersRequested: game.selectWorkers()
        onHomeRequested: if (game.playerFortress) world.rig.focusOn(Qt.vector3d(game.playerFortress.x, 0, game.playerFortress.z))
    }

    Frontend {
        id: frontend
        anchors.fill: parent
        game: game
        progress: game.progress
        settings: game.settings
        lastResult: game.lastResult
        onStartMissionRequested: (id, diff) => game.startMission(id, diff)
        onResumeRequested: game.phase = "playing"
        onRestartRequested: game.restartMatch()
        onQuitToMenuRequested: game.quitToMenu()
        onShowcaseRequested: game.phase = "showcase"
        onExitRequested: Qt.quit()
        onSettingsEdited: { game.applySettings(); game.saveSettings() }
        onResetProgressRequested: game.resetProgress()
    }

    AssetShowcase {
        anchors.fill: parent
        visible: game.phase === "showcase"
        assetBase: game.assetBase
        useModels: game.useModels
        focus: visible
        onCloseRequested: { game.phase = "title"; frontend.screen = "menu" }
    }

    PerfHud {
        id: perf
        visible: false
        view3D: world
        anchors { right: parent.right; top: parent.top; margins: 10; topMargin: 48 }
    }

    // ---- screenshots & scripted self-test ----------------------------------------------------
    property int shotIndex: 0
    function screenshot(name) {
        const file = (name || ("ironfang-shot-" + (++shotIndex))) + ".png"
        game.grabToImage(function(result) { console.log("SCREENSHOT", file, result.saveToFile(file) ? "saved" : "FAILED") })
    }

    readonly property bool autotest: Qt.application.arguments.indexOf("--autotest") >= 0
    property int autoStep: 0
    Timer {
        // Scenario: gather, produce, fight, force a victory - at 8x speed so a whole match
        // shape runs in ~40 s. Logs AUTOTEST lines; used on desktop and in the browser.
        running: game.autotest && game.phase === "playing"
        interval: 1500; repeat: true
        onTriggered: {
            const s = game.autoStep++
            const log = (m) => console.log("AUTOTEST[" + s + "] t=" + matchTime.toFixed(0) + "s", m,
                                           "| iron " + Math.floor(iron) + " units " + units.filter(u => u.alive && u.team === "player").length
                                           + "/" + units.filter(u => u.alive && u.team === "enemy").length
                                           + " fps " + fps.toFixed(0) + " step " + stepMs.toFixed(2) + "ms")
            const workers = units.filter(u => u.alive && u.team === "player" && u.typeId === "goblin_worker")
            switch (s) {
            case 0: log("match started, difficulty " + difficulty + ", buildings " + buildings.length); break
            case 1: { const dep = nearestDeposit(workers[0]); orderGather(workers, dep, null); log("workers -> deposit at " + dep.x + "," + dep.z); break }
            case 2: simSpeed = 8; log("speed x8"); break
            case 4: log("gathered so far " + Math.floor(economy.gathered)); screenshot("autotest-gather"); break
            case 5: { for (let i = 0; i < 3; ++i) produce(playerFoundry, "orc_warrior"); log("queued warriors: " + (playerFoundry.queue ? playerFoundry.queue.items.length : -1))
                      setRally(playerFortress, nearestDeposit(workers[0]), null); produce(playerFortress, "goblin_worker"); log("fortress rally -> deposit, worker queued"); break }
            case 9: { const gathering = units.filter(u => u.alive && u.team === "player" && u.typeId === "goblin_worker" && u.gatherState !== "idle").length
                      log("workers gathering: " + gathering + "/" + units.filter(u => u.alive && u.team === "player" && u.typeId === "goblin_worker").length + " (new worker should auto-gather)"); break }
            case 8: log("production check, foundry queue " + queueLength(playerFoundry)); break
            case 12: { log("enemy AI state " + enemyAI.state + " waves " + enemyAI.wavesLaunched + " enemy iron " + Math.floor(enemyAI.economy.iron)); break }
            case 16: { const army = units.filter(u => u.alive && u.team === "player" && u.typeId !== "goblin_worker")
                       enemyFortress.hp = 60; orderAttack(army, enemyFortress); log("army of " + army.length + " sent at the (weakened) enemy fortress"); break }
            case 20: screenshot("autotest-siege"); log("siege in progress, fortress hp " + Math.ceil(enemyFortress.hp)); break
            case 26: log("phase=" + phase + " waves=" + enemyAI.wavesLaunched + " lost=" + unitsLost + " killed=" + unitsKilled); break
            case 27: if (phase !== "victory") { enemyFortress.hp = 1; dealDamage(null, enemyFortress, 5); log("forced fortress destruction -> phase " + phase) } break
            case 28: log("restart test"); restartMatch(); break
            case 29: log("after restart: phase=" + phase + " units=" + units.length + " buildings=" + buildings.length + " iron=" + iron); break
            case 30: log("DONE"); if (Qt.platform.os !== "wasm") Qt.quit(); break
            }
        }
    }
    Timer {   // the autotest timer stops when the match ends (phase != playing); finish from here
        running: game.autotest && (game.phase === "victory" || game.phase === "defeat") && game.autoStep < 28
        interval: 1500; repeat: false
        onTriggered: { console.log("AUTOTEST end phase=" + game.phase + " at t=" + game.matchTime.toFixed(0)); game.autoStep = 28; game.restartMatch() }
    }
}
