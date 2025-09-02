#!/bin/bash

echo "🔧 Fixing Xcode Build Issues for SkinCrafter..."

# Kill Xcode if running
echo "📛 Closing Xcode..."
osascript -e 'quit app "Xcode"' 2>/dev/null

# Navigate to project
cd "$(dirname "$0")"

# Clean everything
echo "🧹 Deep cleaning build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/SkinCrafter-*
rm -rf build/
rm -rf Pods/
rm -rf SkinCrafter.xcworkspace

# Reinstall pods
echo "📦 Reinstalling CocoaPods..."
pod deintegrate
pod install

# Clean and build
echo "🔨 Building fresh..."
xcodebuild -workspace SkinCrafter.xcworkspace \
           -scheme SkinCrafter \
           -destination 'platform=iOS Simulator,name=iPhone 16' \
           clean build

if [ $? -eq 0 ]; then
    echo "✅ Build fixed! Opening Xcode..."
    open SkinCrafter.xcworkspace
    echo ""
    echo "📱 In Xcode:"
    echo "   1. Wait for indexing to complete"
    echo "   2. Select iPhone 16 simulator"
    echo "   3. Press Cmd+R to run"
else
    echo "❌ Build still failing. Checking for specific issues..."
    xcodebuild -workspace SkinCrafter.xcworkspace \
               -scheme SkinCrafter \
               -destination 'platform=iOS Simulator,name=iPhone 16' \
               build 2>&1 | grep -A 5 "error:"
fi