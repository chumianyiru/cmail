#!/usr/bin/env bash
set -e

SRC="assets/icon.png"

if ! command -v convert &> /dev/null; then
  echo "ImageMagick convert not found, skipping icon generation"
  exit 0
fi

mkdir -p android/app/src/main/res/mipmap-mdpi
mkdir -p android/app/src/main/res/mipmap-hdpi
mkdir -p android/app/src/main/res/mipmap-xhdpi
mkdir -p android/app/src/main/res/mipmap-xxhdpi
mkdir -p android/app/src/main/res/mipmap-xxxhdpi
mkdir -p ios/Runner/Assets.xcassets/AppIcon.appiconset

convert "$SRC" -resize 48x48 android/app/src/main/res/mipmap-mdpi/ic_launcher.png
convert "$SRC" -resize 72x72 android/app/src/main/res/mipmap-hdpi/ic_launcher.png
convert "$SRC" -resize 96x96 android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
convert "$SRC" -resize 144x144 android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
convert "$SRC" -resize 192x192 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

convert "$SRC" -resize 20x20 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png
convert "$SRC" -resize 40x40 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png
convert "$SRC" -resize 60x60 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png
convert "$SRC" -resize 29x29 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png
convert "$SRC" -resize 58x58 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png
convert "$SRC" -resize 87x87 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png
convert "$SRC" -resize 40x40 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png
convert "$SRC" -resize 80x80 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png
convert "$SRC" -resize 120x120 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png
convert "$SRC" -resize 120x120 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png
convert "$SRC" -resize 180x180 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png
convert "$SRC" -resize 76x76 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png
convert "$SRC" -resize 152x152 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png
convert "$SRC" -resize 167x167 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png
convert "$SRC" -resize 1024x1024 ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png

echo "Icons generated successfully"
