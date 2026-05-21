#!/usr/bin/env bash
set -euo pipefail

flutter pub run flutter_launcher_icons

mkdir -p assets/icons

if command -v python >/dev/null 2>&1; then
  python - <<'PY'
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

path = Path('assets/icons/tv_banner.png')
image = Image.new('RGBA', (320, 180), (0, 172, 193, 255))
draw = ImageDraw.Draw(image)

try:
    font = ImageFont.truetype('arial.ttf', 28)
except Exception:
    font = ImageFont.load_default()

text = 'ScreenTrainer'
text_bbox = draw.textbbox((0, 0), text, font=font)
text_width = text_bbox[2] - text_bbox[0]
text_height = text_bbox[3] - text_bbox[1]
draw.text(((320 - text_width) / 2, (180 - text_height) / 2), text, fill='white', font=font)
image.save(path)
PY
elif command -v magick >/dev/null 2>&1; then
  magick -size 320x180 canvas:'#00ACC1' -gravity center -fill white -pointsize 28 -annotate +0+0 'ScreenTrainer' assets/icons/tv_banner.png
else
  echo 'Install Python with Pillow or ImageMagick to generate the TV banner placeholder.' >&2
  exit 1
fi