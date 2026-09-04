// Navigation grid: world<->grid conversion, obstacle blocking, A* around obstacles,
// unreachable destinations, group destination distribution.
import QtQuick
import QtTest
import Clayground.Algorithm
import "../app/scripts/NavGrid.js" as Nav

TestCase {
    name: "NavGrid"

    GridPathfinder { id: pf; diagonal: true }

    function init() {
        Nav.init(20, 20, 1.0)
        pf.columns = Nav.cols
        pf.rows = Nav.rows
        pf.walkableData = Nav.walkableData()
    }

    function test_grid_conversion_roundtrip() {
        compare(Nav.cols, 20)
        compare(Nav.rows, 20)
        const g = Nav.toGrid(3.7, 12.2)
        compare(g.gx, 3); compare(g.gz, 12)
        const w = Nav.toWorld(g.gx, g.gz)
        fuzzyCompare(w.x, 3.5, 1e-9); fuzzyCompare(w.z, 12.5, 1e-9)
        verify(Nav.isBlocked(-1, 5))          // outside the map is blocked
        verify(Nav.isBlocked(5, 20))
        verify(!Nav.isBlocked(5, 5))
    }

    function test_block_rect_marks_cells() {
        Nav.blockRect(4, 4, 8, 6)
        verify(Nav.isBlocked(4.5, 4.5))
        verify(Nav.isBlocked(7.9, 5.9))
        verify(!Nav.isBlocked(8.5, 5.5))
        verify(!Nav.isBlocked(3.5, 5.5))
        pf.walkableData = Nav.walkableData()
        compare(pf.walkableData[4 * Nav.cols + 4], 1)
    }

    function test_path_goes_around_obstacle() {
        // a wall from z=5..15 at x=10..11 - the straight line from (2,10) to (18,10) crosses it
        Nav.blockRect(10, 5, 11, 15)
        pf.walkableData = Nav.walkableData()
        const path = Nav.findPath(pf, 2.5, 10.5, 18.5, 10.5)
        verify(path.length > 0, "path found")
        for (const p of path)
            verify(!Nav.isBlocked(p.x, p.z), "waypoint " + p.x + "," + p.z + " is walkable")
        const last = path[path.length - 1]
        fuzzyCompare(last.x, 18.5, 1e-9); fuzzyCompare(last.z, 10.5, 1e-9)
        // the wall spans z = 5..15, so a real detour must pass above or below it
        verify(path.some(p => p.z < 5 || p.z > 15), "path detours around the wall")
    }

    function test_unreachable_returns_empty() {
        // wall off the right half completely
        Nav.blockRect(10, 0, 11, 20)
        pf.walkableData = Nav.walkableData()
        const path = Nav.findPath(pf, 2.5, 2.5, 18.5, 18.5)
        compare(path.length, 0)
    }

    function test_target_inside_obstacle_snaps_to_edge() {
        Nav.blockRect(8, 8, 12, 12)
        pf.walkableData = Nav.walkableData()
        const path = Nav.findPath(pf, 2.5, 2.5, 10, 10)
        verify(path.length > 0)
        const last = path[path.length - 1]
        verify(!Nav.isBlocked(last.x, last.z))
    }

    function test_same_cell_is_direct() {
        const path = Nav.findPath(pf, 5.2, 5.2, 5.7, 5.7)
        compare(path.length, 1)
        fuzzyCompare(path[0].x, 5.7, 1e-9)
    }

    function test_distribute_spreads_and_avoids_blocked() {
        Nav.blockRect(10, 10, 11, 11)
        const d = Nav.distribute(10.5, 10.5, 9, 1.0)
        compare(d.length, 9)
        const seen = {}
        for (const p of d) {
            verify(!Nav.isBlocked(p.x, p.z))
            const k = p.x.toFixed(2) + "," + p.z.toFixed(2)
            verify(!seen[k], "destinations are distinct")
            seen[k] = true
        }
    }
}
