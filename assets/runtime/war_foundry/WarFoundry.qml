import QtQuick
import QtQuick3D

Node {
    id: node
    // --- Ironfang runtime API (added by scripts/import-runtime.py) ---
    property string clip: "Idle"
    readonly property var clips: []
    signal clipFinished(string name)

    // Resources
    Texture {
        id: qtmesh_gen3d_1_1788604883446_diffuse_png_texture
        objectName: "qtmesh_gen3d_1_1788604883446_diffuse.jpg"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_1_1788604883446_diffuse.jpg"
    }
    Texture {
        id: qtmesh_gen3d_1_1788604883446_roughness_png_texture
        objectName: "qtmesh_gen3d_1_1788604883446_roughness.jpg"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_1_1788604883446_roughness.jpg"
    }
    Texture {
        id: qtmesh_gen3d_1_1788604883446_normal_png_texture
        objectName: "qtmesh_gen3d_1_1788604883446_normal.jpg"
        generateMipmaps: true
        mipFilter: Texture.Linear
        source: "maps/qtmesh_gen3d_1_1788604883446_normal.jpg"
    }
    PrincipledMaterial {
        id: qtmesh_gen3d_1_1788604883446_mesh_mat_material
        objectName: "qtmesh_gen3d_1_1788604883446_mesh_mat"
        baseColorMap: qtmesh_gen3d_1_1788604883446_diffuse_png_texture
        metalnessMap: qtmesh_gen3d_1_1788604883446_roughness_png_texture
        roughnessMap: qtmesh_gen3d_1_1788604883446_roughness_png_texture
        roughness: 1
        normalMap: qtmesh_gen3d_1_1788604883446_normal_png_texture
        alphaMode: PrincipledMaterial.Opaque
    }

    // Nodes:
    Model {
        id: qtmesh_gen3d_1_1788604883446
        objectName: "qtmesh_gen3d_1_1788604883446"
        source: "meshes/meshes_0__mesh.mesh"
        pickable: true
        materials: [
            qtmesh_gen3d_1_1788604883446_mesh_mat_material
        ]
    }

    // Animations:
}
