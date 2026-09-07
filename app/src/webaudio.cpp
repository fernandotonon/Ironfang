// Ironfang: The Broken Crown - MIT License
#include "webaudio.h"
#include <QFile>

#ifdef __EMSCRIPTEN__
#include <emscripten.h>

// One shared AudioContext; buffers by name; a single music voice with pause/resume.
EM_JS(void, ironfang_audio_init, (), {
    if (Module.ironfangAudio) return;
    const A = { ctx: null, buffers: {}, music: null, musicName: "", musicGain: null, musicOffset: 0, musicStart: 0, musicVolume: 0.5, musicLoop: true, musicPending: false, played: 0 };
    A.context = () => {
        if (!A.ctx) {
            const Ctx = window.AudioContext || window.webkitAudioContext;
            if (!Ctx) return null;
            A.ctx = new Ctx();
            const resume = () => { if (A.ctx && A.ctx.state === "suspended") A.ctx.resume(); };
            ["pointerdown", "keydown", "touchstart"].forEach(t => window.addEventListener(t, resume, { capture: true, passive: true }));
        }
        return A.ctx;
    };
    Module.ironfangAudio = A;
});
EM_JS(void, ironfang_audio_load, (const char *name, const unsigned char *data, int len), {
    const A = Module.ironfangAudio; const ctx = A.context(); if (!ctx) return;
    const key = UTF8ToString(name);
    const bytes = HEAPU8.slice(data, data + len);          // copy out of the wasm heap before decoding
    ctx.decodeAudioData(bytes.buffer).then(buf => { A.buffers[key] = buf; }).catch(e => console.warn("WebAudio: decode failed for", key, e));
});
EM_JS(void, ironfang_audio_play, (const char *name, double volume), {
    const A = Module.ironfangAudio; const ctx = A.context(); if (!ctx) return;
    const buf = A.buffers[UTF8ToString(name)]; if (!buf) return;
    if (ctx.state === "suspended") ctx.resume();
    const src = ctx.createBufferSource(); src.buffer = buf;
    const gain = ctx.createGain(); gain.gain.value = Math.max(0, Math.min(1, volume));
    src.connect(gain); gain.connect(ctx.destination); src.start();
    if (++A.played === 1) console.log("WebAudio: first sound played through the browser AudioContext");
});
EM_JS(void, ironfang_audio_music_resume, (), {
    const A = Module.ironfangAudio; if (!A || !A.ctx || A.music || !A.musicName) return;
    const buf = A.buffers[A.musicName]; if (!buf) return;
    const ctx = A.ctx; if (ctx.state === "suspended") ctx.resume();
    const src = ctx.createBufferSource(); src.buffer = buf; src.loop = A.musicLoop;
    const gain = ctx.createGain(); gain.gain.value = Math.max(0, Math.min(1, A.musicVolume));
    src.connect(gain); gain.connect(ctx.destination); src.start(0, A.musicOffset);
    A.music = src; A.musicGain = gain; A.musicStart = ctx.currentTime - A.musicOffset; A.musicOffset = 0;
});
EM_JS(void, ironfang_audio_music, (const char *name, double volume, int loop), {
    const A = Module.ironfangAudio; const ctx = A.context(); if (!ctx) return;
    const key = UTF8ToString(name); const buf = A.buffers[key];
    if (A.music) { try { A.music.stop(); } catch (e) {} A.music = null; }
    A.musicName = key; A.musicVolume = volume; A.musicLoop = !!loop; A.musicOffset = 0;
    if (!buf) { A.musicPending = true; return; }
    A.musicPending = false;
    ironfang_audio_music_resume();
});
EM_JS(void, ironfang_audio_music_stop, (int pause), {
    const A = Module.ironfangAudio; if (!A || !A.ctx) return;
    if (A.music) {
        const buf = A.music.buffer;
        if (pause && buf) A.musicOffset = (A.musicOffset + (A.ctx.currentTime - A.musicStart)) % buf.duration;
        try { A.music.stop(); } catch (e) {}
        A.music = null;
    }
    if (!pause) { A.musicName = ""; A.musicOffset = 0; A.musicPending = false; }
});
EM_JS(void, ironfang_audio_music_volume, (double volume), {
    const A = Module.ironfangAudio; if (!A) return;
    A.musicVolume = volume; if (A.musicGain) A.musicGain.gain.value = Math.max(0, Math.min(1, volume));
});
// a music started before its buffer finished decoding: start it once decoded
EM_JS(void, ironfang_audio_tick, (), {
    const A = Module.ironfangAudio; if (!A || !A.musicPending || !A.musicName) return;
    if (A.buffers[A.musicName]) { A.musicPending = false; A.musicOffset = 0; ironfang_audio_music_resume(); }
});
#endif

WebAudio::WebAudio(QObject *parent) : QObject(parent)
{
#ifdef __EMSCRIPTEN__
    ironfang_audio_init();
#endif
}

bool WebAudio::available() const
{
#ifdef __EMSCRIPTEN__
    return true;
#else
    return false;
#endif
}

bool WebAudio::load(const QString &name, const QUrl &source)
{
#ifdef __EMSCRIPTEN__
    const QString path = source.scheme() == QLatin1String("qrc") ? QLatin1Char(':') + source.path() : source.toLocalFile();
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly)) { qWarning("WebAudio: cannot read %s", qPrintable(path)); return false; }
    const QByteArray bytes = f.readAll();
    ironfang_audio_load(name.toUtf8().constData(), reinterpret_cast<const unsigned char *>(bytes.constData()), bytes.size());
    return true;
#else
    Q_UNUSED(name); Q_UNUSED(source); return false;
#endif
}

void WebAudio::play(const QString &name, double volume)
{
#ifdef __EMSCRIPTEN__
    ironfang_audio_tick();
    ironfang_audio_play(name.toUtf8().constData(), volume);
#else
    Q_UNUSED(name); Q_UNUSED(volume);
#endif
}

void WebAudio::playMusic(const QString &name, double volume, bool loop)
{
#ifdef __EMSCRIPTEN__
    ironfang_audio_music(name.toUtf8().constData(), volume, loop ? 1 : 0);
#else
    Q_UNUSED(name); Q_UNUSED(volume); Q_UNUSED(loop);
#endif
}

void WebAudio::stopMusic()
{
#ifdef __EMSCRIPTEN__
    ironfang_audio_music_stop(0);
#endif
}

void WebAudio::pauseMusic()
{
#ifdef __EMSCRIPTEN__
    ironfang_audio_music_stop(1);
#endif
}

void WebAudio::resumeMusic()
{
#ifdef __EMSCRIPTEN__
    ironfang_audio_tick();
    ironfang_audio_music_resume();
#endif
}

void WebAudio::setMusicVolume(double volume)
{
#ifdef __EMSCRIPTEN__
    ironfang_audio_music_volume(volume);
#else
    Q_UNUSED(volume);
#endif
}
