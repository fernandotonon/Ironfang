// Never instantiated. Lists the QML modules the runtime-loaded asset files use
// (assets/runtime/*/*.qml are resources, not module sources, so the static
// WebAssembly link would otherwise not see their imports).
import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils
import QtQuick.Timeline

Item {}
