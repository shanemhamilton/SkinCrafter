# SkinCrafter Development Guide for Claude

## Project Overview
SkinCrafter is a professional iOS app for creating Minecraft skins, designed as the "mobile Blockbench". It features both a kid-friendly simple mode and a professional mode with advanced editing capabilities.

## Key Features
- Dual-mode interface: Simple (kid-friendly) and Professional (Blockbench-like)
- 15+ advanced drawing tools with customizable settings
- Real-time 3D preview with SceneKit
- Comprehensive export system (Photos, Files, AirDrop, Minecraft integration)
- COPPA-compliant advertising with Google AdMob
- Undo/redo system with 50-state history
- Layer management with opacity control
- Body part isolation for targeted editing
- Color palette management
- Grid, guides, and symmetry tools
- 7 animation preview modes

## Development Commands

### Building the Project
```bash
# Open the workspace (not .xcodeproj)
open SkinCrafter.xcworkspace

# Or build from command line (use Agent for complex builds)
xcodebuild -workspace SkinCrafter.xcworkspace -scheme SkinCrafter -destination 'platform=iOS Simulator,name=iPhone 15' clean build

# Run the build verification script
./build.sh
```

### Managing Dependencies
```bash
# Install/update CocoaPods
pod install

# Update specific pod
pod update Google-Mobile-Ads-SDK
```

### Testing
```bash
# Run unit tests
xcodebuild test -workspace SkinCrafter.xcworkspace -scheme SkinCrafter -destination 'platform=iOS Simulator,name=iPhone 15'

# UI tests require simulator to be running
xcrun simctl boot "iPhone 15"
```

## Project Structure
```
SkinCrafter/
├── Models/
│   ├── MinecraftSkin.swift       # Core skin data model
│   └── SkinTemplates.swift       # Template definitions
├── Views/
│   ├── ContentView.swift         # Main app navigation
│   └── ProfessionalEditorView.swift # Pro mode interface
├── Components/
│   ├── SkinEditorCanvas.swift    # 2D editing canvas
│   ├── Skin3DPreview.swift       # 3D preview
│   └── EnhancedComponents.swift  # Pro mode components
├── Services/
│   ├── AdManager.swift           # COPPA-compliant ads
│   ├── ExportManager.swift       # Export functionality
│   └── EditingSystem.swift       # Advanced editing tools
└── Info.plist                     # App configuration
```

## Key Technical Decisions

### Why SceneKit over Metal
- SceneKit provides higher-level abstractions perfect for Minecraft's voxel-based models
- Built-in animation system for preview modes
- Easier UV mapping for skin textures
- Good performance for our use case

### Why SwiftUI + UIKit Hybrid
- SwiftUI for modern, reactive UI
- UIKit components (via UIViewRepresentable) for:
  - PencilKit integration (drawing)
  - Document picker (import/export)
  - Photo library access
  - Advanced gesture handling

### Export Strategy
- Multiple export formats to support all Minecraft versions
- Direct photo library integration for easy saving
- AirDrop for quick sharing between Apple devices
- URL scheme support for Minecraft app integration

## Important Configuration

### AdMob Setup
- Test App ID: `ca-app-pub-3940256099942544~1458002511`
- COPPA compliance configured in `AdManager.swift`
- Child-directed treatment enabled
- Only contextual (non-personalized) ads shown

### Permissions Required
- Photo Library Usage (saving skins)
- Photo Library Add Usage (export)
- Network access for ads

## Common Tasks

### Adding a New Drawing Tool
1. Add case to `AdvancedTool` enum in `EditingSystem.swift`
2. Implement tool logic in `EnhancedSkinCanvas.applyTool()`
3. Add UI in `ToolPanel`
4. Create settings panel if needed

### Adding a New Export Format
1. Add case to `ExportFormat` enum in `ExportManager.swift`
2. Implement conversion logic
3. Update UI in `ExportView`

### Creating New Templates
1. Add template definition in `SkinTemplates.swift`
2. Define color regions for each body part
3. Templates auto-appear in UI

## Debugging Tips

### 3D Preview Issues
- Check UV mapping coordinates in `Skin3DPreview.swift`
- Verify texture size matches expected format
- Ensure proper material settings (nearest neighbor filtering)

### Export Problems
- Verify Info.plist permissions
- Check file format conversion logic
- Test on real device (simulator has limitations)

### Performance Optimization
- Canvas drawing is optimized with dirty rect tracking
- 3D preview updates only when skin changes
- Undo/redo stack limited to 50 states

## Testing Checklist

### Before Release
- [ ] Test all export options on real device
- [ ] Verify COPPA compliance settings
- [ ] Replace test AdMob IDs with production
- [ ] Test on all supported iOS versions (16.0+)
- [ ] Verify all drawing tools work correctly
- [ ] Test undo/redo with complex edits
- [ ] Verify animations in 3D preview
- [ ] Test import from various sources

### Device Testing
- iPhone SE (small screen)
- iPhone 15 (standard)
- iPhone 15 Pro Max (large)
- iPad (split view layout)
- iPad Pro (professional use)

## Future Enhancements
- Cloud sync with iCloud
- Collaborative editing
- Custom brush creation
- Texture pack support
- Video export of animations
- Support for other games (Roblox, Fortnite)

## Troubleshooting

### Build Errors
- Ensure you're opening `.xcworkspace` not `.xcodeproj`
- Run `pod install` if dependencies are missing
- Check minimum iOS deployment target (16.0)

### Runtime Issues
- Verify AdMob SDK is properly initialized
- Check photo library permissions
- Ensure SceneKit is available on device

### Performance Issues
- Reduce canvas zoom level
- Disable grid/guides when not needed
- Clear undo history if memory constrained

## Agent Recommendations

When working on complex tasks, use these specialized agents:

### For Building/Compilation Issues
Use the `general-purpose` agent to:
- Debug complex Xcode build errors
- Set up CI/CD pipelines
- Configure code signing

### For UI/UX Improvements
Consider using agents to:
- Research latest iOS design patterns
- Find optimal color schemes for kids
- Analyze competitor apps

### For Performance Optimization
Use agents to:
- Profile the app with Instruments
- Identify memory leaks
- Optimize rendering pipelines

## Contact & Support
- GitHub Issues: Report bugs or request features
- App Store Reviews: User feedback channel
- TestFlight: Beta testing program

## Important Notes
- Always test export features on real devices
- Keep AdMob configuration COPPA-compliant
- Maintain kid-friendly UI in simple mode
- Professional mode can be more complex
- Regular testing on various iOS devices recommended