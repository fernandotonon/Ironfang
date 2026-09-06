// Localization singleton. Every player-facing string goes through Loc.tr("key", { args }).
// Tables: app/i18n/<lang>.js (plain objects, no sentence concatenation - full sentences per key).
// Bindings that call tr() re-evaluate when `language` changes because tr() reads it.
// scripts/check-i18n.py (run by ctest) verifies that every key used in QML/JS exists in every
// language table and that the tables have identical key sets.
pragma Singleton
import QtQuick
import "i18n/en.js" as En
import "i18n/pt_BR.js" as PtBR

QtObject {
    id: loc
    property string language: "en"
    readonly property var languages: [ { code: "en", name: "English" }, { code: "pt_BR", name: "Português (Brasil)" } ]
    readonly property var tables: ({ en: En.strings, pt_BR: PtBR.strings })

    function has(key) { return En.strings[key] !== undefined }

    function tr(key, args) {
        const table = tables[language] || En.strings
        let s = table[key]
        if (s === undefined) s = En.strings[key]
        if (s === undefined) return key                    // visible fallback: the key itself
        if (args) for (const k in args) s = s.split("{" + k + "}").join(String(args[k]))
        return s
    }

    // mission texts may be keys or literal strings (older definitions): keys resolve, literals pass
    function trOr(keyOrText, args) { return has(keyOrText) ? tr(keyOrText, args) : keyOrText }

    function setLanguage(code) { if (tables[code]) language = code }

    function fmtTime(seconds) {
        const s = Math.max(0, Math.floor(seconds)), m = Math.floor(s / 60), r = s % 60
        return m + ":" + (r < 10 ? "0" : "") + r
    }
}
