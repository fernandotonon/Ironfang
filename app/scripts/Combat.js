// Combat rules. Entities are plain objects or QML items with:
//   x, z, radius, team, alive, hp, maxHp, isBuilding (bool), typeId
//   buildings also carry footW / footD (axis-aligned footprint in metres)
.pragma library
.import "../config/balance.js" as Balance

function dist(a, b) {
    var dx = a.x - b.x, dz = a.z - b.z
    return Math.sqrt(dx * dx + dz * dz)
}

// Distance from point (px,pz) to the footprint rectangle of `b` (0 inside).
function rectDistance(b, px, pz) {
    var hw = (b.footW || b.radius * 2 || 0) / 2, hd = (b.footD || b.radius * 2 || 0) / 2
    var dx = Math.max(Math.abs(px - b.x) - hw, 0)
    var dz = Math.max(Math.abs(pz - b.z) - hd, 0)
    return Math.sqrt(dx * dx + dz * dz)
}

// Surface gap between two entities: units are discs, buildings are their footprint rectangle.
function gap(a, b) {
    if (b.isBuilding) return rectDistance(b, a.x, a.z) - (a.radius || 0)
    if (a.isBuilding) return rectDistance(a, b.x, b.z) - (b.radius || 0)
    return dist(a, b) - (a.radius || 0) - (b.radius || 0)
}

function attackRange(attackerStats) {
    return attackerStats.range > 0 ? attackerStats.range : Balance.meleeReach
}

function inRange(attacker, attackerStats, target) {
    return gap(attacker, target) <= attackRange(attackerStats) + 0.1
}

function damageFor(attackerStats, target) {
    var dmg = attackerStats.damage
    if (target.isBuilding && attackerStats.buildingDamageMultiplier)
        dmg *= attackerStats.buildingDamageMultiplier
    return dmg
}

// Applies damage; returns true when this hit killed the target.
function applyDamage(target, amount) {
    if (!target || !target.alive || amount <= 0) return false
    target.hp = Math.max(0, target.hp - amount)
    if (target.hp === 0) {
        target.alive = false
        return true
    }
    return false
}

function isHostile(a, b) {
    return !!a && !!b && a.team !== b.team && b.team !== "neutral"
}

function isValidTarget(t) {
    return !!t && t.alive === true && t.team !== "neutral" && !t.untargetable
}

// Nearest hostile within `radius`; a unit beats a building at (nearly) the same distance.
function acquireTarget(self, candidates, radius) {
    var best = null, bestD = radius
    for (var i = 0; i < candidates.length; ++i) {
        var c = candidates[i]
        if (c === self || !isValidTarget(c) || !isHostile(self, c)) continue
        var d = gap(self, c)
        if (d < bestD - 1e-6 || (best && best.isBuilding && !c.isBuilding && d <= bestD + 1.0)) { bestD = d; best = c }
    }
    return best
}

// Where `attacker` should stand to be `standoff` from `target`'s surface, on the side it is
// currently on. Works for discs and for rectangular footprints (nearest boundary point).
function approachPoint(attacker, target, standoff) {
    var r = (attacker.radius || 0) + standoff
    if (target.isBuilding) {
        var hw = (target.footW || 0) / 2, hd = (target.footD || 0) / 2
        var cx = Math.max(target.x - hw, Math.min(attacker.x, target.x + hw))
        var cz = Math.max(target.z - hd, Math.min(attacker.z, target.z + hd))
        var ox = attacker.x - cx, oz = attacker.z - cz
        var od = Math.sqrt(ox * ox + oz * oz)
        if (od < 1e-6) {                              // inside the footprint: leave by the shorter side
            var ex = (target.x + hw) - attacker.x, wx = attacker.x - (target.x - hw)
            var sz = (target.z + hd) - attacker.z, nz = attacker.z - (target.z - hd)
            var m = Math.min(ex, wx, sz, nz)
            if (m === ex) return { x: target.x + hw + r, z: attacker.z }
            if (m === wx) return { x: target.x - hw - r, z: attacker.z }
            if (m === sz) return { x: attacker.x, z: target.z + hd + r }
            return { x: attacker.x, z: target.z - hd - r }
        }
        return { x: cx + ox / od * r, z: cz + oz / od * r }
    }
    var dx = attacker.x - target.x, dz = attacker.z - target.z
    var d = Math.sqrt(dx * dx + dz * dz) || 1
    var rr = (target.radius || 0) + r
    return { x: target.x + dx / d * rr, z: target.z + dz / d * rr }
}
