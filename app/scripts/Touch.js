// Touch "smart tap" decision - what a single tap means, given what is selected.
// Pure function so the rule is testable; the game wires the returned action to its commands.
//   tapped:    entity under the finger or null (fields: isUnit, isBuilding, team, alive, stats, queue)
//   selection: { units: number of own selected units, producer: own selected producer or null,
//                soleUnit: the only selected entity if exactly one own unit is selected, else null }
//   ground:    true when the tap hit the map (there is always ground under a tap on the world)
// Returns { action, ... } with action one of:
//   select | deselect | order | rally | none
.pragma library

function decide(tapped, selection, ground) {
    // Own things are always selectable - that is how you switch between groups on a phone.
    if (tapped && tapped.team === "player" && tapped.alive !== false) {
        if (selection.soleUnit && tapped === selection.soleUnit)
            return { action: "deselect" }
        // return-iron shortcut: workers selected + tapping the drop-off fortress = return
        if (tapped.isBuilding && tapped.stats && tapped.stats.dropOff && selection.units > 0)
            return { action: "order" }
        return { action: "select", entity: tapped }
    }
    if (selection.units > 0) {
        // enemy, deposit, ground: the obvious order for that target
        if (tapped || ground) return { action: "order" }
        return { action: "none" }
    }
    if (selection.producer) {
        if ((tapped && tapped.isBuilding && tapped.stats && tapped.stats.resource) || (!tapped && ground))
            return { action: "rally" }
        return { action: "none" }
    }
    // nothing useful selected: an empty tap does nothing (never an accidental deselect)
    return { action: "none" }
}
