import QtQuick
import QtQuick3D

import QtQuick.Timeline

Node {
    id: node
    // --- Ironfang runtime API (added by scripts/import-runtime.py) ---
    property string clip: "Idle"
    readonly property var clips: ["Attack", "Death", "Gather", "Hit", "Idle", "Walk"]
    signal clipFinished(string name)

    // Resources
    Texture {
        id: qtmesh_gen3d_1_1788479224751_diffuse_png_texture
        objectName: "qtmesh_gen3d_1_1788479224751_diffuse.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_1_1788479224751_diffuse.png"
    }
    Texture {
        id: qtmesh_gen3d_1_1788479224751_roughness_png_texture
        objectName: "qtmesh_gen3d_1_1788479224751_roughness.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_1_1788479224751_roughness.png"
    }
    Texture {
        id: qtmesh_gen3d_1_1788479224751_normal_png_texture
        objectName: "qtmesh_gen3d_1_1788479224751_normal.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_1_1788479224751_normal.png"
    }
    PrincipledMaterial {
        id: qtmesh_gen3d_1_1788479224751_mesh_mat_material
        objectName: "qtmesh_gen3d_1_1788479224751_mesh_mat"
        baseColorMap: qtmesh_gen3d_1_1788479224751_diffuse_png_texture
        metalnessMap: qtmesh_gen3d_1_1788479224751_roughness_png_texture
        roughnessMap: qtmesh_gen3d_1_1788479224751_roughness_png_texture
        roughness: 1
        normalMap: qtmesh_gen3d_1_1788479224751_normal_png_texture
        alphaMode: PrincipledMaterial.Opaque
    }
    Skin {
        id: skin
        joints: [
            hips,
            spine,
            chest,
            leftShoulder,
            leftUpLeg,
            neck,
            leftArm,
            leftLeg,
            rightForeArm,
            head,
            leftForeArm,
            rightShoulder,
            leftFoot,
            rightUpLeg,
            rightHand,
            rightFoot
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, -0.141212, 0, 1, 0, -0.0200084, 0, 0, 1, 0.0362561, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0113871, 0, 1, 0, -0.120203, 0, 0, 1, 0.0272245, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0941683, 0, 1, 0, -0.220398, 0, 0, 1, 0.0331814, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.151394, 0, 1, 0, -0.280515, 0, 0, 1, 0.0262645, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.165932, 0, 1, 0, 3.05772e-05, 0, 0, 1, 0.0356441, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.143136, 0, 1, 0, -0.340632, 0, 0, 1, -0.0195245, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.183672, 0, 1, 0, -0.280515, 0, 0, 1, 0.00105015, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0693155, 0, 1, 0, 0.230479, 0, 0, 1, 0.00105015, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.311872, 0, 1, 0, -0.280515, 0, 0, 1, 0.00105015, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.14512, 0, 1, 0, -0.420788, 0, 0, 1, -0.00439188, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.298028, 0, 1, 0, -0.280515, 0, 0, 1, 0.00105015, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.103746, 0, 1, 0, -0.280515, 0, 0, 1, 0.0262645, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0693155, 0, 1, 0, 0.460927, 0, 0, 1, -0.0134069, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.127813, 0, 1, 0, 3.05772e-05, 0, 0, 1, 0.0356441, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.416698, 0, 1, 0, -0.280515, 0, 0, 1, 0.00105015, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0831595, 0, 1, 0, 0.460927, 0, 0, 1, -0.0134069, 0, 0, 0, 1)
        ]
    }

    // Nodes:
    Node {
        id: a11
        objectName: "a11"
        Node {
            id: goblin
            objectName: "Goblin"
            Node {
                id: hips
                objectName: "Hips"
                position: Qt.vector3d(0.141212, 0.0200084, -0.0362561)
                Node {
                    id: spine
                    objectName: "Spine"
                    position: Qt.vector3d(-0.129825, 0.100195, 0.00903152)
                    Node {
                        id: chest
                        objectName: "Chest"
                        position: Qt.vector3d(0.0827812, 0.100195, -0.00595684)
                        Node {
                            id: neck
                            objectName: "Neck"
                            position: Qt.vector3d(0.0489677, 0.120234, 0.0527059)
                            Node {
                                id: head
                                objectName: "Head"
                                position: Qt.vector3d(0.00198361, 0.0801559, -0.0151326)
                            }
                        }
                        Node {
                            id: leftShoulder
                            objectName: "LeftShoulder"
                            position: Qt.vector3d(0.0572261, 0.0601169, 0.00691682)
                            Node {
                                id: leftArm
                                objectName: "LeftArm"
                                position: Qt.vector3d(0.0322773, 0, 0.0252144)
                                Node {
                                    id: leftForeArm
                                    objectName: "LeftForeArm"
                                    position: Qt.vector3d(0.114356, 0, 0)
                                    Node {
                                        id: leftHand
                                        objectName: "LeftHand"
                                        position: Qt.vector3d(0.104827, 0, 0)
                                    }
                                }
                            }
                        }
                        Node {
                            id: rightShoulder
                            objectName: "RightShoulder"
                            position: Qt.vector3d(0.00957768, 0.0601169, 0.00691682)
                        }
                    }
                }
                Node {
                    id: leftUpLeg
                    objectName: "LeftUpLeg"
                    position: Qt.vector3d(0.0247197, -0.020039, 0.000611905)
                    Node {
                        id: leftLeg
                        objectName: "LeftLeg"
                        position: Qt.vector3d(-0.0966164, -0.230448, 0.034594)
                        Node {
                            id: leftFoot
                            objectName: "LeftFoot"
                            position: Qt.vector3d(0, -0.230448, 0.014457)
                        }
                    }
                }
                Node {
                    id: rightUpLeg
                    objectName: "RightUpLeg"
                    position: Qt.vector3d(-0.0133991, -0.020039, 0.000611905)
                }
            }
        }
        Node {
            id: rightArm
            objectName: "RightArm"
            position: Qt.vector3d(-0.197516, 0.280515, -0.00105015)
            Node {
                id: rightForeArm
                objectName: "RightForeArm"
                position: Qt.vector3d(-0.114356, 2.98023e-08, 0)
                Node {
                    id: rightHand
                    objectName: "RightHand"
                    position: Qt.vector3d(-0.104827, 0, 0)
                }
            }
        }
        Node {
            id: rightLeg
            objectName: "RightLeg"
            position: Qt.vector3d(-0.0831595, -0.230479, -0.00105015)
            Node {
                id: rightFoot
                objectName: "RightFoot"
                position: Qt.vector3d(0, -0.230448, 0.014457)
            }
        }
        Model {
            id: a11_mesh
            objectName: "a11_mesh"
            source: "meshes/meshes_0__mesh.mesh"
            pickable: true
            skin: skin
            materials: [
                qtmesh_gen3d_1_1788479224751_mesh_mat_material
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
            onFinished: Qt.callLater(function() { if (node) node.clipFinished("Attack") })
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_0.qad"
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
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_0.qad"
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
            onFinished: Qt.callLater(function() { if (node) node.clipFinished("Death") })
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_1.qad"
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
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_1.qad"
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
        id: gather_timeline
        objectName: "Gather"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1967
        currentFrame: 0
        enabled: node.clip === "Gather"
        animations: TimelineAnimation {
            duration: 1967
            from: 0
            to: 1967
            running: node.clip === "Gather"
            loops: 1
            // deferred: the handler usually switches `clip`, which drives `running`
            onFinished: Qt.callLater(function() { if (node) node.clipFinished("Gather") })
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_2.qad"
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
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_2.qad"
        }
        KeyframeGroup {
            target: hips
            property: "position"
            keyframeSource: "animations/hips_position_2.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_2.qad"
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
            onFinished: Qt.callLater(function() { if (node) node.clipFinished("Hit") })
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_3.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_3.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_3.qad"
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
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            Keyframe {
                frame: 0
                value: Qt.quaternion(0.769765, -0.464996, 0.433891, 0.05458)
            }
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            Keyframe {
                frame: 0
                value: Qt.quaternion(0.965684, -0.106208, -0.164431, -0.170692)
            }
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            Keyframe {
                frame: 0
                value: Qt.quaternion(0.794462, -0.556634, 0.239462, 0.0405757)
            }
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            Keyframe {
                frame: 0
                value: Qt.quaternion(0.77076, -0.636817, 0.00124095, 0.019781)
            }
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
            keyframeSource: "animations/rightFoot_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightShoulder
            property: "rotation"
            keyframeSource: "animations/rightShoulder_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_5.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftShoulder
            property: "rotation"
            keyframeSource: "animations/leftShoulder_rotation_5.qad"
        }
        KeyframeGroup {
            target: chest
            property: "rotation"
            keyframeSource: "animations/chest_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_5.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_5.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_5.qad"
        }
    }
}
