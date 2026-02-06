#!/bin/bash
set -euo pipefail

# Generate Nudge app icon from a source PNG.
#
# Usage:
#   ./scripts/generate-icon.sh [source.png]
#
# If no source PNG is provided, generates a minimal default icon
# using macOS built-in tools (sips + iconutil).
#
# Requirements: macOS with sips and iconutil (both ship with Xcode CLI tools).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_ROOT/Sources/Nudge/Resources"
ICONSET_DIR="$PROJECT_ROOT/.build/AppIcon.iconset"
OUTPUT_FILE="$OUTPUT_DIR/AppIcon.icns"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$ICONSET_DIR"

SOURCE_PNG="${1:-}"

if [ -z "$SOURCE_PNG" ]; then
    echo "No source PNG provided. Generating minimal default icon..."

    # Create a simple 1024x1024 icon using Python + CoreGraphics
    python3 -c "
import Quartz
import CoreGraphics

size = 1024
cs = CoreGraphics.CGColorSpaceCreateDeviceRGB()
ctx = CoreGraphics.CGBitmapContextCreate(
    None, size, size, 8, size * 4, cs,
    CoreGraphics.kCGImageAlphaPremultipliedLast
)

# Background: rounded rect, warm amber
CoreGraphics.CGContextSetRGBFillColor(ctx, 0.96, 0.78, 0.35, 1.0)
path = CoreGraphics.CGPathCreateWithRoundedRect(
    CoreGraphics.CGRectMake(64, 64, 896, 896), 180, 180, None
)
CoreGraphics.CGContextAddPath(ctx, path)
CoreGraphics.CGContextFillPath(ctx)

# Inner circle: soft white
CoreGraphics.CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 0.85)
CoreGraphics.CGContextFillEllipseInRect(
    ctx, CoreGraphics.CGRectMake(312, 312, 400, 400)
)

# Center dot: amber
CoreGraphics.CGContextSetRGBFillColor(ctx, 0.85, 0.60, 0.15, 1.0)
CoreGraphics.CGContextFillEllipseInRect(
    ctx, CoreGraphics.CGRectMake(432, 432, 160, 160)
)

image = CoreGraphics.CGBitmapContextCreateImage(ctx)
url = CoreGraphics.CFURLCreateWithFileSystemPath(
    None, '$ICONSET_DIR/icon_1024.png',
    CoreGraphics.kCFURLPOSIXPathStyle, False
)
dest = CoreGraphics.CGImageDestinationCreateWithURL(url, 'public.png', 1, None)
CoreGraphics.CGImageDestinationAddImage(dest, image, None)
CoreGraphics.CGImageDestinationFinalize(dest)
print('Generated 1024x1024 source icon')
"
    SOURCE_PNG="$ICONSET_DIR/icon_1024.png"
fi

if [ ! -f "$SOURCE_PNG" ]; then
    echo "Error: source file not found: $SOURCE_PNG"
    exit 1
fi

echo "Generating iconset from: $SOURCE_PNG"

# macOS .icns requires these exact sizes
SIZES=(16 32 64 128 256 512 1024)

for size in "${SIZES[@]}"; do
    sips -z "$size" "$size" "$SOURCE_PNG" --out "$ICONSET_DIR/icon_${size}x${size}.png" >/dev/null 2>&1
done

# Retina variants (@2x)
sips -z 32 32 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null 2>&1
sips -z 64 64 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null 2>&1
sips -z 256 256 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null 2>&1
sips -z 512 512 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null 2>&1
sips -z 1024 1024 "$SOURCE_PNG" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null 2>&1

# Rename standard sizes to match iconutil expectations
mv "$ICONSET_DIR/icon_16x16.png" "$ICONSET_DIR/icon_16x16.png" 2>/dev/null || true
mv "$ICONSET_DIR/icon_32x32.png" "$ICONSET_DIR/icon_32x32.png" 2>/dev/null || true
mv "$ICONSET_DIR/icon_128x128.png" "$ICONSET_DIR/icon_128x128.png" 2>/dev/null || true
mv "$ICONSET_DIR/icon_256x256.png" "$ICONSET_DIR/icon_256x256.png" 2>/dev/null || true
mv "$ICONSET_DIR/icon_512x512.png" "$ICONSET_DIR/icon_512x512.png" 2>/dev/null || true

# Remove intermediate sizes not needed by iconutil
rm -f "$ICONSET_DIR/icon_64x64.png"
rm -f "$ICONSET_DIR/icon_1024x1024.png"
rm -f "$ICONSET_DIR/icon_1024.png"

echo "Converting iconset to .icns..."
iconutil -c icns "$ICONSET_DIR" -o "$OUTPUT_FILE"

echo "Done: $OUTPUT_FILE"
ls -la "$OUTPUT_FILE"

# Cleanup
rm -rf "$ICONSET_DIR"
