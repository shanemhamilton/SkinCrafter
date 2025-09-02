#!/bin/bash

# Create a simple placeholder icon (green square with "SC" text)
cd SkinCrafter/Assets.xcassets/AppIcon.appiconset/

# Create a 1024x1024 base icon using ImageMagick or sips
# Using sips (built into macOS) to create a green placeholder
echo "Creating placeholder app icons..."

# Create a base 1024x1024 image
cat > icon_base.html << 'HTML'
<svg width="1024" height="1024" xmlns="http://www.w3.org/2000/svg">
  <rect width="1024" height="1024" fill="#4CAF50"/>
  <text x="512" y="512" font-family="Arial" font-size="400" fill="white" text-anchor="middle" dominant-baseline="middle">SC</text>
</svg>
HTML

# Convert SVG to PNG using built-in tools
qlmanage -t -s 1024 -o . icon_base.html 2>/dev/null || echo "qlmanage failed"
mv icon_base.html.png Icon-1024.png 2>/dev/null || echo "Move failed"

# If that didn't work, create a simple colored square
if [ ! -f Icon-1024.png ]; then
    # Create a green 1024x1024 PNG using Python
    python3 << 'PYTHON'
from PIL import Image, ImageDraw, ImageFont
import os

# Create a green square with "SC" text
img = Image.new('RGB', (1024, 1024), color='#4CAF50')
draw = ImageDraw.Draw(img)

# Try to add text (may fail if no font available)
try:
    # Attempt to use a system font
    font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 400)
    text = "SC"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    position = ((1024 - text_width) // 2, (1024 - text_height) // 2 - 50)
    draw.text(position, text, fill='white', font=font)
except:
    # If no font, just make a plain green square
    pass

img.save('Icon-1024.png')
print("Created Icon-1024.png")
PYTHON
fi

# Now resize to all required sizes
echo "Generating all icon sizes..."

# iPhone icons
sips -z 120 120 Icon-1024.png --out Icon-60@2x.png
sips -z 180 180 Icon-1024.png --out Icon-60@3x.png

# iPad icons  
sips -z 152 152 Icon-1024.png --out Icon-76@2x.png
sips -z 167 167 Icon-1024.png --out Icon-83.5@2x.png

# App Store
cp Icon-1024.png Icon-1024@1x.png

# Notification icons
sips -z 40 40 Icon-1024.png --out Icon-20@2x.png
sips -z 60 60 Icon-1024.png --out Icon-20@3x.png

# Settings icons
sips -z 58 58 Icon-1024.png --out Icon-29@2x.png
sips -z 87 87 Icon-1024.png --out Icon-29@3x.png

# Spotlight icons
sips -z 80 80 Icon-1024.png --out Icon-40@2x.png
sips -z 120 120 Icon-1024.png --out Icon-40@3x.png

# Clean up
rm -f icon_base.html Icon-1024.png

echo "Icons generated successfully!"
