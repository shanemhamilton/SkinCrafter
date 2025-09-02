#!/bin/bash

echo "🔧 Fixing GoogleMobileAds Framework Issue..."

# Kill Xcode
echo "📛 Closing Xcode..."
osascript -e 'quit app "Xcode"' 2>/dev/null
sleep 2

# Navigate to project
cd "$(dirname "$0")"

# Clean everything
echo "🧹 Deep cleaning all build artifacts..."
rm -rf ~/Library/Developer/Xcode/DerivedData/SkinCrafter-*
rm -rf build/
xcodebuild clean -workspace SkinCrafter.xcworkspace -scheme SkinCrafter

# Remove and reinstall pods
echo "📦 Reinstalling CocoaPods from scratch..."
rm -rf Pods/
rm -rf SkinCrafter.xcworkspace
rm -f Podfile.lock
pod cache clean --all --verbose
pod install --repo-update

# Verify framework exists
echo "🔍 Verifying GoogleMobileAds framework..."
if [ -d "Pods/Google-Mobile-Ads-SDK/Frameworks/GoogleMobileAdsFramework/GoogleMobileAds.xcframework" ]; then
    echo "✅ GoogleMobileAds framework found!"
else
    echo "❌ GoogleMobileAds framework NOT found!"
    exit 1
fi

# Build from command line to verify
echo "🔨 Testing build from command line..."
xcodebuild -workspace SkinCrafter.xcworkspace \
           -scheme SkinCrafter \
           -destination 'platform=iOS Simulator,name=iPhone 16' \
           build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful from command line!"
    echo ""
    echo "📱 Opening Xcode..."
    open SkinCrafter.xcworkspace
    echo ""
    echo "🎯 In Xcode, please:"
    echo "   1. Wait for indexing to complete (progress bar at top)"
    echo "   2. Product → Clean Build Folder (Cmd+Shift+K)"
    echo "   3. Select iPhone 16 simulator"
    echo "   4. Product → Build (Cmd+B)"
    echo ""
    echo "💡 If still failing in Xcode:"
    echo "   - Quit Xcode"
    echo "   - Delete ~/Library/Developer/Xcode/DerivedData/"
    echo "   - Reopen workspace and try again"
else
    echo "❌ Build failed. Checking for specific issues..."
    xcodebuild -workspace SkinCrafter.xcworkspace \
               -scheme SkinCrafter \
               -destination 'platform=iOS Simulator,name=iPhone 16' \
               build 2>&1 | grep -A 5 "error:"
fi