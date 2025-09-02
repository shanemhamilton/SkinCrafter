import SwiftUI
import UIKit

struct SkinEditorCanvas: UIViewRepresentable {
    @EnvironmentObject var skinManager: SkinManager
    
    func makeUIView(context: Context) -> PixelGridView {
        let view = PixelGridView()
        view.skinManager = skinManager
        return view
    }
    
    func updateUIView(_ uiView: PixelGridView, context: Context) {
        uiView.setNeedsDisplay()
    }
}

class PixelGridView: UIView {
    var skinManager: SkinManager?
    private var pixelSize: CGFloat = 8
    private var gridOffset: CGPoint = .zero
    private var isDrawing = false
    private var lastDrawnPoint: CGPoint?
    
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
        isMultipleTouchEnabled = false
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        addGestureRecognizer(pinchGesture)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(),
              let skinManager = skinManager else { return }
        
        let skin = skinManager.currentSkin
        
        // Calculate drawing area
        let totalWidth = CGFloat(CharacterSkin.width) * pixelSize
        let totalHeight = CGFloat(CharacterSkin.height) * pixelSize
        let centerX = (bounds.width - totalWidth) / 2 + gridOffset.x
        let centerY = (bounds.height - totalHeight) / 2 + gridOffset.y
        
        // Draw checkerboard background
        context.setFillColor(UIColor.systemGray6.cgColor)
        context.fill(rect)
        
        for y in 0..<CharacterSkin.height {
            for x in 0..<CharacterSkin.width {
                let pixelRect = CGRect(
                    x: centerX + CGFloat(x) * pixelSize,
                    y: centerY + CGFloat(y) * pixelSize,
                    width: pixelSize,
                    height: pixelSize
                )
                
                // Draw checkerboard pattern
                if (x + y) % 2 == 0 {
                    context.setFillColor(UIColor.systemGray5.cgColor)
                    context.fill(pixelRect)
                }
                
                // Draw base layer
                let baseColor = skin.getPixel(x: x, y: y, layer: .base)
                if baseColor != .clear {
                    context.setFillColor(UIColor(baseColor).cgColor)
                    context.fill(pixelRect)
                }
                
                // Draw overlay layer
                if skinManager.selectedLayer == .overlay {
                    let overlayColor = skin.getPixel(x: x, y: y, layer: .overlay)
                    if overlayColor != .clear {
                        context.setFillColor(UIColor(overlayColor).withAlphaComponent(0.7).cgColor)
                        context.fill(pixelRect)
                    }
                }
                
                // Draw grid lines
                context.setStrokeColor(UIColor.systemGray4.cgColor)
                context.setLineWidth(0.5)
                context.stroke(pixelRect)
            }
        }
        
        // Draw skin region guides
        drawSkinRegionGuides(context: context, centerX: centerX, centerY: centerY)
    }
    
    private func drawSkinRegionGuides(context: CGContext, centerX: CGFloat, centerY: CGFloat) {
        // Enhanced visual guides with clear labeling and better UX
        
        // Define colors for different body parts
        let headColor = UIColor.systemPurple
        let bodyColor = UIColor.systemGreen  
        let rightArmColor = UIColor.systemBlue
        let leftArmColor = UIColor.systemCyan
        let rightLegColor = UIColor.systemIndigo
        let leftLegColor = UIColor.systemPink
        
        // Font styles for labels
        let mainLabelFont = UIFont.systemFont(ofSize: 12, weight: .bold)
        let subLabelFont = UIFont.systemFont(ofSize: 10, weight: .medium)
        let tinyLabelFont = UIFont.systemFont(ofSize: 8)
        
        let mainAttributes: [NSAttributedString.Key: Any] = [
            .font: mainLabelFont,
            .foregroundColor: UIColor.label,
            .strokeColor: UIColor.systemBackground,
            .strokeWidth: -2.0
        ]
        
        let subAttributes: [NSAttributedString.Key: Any] = [
            .font: subLabelFont,
            .foregroundColor: UIColor.label
        ]
        
        let tinyAttributes: [NSAttributedString.Key: Any] = [
            .font: tinyLabelFont,
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        // Helper function to draw labeled region
        func drawLabeledRegion(rect: CGRect, color: UIColor, mainLabel: String, subLabel: String? = nil, position: String? = nil) {
            // Draw filled background with transparency
            context.setFillColor(color.withAlphaComponent(0.1).cgColor)
            context.fill(rect)
            
            // Draw border
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(2.0)
            context.stroke(rect)
            
            // Draw main label with background
            let labelSize = mainLabel.size(withAttributes: mainAttributes)
            let labelPoint = CGPoint(
                x: rect.midX - labelSize.width / 2,
                y: rect.minY - labelSize.height - 4
            )
            
            // Draw label background
            let labelBg = CGRect(
                x: labelPoint.x - 4,
                y: labelPoint.y - 2,
                width: labelSize.width + 8,
                height: labelSize.height + 4
            )
            context.setFillColor(UIColor.systemBackground.withAlphaComponent(0.8).cgColor)
            context.fill(labelBg)
            
            mainLabel.draw(at: labelPoint, withAttributes: mainAttributes)
            
            // Draw sub-label if provided
            if let subLabel = subLabel {
                let subPoint = CGPoint(
                    x: rect.midX - subLabel.size(withAttributes: subAttributes).width / 2,
                    y: rect.midY - 6
                )
                subLabel.draw(at: subPoint, withAttributes: subAttributes)
            }
            
            // Draw position label if provided
            if let position = position {
                let posPoint = CGPoint(
                    x: rect.midX - position.size(withAttributes: tinyAttributes).width / 2,
                    y: rect.maxY + 2
                )
                position.draw(at: posPoint, withAttributes: tinyAttributes)
            }
        }
        
        // ===== HEAD REGIONS (Purple theme) =====
        
        // Head Top (8,0 to 16,8)
        let headTopRect = CGRect(
            x: centerX + 8 * pixelSize, y: centerY + 0 * pixelSize,
            width: 8 * pixelSize, height: 8 * pixelSize
        )
        drawLabeledRegion(rect: headTopRect, color: headColor, mainLabel: "HEAD", subLabel: "TOP", position: "Hat/Hair")
        
        // Head Front (8,8 to 16,16) - Most prominent
        let headFrontRect = CGRect(
            x: centerX + 8 * pixelSize, y: centerY + 8 * pixelSize,
            width: 8 * pixelSize, height: 8 * pixelSize
        )
        drawLabeledRegion(rect: headFrontRect, color: headColor, mainLabel: "FACE", subLabel: "FRONT", position: "Eyes/Mouth")
        
        // Head sides
        let headRightRect = CGRect(
            x: centerX + 0 * pixelSize, y: centerY + 8 * pixelSize,
            width: 8 * pixelSize, height: 8 * pixelSize
        )
        drawLabeledRegion(rect: headRightRect, color: headColor.withAlphaComponent(0.7), mainLabel: "", subLabel: "RIGHT", position: "")
        
        let headLeftRect = CGRect(
            x: centerX + 16 * pixelSize, y: centerY + 8 * pixelSize,
            width: 8 * pixelSize, height: 8 * pixelSize
        )
        drawLabeledRegion(rect: headLeftRect, color: headColor.withAlphaComponent(0.7), mainLabel: "", subLabel: "LEFT", position: "")
        
        let headBackRect = CGRect(
            x: centerX + 24 * pixelSize, y: centerY + 8 * pixelSize,
            width: 8 * pixelSize, height: 8 * pixelSize
        )
        drawLabeledRegion(rect: headBackRect, color: headColor.withAlphaComponent(0.7), mainLabel: "", subLabel: "BACK", position: "")
        
        // Head Bottom (16,0 to 24,8)
        let headBottomRect = CGRect(
            x: centerX + 16 * pixelSize, y: centerY + 0 * pixelSize,
            width: 8 * pixelSize, height: 8 * pixelSize
        )
        drawLabeledRegion(rect: headBottomRect, color: headColor.withAlphaComponent(0.5), mainLabel: "", subLabel: "BOTTOM", position: "")
        
        // ===== BODY REGIONS (Green theme) =====
        
        // Body Front (20,20 to 28,32)
        let bodyFrontRect = CGRect(
            x: centerX + 20 * pixelSize, y: centerY + 20 * pixelSize,
            width: 8 * pixelSize, height: 12 * pixelSize
        )
        drawLabeledRegion(rect: bodyFrontRect, color: bodyColor, mainLabel: "BODY", subLabel: "CHEST", position: "Shirt/Logo")
        
        // ===== ARM REGIONS =====
        
        // Right Arm (44,20 to 48,32)
        let rightArmRect = CGRect(
            x: centerX + 44 * pixelSize, y: centerY + 20 * pixelSize,
            width: 4 * pixelSize, height: 12 * pixelSize
        )
        drawLabeledRegion(rect: rightArmRect, color: rightArmColor, mainLabel: "R.ARM", subLabel: "", position: "")
        
        // Left Arm (36,52 to 40,64)
        let leftArmRect = CGRect(
            x: centerX + 36 * pixelSize, y: centerY + 52 * pixelSize,
            width: 4 * pixelSize, height: 12 * pixelSize
        )
        drawLabeledRegion(rect: leftArmRect, color: leftArmColor, mainLabel: "L.ARM", subLabel: "", position: "")
        
        // ===== LEG REGIONS =====
        
        // Right Leg (4,20 to 8,32)
        let rightLegRect = CGRect(
            x: centerX + 4 * pixelSize, y: centerY + 20 * pixelSize,
            width: 4 * pixelSize, height: 12 * pixelSize
        )
        drawLabeledRegion(rect: rightLegRect, color: rightLegColor, mainLabel: "R.LEG", subLabel: "", position: "")
        
        // Left Leg (20,52 to 24,64)
        let leftLegRect = CGRect(
            x: centerX + 20 * pixelSize, y: centerY + 52 * pixelSize,
            width: 4 * pixelSize, height: 12 * pixelSize
        )
        drawLabeledRegion(rect: leftLegRect, color: leftLegColor, mainLabel: "L.LEG", subLabel: "", position: "")
        
        // ===== OVERLAY REGIONS (Dashed borders for jackets/accessories) =====
        
        // Head Overlay (40,8 to 48,16)
        let headOverlayRect = CGRect(
            x: centerX + 40 * pixelSize, y: centerY + 8 * pixelSize,
            width: 8 * pixelSize, height: 8 * pixelSize
        )
        context.setStrokeColor(headColor.withAlphaComponent(0.5).cgColor)
        context.setLineDash(phase: 0, lengths: [4, 2])
        context.setLineWidth(2.0)
        context.stroke(headOverlayRect)
        context.setLineDash(phase: 0, lengths: [])
        
        "HAT LAYER".draw(at: CGPoint(x: headOverlayRect.midX - 25, y: headOverlayRect.minY - 15), withAttributes: tinyAttributes)
        
        // Add helpful instructions
        let instructionText = "💡 Paint different parts to create your Minecraft skin"
        let instructionPoint = CGPoint(x: centerX, y: centerY + 68 * pixelSize)
        let instructionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        let instructionSize = instructionText.size(withAttributes: instructionAttributes)
        instructionText.draw(at: CGPoint(
            x: instructionPoint.x - instructionSize.width / 2,
            y: instructionPoint.y
        ), withAttributes: instructionAttributes)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let skinManager = skinManager else { return }
        
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            isDrawing = true
            // Save undo state at the beginning of a drawing gesture
            DispatchQueue.main.async {
                skinManager.saveUndoState()
            }
            drawAtPoint(location)
            lastDrawnPoint = location
            
        case .changed:
            if let lastPoint = lastDrawnPoint {
                drawLine(from: lastPoint, to: location)
            }
            lastDrawnPoint = location
            
        case .ended, .cancelled:
            isDrawing = false
            lastDrawnPoint = nil
            
        default:
            break
        }
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            pixelSize *= gesture.scale
            pixelSize = max(4, min(32, pixelSize))
            gesture.scale = 1.0
            setNeedsDisplay()
        }
    }
    
    private func drawAtPoint(_ point: CGPoint) {
        guard let skinManager = skinManager else { return }
        
        let totalWidth = CGFloat(CharacterSkin.width) * pixelSize
        let totalHeight = CGFloat(CharacterSkin.height) * pixelSize
        let centerX = (bounds.width - totalWidth) / 2 + gridOffset.x
        let centerY = (bounds.height - totalHeight) / 2 + gridOffset.y
        
        let x = Int((point.x - centerX) / pixelSize)
        let y = Int((point.y - centerY) / pixelSize)
        
        guard x >= 0, x < CharacterSkin.width, y >= 0, y < CharacterSkin.height else { return }
        
        switch skinManager.selectedTool {
        case .brush, .pencil:
            skinManager.currentSkin.setPixel(x: x, y: y, color: skinManager.selectedColor, layer: skinManager.selectedLayer)
            
        case .eraser:
            skinManager.currentSkin.setPixel(x: x, y: y, color: .clear, layer: skinManager.selectedLayer)
            
        case .bucket:
            skinManager.currentSkin.fill(x: x, y: y, color: skinManager.selectedColor, layer: skinManager.selectedLayer)
            
        case .eyedropper:
            let color = skinManager.currentSkin.getPixel(x: x, y: y, layer: skinManager.selectedLayer)
            if color != .clear {
                DispatchQueue.main.async {
                    skinManager.selectedColor = color
                }
            }
            
        case .line, .rectangle, .circle:
            // For now, these tools behave like pencil - can be enhanced later
            skinManager.currentSkin.setPixel(x: x, y: y, color: skinManager.selectedColor, layer: skinManager.selectedLayer)
            
        case .spray:
            // Spray tool adds multiple pixels in a small area
            for offsetX in -1...1 {
                for offsetY in -1...1 {
                    let sprayX = x + offsetX
                    let sprayY = y + offsetY
                    if sprayX >= 0, sprayX < CharacterSkin.width, sprayY >= 0, sprayY < CharacterSkin.height {
                        if Int.random(in: 0...2) == 0 { // Random spray pattern
                            skinManager.currentSkin.setPixel(x: sprayX, y: sprayY, color: skinManager.selectedColor, layer: skinManager.selectedLayer)
                        }
                    }
                }
            }
            
        case .mirror:
            skinManager.currentSkin.mirrorHorizontally(fromX: x, layer: skinManager.selectedLayer)
        }
        
        // Trigger UI updates on main thread
        DispatchQueue.main.async {
            skinManager.objectWillChange.send()
        }
        
        setNeedsDisplay()
    }
    
    private func drawLine(from startPoint: CGPoint, to endPoint: CGPoint) {
        let distance = hypot(endPoint.x - startPoint.x, endPoint.y - startPoint.y)
        let steps = Int(distance / 2) + 1
        
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let point = CGPoint(
                x: startPoint.x + (endPoint.x - startPoint.x) * t,
                y: startPoint.y + (endPoint.y - startPoint.y) * t
            )
            drawAtPoint(point)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let skinManager = skinManager else { return }
        
        let location = touch.location(in: self)
        
        // Save undo state for single touch actions
        DispatchQueue.main.async {
            skinManager.saveUndoState()
        }
        
        drawAtPoint(location)
    }
}