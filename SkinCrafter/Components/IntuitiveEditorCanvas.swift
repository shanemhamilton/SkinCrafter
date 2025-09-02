import SwiftUI
import UIKit

// Intuitive 2D editor that shows character layout like a paper doll
struct IntuitiveEditorCanvas: UIViewRepresentable {
    @EnvironmentObject var skinManager: SkinManager
    
    func makeUIView(context: Context) -> IntuitivePaintView {
        let view = IntuitivePaintView()
        view.skinManager = skinManager
        return view
    }
    
    func updateUIView(_ uiView: IntuitivePaintView, context: Context) {
        uiView.setNeedsDisplay()
    }
}

class IntuitivePaintView: UIView {
    var skinManager: SkinManager?
    private var currentTool: DrawingTool = .pencil
    private var currentColor: Color = .black
    
    // Layout constants for intuitive character view
    private let pixelSize: CGFloat = 6
    private var scale: CGFloat = 1.0
    
    // Body part positions in our intuitive layout
    private struct BodyPart {
        let name: String
        let rect: CGRect
        let minecraftMapping: (x: Int, y: Int, width: Int, height: Int)
        let color: UIColor
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
        
        // Add pinch gesture for zoom
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        addGestureRecognizer(pinchGesture)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Clear background
        context.setFillColor(UIColor.systemGray6.cgColor)
        context.fill(rect)
        
        // Calculate center position
        let centerX = bounds.width / 2
        let centerY = bounds.height / 2
        
        // Define body parts in intuitive layout (like looking at a person)
        let bodyParts = getBodyParts(centerX: centerX, centerY: centerY)
        
        // Draw each body part
        for part in bodyParts {
            drawBodyPart(context: context, part: part)
        }
        
        // Draw helpful grid lines
        drawGridOverlay(context: context, bodyParts: bodyParts)
    }
    
    private func getBodyParts(centerX: CGFloat, centerY: CGFloat) -> [BodyPart] {
        let p = pixelSize * scale
        
        // Create a more intuitive T-pose layout
        return [
            // HEAD - centered at top, larger for detail work
            BodyPart(
                name: "HEAD",
                rect: CGRect(x: centerX - 6*p, y: centerY - 22*p, width: 12*p, height: 12*p),
                minecraftMapping: (8, 8, 8, 8), // Front face in Minecraft UV
                color: .systemPurple
            ),
            
            // BODY/CHEST - below head, wider for visibility
            BodyPart(
                name: "CHEST", 
                rect: CGRect(x: centerX - 6*p, y: centerY - 8*p, width: 12*p, height: 14*p),
                minecraftMapping: (20, 20, 8, 12), // Body front
                color: .systemTeal
            ),
            
            // LEFT ARM - extended to the left (T-pose)
            BodyPart(
                name: "LEFT ARM",
                rect: CGRect(x: centerX - 18*p, y: centerY - 8*p, width: 10*p, height: 14*p),
                minecraftMapping: (36, 52, 4, 12), // Left arm in 64x64 format
                color: .systemBlue
            ),
            
            // RIGHT ARM - extended to the right (T-pose)
            BodyPart(
                name: "RIGHT ARM",
                rect: CGRect(x: centerX + 8*p, y: centerY - 8*p, width: 10*p, height: 14*p),
                minecraftMapping: (44, 20, 4, 12), // Right arm
                color: .systemBlue
            ),
            
            // LEFT LEG - slightly separated
            BodyPart(
                name: "LEFT LEG",
                rect: CGRect(x: centerX - 7*p, y: centerY + 7*p, width: 6*p, height: 14*p),
                minecraftMapping: (20, 52, 4, 12), // Left leg in 64x64 format
                color: .systemIndigo
            ),
            
            // RIGHT LEG - slightly separated
            BodyPart(
                name: "RIGHT LEG",
                rect: CGRect(x: centerX + 1*p, y: centerY + 7*p, width: 6*p, height: 14*p),
                minecraftMapping: (4, 20, 4, 12), // Right leg
                color: .systemIndigo
            ),
            
            // Additional detail areas for face/hair
            BodyPart(
                name: "FACE",
                rect: CGRect(x: centerX - 4*p, y: centerY - 19*p, width: 8*p, height: 6*p),
                minecraftMapping: (8, 11, 8, 5), // Face area
                color: .systemPink.withAlphaComponent(0.5)
            ),
            
            // Hair/Hat area
            BodyPart(
                name: "HAIR",
                rect: CGRect(x: centerX - 6*p, y: centerY - 22*p, width: 12*p, height: 3*p),
                minecraftMapping: (8, 0, 8, 3), // Top of head
                color: .systemBrown.withAlphaComponent(0.5)
            )
        ]
    }
    
    private func drawBodyPart(context: CGContext, part: BodyPart) {
        // Draw shadow for depth
        context.setShadow(offset: CGSize(width: 0, height: 2), blur: 4, color: UIColor.black.withAlphaComponent(0.1).cgColor)
        
        // Draw filled background with gradient
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                part.color.withAlphaComponent(0.05).cgColor,
                part.color.withAlphaComponent(0.1).cgColor
            ] as CFArray,
            locations: [0.0, 1.0]
        )!
        
        context.saveGState()
        context.addRect(part.rect)
        context.clip()
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: part.rect.minX, y: part.rect.minY),
            end: CGPoint(x: part.rect.maxX, y: part.rect.maxY),
            options: []
        )
        context.restoreGState()
        
        // Clear shadow for other drawings
        context.setShadow(offset: .zero, blur: 0)
        
        // Draw border with rounded corners
        let path = UIBezierPath(roundedRect: part.rect, cornerRadius: 4)
        context.setStrokeColor(part.color.cgColor)
        context.setLineWidth(2.0)
        context.addPath(path.cgPath)
        context.strokePath()
        
        // Draw the actual skin pixels from the skin manager
        if let skinManager = skinManager {
            drawSkinPixels(context: context, part: part, skin: skinManager.currentSkin)
        }
        
        // Draw label with background bubble
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
            .foregroundColor: UIColor.white
        ]
        
        let labelSize = part.name.size(withAttributes: attributes)
        let labelRect = CGRect(
            x: part.rect.midX - labelSize.width / 2 - 6,
            y: part.rect.minY - labelSize.height - 8,
            width: labelSize.width + 12,
            height: labelSize.height + 4
        )
        
        // Draw label background
        let labelPath = UIBezierPath(roundedRect: labelRect, cornerRadius: 8)
        context.setFillColor(part.color.cgColor)
        context.addPath(labelPath.cgPath)
        context.fillPath()
        
        // Draw label text
        let labelPoint = CGPoint(
            x: labelRect.midX - labelSize.width / 2,
            y: labelRect.minY + 2
        )
        part.name.draw(at: labelPoint, withAttributes: attributes)
        
        // Add interactive hint for empty parts
        if let skinManager = skinManager {
            if !hasPixelsInPart(part: part, skin: skinManager.currentSkin) {
                let hintText = "Tap to paint"
                let hintAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 9),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                let hintSize = hintText.size(withAttributes: hintAttributes)
                let hintPoint = CGPoint(
                    x: part.rect.midX - hintSize.width / 2,
                    y: part.rect.midY - hintSize.height / 2
                )
                hintText.draw(at: hintPoint, withAttributes: hintAttributes)
            }
        }
    }
    
    private func hasPixelsInPart(part: BodyPart, skin: CharacterSkin) -> Bool {
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
    
    private func drawSkinPixels(context: CGContext, part: BodyPart, skin: CharacterSkin) {
        let p = pixelSize * scale
        
        // Map from intuitive position to Minecraft UV coordinates
        let (startX, startY, width, height) = part.minecraftMapping
        
        // Draw pixels from the skin
        for y in 0..<height {
            for x in 0..<width {
                let pixelColor = skin.getPixel(x: startX + x, y: startY + y, layer: .base)
                if pixelColor != .clear {
                    context.setFillColor(UIColor(pixelColor).cgColor)
                    
                    let pixelRect = CGRect(
                        x: part.rect.minX + CGFloat(x) * p / CGFloat(width) * part.rect.width / p,
                        y: part.rect.minY + CGFloat(y) * p / CGFloat(height) * part.rect.height / p,
                        width: part.rect.width / CGFloat(width),
                        height: part.rect.height / CGFloat(height)
                    )
                    context.fill(pixelRect)
                }
            }
        }
    }
    
    private func drawGridOverlay(context: CGContext, bodyParts: [BodyPart]) {
        context.setStrokeColor(UIColor.systemGray4.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(0.5)
        
        // Draw grid for each body part
        for part in bodyParts {
            let (_, _, width, height) = part.minecraftMapping
            
            // Vertical lines
            for i in 0...width {
                let x = part.rect.minX + (part.rect.width * CGFloat(i) / CGFloat(width))
                context.move(to: CGPoint(x: x, y: part.rect.minY))
                context.addLine(to: CGPoint(x: x, y: part.rect.maxY))
            }
            
            // Horizontal lines
            for i in 0...height {
                let y = part.rect.minY + (part.rect.height * CGFloat(i) / CGFloat(height))
                context.move(to: CGPoint(x: part.rect.minX, y: y))
                context.addLine(to: CGPoint(x: part.rect.maxX, y: y))
            }
        }
        
        context.strokePath()
        
        // Add helpful annotations
        drawAnnotations(context: context, centerX: bounds.width / 2, centerY: bounds.height / 2)
    }
    
    private func drawAnnotations(context: CGContext, centerX: CGFloat, centerY: CGFloat) {
        let helpText = "👤 Character View - Paint each body part"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        let textSize = helpText.size(withAttributes: attributes)
        let textPoint = CGPoint(
            x: centerX - textSize.width / 2,
            y: centerY + 18 * pixelSize * scale
        )
        
        helpText.draw(at: textPoint, withAttributes: attributes)
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            scale *= gesture.scale
            scale = max(0.5, min(3.0, scale))
            gesture.scale = 1.0
            setNeedsDisplay()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let skinManager = skinManager else { return }
        
        handleTouch(at: touch.location(in: self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouch(at: touch.location(in: self))
    }
    
    private func handleTouch(at point: CGPoint) {
        guard let skinManager = skinManager else { return }
        
        let centerX = bounds.width / 2
        let centerY = bounds.height / 2
        let bodyParts = getBodyParts(centerX: centerX, centerY: centerY)
        
        // Find which body part was touched
        for part in bodyParts {
            if part.rect.contains(point) {
                // Calculate pixel position within the body part
                let relativeX = (point.x - part.rect.minX) / part.rect.width
                let relativeY = (point.y - part.rect.minY) / part.rect.height
                
                let (startX, startY, width, height) = part.minecraftMapping
                let pixelX = startX + Int(relativeX * CGFloat(width))
                let pixelY = startY + Int(relativeY * CGFloat(height))
                
                // Apply the current tool
                applyTool(at: pixelX, y: pixelY, skinManager: skinManager)
                
                // Trigger update
                DispatchQueue.main.async {
                    skinManager.objectWillChange.send()
                }
                setNeedsDisplay()
                break
            }
        }
    }
    
    private func applyTool(at x: Int, y: Int, skinManager: SkinManager) {
        guard x >= 0, x < CharacterSkin.width,
              y >= 0, y < CharacterSkin.height else { return }
        
        switch skinManager.selectedTool {
        case .pencil, .brush:
            skinManager.currentSkin.setPixel(
                x: x, y: y,
                color: skinManager.selectedColor,
                layer: skinManager.selectedLayer
            )
        case .eraser:
            skinManager.currentSkin.setPixel(
                x: x, y: y,
                color: .clear,
                layer: skinManager.selectedLayer
            )
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
        default:
            break
        }
    }
}