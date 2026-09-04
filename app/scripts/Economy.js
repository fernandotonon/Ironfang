// Iron accounting for one side. `state` is a plain object { iron, gathered, spent }.
.pragma library

function create(startIron) {
    return { iron: startIron || 0, gathered: 0, spent: 0 }
}

function canAfford(state, cost) {
    return cost >= 0 && state.iron >= cost
}

// Withdraws `cost`; returns false and leaves the state untouched when it cannot be paid.
function spend(state, cost) {
    if (!canAfford(state, cost)) return false
    state.iron -= cost
    state.spent += cost
    return true
}

function deposit(state, amount) {
    if (!(amount > 0)) return
    state.iron += amount
    state.gathered += amount
}

function refund(state, amount) {
    if (!(amount > 0)) return
    state.iron += amount
    state.spent -= amount
}

// Takes up to `amount` from a resource node ({ iron }); returns what was actually taken.
function takeFromNode(node, amount) {
    var take = Math.max(0, Math.min(amount, node.iron))
    node.iron -= take
    return take
}
