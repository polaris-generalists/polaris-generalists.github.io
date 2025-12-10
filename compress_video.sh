#!/bin/bash
# Video compression script for web optimization
# Usage: ./compress_video.sh input.mp4 output.mp4

INPUT="$1"
OUTPUT="$2"

if [ -z "$INPUT" ] || [ -z "$OUTPUT" ]; then
    echo "Usage: $0 <input_video.mp4> <output_video.mp4>"
    exit 1
fi

# Optimize for web: 480p resolution, H.264 codec, ~1.5 Mbps bitrate
# This should reduce 18MB to ~2-4MB while maintaining good quality
ffmpeg -i "$INPUT" \
    -c:v libx264 \
    -preset slow \
    -crf 28 \
    -vf "scale=854:480:force_original_aspect_ratio=decrease,pad=854:480:(ow-iw)/2:(oh-ih)/2" \
    -maxrate 1.5M \
    -bufsize 3M \
    -c:a aac \
    -b:a 128k \
    -movflags +faststart \
    -pix_fmt yuv420p \
    "$OUTPUT"

echo ""
echo "Compression complete!"
echo "Original size: $(du -h "$INPUT" | cut -f1)"
echo "Compressed size: $(du -h "$OUTPUT" | cut -f1)"

