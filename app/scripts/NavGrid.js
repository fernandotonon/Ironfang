// Ironfang - navigation grid (pure JS, no Qt dependency; A* is Clayground's GridPathfinder).
// World is the XZ plane in metres; grid cells are `cellSize` metres, origin at (0,0).
.pragma library

var cols = 0
var rows = 0
var cellSize = 1.0
var blocked = []          // flat Uint8-like array, index = gz * cols + gx, 1 = blocked

function init(sizeX, sizeZ, cell) {
    cellSize = cell
    cols = Math.ceil(sizeX / cell)
    rows = Math.ceil(sizeZ / cell)
    blocked = new Array(cols * rows).fill(0)
}

function toGrid(x, z) {
    return { gx: Math.floor(x / cellSize), gz: Math.floor(z / cellSize) }
}

function toWorld(gx, gz) {
    return { x: (gx + 0.5) * cellSize, z: (gz + 0.5) * cellSize }
}

function inBounds(gx, gz) { return gx >= 0 && gz >= 0 && gx < cols && gz < rows }

function isBlockedCell(gx, gz) {
    if (!inBounds(gx, gz)) return true
    return blocked[gz * cols + gx] === 1
}

function isBlocked(x, z) {
    var g = toGrid(x, z)
    return isBlockedCell(g.gx, g.gz)
}

// Marks every cell touched by the world-space rectangle [x0,x1] x [z0,z1] as blocked.
function blockRect(x0, z0, x1, z1) {
    var a = toGrid(Math.min(x0, x1), Math.min(z0, z1))
    var b = toGrid(Math.max(x0, x1) - 1e-6, Math.max(z0, z1) - 1e-6)
    for (var gz = a.gz; gz <= b.gz; ++gz)
        for (var gx = a.gx; gx <= b.gx; ++gx)
            if (inBounds(gx, gz)) blocked[gz * cols + gx] = 1
}

function walkableData() { return blocked.slice() }

// Nearest walkable cell to (gx,gz) by growing square rings; null if none within radius.
function nearestWalkable(gx, gz, maxRing) {
    if (!isBlockedCell(gx, gz)) return { gx: gx, gz: gz }
    for (var r = 1; r <= (maxRing || 8); ++r) {
        var best = null, bestD = Infinity
        for (var dz = -r; dz <= r; ++dz)
            for (var dx = -r; dx <= r; ++dx) {
                if (Math.max(Math.abs(dx), Math.abs(dz)) !== r) continue
                var cx = gx + dx, cz = gz + dz
                if (isBlockedCell(cx, cz)) continue
                var d = dx * dx + dz * dz
                if (d < bestD) { bestD = d; best = { gx: cx, gz: cz } }
            }
        if (best) return best
    }
    return null
}

// A* through Clayground's GridPathfinder. Returns world waypoints (cell centres) from the
// cell after the start up to the goal, with the exact goal point appended; [] if unreachable.
function findPath(pathfinder, fromX, fromZ, toX, toZ) {
    var s = toGrid(fromX, fromZ)
    var g0 = toGrid(toX, toZ)
    var g = nearestWalkable(g0.gx, g0.gz, 10)
    if (!g) return []
    var start = nearestWalkable(s.gx, s.gz, 4) || s
    if (start.gx === g.gx && start.gz === g.gz)
        return [{ x: toX, z: toZ }]
    var cells = pathfinder.findPath(start.gx, start.gz, g.gx, g.gz)
    if (!cells || cells.length === 0) return []
    var out = []
    for (var i = 1; i < cells.length; ++i) {   // skip the cell we stand in
        var w = toWorld(cells[i].x, cells[i].y)
        out.push({ x: w.x, z: w.z })
    }
    // snap the last waypoint to the requested point when it lies in the reached cell
    var exact = toGrid(toX, toZ)
    if (exact.gx === g.gx && exact.gz === g.gz) {
        if (out.length) out[out.length - 1] = { x: toX, z: toZ }
        else out.push({ x: toX, z: toZ })
    }
    return out
}

// Spreads `count` destinations around a centre in a compact square spiral (spacing metres),
// skipping blocked cells - the group order "everybody go there" without piling on one spot.
function distribute(cx, cz, count, spacing) {
    var out = []
    if (count <= 0) return out
    var ring = 0
    while (out.length < count && ring < 12) {
        if (ring === 0) {
            if (!isBlocked(cx, cz)) out.push({ x: cx, z: cz })
        } else {
            for (var dz = -ring; dz <= ring && out.length < count; ++dz)
                for (var dx = -ring; dx <= ring && out.length < count; ++dx) {
                    if (Math.max(Math.abs(dx), Math.abs(dz)) !== ring) continue
                    var x = cx + dx * spacing, z = cz + dz * spacing
                    if (!isBlocked(x, z)) out.push({ x: x, z: z })
                }
        }
        ++ring
    }
    while (out.length < count) out.push({ x: cx, z: cz })
    return out
}
