// Ironfang: First Siege - desktop / own-WASM-build entry point.
// Built with Clayground. Forged with QtMeshEditor.
import QtQuick
import QtQuick.Window

Window {
    id: win
    width: 1280
    height: 800
    visible: true
    color: "#14161a"
    title: "Ironfang: The Broken Crown"

    // Clayground convention: every clay_app is a headless ctest smoke test (QT_QPA_PLATFORM=minimal);
    // loading without warnings is the pass criterion, so quit right after the scene is up.
    Component.onCompleted: if (Qt.platform.pluginName === "minimal") Qt.quit()

    IronfangGame {
        anchors.fill: parent
        focus: true
    }
}
