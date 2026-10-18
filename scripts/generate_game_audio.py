#!/usr/bin/env python3
"""
Synthesize clean 16-bit PCM WAV audio effects and ambient loops for Mekatilili game.
Zero external audio dependencies, pure Python math + wave module.
"""

import os
import math
import wave
import struct

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AUDIO_DIR = os.path.join(BASE_DIR, "game", "assets", "audio")

SAMPLE_RATE = 22050

def write_wav(filename, samples, sample_rate=SAMPLE_RATE):
    filepath = os.path.join(AUDIO_DIR, filename)
    with wave.open(filepath, "w") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(sample_rate)
        raw = bytearray()
        for s in samples:
            # Clamp to 16-bit signed
            val = max(-32767, min(32767, int(s * 32767.0)))
            raw.extend(struct.pack("<h", val))
        f.writeframes(raw)
    print(f"Wrote {filename}")

def gen_click():
    samples = []
    duration = 0.05
    n_frames = int(duration * SAMPLE_RATE)
    for i in range(n_frames):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 80)
        s = math.sin(2 * math.pi * 880 * t) * env * 0.4
        samples.append(s)
    return samples

def gen_dialogue_blip():
    samples = []
    duration = 0.04
    n_frames = int(duration * SAMPLE_RATE)
    for i in range(n_frames):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 90)
        s = (math.sin(2 * math.pi * 520 * t) + 0.3 * math.sin(2 * math.pi * 1040 * t)) * env * 0.25
        samples.append(s)
    return samples

def gen_quest_start():
    samples = []
    notes = [440, 554.37, 659.25] # A major triad
    note_dur = 0.12
    for note in notes:
        n_frames = int(note_dur * SAMPLE_RATE)
        for i in range(n_frames):
            t = i / SAMPLE_RATE
            env = math.exp(-t * 12)
            s = math.sin(2 * math.pi * note * t) * env * 0.35
            samples.append(s)
    return samples

def gen_quest_complete():
    samples = []
    notes = [440, 554.37, 659.25, 880]
    note_dur = 0.14
    for note in notes:
        n_frames = int(note_dur * SAMPLE_RATE)
        for i in range(n_frames):
            t = i / SAMPLE_RATE
            env = math.exp(-t * 8)
            s = (math.sin(2 * math.pi * note * t) + 0.25 * math.sin(2 * math.pi * note * 2 * t)) * env * 0.4
            samples.append(s)
    return samples

def gen_item_collect():
    samples = []
    notes = [587.33, 880] # D5, A5
    note_dur = 0.1
    for note in notes:
        n_frames = int(note_dur * SAMPLE_RATE)
        for i in range(n_frames):
            t = i / SAMPLE_RATE
            env = math.exp(-t * 16)
            s = math.sin(2 * math.pi * note * t) * env * 0.3
            samples.append(s)
    return samples

def gen_footstep():
    samples = []
    duration = 0.08
    n_frames = int(duration * SAMPLE_RATE)
    # Filtered noise / low thud for earth
    import random
    random.seed(42)
    for i in range(n_frames):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 45)
        noise = (random.random() * 2.0 - 1.0) * 0.2
        thud = math.sin(2 * math.pi * 90 * t) * 0.4
        samples.append((noise + thud) * env * 0.3)
    return samples

def gen_ambient_coastal():
    duration = 4.0
    n_frames = int(duration * SAMPLE_RATE)
    samples = []
    import random
    random.seed(101)
    # Gentle undulating breeze (pink-ish low noise)
    val = 0.0
    for i in range(n_frames):
        t = i / SAMPLE_RATE
        # Slow swell 0.3 Hz
        swell = 0.5 + 0.5 * math.sin(2 * math.pi * 0.25 * t)
        white = (random.random() * 2.0 - 1.0)
        val = val * 0.94 + white * 0.06
        s = val * swell * 0.18
        # Occasional distant gentle bird chirp
        if 1.2 < t < 1.3 or 2.8 < t < 2.92:
            chirp_t = (t - 1.2) if t < 2.0 else (t - 2.8)
            s += math.sin(2 * math.pi * (2200 + 400 * math.sin(chirp_t * 50)) * chirp_t) * 0.05
        samples.append(s)
    return samples

def gen_music_intro():
    # Warm pentatonic kalimba melody loop (C, D, E, G, A)
    duration = 6.0
    n_frames = int(duration * SAMPLE_RATE)
    samples = [0.0] * n_frames
    
    # Sequence: (time_sec, freq)
    melody = [
        (0.0, 261.63), (0.5, 329.63), (1.0, 392.00), (1.5, 440.00),
        (2.0, 523.25), (2.5, 440.00), (3.0, 392.00), (3.5, 329.63),
        (4.0, 261.63), (4.5, 392.00), (5.0, 440.00), (5.5, 523.25)
    ]
    
    for start_t, freq in melody:
        start_idx = int(start_t * SAMPLE_RATE)
        note_len = int(0.7 * SAMPLE_RATE)
        for i in range(note_len):
            idx = start_idx + i
            if idx < n_frames:
                t = i / SAMPLE_RATE
                env = math.exp(-t * 4.5)
                # Kalimba harmonic: fundamental + high chime
                s = (math.sin(2 * math.pi * freq * t) + 
                     0.3 * math.sin(2 * math.pi * freq * 3.0 * t)) * env * 0.15
                samples[idx] += s
                
    return samples

def gen_drum():
    samples = []
    # Two drum hits: low resonant African Kaya drum
    hits = [0.0, 0.28]
    total_dur = 0.65
    n_frames = int(total_dur * SAMPLE_RATE)
    samples = [0.0] * n_frames
    for hit_t in hits:
        hit_start = int(hit_t * SAMPLE_RATE)
        dur = 0.32
        for i in range(int(dur * SAMPLE_RATE)):
            idx = hit_start + i
            if idx < n_frames:
                t = i / SAMPLE_RATE
                env = math.exp(-t * 14)
                freq = 110 * math.exp(-t * 18) + 55
                s = math.sin(2 * math.pi * freq * t) * env * 0.6
                samples[idx] += s
    return samples

def gen_hen():
    samples = []
    total_dur = 0.55
    n_frames = int(total_dur * SAMPLE_RATE)
    for i in range(n_frames):
        t = i / SAMPLE_RATE
        # Fluttering squawk with frequency modulation
        cluck_env = (0.5 + 0.5 * math.sin(2 * math.pi * 18 * t)) * math.exp(-t * 4.0)
        freq = 550 + 200 * math.sin(2 * math.pi * 32 * t)
        s = math.sin(2 * math.pi * freq * t) * cluck_env * 0.45
        samples.append(s)
    return samples

def gen_whistle():
    samples = []
    total_dur = 0.4
    n_frames = int(total_dur * SAMPLE_RATE)
    for i in range(n_frames):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / total_dur))
        s = (math.sin(2 * math.pi * 2200 * t) + 0.4 * math.sin(2 * math.pi * 2420 * t)) * env * 0.35
        samples.append(s)
    return samples

def main():
    os.makedirs(AUDIO_DIR, exist_ok=True)
    write_wav("sfx_click.wav", gen_click())
    write_wav("sfx_dialogue_blip.wav", gen_dialogue_blip())
    write_wav("sfx_quest_start.wav", gen_quest_start())
    write_wav("sfx_quest_complete.wav", gen_quest_complete())
    write_wav("sfx_item_collect.wav", gen_item_collect())
    write_wav("sfx_footstep.wav", gen_footstep())
    write_wav("sfx_drum.wav", gen_drum())
    write_wav("sfx_hen.wav", gen_hen())
    write_wav("sfx_whistle.wav", gen_whistle())
    write_wav("ambient_coastal_loop.wav", gen_ambient_coastal())
    write_wav("music_intro_loop.wav", gen_music_intro())
    print("All audio generated successfully!")

if __name__ == "__main__":
    main()
