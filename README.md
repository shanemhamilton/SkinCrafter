# SkinCrafter - Professional Skin Editor

A professional-grade iOS app for creating character skins compatible with Minecraft, Roblox, and other popular games. Features advanced editing tools, live 3D preview, and seamless export options. Designed to be both kid-friendly and powerful enough for professional creators.

## Features

### Core Functionality

#### Simple Mode (Kid-Friendly)
- **2D Pixel Editor**: 64x64 grid with intuitive drawing tools
- **Live 3D Preview**: Real-time SceneKit rendering
- **Basic Tools**: Pencil, eraser, fill bucket, eyedropper, mirror
- **Templates Library**: 10+ pre-made skins (Classic, Fantasy, Modern, Monsters)

#### Professional Mode (Blockbench-Like)
- **Advanced Drawing Tools**: 15+ tools including brush, airbrush, gradients, shapes
- **Undo/Redo System**: Up to 50 history states
- **Layer Management**: Multiple layers with opacity control
- **Grid & Guides**: Customizable grid, snap-to-grid, symmetry modes
- **Body Part Isolation**: Edit specific parts without affecting others
- **Color Palettes**: Pre-made and custom palettes, color extraction from skins
- **Zoom & Pan**: Up to 400% zoom with smooth pan controls
- **Animation Preview**: 7 animation modes (idle, walk, run, jump, swim, sneak, attack)

### Export Options (Professional Features)
- **Save to Photos**: Direct export to device photo library
- **Save to Files**: Export to iCloud Drive or local storage  
- **AirDrop**: Instantly share to nearby Apple devices
- **Game Integration**: Direct export to Minecraft and other compatible games
- **Share Sheet**: Share via any installed app (Discord, email, etc.)
- **Multiple Formats**:
  - Standard 64x64 (Compatible with Minecraft Java)
  - Legacy 64x32 (Compatible with older game versions)
  - HD 128x128 (Compatible with Minecraft Bedrock)
  - Game-ready with proper formatting

### Kid-Friendly Design
- Large, colorful buttons easy for small fingers
- Visual feedback with animations and haptics
- Simple navigation with only 4 main tabs
- Bright, engaging color scheme
- Mode toggle between Simple and Professional

### Safety & Compliance
- **COPPA Compliant**: Contextual ads only, no personal data collection
- **Parental Controls**: Built-in safety features
- **No Chat/Social**: Focus on creativity without online interaction

### Monetization
- Google AdMob with child-directed settings
- Non-personalized contextual ads
- Test ads configured for development
- Future premium features behind parental gate

## Technical Stack

- **Language**: Swift 5.0+
- **UI Framework**: SwiftUI
- **3D Rendering**: SceneKit
- **Drawing**: PencilKit + Core Graphics
- **Minimum iOS**: 16.0

## Project Structure

```
SkinCrafter/
├── Models/
│   └── MinecraftSkin.swift       # Core skin data model
├── Views/
│   └── ContentView.swift         # Main app views
├── Components/
│   ├── SkinEditorCanvas.swift    # 2D pixel editor
│   └── Skin3DPreview.swift       # 3D preview component
├── Services/
│   └── (AdManager, etc.)         # Business logic
└── Info.plist                     # App configuration
```

## Setup Instructions

1. Open `SkinCrafter.xcodeproj` in Xcode 15+
2. Configure your AdMob App ID in `Info.plist`
3. Build and run on iOS 16+ device or simulator

## Skin Format

- **Dimensions**: 64x64 pixels (compatible with most games)
- **Format**: PNG with transparency support
- **Layers**: Base layer + Optional overlay
- **Model Support**: Standard (4px arms) and Slim (3px arms) models

## Future Features

- Expanded game compatibility (More formats)
- Cloud save/sync
- Skin sharing gallery (with moderation)
- Advanced tools (gradients, patterns)
- More animation preview modes

## Development Notes

### Adding New Drawing Tools
1. Add case to `DrawingTool` enum in `MinecraftSkin.swift`
2. Implement tool logic in `PixelGridView.drawAtPoint()`
3. Add UI button in `DrawingToolsBar`

### Extending to Other Games
1. Create new model class similar to `MinecraftSkin`
2. Implement game-specific 3D preview
3. Add templates for that game
4. Update export format as needed

## License

Proprietary - All Rights Reserved

## Credits

Created with inspiration from open-source projects:
- skinview3d (Three.js Minecraft viewer)
- Various Minecraft skin editors

Built for kids to unleash their creativity!