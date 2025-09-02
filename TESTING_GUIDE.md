# SkinCrafter Testing Guide

## Overview
This guide covers testing the newly implemented guided creation flow and 3D painting features in SkinCrafter.

## What's Been Implemented

### 1. **Guided Creation Flow**
- Step-by-step wizard through body parts (Head → Arms → Torso → Legs)
- Visual progress indicator with completion tracking
- Auto-advance after first paint on each part
- Skip to freeform option for advanced users

### 2. **Fixed 3D Model Visibility**
- All body parts now have visible base colors (no more transparent sections)
- Checkerboard pattern background for transparent areas
- Default skin template with:
  - Skin tone for head and arms
  - Blue shirt for torso
  - Dark blue pants for legs
  - Simple face features (eyes and smile)

### 3. **Working 3D Touch-to-Paint**
- Proper UV mapping from 3D touches to texture coordinates
- Circular brush with size 2 for kid-friendly painting
- Real-time texture updates on the 3D model
- Support for all six faces of each body part

### 4. **Smart Mirroring System**
- Per-body-part mirroring toggles
- Arms and legs mirror by default
- Visual indicators when mirroring is active
- Instant preview of mirrored changes

### 5. **Dual Preview System**
- Large focused 3D view of current body part
- Mini preview showing full character
- Camera auto-focuses on current body part
- Reset camera button for orientation

## How to Test

### Launch the App
```bash
# Open Xcode
open SkinCrafter.xcodeproj

# Select iPhone 16 Pro simulator
# Press Cmd+R to build and run
```

### Test Flow

#### 1. Mode Selection
- App should open to mode selector
- Choose "Express Mode" (purple, kid-friendly)
- Should see option for "Guided" vs "Freeform" in top-right

#### 2. Guided Creation Flow
**Initial State:**
- Progress bar shows 6 dots (Head, Torso, Arms x2, Legs x2)
- Head should be highlighted/focused
- 3D model should show default skin with visible colors
- Color palette on right side

**Test Each Step:**
1. **Head**
   - Tap/click on the 3D head
   - Should see paint applied
   - Progress dot should turn green
   - Should auto-advance to Torso

2. **Torso**
   - Paint the body/shirt area
   - Test different colors from palette
   - Verify progress updates

3. **Arms**
   - Toggle mirroring on/off
   - Paint one arm with mirroring ON
   - Both arms should update simultaneously
   - Paint with mirroring OFF
   - Only selected arm should update

4. **Legs**
   - Similar to arms - test mirroring
   - Verify camera focuses correctly

#### 3. 3D Painting Tests
- **Single Tap**: Should paint a circular spot
- **Drag**: Should paint a continuous line
- **Different Body Parts**: Only current part should accept paint
- **Color Changes**: Select new color, verify it applies

#### 4. Navigation Tests
- **Skip Button**: Should jump to freeform mode
- **Previous/Next**: Navigate between body parts
- **Body Part Selector**: Click different parts in side panel
- **Reset Camera**: Click reset button, camera should refocus

#### 5. Mode Switching
- Switch from Guided to Freeform mode
- Switch back to Guided - progress should be preserved
- Test mode selector (grid icon in top-left)

## Expected Results

### ✅ Success Criteria
1. **3D Model Always Visible**: No transparent/invisible sections
2. **Touch Painting Works**: Every tap/drag produces visible paint
3. **Mirroring Functions**: Toggle works, updates both sides when ON
4. **Progress Saves**: Moving between modes preserves work
5. **Camera Focus**: Each body part gets proper camera angle
6. **Kid-Friendly**: Large touch targets (70x70pt minimum)

### 🎯 3-Tap Success (Express Mode)
1. **Tap 1**: Select Express Mode
2. **Tap 2**: Choose color (optional - blue is default)
3. **Tap 3**: Paint on model
Result: Visible change on 3D model with celebration animation

## Known Issues to Verify Fixed

1. **Transparent Sections** ✅
   - Previously: Model had invisible areas
   - Now: All faces have visible base colors

2. **3D Painting Not Working** ✅
   - Previously: Taps didn't produce paint
   - Now: UV mapping correctly translates touches to texture

3. **Overwhelming Interface** ✅
   - Previously: Entire skin presented at once
   - Now: Guided step-by-step through body parts

4. **No Clear Progression** ✅
   - Previously: No structure to creation
   - Now: Clear 6-step progression with visual indicators

## Performance Tests

### Memory Usage
- Monitor memory while painting
- Should remain stable (no leaks)
- Undo/redo should not accumulate memory

### Responsiveness
- Paint should appear immediately on tap
- No lag when switching body parts
- Smooth camera transitions

## Accessibility Tests

### Touch Targets
- All buttons should be minimum 44x44pt
- Express mode buttons should be 70x70pt
- Verify with Accessibility Inspector

### VoiceOver
- All buttons should have labels
- Progress indicators should announce state
- Color picker should describe colors

## Edge Cases to Test

1. **Rapid Tapping**: Fast taps shouldn't crash
2. **Quick Mode Switching**: Rapidly toggle between modes
3. **Undo/Redo**: Test with complex paint patterns
4. **Color Picker**: Select same color repeatedly
5. **Mirroring Toggle**: Toggle while actively painting
6. **Skip Tutorial**: Skip at different stages

## Export Testing

After creating a skin:
1. Click "Done" or "Export"
2. Should see export options:
   - Save to Photos
   - Share
   - Open in Minecraft
   - Save to Files
3. Parent gate should appear for external actions
4. Local saves shouldn't require parent gate

## Debug Commands

If you encounter issues, check:
```swift
// In Xcode console
po skinManager.currentSkin
po skinManager.paintCount
po skinManager.achievements
```

## Reporting Issues

When reporting problems, include:
1. Device/Simulator model
2. iOS version
3. Steps to reproduce
4. Screenshot if visual issue
5. Console output if crash

## Next Development Steps

Based on testing results:
1. Fine-tune brush sizes
2. Adjust camera angles
3. Add more celebration animations
4. Implement texture patterns
5. Add preset color palettes per body part

---

**Remember**: The goal is a frustration-free, joyful creation experience that works in 3 taps for kids while maintaining depth for advanced users.