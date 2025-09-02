x`# UX Review Prompt for SkinCrafter - Minecraft Skin Design Tool

## Project Overview
SkinCrafter is a professional iOS app for creating Minecraft skins, designed to be the "mobile Blockbench". It features both a kid-friendly simple mode and a professional mode with advanced editing capabilities. The app needs to be sleek, streamlined, and compact to make skin building easy and efficient on mobile devices.

## Your Role
You are a Senior UX Designer specializing in mobile creative tools and gaming applications. Your expertise includes:
- Mobile-first design patterns for creative tools
- Touch-optimized interfaces for precision editing
- Designing for both children and professional users
- Compact, efficient layouts for complex toolsets
- Gaming and creative community best practices

## Current Implementation
The app currently includes:
- Dual-mode interface (Simple/Professional)
- 2D canvas editor with drawing tools
- 3D preview using SceneKit
- 15+ advanced drawing tools
- Layer management system
- Body part isolation for targeted editing
- Export functionality (Photos, Files, AirDrop, Minecraft)
- Undo/redo with 50-state history
- Color palette management
- Grid, guides, and symmetry tools

## Key UX Goals

### Primary Objectives
1. **Streamlined Workflow**: Minimize taps/gestures needed for common tasks
2. **Compact Interface**: Maximize canvas space while keeping tools accessible
3. **Touch Optimization**: Ensure precision editing on small screens
4. **Mode Differentiation**: Clear, intuitive separation between Simple and Pro modes
5. **Quick Access**: Fast tool switching without cluttering the interface

### User Personas
1. **Young Creators (8-14)**: Need simple, fun, intuitive interface
2. **Serious Hobbyists (14-25)**: Want powerful tools with efficient workflow
3. **Professional Skin Designers**: Require precision tools and batch operations

## Specific Review Areas

### 1. Tool Organization
- How should the 15+ tools be grouped and accessed?
- Should we use a toolbar, floating panels, or gesture-based tool switching?
- How to balance tool visibility with canvas space?

### 2. Canvas Interaction
- Best approach for zoom/pan without interfering with drawing
- How to handle precision pixel editing on small screens
- Should we implement a magnifier loupe for detailed work?

### 3. 3D Preview Integration
- Should 3D preview be always visible, toggleable, or picture-in-picture?
- How to sync 2D edits with 3D preview efficiently?
- Best placement for animation preview controls

### 4. Layer Management
- Compact way to show layer stack on mobile
- Quick layer operations (opacity, visibility, reorder)
- Should layers be in a drawer, popup, or sidebar?

### 5. Color Selection
- Optimal color picker for both modes
- Recent colors vs. palette management
- Eye-dropper tool implementation for touch

### 6. Navigation Flow
- Switching between Simple and Professional modes
- File management (new, open, save, templates)
- Export workflow optimization

## Design Constraints

### Technical Limitations
- iOS 16.0+ target
- Must work on iPhone SE (small) to iPad Pro (large)
- SceneKit for 3D rendering (impacts performance)
- Touch-only interface (no Apple Pencil required, but supported)

### Brand Requirements
- Kid-friendly appearance in Simple mode
- Professional feel in Pro mode
- Must compete with desktop tools like Blockbench
- COPPA-compliant (affects UI for ads/purchases)

## Specific Questions to Address

### Layout & Space Management
1. What's the optimal layout for maximizing canvas space while keeping tools accessible?
2. Should we use bottom sheets, side drawers, or floating panels for tool palettes?
3. How can we implement responsive layouts that work across all iOS devices?

### Interaction Patterns
1. What gestures should we reserve for canvas manipulation vs. tool activation?
2. How can we make pixel-perfect editing possible on touch screens?
3. Should we implement custom gestures for power users?

### Visual Hierarchy
1. How to visually separate Simple mode from Professional mode?
2. What visual cues indicate active tool, layer, and body part?
3. How to show tool settings without overwhelming the interface?

### Workflow Optimization
1. What are the most common action sequences that need shortcuts?
2. How can we reduce mode switching for hybrid workflows?
3. Should we implement customizable tool presets or workspaces?

### Onboarding & Discovery
1. How to introduce new users to the dual-mode system?
2. What's the best way to teach advanced features progressively?
3. Should we include interactive tutorials or tooltip systems?

## Deliverables Requested

1. **Interface Mockups/Wireframes**
   - Compact tool layout proposals
   - Gesture interaction diagrams
   - Responsive design for different screen sizes

2. **User Flow Diagrams**
   - Complete skin creation workflow
   - Mode switching scenarios
   - Export and sharing paths

3. **Interaction Specifications**
   - Touch gesture mappings
   - Tool switching mechanisms
   - Canvas manipulation controls

4. **Design System Recommendations**
   - Component library for consistent UI
   - Color schemes for both modes
   - Typography and spacing guidelines

5. **Prioritized Improvements List**
   - Quick wins for immediate impact
   - Long-term enhancements
   - Features to remove or consolidate

## Success Metrics
- Time to complete common tasks (draw, color, export)
- Number of taps for frequent operations
- Canvas visibility percentage
- User error rate in precision editing
- Mode switching frequency

## Competitive References
- **Blockbench** (desktop): Feature parity goals
- **Skinseed** (mobile): Current market leader
- **Procreate** (iPad): Touch-optimized creative tools
- **Pixel Studio** (mobile): Pixel art specific patterns

## Additional Context
- The app uses SwiftUI with some UIKit components
- Current implementation favors feature completeness over optimization
- Must maintain feature parity between Simple and Pro modes where appropriate
- Export compatibility with all Minecraft versions is critical

Please provide recommendations that prioritize:
1. **Efficiency**: Faster workflow for experienced users
2. **Compactness**: Maximum canvas, minimum chrome
3. **Intuitiveness**: Easy learning curve for new users
4. **Flexibility**: Adapts to different user skill levels
5. **Performance**: Smooth experience even with complex skins

Focus on making the tool feel native to iOS while maintaining the power expected from a professional skin editor. The goal is to make SkinCrafter the definitive mobile Minecraft skin creation tool that's both approachable for kids and powerful enough for professionals.
