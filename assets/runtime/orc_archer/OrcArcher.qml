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
        id: qtmesh_gen3d_3_1788580202226_diffuse_png_texture
        objectName: "qtmesh_gen3d_3_1788580202226_diffuse.jpg"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_3_1788580202226_diffuse.jpg"
    }
    Texture {
        id: qtmesh_gen3d_3_1788580202226_roughness_png_texture
        objectName: "qtmesh_gen3d_3_1788580202226_roughness.jpg"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_3_1788580202226_roughness.jpg"
    }
    Texture {
        id: qtmesh_gen3d_3_1788580202226_normal_png_texture
        objectName: "qtmesh_gen3d_3_1788580202226_normal.jpg"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_3_1788580202226_normal.jpg"
    }
    PrincipledMaterial {
        id: qtmesh_gen3d_3_1788580202226_mesh_mat_material
        objectName: "qtmesh_gen3d_3_1788580202226_mesh_mat"
        baseColorMap: qtmesh_gen3d_3_1788580202226_diffuse_png_texture
        metalnessMap: qtmesh_gen3d_3_1788580202226_roughness_png_texture
        roughnessMap: qtmesh_gen3d_3_1788580202226_roughness_png_texture
        roughness: 1
        normalMap: qtmesh_gen3d_3_1788580202226_normal_png_texture
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
            joint_19,
            joint_20,
            joint_21,
            joint_22,
            joint_23,
            joint_24,
            joint_25,
            joint_26,
            joint_27,
            rightArm,
            rightForeArm,
            rightHand,
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
            joint_46,
            joint_47,
            joint_48,
            joint_49,
            joint_50,
            joint_51,
            joint_52,
            leftUpLeg,
            leftLeg,
            leftFoot,
            joint_56,
            joint_57,
            rightUpLeg,
            rightLeg,
            rightFoot,
            joint_61,
            joint_62
        ]
        inverseBindPoses: [
            Qt.matrix4x4(1, 0, 0, -0.00227091, 0, 1, 0, -0.0347789, 0, 0, 1, -0.0124525, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.00227091, 0, 1, 0, -0.0933281, 0, 0, 1, -0.0163558, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.00227091, 0, 1, 0, -0.163587, 0, 0, 1, -0.0202591, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.00227091, 0, 1, 0, -0.241653, 0, 0, 1, -0.0241624, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.00227091, 0, 1, 0, -0.327525, 0, 0, 1, -0.0319689, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.00227091, 0, 1, 0, -0.358751, 0, 0, 1, -0.0358722, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.00227091, 0, 1, 0, -0.479753, 0, 0, 1, -0.0397755, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0328586, 0, 1, 0, -0.315815, 0, 0, 1, -0.0319689, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0992144, 0, 1, 0, -0.288492, 0, 0, 1, -0.0280657, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.208506, 0, 1, 0, -0.249459, 0, 0, 1, -0.0280657, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.345121, 0, 1, 0, -0.253363, 0, 0, 1, -0.0358722, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.360734, 0, 1, 0, -0.268976, 0, 0, 1, -0.0241624, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.372444, 0, 1, 0, -0.280686, 0, 0, 1, -0.0163558, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.384154, 0, 1, 0, -0.292396, 0, 0, 1, -0.00854925, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.395864, 0, 1, 0, -0.300202, 0, 0, 1, -0.00464596, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.395864, 0, 1, 0, -0.272879, 0, 0, 1, -0.0319689, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.411477, 0, 1, 0, -0.276782, 0, 0, 1, -0.0319689, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.42709, 0, 1, 0, -0.276782, 0, 0, 1, -0.0319689, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.395864, 0, 1, 0, -0.261169, 0, 0, 1, -0.0397755, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.41538, 0, 1, 0, -0.261169, 0, 0, 1, -0.0436788, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.430993, 0, 1, 0, -0.257266, 0, 0, 1, -0.0436788, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.446607, 0, 1, 0, -0.257266, 0, 0, 1, -0.0436788, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.395864, 0, 1, 0, -0.249459, 0, 0, 1, -0.0475821, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.411477, 0, 1, 0, -0.245556, 0, 0, 1, -0.0514854, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.42709, 0, 1, 0, -0.241653, 0, 0, 1, -0.0514854, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.391961, 0, 1, 0, -0.23775, 0, 0, 1, -0.0514854, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.40367, 0, 1, 0, -0.233846, 0, 0, 1, -0.0514854, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0374005, 0, 1, 0, -0.315815, 0, 0, 1, -0.0319689, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.103756, 0, 1, 0, -0.288492, 0, 0, 1, -0.0241624, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.213048, 0, 1, 0, -0.249459, 0, 0, 1, -0.0280657, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.349663, 0, 1, 0, -0.253363, 0, 0, 1, -0.0358722, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.365276, 0, 1, 0, -0.268976, 0, 0, 1, -0.0241624, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.376986, 0, 1, 0, -0.280686, 0, 0, 1, -0.0163558, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.392599, 0, 1, 0, -0.292396, 0, 0, 1, -0.00854925, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.404309, 0, 1, 0, -0.300202, 0, 0, 1, -0.00464596, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.400406, 0, 1, 0, -0.272879, 0, 0, 1, -0.0319689, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.416019, 0, 1, 0, -0.276782, 0, 0, 1, -0.0319689, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.431632, 0, 1, 0, -0.276782, 0, 0, 1, -0.0319689, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.447245, 0, 1, 0, -0.276782, 0, 0, 1, -0.0319689, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.400406, 0, 1, 0, -0.261169, 0, 0, 1, -0.0397755, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.419922, 0, 1, 0, -0.261169, 0, 0, 1, -0.0436788, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.435535, 0, 1, 0, -0.257266, 0, 0, 1, -0.0436788, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.400406, 0, 1, 0, -0.249459, 0, 0, 1, -0.0475821, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.416019, 0, 1, 0, -0.245556, 0, 0, 1, -0.0514854, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.431632, 0, 1, 0, -0.241653, 0, 0, 1, -0.0514854, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.396502, 0, 1, 0, -0.23775, 0, 0, 1, -0.0514854, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.408212, 0, 1, 0, -0.233846, 0, 0, 1, -0.0514854, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.419922, 0, 1, 0, -0.229943, 0, 0, 1, -0.0514854, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.431632, 0, 1, 0, -0.22604, 0, 0, 1, -0.0514854, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.0484718, 0, 1, 0, 0.000350632, 0, 0, 1, -0.0124525, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.103118, 0, 1, 0, 0.234548, 0, 0, 1, -0.0319689, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.130441, 0, 1, 0, 0.441422, 0, 0, 1, -0.0592919, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.149957, 0, 1, 0, 0.492164, 0, 0, 1, 0.0187737, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, 0.15386, 0, 1, 0, 0.488261, 0, 0, 1, 0.0539033, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.0530136, 0, 1, 0, 0.000350632, 0, 0, 1, -0.0124525, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.10766, 0, 1, 0, 0.234548, 0, 0, 1, -0.0319689, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.134983, 0, 1, 0, 0.441422, 0, 0, 1, -0.0553886, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.154499, 0, 1, 0, 0.492164, 0, 0, 1, 0.0187737, 0, 0, 0, 1),
            Qt.matrix4x4(1, 0, 0, -0.158402, 0, 1, 0, 0.488261, 0, 0, 1, 0.0539033, 0, 0, 0, 1)
        ]
    }

    // Nodes:
    Node {
        id: qtmesh_gen3d_3_1788580202226
        objectName: "qtmesh_gen3d_3_1788580202226"
        Node {
            id: hips
            objectName: "Hips"
            position: Qt.vector3d(0.00227091, 0.0347789, 0.0124525)
            Node {
                id: spine
                objectName: "Spine"
                position: Qt.vector3d(0, 0.0585492, 0.00390328)
                Node {
                    id: spine1
                    objectName: "Spine1"
                    position: Qt.vector3d(0, 0.0702591, 0.00390328)
                    Node {
                        id: spine2
                        objectName: "Spine2"
                        position: Qt.vector3d(0, 0.0780656, 0.00390328)
                        Node {
                            id: spine3
                            objectName: "Spine3"
                            position: Qt.vector3d(0, 0.0858722, 0.00780657)
                            Node {
                                id: neck
                                objectName: "Neck"
                                position: Qt.vector3d(0, 0.0312262, 0.00390328)
                                Node {
                                    id: head
                                    objectName: "Head"
                                    position: Qt.vector3d(0, 0.121002, 0.00390328)
                                }
                            }
                        }
                        Node {
                            id: leftArm
                            objectName: "LeftArm"
                            position: Qt.vector3d(-0.0351295, 0.0741624, 0.00780657)
                            Node {
                                id: leftForeArm
                                objectName: "LeftForeArm"
                                position: Qt.vector3d(-0.0663558, -0.027323, -0.00390328)
                                Node {
                                    id: leftHand
                                    objectName: "LeftHand"
                                    position: Qt.vector3d(-0.109292, -0.0390328, 0)
                                    Node {
                                        id: joint_10
                                        objectName: "joint_10"
                                        position: Qt.vector3d(-0.136615, 0.00390328, 0.00780656)
                                        Node {
                                            id: joint_11
                                            objectName: "joint_11"
                                            position: Qt.vector3d(-0.0156131, 0.0156131, -0.0117098)
                                            Node {
                                                id: joint_12
                                                objectName: "joint_12"
                                                position: Qt.vector3d(-0.0117098, 0.0117099, -0.00780657)
                                                Node {
                                                    id: joint_13
                                                    objectName: "joint_13"
                                                    position: Qt.vector3d(-0.0117098, 0.0117098, -0.00780657)
                                                    Node {
                                                        id: joint_14
                                                        objectName: "joint_14"
                                                        position: Qt.vector3d(-0.0117099, 0.00780657, -0.00390328)
                                                    }
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_15
                                            objectName: "joint_15"
                                            position: Qt.vector3d(-0.0507427, 0.0195164, -0.00390328)
                                            Node {
                                                id: joint_16
                                                objectName: "joint_16"
                                                position: Qt.vector3d(-0.0156131, 0.00390327, 0)
                                                Node {
                                                    id: joint_17
                                                    objectName: "joint_17"
                                                    position: Qt.vector3d(-0.0156131, 0, 0)
                                                    Node {
                                                        id: joint_18
                                                        objectName: "joint_18"
                                                        position: Qt.vector3d(-0.0156131, 0, 0)
                                                    }
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_19
                                            objectName: "joint_19"
                                            position: Qt.vector3d(-0.0507427, 0.00780657, 0.00390328)
                                            Node {
                                                id: joint_20
                                                objectName: "joint_20"
                                                position: Qt.vector3d(-0.0195164, 0, 0.00390328)
                                                Node {
                                                    id: joint_21
                                                    objectName: "joint_21"
                                                    position: Qt.vector3d(-0.0156131, -0.0039033, 0)
                                                    Node {
                                                        id: joint_22
                                                        objectName: "joint_22"
                                                        position: Qt.vector3d(-0.0156131, 0, 0)
                                                    }
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_23
                                            objectName: "joint_23"
                                            position: Qt.vector3d(-0.0507427, -0.00390328, 0.0117098)
                                            Node {
                                                id: joint_24
                                                objectName: "joint_24"
                                                position: Qt.vector3d(-0.0156131, -0.00390328, 0.00390328)
                                                Node {
                                                    id: joint_25
                                                    objectName: "joint_25"
                                                    position: Qt.vector3d(-0.0156131, -0.00390328, 0)
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_26
                                            objectName: "joint_26"
                                            position: Qt.vector3d(-0.0468394, -0.0156131, 0.0156131)
                                            Node {
                                                id: joint_27
                                                objectName: "joint_27"
                                                position: Qt.vector3d(-0.0117098, -0.00390328, 0)
                                                Node {
                                                    id: joint_28
                                                    objectName: "joint_28"
                                                    position: Qt.vector3d(-0.0117099, -0.00390328, 0)
                                                    Node {
                                                        id: joint_29
                                                        objectName: "joint_29"
                                                        position: Qt.vector3d(-0.0117098, -0.00390328, 0)
                                                    }
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
                            position: Qt.vector3d(0.0351295, 0.0741624, 0.00780657)
                            Node {
                                id: rightForeArm
                                objectName: "RightForeArm"
                                position: Qt.vector3d(0.0663558, -0.027323, -0.00780657)
                                Node {
                                    id: rightHand
                                    objectName: "RightHand"
                                    position: Qt.vector3d(0.109292, -0.0390328, 0.00390328)
                                    Node {
                                        id: joint_33
                                        objectName: "joint_33"
                                        position: Qt.vector3d(0.136615, 0.00390328, 0.00780656)
                                        Node {
                                            id: joint_34
                                            objectName: "joint_34"
                                            position: Qt.vector3d(0.0156131, 0.0156131, -0.0117098)
                                            Node {
                                                id: joint_35
                                                objectName: "joint_35"
                                                position: Qt.vector3d(0.0117098, 0.0117099, -0.00780657)
                                                Node {
                                                    id: joint_36
                                                    objectName: "joint_36"
                                                    position: Qt.vector3d(0.0156131, 0.0117098, -0.00780657)
                                                    Node {
                                                        id: joint_37
                                                        objectName: "joint_37"
                                                        position: Qt.vector3d(0.0117098, 0.00780657, -0.00390328)
                                                    }
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_38
                                            objectName: "joint_38"
                                            position: Qt.vector3d(0.0507427, 0.0195164, -0.00390328)
                                            Node {
                                                id: joint_39
                                                objectName: "joint_39"
                                                position: Qt.vector3d(0.0156131, 0.00390327, 0)
                                                Node {
                                                    id: joint_40
                                                    objectName: "joint_40"
                                                    position: Qt.vector3d(0.0156131, 0, 0)
                                                    Node {
                                                        id: joint_41
                                                        objectName: "joint_41"
                                                        position: Qt.vector3d(0.0156131, 0, 0)
                                                    }
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_42
                                            objectName: "joint_42"
                                            position: Qt.vector3d(0.0507427, 0.00780657, 0.00390328)
                                            Node {
                                                id: joint_43
                                                objectName: "joint_43"
                                                position: Qt.vector3d(0.0195164, 0, 0.00390328)
                                                Node {
                                                    id: joint_44
                                                    objectName: "joint_44"
                                                    position: Qt.vector3d(0.0156131, -0.0039033, 0)
                                                    Node {
                                                        id: joint_45
                                                        objectName: "joint_45"
                                                        position: Qt.vector3d(0.0156131, 0, 0)
                                                    }
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_46
                                            objectName: "joint_46"
                                            position: Qt.vector3d(0.0507427, -0.00390328, 0.0117098)
                                            Node {
                                                id: joint_47
                                                objectName: "joint_47"
                                                position: Qt.vector3d(0.0156131, -0.00390328, 0.00390328)
                                                Node {
                                                    id: joint_48
                                                    objectName: "joint_48"
                                                    position: Qt.vector3d(0.0156131, -0.00390328, 0)
                                                }
                                            }
                                        }
                                        Node {
                                            id: joint_49
                                            objectName: "joint_49"
                                            position: Qt.vector3d(0.0468394, -0.0156131, 0.0156131)
                                            Node {
                                                id: joint_50
                                                objectName: "joint_50"
                                                position: Qt.vector3d(0.0117098, -0.00390328, 0)
                                                Node {
                                                    id: joint_51
                                                    objectName: "joint_51"
                                                    position: Qt.vector3d(0.0117098, -0.00390328, 0)
                                                    Node {
                                                        id: joint_52
                                                        objectName: "joint_52"
                                                        position: Qt.vector3d(0.0117098, -0.00390328, 0)
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
            }
            Node {
                id: leftUpLeg
                objectName: "LeftUpLeg"
                position: Qt.vector3d(-0.0507427, -0.0351295, 0)
                Node {
                    id: leftLeg
                    objectName: "LeftLeg"
                    position: Qt.vector3d(-0.054646, -0.234197, 0.0195164)
                    Node {
                        id: leftFoot
                        objectName: "LeftFoot"
                        position: Qt.vector3d(-0.027323, -0.206874, 0.027323)
                        Node {
                            id: joint_56
                            objectName: "joint_56"
                            position: Qt.vector3d(-0.0195164, -0.0507427, -0.0780656)
                            Node {
                                id: joint_57
                                objectName: "joint_57"
                                position: Qt.vector3d(-0.00390328, 0.00390327, -0.0351295)
                            }
                        }
                    }
                }
            }
            Node {
                id: rightUpLeg
                objectName: "RightUpLeg"
                position: Qt.vector3d(0.0507427, -0.0351295, 0)
                Node {
                    id: rightLeg
                    objectName: "RightLeg"
                    position: Qt.vector3d(0.054646, -0.234197, 0.0195164)
                    Node {
                        id: rightFoot
                        objectName: "RightFoot"
                        position: Qt.vector3d(0.027323, -0.206874, 0.0234197)
                        Node {
                            id: joint_61
                            objectName: "joint_61"
                            position: Qt.vector3d(0.0195164, -0.0507427, -0.0741624)
                            Node {
                                id: joint_62
                                objectName: "joint_62"
                                position: Qt.vector3d(0.00390328, 0.00390327, -0.0351295)
                            }
                        }
                    }
                }
            }
        }
        Model {
            id: qtmesh_gen3d_3_1788580202226_mesh
            objectName: "qtmesh_gen3d_3_1788580202226_mesh"
            source: "meshes/meshes_0__mesh.mesh"
            pickable: true
            skin: skin
            materials: [
                qtmesh_gen3d_3_1788580202226_mesh_mat_material
            ]
        }
    }

    // Animations:
    Timeline {
        id: attack_timeline
        objectName: "Attack"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1034
        currentFrame: 0
        enabled: node.clip === "Attack"
        animations: TimelineAnimation {
            duration: 1034
            from: 0
            to: 1034
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
            target: spine3
            property: "rotation"
            keyframeSource: "animations/spine3_rotation_0.qad"
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
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_0.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_0.qad"
        }
        KeyframeGroup {
            target: spine2
            property: "rotation"
            keyframeSource: "animations/spine2_rotation_0.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_0.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_0.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_0.qad"
        }
    }
    Timeline {
        id: death_timeline
        objectName: "Death"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 3534
        currentFrame: 0
        enabled: node.clip === "Death"
        animations: TimelineAnimation {
            duration: 3534
            from: 0
            to: 3534
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
            target: spine3
            property: "rotation"
            keyframeSource: "animations/spine3_rotation_1.qad"
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
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_1.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_1.qad"
        }
        KeyframeGroup {
            target: spine2
            property: "rotation"
            keyframeSource: "animations/spine2_rotation_1.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_1.qad"
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
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_1.qad"
        }
    }
    Timeline {
        id: hit_timeline
        objectName: "Hit"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1767
        currentFrame: 0
        enabled: node.clip === "Hit"
        animations: TimelineAnimation {
            duration: 1767
            from: 0
            to: 1767
            running: node.clip === "Hit"
            loops: 1
            // deferred: the handler usually switches `clip`, which drives `running`
            onFinished: Qt.callLater(function() { if (node) node.clipFinished("Hit") })
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
            target: spine3
            property: "rotation"
            keyframeSource: "animations/spine3_rotation_2.qad"
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
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_2.qad"
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
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_2.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_2.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_2.qad"
        }
    }
    Timeline {
        id: idle_timeline
        objectName: "Idle"
        property real framesPerSecond: 1000
        startFrame: 0
        endFrame: 1834
        currentFrame: 0
        enabled: node.clip === "Idle"
        animations: TimelineAnimation {
            duration: 1834
            from: 0
            to: 1834
            running: node.clip === "Idle"
            loops: Animation.Infinite
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
            target: spine3
            property: "rotation"
            keyframeSource: "animations/spine3_rotation_3.qad"
        }
        KeyframeGroup {
            target: rightArm
            property: "rotation"
            keyframeSource: "animations/rightArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftArm
            property: "rotation"
            keyframeSource: "animations/leftArm_rotation_3.qad"
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
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_3.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_3.qad"
        }
        KeyframeGroup {
            target: spine2
            property: "rotation"
            keyframeSource: "animations/spine2_rotation_3.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_3.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_3.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_3.qad"
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
            target: spine3
            property: "rotation"
            keyframeSource: "animations/spine3_rotation_4.qad"
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
            target: rightForeArm
            property: "rotation"
            keyframeSource: "animations/rightForeArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: leftForeArm
            property: "rotation"
            keyframeSource: "animations/leftForeArm_rotation_4.qad"
        }
        KeyframeGroup {
            target: neck
            property: "rotation"
            keyframeSource: "animations/neck_rotation_4.qad"
        }
        KeyframeGroup {
            target: spine2
            property: "rotation"
            keyframeSource: "animations/spine2_rotation_4.qad"
        }
        KeyframeGroup {
            target: spine1
            property: "rotation"
            keyframeSource: "animations/spine1_rotation_4.qad"
        }
        KeyframeGroup {
            target: hips
            property: "rotation"
            keyframeSource: "animations/hips_rotation_4.qad"
        }
        KeyframeGroup {
            target: spine
            property: "rotation"
            keyframeSource: "animations/spine_rotation_4.qad"
        }
    }
}
