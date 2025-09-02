import SwiftUI
import UIKit

// MARK: - Enhanced Intuitive Editor Canvas with Express/Studio Modes
struct IntuitiveEditorCanvasEnhanced: UIViewRepresentable {
    @EnvironmentObject var skinManager: SkinManager
    @Binding var editorMode: EditorMode
    
    enum EditorMode {
        case express
        case studio
    }
    
    func makeUIView(context: Context) -> EnhancedIntuitivePaintView {
        let view = EnhancedIntuitivePaintView()
        view.skinManager = skinManager
        view.editorMode = editorMode
        return view
    }
    
    func updateUIView(_ uiView: EnhancedIntuitivePaintView, context: Context) {
        uiView.editorMode = editorMode
        uiView.setNeedsDisplay()
    }
}

class EnhancedIntuitivePaintView: UIView {
    var skinManager: SkinManager?
    var editorMode: IntuitiveEditorCanvasEnhanced.EditorMode = .express
    
    // Enhanced touch targets
    private let minTouchTarget: CGFloat = 44.0 // iOS HIG minimum
    private var pixelSize: CGFloat = 8 // Increased base size
    private var scale: CGFloat = 1.0
    
    // Visual feedback
    private var touchRipples: [TouchRipple] = []
    private var displayLink: CADisplayLink?
    private var loupeView: LoupeView?
    private var gridOverlayEnabled = false
    private var symmetryGuideEnabled = false
    
    // Haptic feedback
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    // Quick-win features
    private var activeSticker: StickerOverlay?
    private var lastTouchPoint: CGPoint?
    private var isDrawingLine = false
    
    // Cognitive hints
    private var showBodyPartLabels = true
    private var highlightSymmetry = false
    
    // Body part structure with enhanced touch areas
    private struct EnhancedBodyPart {
        let name: String
        let displayRect: CGRect // Visual display area
        let touchRect: CGRect   // Larger touch target area
        let minecraftMapping: (x: Int, y: Int, width: Int, height: Int)
        let color: UIColor
        let tier: ReadingTier   // Age-appropriate labeling
        let cognitiveHint: String? // Optional micro-lesson
    }
    
    enum ReadingTier {
        case tierA  // Pre/early readers (icons only)
        case tierB  // Confident readers (short labels)
        case tierC  // Tweens/teens (full labels)
    }
    
    struct TouchRipple {
        let center: CGPoint
        var radius: CGFloat
        var opacity: CGFloat
        let color: UIColor
    }
    
    struct StickerOverlay {
        let image: UIImage
        let position: CGPoint
        let size: CGSize
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        isMultipleTouchEnabled = true
        
        // Gestures
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        
        addGestureRecognizer(pinchGesture)
        addGestureRecognizer(longPressGesture)
        
        // Animation display link
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimations))
        displayLink?.add(to: .main, forMode: .common)
        
        // Prepare haptics
        impactFeedback.prepare()
        selectionFeedback.prepare()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Background
        drawBackground(context: context, rect: rect)
        
        // Calculate layout
        let centerX = bounds.width / 2
        let centerY = bounds.height / 2
        
        // Get body parts with enhanced touch targets
        let bodyParts = getEnhancedBodyParts(centerX: centerX, centerY: centerY)
        
        // Draw grid underlay in Studio mode
        if editorMode == .studio && gridOverlayEnabled {
            drawPixelGrid(context: context, bodyParts: bodyParts)
        }
        
        // Draw symmetry guides
        if symmetryGuideEnabled {
            drawSymmetryGuides(context: context, centerX: centerX)
        }
        
        // Draw each body part with enhanced visuals
        for part in bodyParts {
            drawEnhancedBodyPart(context: context, part: part)
        }
        
        // Draw touch ripples
        drawTouchRipples(context: context)
        
        // Draw active sticker preview
        if let sticker = activeSticker {
            drawStickerPreview(context: context, sticker: sticker)
        }
        
        // Draw mode-specific UI
        drawModeSpecificUI(context: context, centerX: centerX, centerY: centerY)
    }
    
    private func getEnhancedBodyParts(centerX: CGFloat, centerY: CGFloat) -> [EnhancedBodyPart] {
        let p = pixelSize * scale
        let touchPadding: CGFloat = 8.0 // Extra padding for touch targets
        
        var parts: [EnhancedBodyPart] = []
        
        // HEAD - Minimum 44pt touch target
        let headDisplay = CGRect(x: centerX - 6*p, y: centerY - 24*p, width: 12*p, height: 12*p)
        let headTouch = headDisplay.insetBy(dx: -touchPadding, dy: -touchPadding)
            .ensureMinimumSize(minTouchTarget)
        
        parts.append(EnhancedBodyPart(
            name: editorMode == .express ? "👤" : "HEAD",
            displayRect: headDisplay,
            touchRect: headTouch,
            minecraftMapping: (8, 8, 8, 8),
            color: .systemPurple,
            tier: editorMode == .express ? .tierA : .tierB,
            cognitiveHint: "Symmetry: Left and right sides mirror each other!"
        ))
        
        // CHEST - Larger for easier targeting
        let chestDisplay = CGRect(x: centerX - 7*p, y: centerY - 10*p, width: 14*p, height: 16*p)
        let chestTouch = chestDisplay.insetBy(dx: -touchPadding, dy: -touchPadding)
            .ensureMinimumSize(minTouchTarget)
        
        parts.append(EnhancedBodyPart(
            name: editorMode == .express ? "👕" : "CHEST",
            displayRect: chestDisplay,
            touchRect: chestTouch,
            minecraftMapping: (20, 20, 8, 12),
            color: .systemTeal,
            tier: editorMode == .express ? .tierA : .tierB,
            cognitiveHint: "Planning: Design your outfit before painting!"
        ))
        
        // ARMS - Enlarged for Express mode
        let armWidth = editorMode == .express ? 12*p : 10*p
        let armHeight = editorMode == .express ? 16*p : 14*p
        
        // Left Arm
        let leftArmDisplay = CGRect(x: centerX - 20*p, y: centerY - 10*p, width: armWidth, height: armHeight)
        let leftArmTouch = leftArmDisplay.insetBy(dx: -touchPadding, dy: -touchPadding)
            .ensureMinimumSize(minTouchTarget)
        
        parts.append(EnhancedBodyPart(
            name: editorMode == .express ? "💪" : "L.ARM",
            displayRect: leftArmDisplay,
            touchRect: leftArmTouch,
            minecraftMapping: (36, 52, 4, 12),
            color: .systemBlue,
            tier: editorMode == .express ? .tierA : .tierB,
            cognitiveHint: "Mirror: Paint one arm, then copy to the other!"
        ))
        
        // Right Arm
        let rightArmDisplay = CGRect(x: centerX + 8*p, y: centerY - 10*p, width: armWidth, height: armHeight)
        let rightArmTouch = rightArmDisplay.insetBy(dx: -touchPadding, dy: -touchPadding)
            .ensureMinimumSize(minTouchTarget)
        
        parts.append(EnhancedBodyPart(
            name: editorMode == .express ? "💪" : "R.ARM",
            displayRect: rightArmDisplay,
            touchRect: rightArmTouch,
            minecraftMapping: (44, 20, 4, 12),
            color: .systemBlue,
            tier: editorMode == .express ? .tierA : .tierB,
            cognitiveHint: nil
        ))
        
        // LEGS - Wider spacing for Express
        let legSpacing = editorMode == .express ? 4*p : 2*p
        let legWidth = editorMode == .express ? 8*p : 6*p
        
        // Left Leg
        let leftLegDisplay = CGRect(x: centerX - legWidth - legSpacing/2, y: centerY + 7*p, width: legWidth, height: 16*p)
        let leftLegTouch = leftLegDisplay.insetBy(dx: -touchPadding, dy: -touchPadding)
            .ensureMinimumSize(minTouchTarget)
        
        parts.append(EnhancedBodyPart(
            name: editorMode == .express ? "🦵" : "L.LEG",
            displayRect: leftLegDisplay,
            touchRect: leftLegTouch,
            minecraftMapping: (20, 52, 4, 12),
            color: .systemIndigo,
            tier: editorMode == .express ? .tierA : .tierB,
            cognitiveHint: "Patterns: Create repeating designs!"
        ))
        
        // Right Leg
        let rightLegDisplay = CGRect(x: centerX + legSpacing/2, y: centerY + 7*p, width: legWidth, height: 16*p)
        let rightLegTouch = rightLegDisplay.insetBy(dx: -touchPadding, dy: -touchPadding)
            .ensureMinimumSize(minTouchTarget)
        
        parts.append(EnhancedBodyPart(
            name: editorMode == .express ? "🦵" : "R.LEG",
            displayRect: rightLegDisplay,
            touchRect: rightLegTouch,
            minecraftMapping: (4, 20, 4, 12),
            color: .systemIndigo,
            tier: editorMode == .express ? .tierA : .tierB,
            cognitiveHint: nil
        ))
        
        // Studio mode adds precision areas
        if editorMode == .studio {
            // Face detail area
            parts.append(EnhancedBodyPart(
                name: "FACE",
                displayRect: CGRect(x: centerX - 4*p, y: centerY - 20*p, width: 8*p, height: 6*p),
                touchRect: CGRect(x: centerX - 5*p, y: centerY - 21*p, width: 10*p, height: 8*p),
                minecraftMapping: (8, 11, 8, 5),
                color: .systemPink.withAlphaComponent(0.7),
                tier: .tierC,
                cognitiveHint: "Detail work: Zoom in for precision!"
            ))
            
            // Hat/Hair layer
            parts.append(EnhancedBodyPart(
                name: "HAT",
                displayRect: CGRect(x: centerX - 7*p, y: centerY - 25*p, width: 14*p, height: 4*p),
                touchRect: CGRect(x: centerX - 8*p, y: centerY - 26*p, width: 16*p, height: 6*p),
                minecraftMapping: (40, 8, 8, 8),
                color: .systemBrown.withAlphaComponent(0.7),
                tier: .tierC,
                cognitiveHint: nil
            ))
        }
        
        return parts
    }
    
    private func drawEnhancedBodyPart(context: CGContext, part: EnhancedBodyPart) {
        // Shadow for depth (subtle in Express, stronger in Studio)
        let shadowOpacity = editorMode == .express ? 0.05 : 0.1
        context.setShadow(
            offset: CGSize(width: 0, height: 2),
            blur: editorMode == .express ? 2 : 4,
            color: UIColor.black.withAlphaComponent(shadowOpacity).cgColor
        )
        
        // Background gradient
        drawBodyPartBackground(context: context, part: part)
        
        // Clear shadow
        context.setShadow(offset: .zero, blur: 0)
        
        // Draw skin pixels
        if let skinManager = skinManager {
            drawSkinPixels(context: context, part: part, skin: skinManager.currentSkin)
        }
        
        // Border with appropriate styling
        drawBodyPartBorder(context: context, part: part)
        
        // Labels and hints
        drawBodyPartLabel(context: context, part: part)
        
        // Empty state hint
        if editorMode == .express {
            drawEmptyStateHint(context: context, part: part)
        }
        
        // Touch area indicator (Studio mode debug)
        if editorMode == .studio && UserDefaults.standard.bool(forKey: "showTouchAreas") {
            context.setStrokeColor(UIColor.systemRed.withAlphaComponent(0.2).cgColor)
            context.setLineWidth(1)
            context.stroke(part.touchRect)
        }
    }
    
    private func drawBodyPartBackground(context: CGContext, part: EnhancedBodyPart) {
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                part.color.withAlphaComponent(0.03).cgColor,
                part.color.withAlphaComponent(0.08).cgColor
            ] as CFArray,
            locations: [0.0, 1.0]
        )!
        
        context.saveGState()
        
        let path = UIBezierPath(
            roundedRect: part.displayRect,
            cornerRadius: editorMode == .express ? 8 : 4
        )
        context.addPath(path.cgPath)
        context.clip()
        
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: part.displayRect.minX, y: part.displayRect.minY),
            end: CGPoint(x: part.displayRect.maxX, y: part.displayRect.maxY),
            options: []
        )
        
        context.restoreGState()
    }
    
    private func drawBodyPartBorder(context: CGContext, part: EnhancedBodyPart) {
        let path = UIBezierPath(
            roundedRect: part.displayRect,
            cornerRadius: editorMode == .express ? 8 : 4
        )
        
        // Thicker, friendlier borders in Express mode
        context.setStrokeColor(part.color.cgColor)
        context.setLineWidth(editorMode == .express ? 3.0 : 2.0)
        
        if editorMode == .express {
            // Dashed border for playful look
            context.setLineDash(phase: 0, lengths: [6, 3])
        }
        
        context.addPath(path.cgPath)
        context.strokePath()
        
        // Reset dash
        context.setLineDash(phase: 0, lengths: [])
    }
    
    private func drawBodyPartLabel(context: CGContext, part: EnhancedBodyPart) {
        // Label styling based on tier
        let fontSize: CGFloat
        let fontWeight: UIFont.Weight
        
        switch part.tier {
        case .tierA:
            fontSize = 16
            fontWeight = .bold
        case .tierB:
            fontSize = 12
            fontWeight = .semibold
        case .tierC:
            fontSize = 10
            fontWeight = .medium
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: fontWeight),
            .foregroundColor: UIColor.white
        ]
        
        let labelSize = part.name.size(withAttributes: attributes)
        
        // Position label above part with bubble background
        let labelRect = CGRect(
            x: part.displayRect.midX - labelSize.width / 2 - 8,
            y: part.displayRect.minY - labelSize.height - 12,
            width: labelSize.width + 16,
            height: labelSize.height + 6
        )
        
        // Bubble background
        let bubblePath = UIBezierPath(roundedRect: labelRect, cornerRadius: labelRect.height / 2)
        context.setFillColor(part.color.cgColor)
        context.addPath(bubblePath.cgPath)
        context.fillPath()
        
        // Draw text
        let labelPoint = CGPoint(
            x: labelRect.midX - labelSize.width / 2,
            y: labelRect.minY + 3
        )
        part.name.draw(at: labelPoint, withAttributes: attributes)
        
        // Cognitive hint chip (Express mode)
        if editorMode == .express, let hint = part.cognitiveHint, showBodyPartLabels {
            drawCognitiveHint(context: context, hint: hint, nearRect: part.displayRect)
        }
    }
    
    private func drawEmptyStateHint(context: CGContext, part: EnhancedBodyPart) {
        guard let skinManager = skinManager else { return }
        
        if !hasPixelsInPart(part: part, skin: skinManager.currentSkin) {
            let hintText = editorMode == .express ? "Tap! 👆" : "Empty"
            let hintAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(
                    ofSize: editorMode == .express ? 14 : 9,
                    weight: editorMode == .express ? .semibold : .regular
                ),
                .foregroundColor: UIColor.secondaryLabel.withAlphaComponent(0.6)
            ]
            
            let hintSize = hintText.size(withAttributes: hintAttributes)
            let hintPoint = CGPoint(
                x: part.displayRect.midX - hintSize.width / 2,
                y: part.displayRect.midY - hintSize.height / 2
            )
            
            // Pulsing animation in Express mode
            if editorMode == .express {
                let pulseAlpha = 0.3 + 0.3 * sin(CACurrentMediaTime() * 2)
                context.setAlpha(pulseAlpha)
            }
            
            hintText.draw(at: hintPoint, withAttributes: hintAttributes)
            context.setAlpha(1.0)
        }
    }
    
    private func drawCognitiveHint(context: CGContext, hint: String, nearRect: CGRect) {
        // Small info bubble that appears on first interaction
        let infoIcon = "ℹ️"
        let iconAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10)
        ]
        
        let iconPoint = CGPoint(
            x: nearRect.maxX - 15,
            y: nearRect.minY - 20
        )
        
        infoIcon.draw(at: iconPoint, withAttributes: iconAttributes)
    }
    
    private func drawTouchRipples(context: CGContext) {
        for ripple in touchRipples {
            context.setFillColor(ripple.color.withAlphaComponent(ripple.opacity).cgColor)
            context.fillEllipse(in: CGRect(
                x: ripple.center.x - ripple.radius,
                y: ripple.center.y - ripple.radius,
                width: ripple.radius * 2,
                height: ripple.radius * 2
            ))
        }
    }
    
    private func drawPixelGrid(context: CGContext, bodyParts: [EnhancedBodyPart]) {
        context.setStrokeColor(UIColor.systemGray4.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(0.5)
        
        for part in bodyParts {
            let (_, _, width, height) = part.minecraftMapping
            
            // Calculate pixel size for this part
            let pixelWidth = part.displayRect.width / CGFloat(width)
            let pixelHeight = part.displayRect.height / CGFloat(height)
            
            // Vertical lines
            for i in 0...width {
                let x = part.displayRect.minX + CGFloat(i) * pixelWidth
                context.move(to: CGPoint(x: x, y: part.displayRect.minY))
                context.addLine(to: CGPoint(x: x, y: part.displayRect.maxY))
            }
            
            // Horizontal lines
            for i in 0...height {
                let y = part.displayRect.minY + CGFloat(i) * pixelHeight
                context.move(to: CGPoint(x: part.displayRect.minX, y: y))
                context.addLine(to: CGPoint(x: part.displayRect.maxX, y: y))
            }
        }
        
        context.strokePath()
    }
    
    private func drawSymmetryGuides(context: CGContext, centerX: CGFloat) {
        context.setStrokeColor(UIColor.systemPurple.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(2)
        context.setLineDash(phase: 0, lengths: [5, 5])
        
        // Vertical center line
        context.move(to: CGPoint(x: centerX, y: 0))
        context.addLine(to: CGPoint(x: centerX, y: bounds.height))
        context.strokePath()
        
        // Reset dash
        context.setLineDash(phase: 0, lengths: [])
    }
    
    private func drawBackground(context: CGContext, rect: CGRect) {
        // Express mode: Playful gradient
        // Studio mode: Neutral workspace
        if editorMode == .express {
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor.systemPurple.withAlphaComponent(0.05).cgColor,
                    UIColor.systemBlue.withAlphaComponent(0.05).cgColor,
                    UIColor.systemPink.withAlphaComponent(0.05).cgColor
                ] as CFArray,
                locations: [0.0, 0.5, 1.0]
            )!
            
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: rect.width, y: rect.height),
                options: []
            )
        } else {
            context.setFillColor(UIColor.systemGray6.cgColor)
            context.fill(rect)
        }
    }
    
    private func drawModeSpecificUI(context: CGContext, centerX: CGFloat, centerY: CGFloat) {
        if editorMode == .express {
            // Fun decorative elements
            drawExpressDecorations(context: context, centerX: centerX, centerY: centerY)
        } else {
            // Professional grid markers and rulers
            drawStudioRulers(context: context)
        }
    }
    
    private func drawExpressDecorations(context: CGContext, centerX: CGFloat, centerY: CGFloat) {
        // Sparkles around the character
        let sparkleEmojis = ["✨", "⭐", "🌟"]
        let positions = [
            CGPoint(x: centerX - 100, y: centerY - 150),
            CGPoint(x: centerX + 100, y: centerY - 150),
            CGPoint(x: centerX - 120, y: centerY),
            CGPoint(x: centerX + 120, y: centerY)
        ]
        
        for (index, position) in positions.enumerated() {
            let sparkle = sparkleEmojis[index % sparkleEmojis.count]
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20)
            ]
            
            // Gentle rotation animation
            let rotation = sin(CACurrentMediaTime() + Double(index)) * 0.2
            context.saveGState()
            context.translateBy(x: position.x, y: position.y)
            context.rotate(by: rotation)
            sparkle.draw(at: CGPoint(x: -10, y: -10), withAttributes: attributes)
            context.restoreGState()
        }
    }
    
    private func drawStudioRulers(context: CGContext) {
        // Pixel rulers on edges
        context.setStrokeColor(UIColor.secondaryLabel.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(0.5)
        
        // Top ruler
        for i in stride(from: 0, to: Int(bounds.width), by: 10) {
            let height: CGFloat = i % 50 == 0 ? 10 : 5
            context.move(to: CGPoint(x: CGFloat(i), y: 0))
            context.addLine(to: CGPoint(x: CGFloat(i), y: height))
        }
        
        // Left ruler
        for i in stride(from: 0, to: Int(bounds.height), by: 10) {
            let width: CGFloat = i % 50 == 0 ? 10 : 5
            context.move(to: CGPoint(x: 0, y: CGFloat(i)))
            context.addLine(to: CGPoint(x: width, y: CGFloat(i)))
        }
        
        context.strokePath()
    }
    
    private func drawStickerPreview(context: CGContext, sticker: StickerOverlay) {
        context.saveGState()
        context.translateBy(x: sticker.position.x, y: sticker.position.y)
        context.setAlpha(0.7)
        sticker.image.draw(in: CGRect(
            x: -sticker.size.width / 2,
            y: -sticker.size.height / 2,
            width: sticker.size.width,
            height: sticker.size.height
        ))
        context.restoreGState()
    }
    
    private func drawSkinPixels(context: CGContext, part: EnhancedBodyPart, skin: CharacterSkin) {
        let (startX, startY, width, height) = part.minecraftMapping
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelColor = skin.getPixel(x: startX + x, y: startY + y, layer: .base)
                if pixelColor != .clear {
                    context.setFillColor(UIColor(pixelColor).cgColor)
                    
                    let pixelRect = CGRect(
                        x: part.displayRect.minX + (part.displayRect.width * CGFloat(x) / CGFloat(width)),
                        y: part.displayRect.minY + (part.displayRect.height * CGFloat(y) / CGFloat(height)),
                        width: part.displayRect.width / CGFloat(width),
                        height: part.displayRect.height / CGFloat(height)
                    )
                    
                    context.fill(pixelRect)
                }
            }
        }
    }
    
    private func hasPixelsInPart(part: EnhancedBodyPart, skin: CharacterSkin) -> Bool {
        let (startX, startY, width, height) = part.minecraftMapping
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelColor = skin.getPixel(x: startX + x, y: startY + y, layer: .base)
                if pixelColor != .clear && pixelColor != Color(red: 0.96, green: 0.80, blue: 0.69) {
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        lastTouchPoint = location
        
        // Haptic feedback
        impactFeedback.impactOccurred()
        
        // Add touch ripple
        addTouchRipple(at: location)
        
        // Handle touch
        handleTouch(at: location, touch: touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        // Show loupe in Studio mode for precision
        if editorMode == .studio {
            showLoupe(at: location)
        }
        
        // Line drawing
        if isDrawingLine, let lastPoint = lastTouchPoint {
            drawLine(from: lastPoint, to: location)
        }
        
        lastTouchPoint = location
        handleTouch(at: location, touch: touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDrawingLine = false
        lastTouchPoint = nil
        hideLoupe()
        
        // Selection feedback
        selectionFeedback.selectionChanged()
    }
    
    private func handleTouch(at point: CGPoint, touch: UITouch) {
        guard let skinManager = skinManager else { return }
        
        let centerX = bounds.width / 2
        let centerY = bounds.height / 2
        let bodyParts = getEnhancedBodyParts(centerX: centerX, centerY: centerY)
        
        // Check which body part was touched (using enlarged touch rect)
        for part in bodyParts {
            if part.touchRect.contains(point) {
                // Visual feedback
                highlightBodyPart(part)
                
                // Calculate pixel position
                let relativeX = (point.x - part.displayRect.minX) / part.displayRect.width
                let relativeY = (point.y - part.displayRect.minY) / part.displayRect.height
                
                let (startX, startY, width, height) = part.minecraftMapping
                let pixelX = startX + Int(relativeX * CGFloat(width))
                let pixelY = startY + Int(relativeY * CGFloat(height))
                
                // Apply tool with pressure sensitivity
                let pressure = touch.force > 0 ? touch.force / touch.maximumPossibleForce : 1.0
                applyTool(at: pixelX, y: pixelY, pressure: pressure, skinManager: skinManager)
                
                // Update display
                DispatchQueue.main.async {
                    skinManager.objectWillChange.send()
                }
                setNeedsDisplay()
                break
            }
        }
    }
    
    private func applyTool(at x: Int, y: Int, pressure: CGFloat, skinManager: SkinManager) {
        guard x >= 0, x < CharacterSkin.width,
              y >= 0, y < CharacterSkin.height else { return }
        
        // Apply brush size based on pressure in Studio mode
        let brushRadius = editorMode == .studio ? Int(skinManager.brushSize * pressure) : 1
        
        switch skinManager.selectedTool {
        case .pencil, .brush:
            // Apply to area based on brush size
            for dy in -brushRadius...brushRadius {
                for dx in -brushRadius...brushRadius {
                    let dist = sqrt(Double(dx*dx + dy*dy))
                    if dist <= Double(brushRadius) {
                        let px = x + dx
                        let py = y + dy
                        if px >= 0, px < CharacterSkin.width,
                           py >= 0, py < CharacterSkin.height {
                            skinManager.currentSkin.setPixel(
                                x: px, y: py,
                                color: skinManager.selectedColor,
                                layer: skinManager.selectedLayer
                            )
                        }
                    }
                }
            }
            
        case .eraser:
            for dy in -brushRadius...brushRadius {
                for dx in -brushRadius...brushRadius {
                    let px = x + dx
                    let py = y + dy
                    if px >= 0, px < CharacterSkin.width,
                       py >= 0, py < CharacterSkin.height {
                        skinManager.currentSkin.setPixel(
                            x: px, y: py,
                            color: .clear,
                            layer: skinManager.selectedLayer
                        )
                    }
                }
            }
            
        case .bucket:
            skinManager.currentSkin.fill(
                x: x, y: y,
                color: skinManager.selectedColor,
                layer: skinManager.selectedLayer
            )
            
        case .eyedropper:
            let color = skinManager.currentSkin.getPixel(
                x: x, y: y,
                layer: skinManager.selectedLayer
            )
            if color != .clear {
                DispatchQueue.main.async {
                    skinManager.selectedColor = color
                }
            }
            
        case .mirror:
            // Apply symmetrical painting
            applyMirrorTool(at: x, y: y, skinManager: skinManager)
            
        default:
            break
        }
    }
    
    private func applyMirrorTool(at x: Int, y: Int, skinManager: SkinManager) {
        // Find the center line and mirror the action
        let centerX = CharacterSkin.width / 2
        let mirroredX = centerX - (x - centerX)
        
        // Apply to both sides
        skinManager.currentSkin.setPixel(
            x: x, y: y,
            color: skinManager.selectedColor,
            layer: skinManager.selectedLayer
        )
        
        if mirroredX >= 0 && mirroredX < CharacterSkin.width {
            skinManager.currentSkin.setPixel(
                x: mirroredX, y: y,
                color: skinManager.selectedColor,
                layer: skinManager.selectedLayer
            )
        }
    }
    
    private func drawLine(from: CGPoint, to: CGPoint) {
        // Implement line drawing between points
        // This would interpolate between the two points and apply the tool
    }
    
    private func addTouchRipple(at point: CGPoint) {
        let ripple = TouchRipple(
            center: point,
            radius: 10,
            opacity: 0.5,
            color: editorMode == .express ? .systemPurple : .systemBlue
        )
        touchRipples.append(ripple)
        
        // Limit ripples
        if touchRipples.count > 5 {
            touchRipples.removeFirst()
        }
    }
    
    private func highlightBodyPart(_ part: EnhancedBodyPart) {
        // Add a brief highlight animation
        UIView.animate(withDuration: 0.1) {
            self.alpha = 0.95
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.alpha = 1.0
            }
        }
    }
    
    private func showLoupe(at point: CGPoint) {
        if loupeView == nil {
            loupeView = LoupeView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            addSubview(loupeView!)
        }
        
        loupeView?.center = CGPoint(x: point.x, y: point.y - 60)
        loupeView?.sourcePoint = point
        loupeView?.isHidden = false
    }
    
    private func hideLoupe() {
        loupeView?.isHidden = true
    }
    
    // MARK: - Gesture Handlers
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            scale *= gesture.scale
            scale = max(0.5, min(3.0, scale))
            gesture.scale = 1.0
            setNeedsDisplay()
            
            // Haptic feedback at scale limits
            if scale == 0.5 || scale == 3.0 {
                impactFeedback.impactOccurred(intensity: 0.7)
            }
        }
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let location = gesture.location(in: self)
            
            // Studio mode: Show context menu
            if editorMode == .studio {
                showContextMenu(at: location)
            } else {
                // Express mode: Quick fill
                isDrawingLine = true
            }
            
            // Strong haptic
            impactFeedback.impactOccurred(intensity: 1.0)
        }
    }
    
    private func showContextMenu(at point: CGPoint) {
        // Would show a context menu with quick actions
        // Copy, Paste, Mirror, Fill, etc.
    }
    
    // MARK: - Animation Updates
    
    @objc private func updateAnimations() {
        // Update touch ripples
        for i in (0..<touchRipples.count).reversed() {
            touchRipples[i].radius += 2
            touchRipples[i].opacity -= 0.02
            
            if touchRipples[i].opacity <= 0 {
                touchRipples.remove(at: i)
            }
        }
        
        // Redraw if we have animations
        if !touchRipples.isEmpty || editorMode == .express {
            setNeedsDisplay()
        }
    }
    
    deinit {
        displayLink?.invalidate()
    }
}

// MARK: - Helper Extensions

extension CGRect {
    func ensureMinimumSize(_ minSize: CGFloat) -> CGRect {
        var rect = self
        if rect.width < minSize {
            let diff = minSize - rect.width
            rect.origin.x -= diff / 2
            rect.size.width = minSize
        }
        if rect.height < minSize {
            let diff = minSize - rect.height
            rect.origin.y -= diff / 2
            rect.size.height = minSize
        }
        return rect
    }
}

// MARK: - Loupe View for Precision

class LoupeView: UIView {
    var sourcePoint: CGPoint = .zero {
        didSet { setNeedsDisplay() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemBlue.cgColor
        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Magnify the area around sourcePoint
        context.translateBy(x: rect.width / 2, y: rect.height / 2)
        context.scaleBy(x: 2.0, y: 2.0)
        context.translateBy(x: -sourcePoint.x, y: -sourcePoint.y)
        
        // Draw the magnified content
        if let superview = superview {
            superview.layer.render(in: context)
        }
    }
}