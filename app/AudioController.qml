// All game audio in one place. Sounds are original, synthesized by scripts/gen-audio.py and
// shipped as WAV resources.
//   desktop:      Clayground.Sound (Qt Multimedia); the ambient loop is a Sound re-triggered by a Timer
//   WebAssembly:  the WebAudio bridge (app/src/webaudio.cpp, browser AudioContext) - Clayground.Sound
//                 stalls the page there (clayground#216); the browser unlocks audio on the first click
import QtQuick
import Clayground.Sound

Item {
    id: audio
    WebAudio { id: web }
    readonly property bool useWeb: web.available
    readonly property bool platformSupported: true
    property bool soundOn: true
    property real sfxVolume: 0.8
    property real musicVolume: 0.35
    property bool musicPlaying: false
    property bool musicPaused: false

    readonly property var _names: ["select", "move", "attack_order", "invalid", "melee_hit", "arrow_shot",
                                   "arrow_hit", "ogre_hit", "death", "gather", "deposit", "produced",
                                   "building_destroyed", "wave_incoming", "victory", "defeat"]
    readonly property string _musicName: "ambient_loop"
    readonly property int _musicLengthMs: 22860
    property var _sounds: ({})
    property var _lastPlayed: ({})

    // rate limits per sound (seconds) so 40 melee hits a second do not become a wall of noise
    readonly property var _minGap: ({ melee_hit: 0.08, arrow_shot: 0.06, arrow_hit: 0.06, gather: 0.25, ogre_hit: 0.1, death: 0.15, select: 0.05, move: 0.1 })

    Component { id: soundComp; Sound { volume: audio.sfxVolume; lazyLoading: false } }

    Component.onCompleted: {
        console.log("AudioController:", useWeb ? "browser AudioContext" : "Clayground.Sound")
        if (useWeb) {
            for (const n of _names) web.load(n, Qt.resolvedUrl("assets/audio/" + n + ".wav"))
            web.load(_musicName, Qt.resolvedUrl("assets/audio/" + _musicName + ".wav"))
            return
        }
        const map = {}
        for (const n of _names)
            map[n] = soundComp.createObject(audio, { source: Qt.resolvedUrl("assets/audio/" + n + ".wav") })
        _sounds = map
    }

    function play(name, volumeScale) {
        if (!soundOn) return
        const now = Date.now() / 1000
        const gap = _minGap[name] || 0
        if (gap > 0 && _lastPlayed[name] && now - _lastPlayed[name] < gap) return
        _lastPlayed[name] = now
        const vol = sfxVolume * (volumeScale === undefined ? 1 : volumeScale)
        if (useWeb) { web.play(name, vol); return }
        const s = _sounds[name]
        if (!s) return
        s.volume = vol
        s.play()
    }

    // Desktop ambient loop as a re-triggered Sound (Clayground's Music type stalls QML creation
    // on WebAssembly; Sound works on desktop). The loop file is 22.86 s; the timer restarts it
    // just before it ends. On the web the AudioContext loops the buffer natively.
    Loader {
        id: musicLoader
        active: !audio.useWeb
        sourceComponent: Sound {
            source: Qt.resolvedUrl("assets/audio/" + audio._musicName + ".wav")
            volume: audio.musicVolume
            lazyLoading: true
        }
    }
    readonly property var musicSound: musicLoader.item
    Timer {
        id: musicLoop
        interval: audio._musicLengthMs - 160; repeat: true; running: false
        onTriggered: if (musicSound) musicSound.play()
    }
    function startMusic() {
        if (!soundOn) return
        musicPlaying = true; musicPaused = false
        if (useWeb) { web.playMusic(_musicName, musicVolume, true); return }
        if (!musicSound) return
        musicSound.play(); musicLoop.restart()
    }
    function stopMusic() {
        musicLoop.stop(); musicPlaying = false; musicPaused = false
        if (useWeb) web.stopMusic(); else if (musicSound) musicSound.stop()
    }
    function pauseMusic() {
        if (!musicPlaying) return
        musicLoop.stop(); musicPaused = true
        if (useWeb) web.pauseMusic(); else if (musicSound) musicSound.stop()
    }
    function resumeMusic() {
        if (!soundOn || !musicPlaying || !musicPaused) return
        musicPaused = false
        if (useWeb) web.resumeMusic(); else if (musicSound) { musicSound.play(); musicLoop.restart() }
    }
    onMusicVolumeChanged: if (useWeb) web.setMusicVolume(musicVolume)
    onSoundOnChanged: if (!soundOn) stopMusic()
}
