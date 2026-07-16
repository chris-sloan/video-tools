#!/usr/bin/env zsh
#
# video_tool.sh
#
# Usage:
#   ./video_tool.sh /path/to/video.mp4
#   ./video_tool.sh /path/to/video.webm
#   ./video_tool.sh /path/to/video.mov
#
# Then choose an action:
#   1) Fix VFR -> CFR (removes "slow" playback glitches)     [outputs: *_cfr.mp4]
#   2) Make small WebM (mp4/mov->webm or webm->tiny)         [outputs: .webm or *_tiny.webm]
#   3) Compress MOV -> MP4 (H.264, CRF 23, AAC audio)       [outputs: *_compressed.mp4]
#
# Defaults chosen from your working settings:
#   - WebM shrink: VP9, CRF 33, no audio, scale down to max 720w (never upscale)
#   - VFR fix: CFR at 30fps, re-encode video only (x264), copy audio
#   - MOV compress: H.264 CRF 23, AAC audio, no scale change

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 /path/to/video.(mp4|webm|mov)"
  exit 1
fi

INPUT="$1"
if [[ ! -f "$INPUT" ]]; then
  echo "Input file does not exist: $INPUT"
  exit 1
fi

DIR="$(cd "$(dirname "$INPUT")" && pwd)"
BASE="$(basename "$INPUT")"
NAME="${BASE%.*}"
EXT="${BASE##*.}"
EXT="${EXT:l}" # lowercase in zsh

echo "Input: $INPUT"
echo ""
echo "Choose an action:"
echo "  1) Fix VFR -> CFR (removes slow playback glitches)       -> ${NAME}_cfr.mp4"
echo "  2) Convert/shrink to WebM (mp4/mov->.webm, webm->_tiny.webm)"
echo "  3) Compress MOV -> MP4 (H.264 CRF 23, AAC audio)        -> ${NAME}_compressed.mp4"
echo ""
print -n "Enter 1, 2, or 3: "
read -r CHOICE

case "$CHOICE" in
  1)
    if [[ "$EXT" != "mp4" && "$EXT" != "mov" ]]; then
      echo "Option 1 requires an .mp4 or .mov input (got .$EXT)"
      exit 1
    fi

    # You can change this to 24 or 60 if needed
    FPS="${FPS:-30}"

    OUT="$DIR/${NAME}_cfr.mp4"
    echo "Output: $OUT"
    echo "Fixing VFR -> CFR at ${FPS}fps (re-encode video, copy audio)..."

    ffmpeg -i "$INPUT" \
      -vsync cfr -r "$FPS" \
      -c:v libx264 -crf 18 -preset slow \
      -c:a copy \
      "$OUT"
    ;;

  2)
    # WebM shrink settings
    CRF="${CRF:-33}"
    MAXW="${MAXW:-720}"

    if [[ "$EXT" == "mp4" || "$EXT" == "mov" ]]; then
      OUT="$DIR/${NAME}.webm"
    elif [[ "$EXT" == "webm" ]]; then
      OUT="$DIR/${NAME}_tiny.webm"
    else
      echo "Option 2 supports .mp4, .mov, or .webm inputs (got .$EXT)"
      exit 1
    fi

    echo "Output: $OUT"
    echo "Encoding VP9 WebM (CRF=${CRF}), max width ${MAXW} (no upscale), no audio..."

    ffmpeg -i "$INPUT" \
      -vf "scale='min(${MAXW},iw)':-2" -an \
      -c:v libvpx-vp9 -crf "$CRF" -b:v 0 \
      "$OUT"
    ;;

  3)
    if [[ "$EXT" != "mov" ]]; then
      echo "Option 3 requires a .mov input (got .$EXT)"
      exit 1
    fi

    CRF="${CRF:-23}"

    OUT="$DIR/${NAME}_compressed.mp4"
    echo "Output: $OUT"
    echo "Compressing MOV -> MP4 (H.264 CRF=${CRF}, AAC audio)..."

    ffmpeg -i "$INPUT" \
      -c:v libx264 -crf "$CRF" -preset slow \
      -c:a aac -b:a 128k \
      -movflags +faststart \
      "$OUT"
    ;;

  *)
    echo "Invalid choice: $CHOICE"
    exit 1
    ;;
esac

echo "Done."
