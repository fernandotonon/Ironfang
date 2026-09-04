import QtQuick
import QtQuick3D

import QtQuick.Timeline

Node {
    id: node
    // --- Ironfang runtime API (added by scripts/import-runtime.py) ---
    property string clip: "Idle"
    readonly property var clips: ["Attack", "Death", "Hit", "Idle", "Walk"]
    signal clipFinished(string name)

    // Resources
    Texture {
        id: qtmesh_gen3d_1_1788480777013_diffuse_png_texture
        objectName: "qtmesh_gen3d_1_1788480777013_diffuse.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_1_1788480777013_diffuse.png"
    }
    Texture {
        id: qtmesh_gen3d_1_1788480777013_roughness_png_texture
        objectName: "qtmesh_gen3d_1_1788480777013_roughness.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_1_1788480777013_roughness.png"
    }
    Texture {
        id: qtmesh_gen3d_1_1788480777013_normal_png_texture
        objectName: "qtmesh_gen3d_1_1788480777013_normal.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_1_1788480777013_normal.png"
    }
    PrincipledMaterial {
        id: qtmesh_gen3d_1_1788480777013_mesh_mat_material
        objectName: "qtmesh_gen3d_1_1788480777013_mesh_mat"
        baseColorMap: qtmesh_gen3d_1_1788480777013_diffuse_png_texture
        metalnessMap: qtmesh_gen3d_1_1788480777013_roughness_png_texture
        roughnessMap: qtmesh_gen3d_1_1788480777013_roughness_png_texture
        roughness: 1
        normalMap: qtmesh_gen3d_1_1788480777013_normal_png_texture
        alphaMode: PrincipledMaterial.Opaque
    }
    Skin {
        id: skin
        joints: [
            hips,
            spine,
            chest,
            leftShoulder,
            rightShoulder,
            leftArm,
            rightArm,
            leftUpLeg,
            rightUpLeg,
            neck,
            leftForeArm,
            rightForeArm,
            leftLeg,
            rightLeg,
            head,
            leftHand,
            rightHand,
            leftFoot,
            rightFoot
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, -0.0101772, 0, 1, 0, -0.0202455, 0, 0, 1, 0.00288791, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.00436959, 0, 1, 0, -0.120519, 0, 0, 1, -0.00300947, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0102671, 0, 1, 0, -0.220793, 0, 0, 1, 0.0173401, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.00119473, 0, 1, 0, -0.280958, 0, 0, 1, 0.0206584, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0489122, 0, 1, 0, -0.280958, 0, 0, 1, 0.0206584, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.200515, 0, 1, 0, -0.280958, 0, 0, 1, 0.000403207, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.200341, 0, 1, 0, -0.280958, 0, 0, 1, 0.000403207, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0302431, 0, 1, 0, -0.000190675, 0, 0, 1, 0.00333594, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.00984243, 0, 1, 0, -0.000190675, 0, 0, 1, 0.00333594, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0124252, 0, 1, 0, -0.341122, 0, 0, 1, 0.0257733, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.320771, 0, 1, 0, -0.280958, 0, 0, 1, 0.000403207, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.320598, 0, 1, 0, -0.280958, 0, 0, 1, 0.000403207, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.080258, 0, 1, 0, 0.230439, 0, 0, 1, 0.000403207, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0800842, 0, 1, 0, 0.230439, 0, 0, 1, 0.000403207, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.000506139, 0, 1, 0, -0.421341, 0, 0, 1, 0.0103024, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.431007, 0, 1, 0, -0.280958, 0, 0, 1, 0.000403207, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.430833, 0, 1, 0, -0.280958, 0, 0, 1, 0.000403207, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.080258, 0, 1, 0, 0.46107, 0, 0, 1, -0.0095897, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0800842, 0, 1, 0, 0.46107, 0, 0, 1, -0.0095897, 0, 0, 0, 1)
        ]
    }

    // Nodes:
    Node {
        id: a9
        objectName: "a9"
        Node {
            id: orc_Archer
            objectName: "Orc Archer"
            Node {
                id: hips
                objectName: "Hips"
                position: Qt.vector3d(0.0101772, 0.0202455, -0.00288791)
                Node {
                    id: spine
                    objectName: "Spine"
                    position: Qt.vector3d(-0.0058076, 0.100274, 0.00589738)
                    Node {
                        id: chest
                        objectName: "Chest"
                        position: Qt.vector3d(-0.0146367, 0.100274, -0.0203495)
                        Node {
                            id: neck
                            objectName: "Neck"
                            position: Qt.vector3d(-0.0021581, 0.120329, -0.00843324)
                            Node {
                                id: head
                                objectName: "Head"
                                position: Qt.vector3d(0.011919, 0.0802192, 0.0154709)
                            }
                        }
                        Node {
                            id: leftShoulder
                            objectName: "LeftShoulder"
                            position: Qt.vector3d(0.0114618, 0.0601644, -0.00331832)
                            Node {
                                id: leftArm
                                objectName: "LeftArm"
                                position: Qt.vector3d(0.19932, 0, 0.0202552)
                                Node {
                                    id: leftForeArm
                                    objectName: "LeftForeArm"
                                    position: Qt.vector3d(0.120257, 0, 0)
                                    Node {
                                        id: leftHand
                                        objectName: "LeftHand"
                                        position: Qt.vector3d(0.110235, 0, 0)
                                    }
                                }
                            }
                        }
                        Node {
                            id: rightShoulder
                            objectName: "RightShoulder"
                            position: Qt.vector3d(-0.0386452, 0.0601644, -0.00331832)
                            Node {
                                id: rightArm
                                objectName: "RightArm"
                                position: Qt.vector3d(-0.151429, 0, 0.0202552)
                                Node {
                                    id: rightForeArm
                                    objectName: "RightForeArm"
                                    position: Qt.vector3d(-0.120257, 0, 0)
                                    Node {
                                        id: rightHand
                                        objectName: "RightHand"
                                        position: Qt.vector3d(-0.110235, 0, 0)
                                    }
                                }
                            }
                        }
                    }
                }
                Node {
                    id: leftUpLeg
                    objectName: "LeftUpLeg"
                    position: Qt.vector3d(0.0200659, -0.0200548, -0.000448025)
                    Node {
                        id: leftLeg
                        objectName: "LeftLeg"
                        position: Qt.vector3d(0.0500149, -0.23063, 0.00293273)
                        Node {
                            id: leftFoot
                            objectName: "LeftFoot"
                            position: Qt.vector3d(0, -0.23063, 0.0099929)
                        }
                    }
                }
                Node {
                    id: rightUpLeg
                    objectName: "RightUpLeg"
                    position: Qt.vector3d(-0.0200196, -0.0200548, -0.000448025)
                    Node {
                        id: rightLeg
                        objectName: "RightLeg"
                        position: Qt.vector3d(-0.0702418, -0.23063, 0.00293273)
                        Node {
                            id: rightFoot
                            objectName: "RightFoot"
                            position: Qt.vector3d(0, -0.23063, 0.0099929)
                        }
                    }
                }
            }
        }
        Model {
            id: a9_mesh
            objectName: "a9_mesh"
            source: "meshes/meshes_0__mesh.mesh"
            pickable: true
            skin: skin
            materials: [
                qtmesh_gen3d_1_1788480777013_mesh_mat_material
            ]
        }
    }

    // Animations:
    Timeline {
        id: attack_timeline
        objectName: "Attack"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1467
        currentFrame: 0
        enabled: node.clip === "Attack"
        animations: TimelineAnimation {
            duration: 1467
            from: 0
            to: 1467
            running: node.clip === "Attack"
            loops: 1
            // deferred: the handler usually switches `clip`, which drives `running`
            onFinished: Qt.callLater(function() { node.clipFinished("Attack") })
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_0.qad"
        }
        KeyframeGroup {
            target: chest
            property: "rotation"
            keyframeSource: "animations/chest_rotation_0.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_0.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_0.qad"
        }
    }
    Timeline {
        id: death_timeline
        objectName: "Death"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 2467
        currentFrame: 0
        enabled: node.clip === "Death"
        animations: TimelineAnimation {
            duration: 2467
            from: 0
            to: 2467
            running: node.clip === "Death"
            loops: 1
            // deferred: the handler usually switches `clip`, which drives `running`
            onFinished: Qt.callLater(function() { node.clipFinished("Death") })
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_1.qad"
        }
        KeyframeGroup {
            target: chest
            property: "rotation"
            keyframeSource: "animations/chest_rotation_1.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_1.qad"
        }
        KeyframeGroup {
            target: hips
            property: "position"
            keyframeSource: "animations/hips_position_1.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_1.qad"
        }
    }
    Timeline {
        id: hit_timeline
        objectName: "Hit"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 767
        currentFrame: 0
        enabled: node.clip === "Hit"
        animations: TimelineAnimation {
            duration: 767
            from: 0
            to: 767
            running: node.clip === "Hit"
            loops: 1
            // deferred: the handler usually switches `clip`, which drives `running`
            onFinished: Qt.callLater(function() { node.clipFinished("Hit") })
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_2.qad"
        }
        KeyframeGroup {
            target: chest
            property: "rotation"
            keyframeSource: "animations/chest_rotation_2.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_2.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_2.qad"
        }
    }
    Timeline {
        id: idle_timeline
        objectName: "Idle"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 2967
        currentFrame: 0
        enabled: node.clip === "Idle"
        animations: TimelineAnimation {
            duration: 2967
            from: 0
            to: 2967
            running: node.clip === "Idle"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_3.qad"
        }
    }
    Timeline {
        id: walk_timeline
        objectName: "Walk"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 967
        currentFrame: 0
        enabled: node.clip === "Walk"
        animations: TimelineAnimation {
            duration: 967
            from: 0
            to: 967
            running: node.clip === "Walk"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_4.qad"
        }
        KeyframeGroup {
            target: chest
            property: "rotation"
            keyframeSource: "animations/chest_rotation_4.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_4.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_4.qad"
        }
    }
}
