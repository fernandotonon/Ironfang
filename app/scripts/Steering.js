// Ironfang - unit movement: waypoint following + soft separation + static-cell avoidance.
// Runs on the fixed simulation step; units are UnitView objects (position, path, speed, radius).
.pragma library
.import "NavGrid.js" as Nav

var ARRIVE_DIST = 0.25
var SEPARATION_STRENGTH = 4.0

function step(units, dt) {
    var i, j, u
    // 1. desired motion along the path
    for (i = 0; i < units.length; ++i) {
        u = units[i]
        u.vx = 0; u.vz = 0
        if (!u.alive || u.path.length === 0) continue
        var wp = u.path[u.pathIndex]
        var dx = wp.x - u.x, dz = wp.z - u.z
        var d = Math.sqrt(dx * dx + dz * dz)
        if (d < ARRIVE_DIST) {
            u.pathIndex++
            if (u.pathIndex >= u.path.length) { u.arrive(); continue }
            wp = u.path[u.pathIndex]
            dx = wp.x - u.x; dz = wp.z - u.z; d = Math.sqrt(dx * dx + dz * dz) || 1
        }
        var sp = Math.min(u.speed, d / dt)
        u.vx = dx / d * sp
        u.vz = dz / d * sp
    }
    // 2. separation (O(n^2) is fine for a few dozen units)
    for (i = 0; i < units.length; ++i) {
        u = units[i]
        if (!u.alive) continue
        for (j = i + 1; j < units.length; ++j) {
            var v = units[j]
            if (!v.alive) continue
            var ddx = v.x - u.x, ddz = v.z - u.z
            var dist2 = ddx * ddx + ddz * ddz
            var minD = u.radius + v.radius
            if (dist2 >= minD * minD || dist2 < 1e-6) continue
            var dist = Math.sqrt(dist2)
            var push = (minD - dist) / minD * SEPARATION_STRENGTH
            var nx = ddx / dist, nz = ddz / dist
            // idle units yield less than moving ones so a walking group can pass through
            var wu = u.path.length ? 1.0 : 0.35
            var wv = v.path.length ? 1.0 : 0.35
            u.vx -= nx * push * wv; u.vz -= nz * push * wv
            v.vx += nx * push * wu; v.vz += nz * push * wu
        }
    }
    // 3. integrate, refusing to enter blocked cells
    for (i = 0; i < units.length; ++i) {
        u = units[i]
        if (!u.alive) continue
        if (u.vx === 0 && u.vz === 0) continue
        var nx2 = u.x + u.vx * dt, nz2 = u.z + u.vz * dt
        if (!Nav.isBlocked(nx2, nz2)) { u.x = nx2; u.z = nz2 }
        else if (!Nav.isBlocked(nx2, u.z)) { u.x = nx2 }
        else if (!Nav.isBlocked(u.x, nz2)) { u.z = nz2 }
        else if (u.path.length) { u.blockedTicks++ }
        if (u.path.length) {
            var speed2 = u.vx * u.vx + u.vz * u.vz
            if (speed2 > 0.01) u.heading = Math.atan2(u.vx, u.vz) * 180 / Math.PI
        }
    }
}
