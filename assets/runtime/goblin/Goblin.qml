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
        id: qtmesh_gen3d_2_1788575330441_diffuse_png_texture
        objectName: "qtmesh_gen3d_2_1788575330441_diffuse.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_2_1788575330441_diffuse.png"
    }
    Texture {
        id: qtmesh_gen3d_2_1788575330441_roughness_png_texture
        objectName: "qtmesh_gen3d_2_1788575330441_roughness.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_2_1788575330441_roughness.png"
    }
    Texture {
        id: qtmesh_gen3d_2_1788575330441_normal_png_texture
        objectName: "qtmesh_gen3d_2_1788575330441_normal.png"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_2_1788575330441_normal.png"
    }
    PrincipledMaterial {
        id: qtmesh_gen3d_2_1788575330441_mesh_mat_material
        objectName: "qtmesh_gen3d_2_1788575330441_mesh_mat"
        baseColorMap: qtmesh_gen3d_2_1788575330441_diffuse_png_texture
        metalnessMap: qtmesh_gen3d_2_1788575330441_roughness_png_texture
        roughnessMap: qtmesh_gen3d_2_1788575330441_roughness_png_texture
        roughness: 1
        normalMap: qtmesh_gen3d_2_1788575330441_normal_png_texture
        alphaMode: PrincipledMaterial.Opaque
    }
    Skin {
        id: skin
        joints: [
            hips,
            spine,
            spine1,
            spine2,
            spine3,
            neck,
            head,
            leftArm,
            leftForeArm,
            leftHand,
            joint_10,
            joint_11,
            joint_12,
            joint_13,
            joint_14,
            joint_15,
            joint_16,
            joint_17,
            joint_18,
            joint_19,
            joint_20,
            joint_21,
            joint_22,
            joint_23,
            joint_24,
            joint_25,
            joint_26,
            joint_27,
            joint_28,
            rightArm,
            rightForeArm,
            rightHand,
            joint_32,
            joint_33,
            joint_34,
            joint_35,
            joint_36,
            joint_37,
            joint_38,
            joint_39,
            joint_40,
            joint_41,
            joint_42,
            joint_43,
            joint_44,
            joint_45,
            joint_46,
            joint_47,
            joint_48,
            joint_49,
            joint_50,
            leftUpLeg,
            leftLeg,
            leftFoot,
            joint_54,
            joint_55,
            rightUpLeg,
            rightLeg,
            rightFoot,
            joint_59,
            joint_60
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, -0.00170332, 0, 1, 0, -0.0260162, 0, 0, 1, -0.0074598, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.00170332, 0, 1, 0, -0.0651776, 0, 0, 1, -0.0113759, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.00170332, 0, 1, 0, -0.108255, 0, 0, 1, -0.0152921, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.00170332, 0, 1, 0, -0.159165, 0, 0, 1, -0.0192082, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.00170332, 0, 1, 0, -0.217907, 0, 0, 1, -0.0231244, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.00170332, 0, 1, 0, -0.249236, 0, 0, 1, -0.0152921, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.00170332, 0, 1, 0, -0.351056, 0, 0, 1, 0.0160371, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0296258, 0, 1, 0, -0.202243, 0, 0, 1, -0.0231244, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0922841, 0, 1, 0, -0.178746, 0, 0, 1, -0.0231244, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.217601, 0, 1, 0, -0.139584, 0, 0, 1, -0.0387889, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.362498, 0, 1, 0, -0.131752, 0, 0, 1, -0.0309567, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.378163, 0, 1, 0, -0.147417, 0, 0, 1, -0.0152921, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.389911, 0, 1, 0, -0.159165, 0, 0, 1, -0.00354365, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.397743, 0, 1, 0, -0.178746, 0, 0, 1, 0.00820478, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.405576, 0, 1, 0, -0.190494, 0, 0, 1, 0.0121209, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.425156, 0, 1, 0, -0.155249, 0, 0, 1, -0.0152921, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.448653, 0, 1, 0, -0.159165, 0, 0, 1, -0.0113759, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.468234, 0, 1, 0, -0.163081, 0, 0, 1, 0.00037249, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.483898, 0, 1, 0, -0.166997, 0, 0, 1, 0.00820478, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.429072, 0, 1, 0, -0.139584, 0, 0, 1, -0.0270405, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.452569, 0, 1, 0, -0.139584, 0, 0, 1, -0.0192082, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.476066, 0, 1, 0, -0.139584, 0, 0, 1, -0.0113759, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.495647, 0, 1, 0, -0.139584, 0, 0, 1, -0.0074598, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.429072, 0, 1, 0, -0.120004, 0, 0, 1, -0.0309567, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.452569, 0, 1, 0, -0.116087, 0, 0, 1, -0.0231244, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.47215, 0, 1, 0, -0.112171, 0, 0, 1, -0.0152921, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.42124, 0, 1, 0, -0.104339, 0, 0, 1, -0.0309567, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.440821, 0, 1, 0, -0.0925906, 0, 0, 1, -0.0270405, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.456485, 0, 1, 0, -0.0847583, 0, 0, 1, -0.0231244, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0330325, 0, 1, 0, -0.202243, 0, 0, 1, -0.0231244, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0956907, 0, 1, 0, -0.178746, 0, 0, 1, -0.0231244, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.221007, 0, 1, 0, -0.139584, 0, 0, 1, -0.0387889, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.365905, 0, 1, 0, -0.131752, 0, 0, 1, -0.0309567, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.381569, 0, 1, 0, -0.147417, 0, 0, 1, -0.0192082, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.393318, 0, 1, 0, -0.159165, 0, 0, 1, -0.0074598, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.40115, 0, 1, 0, -0.178746, 0, 0, 1, 0.00428863, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.408982, 0, 1, 0, -0.190494, 0, 0, 1, 0.0121209, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.428563, 0, 1, 0, -0.155249, 0, 0, 1, -0.0192082, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.45206, 0, 1, 0, -0.159165, 0, 0, 1, -0.0152921, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.47164, 0, 1, 0, -0.163081, 0, 0, 1, -0.00354365, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.487305, 0, 1, 0, -0.166997, 0, 0, 1, 0.00428863, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.432479, 0, 1, 0, -0.139584, 0, 0, 1, -0.0270405, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.455976, 0, 1, 0, -0.139584, 0, 0, 1, -0.0192082, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.479473, 0, 1, 0, -0.139584, 0, 0, 1, -0.0074598, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.499053, 0, 1, 0, -0.139584, 0, 0, 1, 0.00428863, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.432479, 0, 1, 0, -0.120004, 0, 0, 1, -0.0270405, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.455976, 0, 1, 0, -0.112171, 0, 0, 1, -0.0231244, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.475557, 0, 1, 0, -0.108255, 0, 0, 1, -0.0152921, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.424647, 0, 1, 0, -0.100423, 0, 0, 1, -0.0309567, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.444227, 0, 1, 0, -0.0925906, 0, 0, 1, -0.0270405, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.459892, 0, 1, 0, -0.0847583, 0, 0, 1, -0.0231244, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0413743, 0, 1, 0, -0.00251931, 0, 0, 1, -0.0074598, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0844518, 0, 1, 0, 0.169791, 0, 0, 1, 0.000372489, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.115781, 0, 1, 0, 0.314688, 0, 0, 1, -0.0427051, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.135362, 0, 1, 0, 0.369514, 0, 0, 1, 0.0395339, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.139278, 0, 1, 0, 0.369514, 0, 0, 1, 0.0708631, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0447809, 0, 1, 0, -0.00251931, 0, 0, 1, -0.0074598, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0878585, 0, 1, 0, 0.169791, 0, 0, 1, 0.000372489, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.119188, 0, 1, 0, 0.314688, 0, 0, 1, -0.0427051, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.138768, 0, 1, 0, 0.369514, 0, 0, 1, 0.0395339, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.142684, 0, 1, 0, 0.369514, 0, 0, 1, 0.0708631, 0, 0, 0, 1)
        ]
    }

    // Nodes:
    Node {
        id: qtmesh_gen3d_2_1788575330441
        objectName: "qtmesh_gen3d_2_1788575330441"
        Node {
            id: hips
            objectName: "Hips"
            position: Qt.vector3d(0.00170332, 0.0260162, 0.0074598)
            Node {
                id: spine
                objectName: "Spine"
                position: Qt.vector3d(0, 0.0391614, 0.00391614)
                Node {
                    id: spine1
                    objectName: "Spine1"
                    position: Qt.vector3d(0, 0.0430776, 0.00391614)
                    Node {
                        id: spine2
                        objectName: "Spine2"
                        position: Qt.vector3d(0, 0.0509099, 0.00391614)
                        Node {
                            id: spine3
                            objectName: "Spine3"
                            position: Qt.vector3d(0, 0.0587422, 0.00391614)
                            Node {
                                id: neck
                                objectName: "Neck"
                                position: Qt.vector3d(0, 0.0313291, -0.00783229)
                                Node {
                                    id: head
                                    objectName: "Head"
                                    position: Qt.vector3d(0, 0.10182, -0.0313291)
                                }
                            }
                        }
                        Node {
                            id: leftArm
                            objectName: "LeftArm"
                            position: Qt.vector3d(-0.0313291, 0.0430776, 0.00391614)
                            Node {
                                id: leftForeArm
                                objectName: "LeftForeArm"
                                position: Qt.vector3d(-0.0626583, -0.0234969, 0)
                                Node {
                                    id: leftHand
                                    objectName: "LeftHand"
                                    position: Qt.vector3d(-0.125317, -0.0391614, 0.0156646)
                                    Node {
                                        id: joint_10
                                        objectName: "joint_10"
                                        position: Qt.vector3d(-0.144897, -0.00783229, -0.00783229)
                                        Node {
                                            id: joint_11
                                            objectName: "joint_11"
                                            position: Qt.vector3d(-0.0156645, 0.0156646, -0.0156646)
                                            Node {
                                                id: joint_12
                                                objectName: "joint_12"
                                                position: Qt.vector3d(-0.0117484, 0.0117484, -0.0117484)
                                                Node {
                                                    id: joint_13
                                                    objectName: "joint_13"
                                                    position: Qt.vector3d(-0.00783229, 0.0195807, -0.0117484)
                                                    Node {
                                                        id: joint_14
                                                        objectName: "joint_14"
                                                        position: Qt.vector3d(-0.00783229, 0.0117484, -0.00391614)
                                                    }
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_15
                                            objectName: "joint_15"
                                            position: Qt.vector3d(-0.0626583, 0.0234969, -0.0156646)
                                            Node {
                                                id: joint_16
                                                objectName: "joint_16"
                                                position: Qt.vector3d(-0.0234969, 0.00391614, -0.00391614)
                                                Node {
                                                    id: joint_17
                                                    objectName: "joint_17"
                                                    position: Qt.vector3d(-0.0195807, 0.00391614, -0.0117484)
                                                    Node {
                                                        id: joint_18
                                                        objectName: "joint_18"
                                                        position: Qt.vector3d(-0.0156646, 0.00391614, -0.00783229)
                                                    }
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_19
                                            objectName: "joint_19"
                                            position: Qt.vector3d(-0.0665744, 0.00783229, -0.00391614)
                                            Node {
                                                id: joint_20
                                                objectName: "joint_20"
                                                position: Qt.vector3d(-0.0234969, 0, -0.00783229)
                                                Node {
                                                    id: joint_21
                                                    objectName: "joint_21"
                                                    position: Qt.vector3d(-0.0234968, 0, -0.00783229)
                                                    Node {
                                                        id: joint_22
                                                        objectName: "joint_22"
                                                        position: Qt.vector3d(-0.0195807, 0, -0.00391614)
                                                    }
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_23
                                            objectName: "joint_23"
                                            position: Qt.vector3d(-0.0665744, -0.0117484, 0)
                                            Node {
                                                id: joint_24
                                                objectName: "joint_24"
                                                position: Qt.vector3d(-0.0234969, -0.00391614, -0.00783229)
                                                Node {
                                                    id: joint_25
                                                    objectName: "joint_25"
                                                    position: Qt.vector3d(-0.0195807, -0.00391614, -0.00783229)
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_26
                                            objectName: "joint_26"
                                            position: Qt.vector3d(-0.0587421, -0.027413, 0)
                                            Node {
                                                id: joint_27
                                                objectName: "joint_27"
                                                position: Qt.vector3d(-0.0195807, -0.0117484, -0.00391614)
                                                Node {
                                                    id: joint_28
                                                    objectName: "joint_28"
                                                    position: Qt.vector3d(-0.0156646, -0.00783229, -0.00391614)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        Node {
                            id: rightArm
                            objectName: "RightArm"
                            position: Qt.vector3d(0.0313291, 0.0430776, 0.00391614)
                            Node {
                                id: rightForeArm
                                objectName: "RightForeArm"
                                position: Qt.vector3d(0.0626583, -0.0234969, 0)
                                Node {
                                    id: rightHand
                                    objectName: "RightHand"
                                    position: Qt.vector3d(0.125317, -0.0391614, 0.0156646)
                                    Node {
                                        id: joint_32
                                        objectName: "joint_32"
                                        position: Qt.vector3d(0.144897, -0.00783229, -0.00783229)
                                        Node {
                                            id: joint_33
                                            objectName: "joint_33"
                                            position: Qt.vector3d(0.0156645, 0.0156646, -0.0117484)
                                            Node {
                                                id: joint_34
                                                objectName: "joint_34"
                                                position: Qt.vector3d(0.0117484, 0.0117484, -0.0117484)
                                                Node {
                                                    id: joint_35
                                                    objectName: "joint_35"
                                                    position: Qt.vector3d(0.00783229, 0.0195807, -0.0117484)
                                                    Node {
                                                        id: joint_36
                                                        objectName: "joint_36"
                                                        position: Qt.vector3d(0.00783229, 0.0117484, -0.00783229)
                                                    }
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_37
                                            objectName: "joint_37"
                                            position: Qt.vector3d(0.0626583, 0.0234969, -0.0117484)
                                            Node {
                                                id: joint_38
                                                objectName: "joint_38"
                                                position: Qt.vector3d(0.0234969, 0.00391614, -0.00391614)
                                                Node {
                                                    id: joint_39
                                                    objectName: "joint_39"
                                                    position: Qt.vector3d(0.0195807, 0.00391614, -0.0117484)
                                                    Node {
                                                        id: joint_40
                                                        objectName: "joint_40"
                                                        position: Qt.vector3d(0.0156646, 0.00391614, -0.00783229)
                                                    }
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_41
                                            objectName: "joint_41"
                                            position: Qt.vector3d(0.0665744, 0.00783229, -0.00391614)
                                            Node {
                                                id: joint_42
                                                objectName: "joint_42"
                                                position: Qt.vector3d(0.0234969, 0, -0.00783229)
                                                Node {
                                                    id: joint_43
                                                    objectName: "joint_43"
                                                    position: Qt.vector3d(0.0234968, 0, -0.0117484)
                                                    Node {
                                                        id: joint_44
                                                        objectName: "joint_44"
                                                        position: Qt.vector3d(0.0195807, 0, -0.0117484)
                                                    }
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_45
                                            objectName: "joint_45"
                                            position: Qt.vector3d(0.0665744, -0.0117484, -0.00391614)
                                            Node {
                                                id: joint_46
                                                objectName: "joint_46"
                                                position: Qt.vector3d(0.0234969, -0.00783228, -0.00391614)
                                                Node {
                                                    id: joint_47
                                                    objectName: "joint_47"
                                                    position: Qt.vector3d(0.0195807, -0.00391614, -0.00783229)
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_48
                                            objectName: "joint_48"
                                            position: Qt.vector3d(0.0587421, -0.0313291, 0)
                                            Node {
                                                id: joint_49
                                                objectName: "joint_49"
                                                position: Qt.vector3d(0.0195807, -0.00783228, -0.00391614)
                                                Node {
                                                    id: joint_50
                                                    objectName: "joint_50"
                                                    position: Qt.vector3d(0.0156645, -0.00783229, -0.00391614)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Node {
                id: leftUpLeg
                objectName: "LeftUpLeg"
                position: Qt.vector3d(-0.0430776, -0.0234969, 0)
                Node {
                    id: leftLeg
                    objectName: "LeftLeg"
                    position: Qt.vector3d(-0.0430776, -0.17231, -0.00783229)
                    Node {
                        id: leftFoot
                        objectName: "LeftFoot"
                        position: Qt.vector3d(-0.0313291, -0.144897, 0.0430776)
                        Node {
                            id: joint_54
                            objectName: "joint_54"
                            position: Qt.vector3d(-0.0195807, -0.054826, -0.082239)
                            Node {
                                id: joint_55
                                objectName: "joint_55"
                                position: Qt.vector3d(-0.00391614, 0, -0.0313291)
                            }
                        }
                    }
                }
            }
            Node {
                id: rightUpLeg
                objectName: "RightUpLeg"
                position: Qt.vector3d(0.0430776, -0.0234969, 0)
                Node {
                    id: rightLeg
                    objectName: "RightLeg"
                    position: Qt.vector3d(0.0430776, -0.17231, -0.00783229)
                    Node {
                        id: rightFoot
                        objectName: "RightFoot"
                        position: Qt.vector3d(0.0313291, -0.144897, 0.0430776)
                        Node {
                            id: joint_59
                            objectName: "joint_59"
                            position: Qt.vector3d(0.0195807, -0.054826, -0.082239)
                            Node {
                                id: joint_60
                                objectName: "joint_60"
                                position: Qt.vector3d(0.00391614, 0, -0.0313291)
                            }
                        }
                    }
                }
            }
        }
        Model {
            id: qtmesh_gen3d_2_1788575330441_mesh
            objectName: "qtmesh_gen3d_2_1788575330441_mesh"
            source: "meshes/meshes_0__mesh.mesh"
            pickable: true
            skin: skin
            materials: [
                qtmesh_gen3d_2_1788575330441_mesh_mat_material
            ]
        }
    }

    // Animations:
    Timeline {
        id: attack_timeline
        objectName: "Attack"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1367
        currentFrame: 0
        enabled: node.clip === "Attack"
        animations: TimelineAnimation {
            duration: 1367
            from: 0
            to: 1367
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
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_0.qad"
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
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_0.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: spine2
            property: "rotation"
            keyframeSource: "animations/spine2_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: spine3
            property: "rotation"
            keyframeSource: "animations/spine3_rotation_0.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_0.qad"
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
        endFrame: 701
        currentFrame: 0
        enabled: node.clip === "Death"
        animations: TimelineAnimation {
            duration: 701
            from: 0
            to: 701
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
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_1.qad"
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
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_1.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: spine2
            property: "rotation"
            keyframeSource: "animations/spine2_rotation_1.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: spine3
            property: "rotation"
            keyframeSource: "animations/spine3_rotation_1.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_1.qad"
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
        endFrame: 3967
        currentFrame: 0
        enabled: node.clip === "Gather"
        animations: TimelineAnimation {
            duration: 3967
            from: 0
            to: 3967
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
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_2.qad"
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
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_2.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: spine2
            property: "rotation"
            keyframeSource: "animations/spine2_rotation_2.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_2.qad"
        }
        KeyframeGroup {
            target: spine3
            property: "rotation"
            keyframeSource: "animations/spine3_rotation_2.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_2.qad"
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
        endFrame: 534
        currentFrame: 0
        enabled: node.clip === "Hit"
        animations: TimelineAnimation {
            duration: 534
            from: 0
            to: 534
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
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_3.qad"
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
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_3.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_3.qad"
        }
        KeyframeGroup {
            target: hips
            property: "position"
            keyframeSource: "animations/hips_position_3.qad"
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
        endFrame: 3967
        currentFrame: 0
        enabled: node.clip === "Idle"
        animations: TimelineAnimation {
            duration: 3967
            from: 0
            to: 3967
            running: node.clip === "Idle"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightUpLeg
            property: "rotation"
            keyframeSource: "animations/rightUpLeg_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftFoot
            property: "rotation"
            keyframeSource: "animations/leftFoot_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_4.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            Keyframe {
                frame: 0
                value: Qt.quaternion(0.987688, -3.12174e-11, 0.0112791, 0.156027)
            }
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            Keyframe {
                frame: 0
                value: Qt.quaternion(0.987688, -3.12174e-11, -0.0112791, -0.156027)
            }
        }
    }
    Timeline {
        id: walk_timeline
        objectName: "Walk"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1034
        currentFrame: 0
        enabled: node.clip === "Walk"
        animations: TimelineAnimation {
            duration: 1034
            from: 0
            to: 1034
            running: node.clip === "Walk"
            loops: Animation.Infinite
        }
        KeyframeGroup {
            target: rightFoot
            property: "rotation"
            keyframeSource: "animations/rightFoot_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightLeg
            property: "rotation"
            keyframeSource: "animations/rightLeg_rotation_5.qad"
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
            target: leftLeg
            property: "rotation"
            keyframeSource: "animations/leftLeg_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftUpLeg
            property: "rotation"
            keyframeSource: "animations/leftUpLeg_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightHand
            property: "rotation"
            keyframeSource: "animations/rightHand_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftHand
            property: "rotation"
            keyframeSource: "animations/leftHand_rotation_5.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_5.qad"
        }
        KeyframeGroup {
            target: spine2
            property: "rotation"
            keyframeSource: "animations/spine2_rotation_5.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_5.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_5.qad"
        }
        KeyframeGroup {
            target: spine3
            property: "rotation"
            keyframeSource: "animations/spine3_rotation_5.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_5.qad"
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
