// Worker gathering loop - a small state machine per worker.
//   idle -> toDeposit -> gathering -> toDropOff -> (deposit) -> toDeposit ...
// The worker object needs: x, z, radius, carried, gatherTimer, gatherState, gatherNode,
// dropOff (building), alive; plus moveTo(pointOrNull) / play(clip) / path (from Steering).
// `ctx` provides: findDropOff(worker), findDeposit(worker), deposit(worker, amount),
// stats (Balance unit entry), gap(a,b) distance helper.
.pragma library
.import "Economy.js" as Economy

var REACH = 0.9          // how close to a node/building surface counts as "there"

function start(worker, node) {
    worker.gatherNode = node
    worker.gatherState = worker.carried > 0 ? "toDropOff" : "toDeposit"
    worker.gatherTimer = 0
    worker.gatherArrived = false
}

function stop(worker) {
    worker.gatherState = "idle"
    worker.gatherNode = null
    worker.gatherTimer = 0
    worker.gatherArrived = false
}

// Order a worker carrying iron to go home; empty-handed workers ignore it.
function returnHome(worker) {
    if (worker.carried <= 0) return false
    worker.gatherState = "toDropOff"
    worker.gatherArrived = false
    return true
}

function isActive(worker) {
    return worker.gatherState && worker.gatherState !== "idle"
}

function step(worker, dt, ctx) {
    if (!worker.alive) return
    var stats = ctx.stats
    switch (worker.gatherState) {
    case "toDeposit": {
        var node = worker.gatherNode
        if (!node || node.iron <= 0) {
            node = ctx.findDeposit(worker)
            worker.gatherNode = node
            if (!node) {                                    // nothing left anywhere
                if (worker.carried > 0) { worker.gatherState = "toDropOff"; worker.gatherArrived = false }
                else stop(worker)
                return
            }
        }
        if (ctx.gap(worker, node) <= REACH) {
            worker.path = []
            worker.gatherState = "gathering"
            worker.gatherTimer = 0
            worker.play("Gather")
            worker.lookAt(node)
        } else if (!worker.path.length) {
            worker.moveTo(ctx.approach(worker, node))
        }
        break
    }
    case "gathering": {
        var n = worker.gatherNode
        if (!n || n.iron <= 0) { worker.gatherState = "toDeposit"; return }
        worker.gatherTimer += dt
        if (worker.gatherTimer >= stats.gatherTime) {
            worker.carried += Economy.takeFromNode(n, stats.carry - worker.carried)
            worker.gatherTimer = 0
            if (worker.carried >= stats.carry || n.iron <= 0) {
                worker.gatherState = "toDropOff"
                worker.gatherArrived = false
            }
        }
        break
    }
    case "toDropOff": {
        var home = ctx.findDropOff(worker)
        if (!home) { stop(worker); worker.play("Idle"); return }
        if (ctx.gap(worker, home) <= REACH + 0.6) {
            worker.path = []
            ctx.deposit(worker, worker.carried)
            worker.carried = 0
            worker.gatherState = (worker.gatherNode && worker.gatherNode.iron > 0) ? "toDeposit" : "toDeposit"
            worker.gatherArrived = false
            if (!worker.gatherNode || worker.gatherNode.iron <= 0) {
                worker.gatherNode = ctx.findDeposit(worker)
                if (!worker.gatherNode) { stop(worker); worker.play("Idle") }
            }
        } else if (!worker.path.length) {
            worker.moveTo(ctx.approach(worker, home))
        }
        break
    }
    default:
        break
    }
}
