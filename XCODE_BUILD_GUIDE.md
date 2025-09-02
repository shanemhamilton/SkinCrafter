# SkinCrafter - Xcode Build Guide

## 🚀 Quick Start

### Prerequisites
- Xcode 15.0 or later
- iOS 16.0+ deployment target
- CocoaPods installed (`sudo gem install cocoapods`)

### Build Steps

1. **Open Terminal and navigate to project:**
   ```bash
   cd /Users/shanehamilton/Documents/Projects/SkinCrafter
   ```

2. **Run the build preparation script:**
   ```bash
   ./build_for_xcode.sh
   ```

3. **Open in Xcode:**
   ```bash
   open SkinCrafter.xcworkspace
   ```
   
   ⚠️ **Important:** Always open the `.xcworkspace` file, NOT the `.xcodeproj` file!

4. **Select a simulator or device:**
   - In Xcode, click the device selector next to the Run button
   - Choose an iPhone simulator (iPhone 16 recommended) or connected device

5. **Run the app:**
   - Press `Cmd + R` or click the Run button
   - The app will build and launch in the simulator/device

## 📱 Available Simulators
- iPhone 16 (Recommended)
- iPhone 16 Pro
- iPhone 16 Pro Max
- iPad (various models)

## 🎨 New Features
- **3D-First Editing:** Paint directly on the 3D model
- **Default Skin Template:** Starts with a Steve-like colored skin
- **Multiple Editing Modes:**
  - 3D Edit (default) - Direct 3D model painting
  - Simple - Kid-friendly interface
  - Professional - Advanced tools
  - Focused - Fullscreen canvas

## 🔧 Troubleshooting

### If build fails:
1. Clean build folder: `Cmd + Shift + K`
2. Delete derived data: `Cmd + Shift + Option + K`
3. Run `pod install` again
4. Restart Xcode

### Common Issues:
- **"No such module 'GoogleMobileAds'"**: Run `pod install`
- **Simulator not appearing**: Go to Xcode > Settings > Platforms and download iOS simulators
- **Build errors**: Make sure you opened `.xcworkspace` not `.xcodeproj`

## 🧪 Testing Features

### 3D Painting Mode:
1. Launch the app
2. The 3D model appears by default
3. Toggle between rotation and drawing modes with the button
4. Select colors from the palette
5. Paint directly on the 3D model

### Mode Switching:
1. Tap the mode selector in the top-right
2. Choose between 3D Edit, Simple, Professional, or Focused modes
3. Each mode offers different editing experiences

## 📦 Project Structure
```
SkinCrafter/
├── SkinCrafter.xcworkspace    # ← Open this in Xcode
├── SkinCrafter.xcodeproj      # (Don't open directly)
├── Podfile                     # CocoaPods dependencies
├── SkinCrafter/
│   ├── SkinCrafterApp.swift   # Main app entry
│   ├── Enhanced3DEditingView.swift  # 3D editing interface
│   ├── Direct3DPaintingSystem.swift # 3D painting logic
│   ├── DefaultSkinTemplates.swift   # Default skin templates
│   └── ... (other source files)
└── Pods/                       # CocoaPods dependencies
```

## 🚀 Ready to Build!
The project is now configured and ready for Xcode. Happy coding! 🎮