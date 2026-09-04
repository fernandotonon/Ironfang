// Production queues. A queue is a plain object owned by a building:
//   { items: [typeId, ...], progress: seconds spent on items[0], maxLength }
.pragma library
.import "Economy.js" as Economy
.import "../config/balance.js" as Balance

function createQueue(maxLength) {
    return { items: [], progress: 0, maxLength: maxLength || 5 }
}

// Tries to add `typeId` to `queue`, paying from `economy`. Returns { ok, reason }.
function enqueue(queue, buildingTypeId, typeId, economy) {
    var b = Balance.buildings[buildingTypeId]
    var u = Balance.units[typeId]
    if (!b || !u) return { ok: false, reason: "unknown type" }
    if (b.produces.indexOf(typeId) < 0) return { ok: false, reason: b.name + " cannot produce " + u.name }
    if (queue.items.length >= queue.maxLength) return { ok: false, reason: "queue full" }
    if (!Economy.canAfford(economy, u.cost)) return { ok: false, reason: "not enough iron (" + u.cost + ")" }
    Economy.spend(economy, u.cost)
    queue.items.push(typeId)
    return { ok: true }
}

// Removes the last queued item and refunds it. Returns the typeId or null.
function cancelLast(queue, economy) {
    if (queue.items.length === 0) return null
    var typeId = queue.items.pop()
    Economy.refund(economy, Balance.units[typeId].cost)
    if (queue.items.length === 0) queue.progress = 0
    return typeId
}

// Advances the head item by dt seconds. Returns the finished typeId, or null.
function step(queue, dt) {
    if (queue.items.length === 0) return null
    queue.progress += dt
    var head = queue.items[0]
    if (queue.progress >= Balance.units[head].buildTime) {
        queue.items.shift()
        queue.progress = 0
        return head
    }
    return null
}

function headProgress(queue) {
    if (queue.items.length === 0) return 0
    return Math.min(1, queue.progress / Balance.units[queue.items[0]].buildTime)
}
