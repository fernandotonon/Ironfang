// All game audio in one place. Sounds are original, synthesized by scripts/gen-audio.py and
// shipped as WAV resources; played through Clayground.Sound (Web Audio on WebAssembly).
import QtQuick
import Clayground.Sound

Item {
    id: audio
    // Clayground.Sound playback freezes the page on WebAssembly (Sound.play() and Music alike,
    // MisterGC/clayground#216), so the web build runs silent until that is fixed upstream.
    readonly property bool platformSupported: Qt.platform.os !== "wasm"
    property bool soundOn: platformSupported
    property real sfxVolume: 0.8
    property real musicVolume: 0.35
    property bool musicPlaying: false

    readonly property var _names: ["select", "move", "attack_order", "invalid", "melee_hit", "arrow_shot",
                                   "arrow_hit", "ogre_hit", "death", "gather", "deposit", "produced",
                                   "building_destroyed", "wave_incoming", "victory", "defeat"]
    property var _sounds: ({})
    property var _lastPlayed: ({})

    // rate limits per sound (seconds) so 40 melee hits a second do not become a wall of noise
    readonly property var _minGap: ({ melee_hit: 0.08, arrow_shot: 0.06, arrow_hit: 0.06, gather: 0.25, ogre_hit: 0.1, death: 0.15, select: 0.05, move: 0.1 })

    Component { id: soundComp; Sound { volume: audio.sfxVolume; lazyLoading: false } }

    Component.onCompleted: {
        if (!platformSupported) return
        const map = {}
        for (const n of _names)
            map[n] = soundComp.createObject(audio, { source: Qt.resolvedUrl("assets/audio/" + n + ".wav") })
        _sounds = map
    }

    function play(name, volumeScale) {
        if (!soundOn || !platformSupported) return
        const s = _sounds[name]
        if (!s) return
        const now = Date.now() / 1000
        const gap = _minGap[name] || 0
        if (gap > 0 && _lastPlayed[name] && now - _lastPlayed[name] < gap) return
        _lastPlayed[name] = now
        s.volume = sfxVolume * (volumeScale === undefined ? 1 : volumeScale)
        s.play()
    }

    // Ambient loop as a re-triggered Sound: Clayground's Music type stalls QML creation on
    // WebAssembly (see the Clayground issue linked in docs/feasibility-report.md), while Sound
    // works everywhere. The loop file is 22.86 s; the timer restarts it just before it ends.
    Loader {
        id: musicLoader
        active: audio.platformSupported
        sourceComponent: Sound {
            source: Qt.resolvedUrl("assets/audio/ambient_loop.wav")
            volume: audio.musicVolume
            lazyLoading: true
        }
    }
    readonly property var musicSound: musicLoader.item
    Timer {
        id: musicLoop
        interval: 22700; repeat: true; running: false
        onTriggered: if (musicSound) musicSound.play()
    }
    function startMusic() { if (!soundOn || !musicSound) return; musicSound.play(); musicLoop.restart(); musicPlaying = true }
    function stopMusic() { musicLoop.stop(); if (musicSound) musicSound.stop(); musicPlaying = false }
    function pauseMusic() { musicLoop.stop(); if (musicSound) musicSound.stop() }
    function resumeMusic() { if (soundOn && musicPlaying && musicSound) { musicSound.play(); musicLoop.restart() } }
}
