#!/usr/bin/env python3
"""Generate Ironfang's audio: original, synthesized, CC0-equivalent (no external samples).

    python3 scripts/gen-audio.py [out_dir=assets/audio]

Pure Python (wave + math): short sound effects + a looping ambient/battle drone. Everything is
deterministic (seeded), so re-running reproduces the same files. Clayground's synth
(`SynthInstrument`) is desktop-only on WebAssembly for now, hence pre-rendered WAVs played
through `Clayground.Sound.Sound` / `Music`.
"""
import math
import os
import random
import struct
import sys
import wave

SR = 22050
random.seed(1337)


def write_wav(path, samples):
    data = b"".join(struct.pack("<h", max(-32767, min(32767, int(s * 32767)))) for s in samples)
    with wave.open(path, "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(data)


def env(i, n, a=0.005, r=0.2):
    t = i / SR; total = n / SR
    at = min(1.0, t / a) if a > 0 else 1.0
    rel = min(1.0, (total - t) / max(r, 1e-4)) if r > 0 else 1.0
    return max(0.0, min(at, rel))


def tone(freq, dur, wave_fn=math.sin, vol=0.6, a=0.005, r=0.15, slide=0.0, vib=0.0):
    n = int(SR * dur); out = []; ph = 0.0
    for i in range(n):
        f = freq * (1 + slide * i / n) * (1 + vib * math.sin(2 * math.pi * 6 * i / SR))
        ph += 2 * math.pi * f / SR
        out.append(vol * env(i, n, a, r) * wave_fn(ph))
    return out


def square(ph): return 1.0 if math.sin(ph) >= 0 else -1.0
def saw(ph): return (ph / math.pi) % 2 - 1
def tri(ph): return 2 * abs(saw(ph)) - 1


def noise(dur, vol=0.5, a=0.002, r=0.12, lowpass=0.2):
    n = int(SR * dur); out = []; y = 0.0
    for i in range(n):
        x = random.uniform(-1, 1)
        y += lowpass * (x - y)                          # crude one-pole low-pass
        out.append(vol * env(i, n, a, r) * y)
    return out


def mix(*parts):
    n = max(len(p) for p in parts); out = [0.0] * n
    for p in parts:
        for i, s in enumerate(p): out[i] += s
    peak = max(1e-6, max(abs(s) for s in out))
    return [s / peak * 0.9 for s in out] if peak > 0.9 else out


def concat(*parts):
    out = []
    for p in parts: out += p
    return out


def delay(samples, seconds, gain):
    d = int(seconds * SR); out = samples + [0.0] * d
    for i in range(len(samples)): out[i + d] += samples[i] * gain
    return out


def sfx():
    return {
        # UI / orders
        "select":      mix(tone(880, 0.07, square, 0.25, r=0.05), tone(1320, 0.05, math.sin, 0.15, r=0.04)),
        "move":        mix(tone(520, 0.06, tri, 0.3, r=0.05), tone(660, 0.08, tri, 0.2, a=0.02, r=0.06)),
        "attack_order": mix(tone(330, 0.09, saw, 0.3, r=0.06, slide=-0.2), noise(0.06, 0.15)),
        "invalid":     concat(tone(220, 0.08, square, 0.25, r=0.04), tone(180, 0.1, square, 0.25, r=0.06)),
        # combat
        "melee_hit":   mix(noise(0.12, 0.6, lowpass=0.35), tone(140, 0.1, math.sin, 0.5, r=0.08, slide=-0.4)),
        "arrow_shot":  mix(noise(0.16, 0.35, lowpass=0.6), tone(1400, 0.12, math.sin, 0.15, r=0.1, slide=-0.5)),
        "arrow_hit":   mix(noise(0.08, 0.5, lowpass=0.5), tone(260, 0.06, tri, 0.3, r=0.05)),
        "ogre_hit":    mix(noise(0.3, 0.7, lowpass=0.12), tone(70, 0.3, math.sin, 0.7, r=0.25, slide=-0.3)),
        "death":       mix(tone(300, 0.35, saw, 0.35, r=0.3, slide=-0.6), noise(0.3, 0.25, lowpass=0.2)),
        # economy
        "gather":      concat(tone(1900, 0.04, tri, 0.25, r=0.03), tone(2300, 0.05, tri, 0.2, r=0.04)),
        "deposit":     mix(tone(660, 0.12, math.sin, 0.35, r=0.1), tone(990, 0.16, math.sin, 0.25, a=0.03, r=0.12)),
        "produced":    concat(tone(523, 0.1, square, 0.22, r=0.05), tone(659, 0.1, square, 0.22, r=0.05), tone(784, 0.18, square, 0.25, r=0.12)),
        # structures / match
        "building_destroyed": mix(noise(1.1, 0.8, lowpass=0.08), tone(55, 1.0, math.sin, 0.7, r=0.8, slide=-0.5)),
        "wave_incoming": concat(tone(196, 0.35, saw, 0.4, a=0.02, r=0.2), tone(185, 0.5, saw, 0.4, a=0.02, r=0.35)),
        "victory":     delay(concat(tone(523, 0.18, tri, 0.4, r=0.1), tone(659, 0.18, tri, 0.4, r=0.1), tone(784, 0.18, tri, 0.4, r=0.1), tone(1047, 0.6, tri, 0.45, r=0.5)), 0.25, 0.35),
        "defeat":      delay(concat(tone(392, 0.3, saw, 0.35, r=0.2), tone(349, 0.3, saw, 0.35, r=0.2), tone(311, 0.3, saw, 0.35, r=0.2), tone(262, 0.9, saw, 0.35, r=0.8)), 0.3, 0.3),
    }


def music_loop():
    """~24 s ambient war-drum loop: low drone, drums, a sparse minor motif. Seamless loop."""
    bpm = 84; beat = 60 / bpm; bars = 8; total = bars * 4 * beat
    n = int(SR * total); out = [0.0] * n

    def add(samples, at, gain=1.0):
        s = int(at * SR)
        for i, v in enumerate(samples):
            j = (s + i) % n                          # wrap -> seamless loop tail
            out[j] += v * gain

    # drone: two detuned saws, slow LFO
    for i in range(n):
        t = i / SR
        lfo = 0.5 + 0.5 * math.sin(2 * math.pi * t / total * 2)
        out[i] += 0.10 * (saw(2 * math.pi * 55 * t) + saw(2 * math.pi * 55.4 * t)) * (0.6 + 0.4 * lfo)
    # drums: kick on 1 and 3, low tom on 2.5/4, shaker 8ths
    for bar in range(bars):
        b0 = bar * 4 * beat
        for k in (0, 2): add(mix(tone(60, 0.25, math.sin, 0.9, r=0.2, slide=-0.6), noise(0.05, 0.4, lowpass=0.3)), b0 + k * beat, 0.8)
        add(tone(95, 0.3, math.sin, 0.6, r=0.25, slide=-0.5), b0 + 2.5 * beat, 0.6)
        if bar % 2 == 1: add(tone(95, 0.3, math.sin, 0.6, r=0.25, slide=-0.5), b0 + 3.5 * beat, 0.6)
        for e in range(8): add(noise(0.05, 0.25, lowpass=0.7), b0 + e * beat / 2, 0.35 if e % 2 else 0.5)
    # motif (A minor-ish): sparse, alternating bars
    motif = [(0, 220), (1.5, 261.6), (2, 246.9), (3, 196), (4.5, 220), (6, 174.6), (7, 196)]
    for bar in (0, 2, 4, 6):
        for t, f in motif:
            if (bar // 2) % 2 == 1 and t > 4: continue
            add(tone(f, 0.9, tri, 0.35, a=0.02, r=0.6, vib=0.004), bar * 4 * beat + t * beat, 0.7)
    peak = max(abs(s) for s in out)
    return [s / peak * 0.85 for s in out]


def main():
    out_dir = sys.argv[1] if len(sys.argv) > 1 else "assets/audio"
    os.makedirs(out_dir, exist_ok=True)
    for name, samples in sfx().items():
        write_wav(os.path.join(out_dir, f"{name}.wav"), samples)
    write_wav(os.path.join(out_dir, "ambient_loop.wav"), music_loop())
    total = sum(os.path.getsize(os.path.join(out_dir, f)) for f in os.listdir(out_dir) if f.endswith(".wav"))
    print(f"wrote {len(os.listdir(out_dir))} files to {out_dir} ({total / 1048576:.1f} MB)")


if __name__ == "__main__":
    main()
