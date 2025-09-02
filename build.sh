#!/bin/bash

echo "SkinCrafter Build Script"
echo "========================"

# Check if CocoaPods are installed
if [ -f "Pods/Manifest.lock" ]; then
    echo "✓ CocoaPods dependencies installed"
else
    echo "✗ CocoaPods not installed. Run: pod install"
    exit 1
fi

# Check for workspace
if [ -d "SkinCrafter.xcworkspace" ]; then
    echo "✓ Workspace exists"
else
    echo "✗ Workspace not found"
    exit 1
fi

# List key source files
echo ""
echo "Key Source Files:"
echo "-----------------"
[ -f "SkinCrafter/SkinCrafterApp.swift" ] && echo "✓ SkinCrafterApp.swift"
[ -f "SkinCrafter/ContentView.swift" ] && echo "✓ ContentView.swift"
[ -f "SkinCrafter/Models/MinecraftSkin.swift" ] && echo "✓ MinecraftSkin.swift"
[ -f "SkinCrafter/Models/SkinTemplates.swift" ] && echo "✓ SkinTemplates.swift"
[ -f "SkinCrafter/Components/SkinEditorCanvas.swift" ] && echo "✓ SkinEditorCanvas.swift"
[ -f "SkinCrafter/Components/Skin3DPreview.swift" ] && echo "✓ Skin3DPreview.swift"
[ -f "SkinCrafter/Services/AdManager.swift" ] && echo "✓ AdManager.swift"
[ -f "SkinCrafter/LaunchScreen.swift" ] && echo "✓ LaunchScreen.swift"

echo ""
echo "Build Instructions:"
echo "-------------------"
echo "1. Open SkinCrafter.xcworkspace in Xcode (not the .xcodeproj)"
echo "2. Select a simulator or device"
echo "3. Press Cmd+R to build and run"
echo ""
echo "Note: The app uses test AdMob IDs for development."
echo "Replace with production IDs before App Store submission."