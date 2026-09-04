// Ironfang: First Siege - game root (an Item, so it runs both inside the desktop Window
// and when loaded by the Clayground Web Runtime from static files).
// Milestone 0: feasibility spike - scene, RTS camera, picking, box selection, move orders,
// grid navigation around obstacles, animated QtMeshEditor units, 40-unit stress test.
import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import Clayground.Canvas3D
import Clayground.Algorithm
import "scripts/NavGrid.js" as Nav
import "scripts/Steering.js" as Steer
import "config/assets.js" as Assets

Item {
    id: game
    focus: true

    // ---- world -------------------------------------------------------------------------
    readonly property real mapSize: 60          // metres, square map, origin at a corner
    readonly property real navCell: 1.0
    readonly property real simStep: 1 / 30      // fixed simulation step (seconds)

    property var assetConfig: ({ units: Assets.units })
    property bool assetsLoaded: false
    property bool useModels: Qt.application.arguments.indexOf("--no-models") < 0
    property string defaultUnitType: "orc_warrior"

    property var units: []                      // UnitView objects (imperatively created)
    property var selection: []
    property int nextUnitId: 1
    property real fps: 0
    property string message: ""

    signal unitsChanged_()

    // ---- startup -------------------------------------------------------------------------
    Component.onCompleted: {
        Nav.init(mapSize, mapSize, navCell)
        for (const o of obstacles.children)
            if (o.navBlock) Nav.blockRect(o.x - o.width / 2, o.z - o.depth / 2,
                                          o.x + o.width / 2, o.z + o.depth / 2)
        pathfinder.columns = Nav.cols
        pathfinder.rows = Nav.rows
        pathfinder.walkableData = Nav.walkableData()
        loadAssetConfig()
    }

    function loadAssetConfig() {
        assetConfig = { units: Assets.units }
        assetsLoaded = true
        spawn(1)
    }

    // ---- units ---------------------------------------------------------------------------
    Component {
        id: unitComp
        UnitView {
            camYaw: rig.yaw
            camPitch: rig.pitch
            useModel: game.useModels
        }
    }

    function spawn(count) {
        if (count < 0) count = Math.max(0, -count - units.length)   // "-40" means fill up to 40
        const list = units.slice()
        for (let i = 0; i < count; ++i) {
            const n = list.length
            const col = n % 8, row = Math.floor(n / 8)
            const typeId = assetConfig.units[defaultUnitType] ? defaultUnitType : "placeholder"
            const u = unitComp.createObject(unitRoot, {
                unitId: nextUnitId++,
                typeId: typeId,
                typeDef: assetConfig.units[typeId] || {},
                x: mapSize * 0.5 - 8 + col * 1.6,
                z: mapSize * 0.5 + 6 + row * 1.6,
                heading: 180
            })
            list.push(u)
        }
        units = list
    }

    function clearUnits() {
        for (const u of units) u.destroy()
        units = []
        setSelection([])
    }

    function unitOf(obj) {
        let o = obj
        for (let guard = 0; o && guard < 12; ++guard) {
            if (o.isUnit === true) return o
            o = o.parent
        }
        return null
    }

    // Ray pick through the 3D view first (QtMeshEditor meshes are pickable), then a
    // screen-space capsule test as fallback (placeholder boxes, misses between limbs).
    function unitAtScreen(sx, sy) {
        const p = nav.pickAt(sx, sy)
        if (p && p.object) {
            const hit = unitOf(p.object)
            if (hit) return hit
        }
        let best = null, bestD = 1e9
        for (const u of units) {
            const feet = view3d.mapFrom3DScene(u.scenePosition)
            const head = view3d.mapFrom3DScene(Qt.vector3d(u.scenePosition.x, u.scenePosition.y + u.bodyHeight, u.scenePosition.z))
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
        for (const u of selection) u.selected = false
        selection = list
        for (const u of selection) u.selected = true
    }

    function selectAt(sx, sy, additive) {
        const u = unitAtScreen(sx, sy)
        if (!additive) { setSelection(u ? [u] : []); return }
        if (!u) return
        const idx = selection.indexOf(u)
        const list = selection.slice()
        if (idx >= 0) list.splice(idx, 1); else list.push(u)
        setSelection(list)
    }

    function selectInRect(x0, y0, x1, y1, additive) {
        const left = Math.min(x0, x1), right = Math.max(x0, x1)
        const top = Math.min(y0, y1), bottom = Math.max(y0, y1)
        const list = additive ? selection.slice() : []
        for (const u of units) {
            const s = view3d.mapFrom3DScene(Qt.vector3d(u.scenePosition.x, u.scenePosition.y + 0.9, u.scenePosition.z))
            if (s.x >= left && s.x <= right && s.y >= top && s.y <= bottom && list.indexOf(u) < 0)
                list.push(u)
        }
        setSelection(list)
    }

    function updateHover(sx, sy) {
        const u = unitAtScreen(sx, sy)
        if (hoveredUnit === u) return
        if (hoveredUnit) hoveredUnit.hovered = false
        hoveredUnit = u
        if (u) u.hovered = true
    }
    property var hoveredUnit: null

    function issueMoveOrder(sx, sy) {
        const g = nav.groundAt(sx, sy)
        if (!g) return
        if (selection.length === 0) { flash("nothing selected"); return }
        const dests = Nav.distribute(g.x, g.z, selection.length, 1.5)
        let unreachable = 0
        for (let i = 0; i < selection.length; ++i) {
            const u = selection[i]
            const path = Nav.findPath(pathfinder, u.x, u.z, dests[i].x, dests[i].z)
            if (path.length === 0) { unreachable++; continue }
            u.moveAlong(path)
        }
        moveMarker.showAt(g.x, g.z, unreachable === 0 ? "#e0b24a" : "#c9432e")
        if (unreachable) flash(unreachable + " unit(s): destination unreachable")
    }

    function playOnSelection(clip) {
        const targets = selection.length ? selection : units
        for (const u of targets) { u.path = []; u.play(clip) }
    }

    function flash(text) { message = text; messageTimer.restart() }
    Timer { id: messageTimer; interval: 2200; onTriggered: game.message = "" }

    // Screenshot of the whole game item (works offscreen too): key P or the autotest.
    property int shotIndex: 0
    function screenshot(name) {
        const file = (name || ("ironfang-shot-" + (++shotIndex))) + ".png"
        game.grabToImage(function(result) {
            const ok = result.saveToFile(file)
            console.log("SCREENSHOT", file, ok ? "saved" : "FAILED")
        })
    }

    // ---- scripted self-test (run with --autotest): spawn, select, order, animate, measure ----
    readonly property bool autotest: Qt.application.arguments.indexOf("--autotest") >= 0
    property real stepMs: 0                     // smoothed cost of one Steering.step (ms)
    property real frameMs: 0                    // smoothed frame time (ms)
    property int autoStep: 0
    Timer {
        running: game.autotest && game.assetsLoaded
        interval: 1500; repeat: true
        onTriggered: {
            const s = game.autoStep++
            const log = (m) => console.log("AUTOTEST[" + s + "]", m, "| step " + stepMs.toFixed(2) + "ms frame " + frameMs.toFixed(1) + "ms models=" + useModels)
            switch (s) {
            case 0: log("units=" + units.length + " fps=" + fps.toFixed(1) + " modelReady=" + (units[0] && units[0].modelReady)); break
            case 1: screenshot("autotest-1unit"); break
            case 2: spawn(-20); log("spawned to " + units.length); break
            case 3: log("units=" + units.length + " fps=" + fps.toFixed(1)); break
            case 4: spawn(-40); log("spawned to " + units.length); break
            case 5: log("units=" + units.length + " fps=" + fps.toFixed(1)); break
            case 6: selectInRect(0, 0, width, height, false); log("selected=" + selection.length)
                    for (const u of selection) u.moveAlong([]) ; break
            case 7: {   // order everybody to the far side of the building at (30,22)
                const dests = Nav.distribute(30, 10, selection.length, 1.5)
                let ok = 0
                for (let i = 0; i < selection.length; ++i) {
                    const p = Nav.findPath(pathfinder, selection[i].x, selection[i].z, dests[i].x, dests[i].z)
                    if (p.length) { selection[i].moveAlong(p); ok++ }
                }
                log("move order: paths=" + ok + "/" + selection.length); break }
            case 8: log("walking fps=" + fps.toFixed(1)); screenshot("autotest-walk"); break
            case 10: { let moving = 0; for (const u of units) if (u.path.length) moving++
                       log("still moving=" + moving + " fps=" + fps.toFixed(1)); break }
            case 12: { let moving = 0, blocked = 0
                       for (const u of units) { if (u.path.length) moving++; if (Nav.isBlocked(u.x, u.z)) blocked++ }
                       log("arrived check: moving=" + moving + " insideObstacle=" + blocked)
                       playOnSelection("Attack"); log("clip=Attack"); break }
            case 13: screenshot("autotest-attack"); log("fps=" + fps.toFixed(1)); break
            case 14: playOnSelection("Idle"); log("clip=Idle"); break
            case 15: log("DONE units=" + units.length + " fps=" + fps.toFixed(1)); if (Qt.platform.os !== "wasm") Qt.quit(); break
            }
        }
    }

    // ---- simulation clock ----------------------------------------------------------------
    property real _acc: 0
    property int _frames: 0
    property real _fpsClock: 0
    FrameAnimation {
        running: true
        onTriggered: {
            const dt = Math.min(frameTime, 0.25)          // tab throttling: never explode
            game._acc += dt
            let guard = 0
            while (game._acc >= game.simStep && guard++ < 8) {
                const t0 = Date.now()
                Steer.step(game.units, game.simStep)
                game.stepMs = game.stepMs * 0.9 + (Date.now() - t0) * 0.1
                game._acc -= game.simStep
            }
            game.frameMs = game.frameMs * 0.9 + dt * 1000 * 0.1
            if (guard >= 8) game._acc = 0
            rig.tickKeyboard(dt)
            game._frames++
            game._fpsClock += dt
            if (game._fpsClock >= 0.5) { game.fps = game._frames / game._fpsClock; game._frames = 0; game._fpsClock = 0 }
        }
    }

    GridPathfinder { id: pathfinder; diagonal: true }

    // ---- 3D scene --------------------------------------------------------------------------
    View3D {
        id: view3d
        anchors.fill: parent
        camera: rig.camera
        environment: SceneEnvironment {
            clearColor: "#1f232a"
            backgroundMode: SceneEnvironment.Color
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.Medium
        }

        RtsCamera { id: rig; mapSizeX: game.mapSize; mapSizeZ: game.mapSize }

        DirectionalLight {
            eulerRotation.x: -58; eulerRotation.y: -32
            brightness: 1.35
            ambientColor: "#3a3f47"
        }
        DirectionalLight { eulerRotation.x: -25; eulerRotation.y: 145; brightness: 0.35; color: "#c9d6ff" }

        // ground: rocky slate
        Model {
            source: "#Rectangle"
            eulerRotation.x: -90
            position: Qt.vector3d(game.mapSize / 2, 0, game.mapSize / 2)
            scale: Qt.vector3d(game.mapSize / 100, game.mapSize / 100, 1)
            materials: PrincipledMaterial { baseColor: "#4b4f47"; roughness: 0.95; metalness: 0 }
            pickable: false
        }
        // grid lines every 10 m so movement distance reads
        Repeater3D {
            model: 7
            Model {
                source: "#Cube"
                position: Qt.vector3d(index * 10, 0.01, game.mapSize / 2)
                scale: Qt.vector3d(0.0004, 0.0002, game.mapSize / 100)
                materials: PrincipledMaterial { baseColor: "#5a5e56"; lighting: PrincipledMaterial.NoLighting }
                pickable: false
            }
        }
        Repeater3D {
            model: 7
            Model {
                source: "#Cube"
                position: Qt.vector3d(game.mapSize / 2, 0.01, index * 10)
                scale: Qt.vector3d(game.mapSize / 100, 0.0002, 0.0004)
                materials: PrincipledMaterial { baseColor: "#5a5e56"; lighting: PrincipledMaterial.NoLighting }
                pickable: false
            }
        }

        // static obstacles (buildings/rocks placeholders); navBlock marks them in the grid
        Node {
            id: obstacles
            Box3D { property bool navBlock: true; x: 30; z: 22; width: 8; height: 4.5; depth: 6
                    color: "#6b4f3d"; useToonShading: true; showEdges: true; edgeColor: "#2a1e16"; edgeThickness: 1.5 }
            Box3D { property bool navBlock: true; x: 16; z: 38; width: 3; height: 1.6; depth: 3
                    color: "#5d6066"; useToonShading: true; showEdges: true; edgeColor: "#26282c" }
            Box3D { property bool navBlock: true; x: 44; z: 42; width: 4; height: 2.2; depth: 2
                    color: "#5d6066"; useToonShading: true; showEdges: true; edgeColor: "#26282c" }
        }

        Node { id: unitRoot }

        // move-order marker: flat ring that fades
        Node {
            id: moveMarker
            visible: false
            property color tone: "#e0b24a"
            function showAt(x, z, c) { position = Qt.vector3d(x, 0.02, z); tone = c; visible = true; markerAnim.restart() }
            Model {
                id: markerModel
                source: "#Cylinder"
                scale: Qt.vector3d(0.014, 0.0006, 0.014)
                materials: PrincipledMaterial { baseColor: moveMarker.tone; lighting: PrincipledMaterial.NoLighting }
                pickable: false
            }
            SequentialAnimation {
                id: markerAnim
                NumberAnimation { target: markerModel; property: "scale.x"; from: 0.004; to: 0.016; duration: 250 }
                PauseAnimation { duration: 350 }
                ScriptAction { script: moveMarker.visible = false }
            }
        }
    }

    // ---- input -----------------------------------------------------------------------------
    OrbitInput3D {
        id: nav
        rig: rig
        view: view3d
        groundY: 0
        onCancelled: game.issueMoveOrder(mouse.rmbX, mouse.rmbY)   // right *click* = order
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        hoverEnabled: true
        cursorShape: nav.cursorShape
        property bool boxing: false
        property real x0: 0
        property real y0: 0
        property real rmbX: 0
        property real rmbY: 0
        onPressed: (m) => {
            game.forceActiveFocus()
            if (m.button === Qt.RightButton) { rmbX = m.x; rmbY = m.y }
            if (nav.begin(m.x, m.y, m.button, m.modifiers) !== "") return
            if (m.button === Qt.LeftButton) {
                boxing = true; x0 = m.x; y0 = m.y
                selBox.set(x0, y0, m.x, m.y); selBox.visible = false
            }
        }
        onPositionChanged: (m) => {
            if (nav.move(m.x, m.y)) return
            if (boxing) {
                selBox.set(x0, y0, m.x, m.y)
                selBox.visible = Math.abs(m.x - x0) > 3 || Math.abs(m.y - y0) > 3
            } else if (!pressed) {
                game.updateHover(m.x, m.y)
            }
        }
        onReleased: (m) => {
            nav.end()
            if (!boxing) return
            boxing = false
            const additive = (m.modifiers & Qt.ShiftModifier) !== 0
            if (selBox.visible) game.selectInRect(x0, y0, m.x, m.y, additive)
            else game.selectAt(m.x, m.y, additive)
            selBox.visible = false
        }
        onWheel: (w) => nav.wheel(w.angleDelta.y, w.x, w.y)
    }

    Rectangle {
        id: selBox
        visible: false
        color: "#33e0b24a"; border.color: "#e0b24a"; border.width: 1
        function set(ax, ay, bx, by) {
            x = Math.min(ax, bx); y = Math.min(ay, by)
            width = Math.abs(bx - ax); height = Math.abs(by - ay)
        }
    }

    Keys.onPressed: (e) => {
        switch (e.key) {
        case Qt.Key_W: case Qt.Key_Up:    rig.keyAway = 1; break
        case Qt.Key_S: case Qt.Key_Down:  rig.keyAway = -1; break
        case Qt.Key_A: case Qt.Key_Left:  rig.keyRight = -1; break
        case Qt.Key_D: case Qt.Key_Right: rig.keyRight = 1; break
        case Qt.Key_Escape: setSelection([]); break
        case Qt.Key_1: playOnSelection("Idle"); break
        case Qt.Key_2: playOnSelection("Walk"); break
        case Qt.Key_3: playOnSelection("Attack"); break
        case Qt.Key_4: playOnSelection("Hit"); break
        case Qt.Key_5: playOnSelection("Death"); break
        case Qt.Key_Plus: case Qt.Key_Equal: spawn(1); break
        case Qt.Key_M: useModels = !useModels; break
        case Qt.Key_F: perf.visible = !perf.visible; break
        case Qt.Key_P: screenshot(); break
        default: return
        }
        e.accepted = true
    }
    Keys.onReleased: (e) => {
        switch (e.key) {
        case Qt.Key_W: case Qt.Key_Up: case Qt.Key_S: case Qt.Key_Down: rig.keyAway = 0; break
        case Qt.Key_A: case Qt.Key_Left: case Qt.Key_D: case Qt.Key_Right: rig.keyRight = 0; break
        default: return
        }
        e.accepted = true
    }

    // ---- overlay ----------------------------------------------------------------------------
    SpikeHud {
        anchors.fill: parent
        unitCount: game.units.length
        selectedCount: game.selection.length
        fps: game.fps
        useModels: game.useModels
        lastMessage: game.message
        modelStatus: {
            const t = game.assetConfig.units ? game.assetConfig.units[game.defaultUnitType] : null
            if (!t) return "loading config..."
            return (t.displayName || game.defaultUnitType) + " · " + (t.status || "?") + " · " + (t.model || "placeholder")
                   + (game.units.length && game.units[0].modelReady ? " · loaded" : "")
        }
        onSpawnRequested: (n) => game.spawn(n)
        onClearRequested: game.clearUnits()
        onToggleModelsRequested: game.useModels = !game.useModels
        onPlayRequested: (clip) => game.playOnSelection(clip)
    }

    PerfHud {
        id: perf
        visible: false
        view3D: view3d
        anchors { right: parent.right; top: parent.top; margins: 10 }
    }
}
