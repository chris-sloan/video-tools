# video-tools

Small personal video utilities built on top of `ffmpeg`.

This repo currently contains a single script (`video-tool`) that solves two recurring problems:

1. **Fix MP4 videos that randomly play in slow motion**\
   (caused by Variable Frame Rate / broken timestamps)
2. **Convert and shrink videos to efficient WebM files**

The goal is to make these fixes **repeatable, safe, and hard to mess up**.

---

## Requirements

- macOS
- zsh
- ffmpeg (via Homebrew)

Install Homebrew (if needed):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Install ffmpeg:

```bash
brew install ffmpeg
```

---

## Installation

You can either **copy** the script (simplest and most robust) or **symlink** it (if you want easy updates).

### Option A: Copy (recommended for work machines)

```bash
mkdir -p ~/bin
cp video-tool ~/bin/video-tool
chmod +x ~/bin/video-tool
```

### Option B: Symlink (recommended if you plan to update often)

```bash
mkdir -p ~/bin
ln -s /path/to/video-tool ~/bin/video-tool
chmod +x ~/bin/video-tool
```

Ensure `~/bin` is on your PATH (usually in `~/.zshrc`):

```bash
export PATH="$HOME/bin:$PATH"
```

Reload your shell:

```bash
source ~/.zshrc
```

---

## Usage

Run the tool by passing a path to a video file:

```bash
video-tool /path/to/video.mp4
video-tool /path/to/video.webm
```

You will be prompted to choose one of two actions.

---

## Option 1: Fix MP4 slow-motion / VFR issues

Use this if:

- an MP4 plays normally at first
- then suddenly looks like slow motion
- even though you didn’t record it that way

This is caused by **Variable Frame Rate (VFR)** timing issues in the file.

### What it does

- Re-encodes **video only** to Constant Frame Rate (CFR)
- Keeps **audio untouched**
- Rebuilds timestamps so playback is consistent

### Output

```
input.mp4  →  input_cfr.mp4
```

### Notes

- Default output frame rate: **30 fps**
- Video quality is visually lossless for screen recordings
- Audio remains bit-for-bit identical
- This reliably removes slow-motion glitches

---

## Option 2: Convert / shrink to WebM

Use this if you want:

- much smaller files
- consistent playback
- WebM output for demos or sharing

### Behaviour

- MP4 input → WebM output
- WebM input → smaller WebM output

### Output rules

```
input.mp4   →  input.webm
input.webm  →  input_tiny.webm
```

### Encoding details

- VP9 video
- Maximum width: **720px** (never upscales)
- Audio removed
- Tuned for UI / screen recordings

This typically reduces file size by **70–85%**.

---

## Migration checklist (future you will thank you)

On a **new machine**, do the following:

```bash
# 1. install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. install ffmpeg
brew install ffmpeg

# 3. clone your tools
git clone git@github.com:you/video-tools.git ~/dev/tools/video-tools

# 4. install command (copy method)
mkdir -p ~/bin
cp ~/dev/tools/video-tools/video-tool ~/bin/video-tool
chmod +x ~/bin/video-tool

# 5. ensure PATH
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

After this, `video-tool` will be available everywhere.

---

## Why this exists

Some recording tools produce MP4 files with broken or inconsistent timestamps. This can cause sections of the video to appear to play in slow motion.

Re-encoding through FFmpeg (or converting to WebM) fixes the timeline. This script packages those fixes into a single, repeatable command.

---

## Philosophy

- Prefer boring, explicit defaults
- Fix the root cause, not the symptom
- Make common media problems easy to undo

This is a personal utility, but written to be understandable by future-you.

