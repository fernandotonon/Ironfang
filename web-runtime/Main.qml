// Ironfang on the Clayground Web Runtime (prebuilt clayground.wasm, no build step).
// The runtime loads this file by URL and expects an Item root; everything else - the game
// QML (qmldir-listed siblings), scripts/, config/ and assets/runtime - sits next to it.
import QtQuick
import "." as Game

Game.IronfangGame {
    anchors.fill: parent
    focus: true
    // index.html preloaded assets-manifest.json into the runtime's filesystem under /game/
    assetBase: "file:///game/"
}
