#!/bin/bash

# SkinCrafter Build Script for Xcode
# This script prepares the project for building in Xcode

echo "🚀 Preparing SkinCrafter for Xcode..."

# Navigate to project directory
cd "$(dirname "$0")"

# Clean any previous builds
echo "🧹 Cleaning previous builds..."
xcodebuild -workspace SkinCrafter.xcworkspace -scheme SkinCrafter clean

# Update CocoaPods
echo "📦 Updating CocoaPods..."
pod install

# Build for simulator to verify everything works
echo "🔨 Building for iPhone Simulator..."
xcodebuild -workspace SkinCrafter.xcworkspace \
           -scheme SkinCrafter \
           -destination 'platform=iOS Simulator,name=iPhone 16' \
           build

if [ $? -eq 0 ]; then
    echo "✅ Build successful! You can now open SkinCrafter.xcworkspace in Xcode."
    echo ""
    echo "📱 To run in Xcode:"
    echo "   1. Open SkinCrafter.xcworkspace (not .xcodeproj)"
    echo "   2. Select an iPhone simulator or connected device"
    echo "   3. Press Cmd+R to run"
    echo ""
    echo "🎨 Features:"
    echo "   - 3D-first editing with direct model painting"
    echo "   - Default skin template with baseline colors"
    echo "   - Rotation and painting gesture separation"
    echo "   - Multiple editing modes (3D, Simple, Professional, Focused)"
else
    echo "❌ Build failed. Please check the errors above."
    exit 1
fi