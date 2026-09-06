// Storage abstraction for saves and settings: string in, string out, keyed.
//   * default: QtCore Settings (desktop: platform-native QSettings location, atomic file writes;
//     WebAssembly: window.localStorage through Qt's WebLocalStorageFormat, synchronous)
//   * QtMesh Games (or tests) may install `adapter` = { read(key) -> string|null, write(key, str),
//     remove(key) } and take over persistence without the game noticing.
// Two independent keys are used by the game: "progress" (campaign, achievements, stats) and
// "settings" (user preferences) - docs/save-format.md.
import QtQuick
import QtCore

Item {
    id: root
    property var adapter: null
    readonly property bool usingAdapter: adapter !== null
    property string lastError: ""

    Component {
        id: settingsComp
        Settings { category: "ironfang" }
    }
    property var store: null
    function ensure() {
        if (store) return store
        if (!Qt.application.organization) Qt.application.organization = "QtMesh Games"
        if (!Qt.application.name || Qt.application.name === "ironfang") Qt.application.name = "Ironfang"
        store = settingsComp.createObject(root)
        return store
    }

    function read(key) {
        try {
            if (adapter) { const v = adapter.read(key); return v === undefined || v === null || v === "" ? null : String(v) }
            const s = ensure().value(key, "")
            return s === undefined || s === null || s === "" ? null : String(s)
        } catch (e) { lastError = String(e); return null }
    }

    function write(key, text) {
        try {
            if (adapter) { adapter.write(key, text); return true }
            const s = ensure(); s.setValue(key, text); s.sync(); return true
        } catch (e) { lastError = String(e); return false }
    }

    function remove(key) {
        try {
            if (adapter) { adapter.remove(key); return true }
            const s = ensure(); s.setValue(key, ""); s.sync(); return true
        } catch (e) { lastError = String(e); return false }
    }
}
