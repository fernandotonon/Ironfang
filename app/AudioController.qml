// All game audio in one place. Sounds are original, synthesized by scripts/gen-audio.py and
// shipped as WAV resources; played through Clayground.Sound (Web Audio on WebAssembly).
import QtQuick
import Clayground.Sound

Item {
    id: audio
    property bool soundOn: true
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
        const map = {}
        for (const n of _names)
            map[n] = soundComp.createObject(audio, { source: Qt.resolvedUrl("assets/audio/" + n + ".wav") })
        _sounds = map
    }

    function play(name, volumeScale) {
        if (!soundOn) return
        const s = _sounds[name]
        if (!s) return
        const now = Date.now() / 1000
        const gap = _minGap[name] || 0
        if (gap > 0 && _lastPlayed[name] && now - _lastPlayed[name] < gap) return
        _lastPlayed[name] = now
        s.volume = sfxVolume * (volumeScale === undefined ? 1 : volumeScale)
        s.play()
    }

    Music {
        id: music
        source: Qt.resolvedUrl("assets/audio/ambient_loop.wav")
        volume: audio.musicVolume
        loop: true
    }
    function startMusic() { if (soundOn) { music.play(); musicPlaying = true } }
    function stopMusic() { music.stop(); musicPlaying = false }
    function pauseMusic() { music.pause() }
    function resumeMusic() { if (soundOn && musicPlaying) music.play() }
}
