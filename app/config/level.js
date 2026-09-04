// The one map of the MVP. Positions in metres on a `size` x `size` ground plane, origin at a
// corner, +x right, +z towards the camera (south). Player base south-west, enemy north-east.
.pragma library

var layout = {
    size: 64,
    cameraStart: { x: 18, z: 50 },
    player: {
        fortress: { x: 13, z: 51 },
        foundry:  { x: 25, z: 56 },
        rally:    { x: 24, z: 47 },
        deposits: [ { x: 6, z: 38 }, { x: 21, z: 41 }, { x: 8, z: 59 } ],
        startUnits: [
            { type: "goblin_worker", x: 15, z: 44 }, { type: "goblin_worker", x: 17, z: 44 },
            { type: "goblin_worker", x: 19, z: 45 }, { type: "orc_warrior",   x: 22, z: 48 }
        ]
    },
    enemy: {
        fortress: { x: 51, z: 12 },
        rally:    { x: 43, z: 20 },
        deposits: [ { x: 57, z: 25 }, { x: 40, z: 6 } ],
        startUnits: [
            { type: "orc_warrior", x: 46, z: 18 }, { type: "orc_warrior", x: 49, z: 20 },
            { type: "orc_archer",  x: 44, z: 16 }
        ]
    },
    obstacles: [
        { type: "rocks_large", x: 32, z: 33 }, { type: "rocks_large", x: 41, z: 45 },
        { type: "rocks_large", x: 9,  z: 9 },  { type: "rocks_small", x: 22, z: 27 },
        { type: "rocks_small", x: 56, z: 51 }, { type: "rocks_small", x: 36, z: 12 },
        { type: "dead_tree",   x: 12, z: 22 }, { type: "dead_tree",   x: 48, z: 40 },
        { type: "dead_tree",   x: 31, z: 59 }, { type: "dead_tree",   x: 60, z: 34 },
        { type: "broken_cart", x: 34, z: 21 }
    ]
}
