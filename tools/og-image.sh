#!/usr/bin/env bash
# Tạo ảnh share mạng xã hội (1200x630) cho bài viết.
#
# Chạy trong container Jekyll (có sẵn ImageMagick):
#   docker exec blog-jekyll bash tools/og-image.sh "Tiêu đề bài" "#ctf #pwn" images/posts/ten-bai.png
#
# Rồi thêm vào đầu bài viết:
#   image: /images/posts/ten-bai.png
set -euo pipefail

TITLE="${1:?Thiếu tiêu đề}"
TAGS="${2:-}"
OUT="${3:?Thiếu đường dẫn file output}"
SITE="${SITE_TITLE:->_ 0xToanNai // notes}"

FONT_DIR=/usr/share/fonts/truetype/dejavu
BOLD="$FONT_DIR/DejaVuSans-Bold.ttf"
MONO="$FONT_DIR/DejaVuSansMono.ttf"
SANS="$FONT_DIR/DejaVuSans.ttf"   # dòng tag dùng Sans vì Mono thiếu vài ký tự tiếng Việt (vd: ố)
MONO_BOLD="$FONT_DIR/DejaVuSansMono-Bold.ttf"

mkdir -p "$(dirname "$OUT")"

# Cỡ chữ tiêu đề theo độ dài
LEN=$(printf '%s' "$TITLE" | wc -m)
if   [ "$LEN" -le 40 ]; then PS=76
elif [ "$LEN" -le 70 ]; then PS=64
else                         PS=52
fi

magick -size 1200x630 xc:'#0d1117' \
  -fill '#3fb950' -draw 'rectangle 0,0 14,630' \
  -fill '#161b22' -draw 'roundrectangle 1040,60 1140,160 18,18' \
  -fill '#3fb950' -font "$MONO_BOLD" -pointsize 52 -gravity northwest -annotate +1058+76 '>_' \
  -fill '#3fb950' -font "$MONO_BOLD" -pointsize 30 -annotate +80+90 "$SITE" \
  \( -size 1000x330 -background none -fill '#e6edf3' -font "$BOLD" -pointsize "$PS" \
     -interline-spacing 6 -gravity west caption:"$TITLE" \) \
  -gravity northwest -geometry +80+170 -composite \
  -fill '#30363d' -draw 'rectangle 80,525 1120,527' \
  -fill '#8b949e' -font "$SANS" -pointsize 28 -annotate +80+550 "$TAGS" \
  "$OUT"

echo "Đã tạo $OUT"
