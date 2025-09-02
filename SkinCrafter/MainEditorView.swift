import SwiftUI
import SceneKit

struct MainEditorView: View {
    @EnvironmentObject var skinManager: SkinManager
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    
    var body: some View {
        ZStack {
            // Main editor takes full screen
            VStack(spacing: 0) {
                // Simplified top bar
                simplifiedTopBar
                
                // Main 2D editor - takes most of the space
                mainEditorArea
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                
                // Tool panel at bottom
                compactToolPanel
            }
            .background(Color(.systemBackground))
            
            // 3D preview overlay in corner
            VStack {
                HStack {
                    Spacer()
                    threeDPreviewOverlay
                        .padding(.trailing, 16)
                        .padding(.top, 60) // Below top bar
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            SimpleExportView()
                .environmentObject(skinManager)
        }
        .sheet(isPresented: $showingImportSheet) {
            SimpleImportView()
                .environmentObject(skinManager)
        }
    }
    
    // MARK: - Simplified Layout Components
    
    private var simplifiedTopBar: some View {
        HStack {
            Button(action: { showingImportSheet = true }) {
                Label("Import", systemImage: "square.and.arrow.down")
                    .font(.system(size: 14, weight: .medium))
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
            
            Text("SkinCrafter")
                .font(.headline)
            
            Spacer()
            
            Button(action: { showingExportSheet = true }) {
                Label("Export", systemImage: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .medium))
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private var mainEditorArea: some View {
        VStack(spacing: 4) {
            // Title
            Text("Paint Your Character")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.top, 4)
            
            // Use intuitive canvas that fills available space
            IntuitiveCanvasWrapper()
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
        }
    }
    
    private var threeDPreviewOverlay: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("3D Preview")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Skin3DPreview()
                .frame(width: 140, height: 140)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
        }
    }
    
    private var compactToolPanel: some View {
        VStack(spacing: 12) {
            // Tool selection row
            HStack(spacing: 16) {
                ForEach([DrawingTool.pencil, .brush, .eraser, .bucket, .eyedropper], id: \.self) { tool in
                    Button(action: { skinManager.selectedTool = tool }) {
                        VStack(spacing: 4) {
                            Image(systemName: tool.iconName)
                                .font(.system(size: 20))
                            Text(tool.displayName)
                                .font(.caption2)
                        }
                        .frame(width: 50, height: 50)
                        .foregroundColor(skinManager.selectedTool == tool ? .white : .primary)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(skinManager.selectedTool == tool ? 
                                      toolColor(for: tool) : Color(.systemGray5))
                        )
                    }
                }
                
                Spacer()
                
                // Color picker
                ColorPicker("", selection: $skinManager.selectedColor)
                    .labelsHidden()
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            
            // Action buttons row
            HStack(spacing: 12) {
                Button("Reset") {
                    skinManager.saveUndoState()
                    skinManager.resetSkin()
                }
                .buttonStyle(.bordered)
                .tint(.red)
                
                Button("Undo") {
                    skinManager.undo()
                }
                .buttonStyle(.bordered)
                .disabled(!skinManager.canUndo)
                
                Button("Redo") {
                    skinManager.redo()
                }
                .buttonStyle(.bordered)
                .disabled(!skinManager.canRedo)
                
                Spacer()
                
                Button(action: { showingExportSheet = true }) {
                    Label("Save Skin", systemImage: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .controlSize(.large)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private func toolColor(for tool: DrawingTool) -> Color {
        switch tool {
        case .brush, .pencil: return .blue
        case .eraser: return .red
        case .bucket: return .green
        case .eyedropper: return .purple
        default: return .primary
        }
    }
}

// Tool Selection Panel - Removed as we have inline tool selection now

// Simple Import View
struct SimpleImportView: View {
    @EnvironmentObject var skinManager: SkinManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Import a Skin")
                    .font(.largeTitle)
                    .padding()
                
                Text("Choose a template to start with:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(DefaultSkinTemplates.availableTemplates) { template in
                        Button(action: {
                            if let skinData = template.generator().pngData() {
                                skinManager.importSkin(from: skinData)
                            }
                            dismiss()
                        }) {
                            VStack {
                                Image(systemName: template.icon)
                                    .font(.system(size: 30))
                                    .foregroundColor(.primary)
                                
                                Text(template.name)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                            .frame(width: 80, height: 80)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
        }
    }
}

// Wrapper for the intuitive canvas that includes the code inline
struct IntuitiveCanvasWrapper: UIViewRepresentable {
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

// Intuitive 2D paint view that shows character in T-pose
class IntuitivePaintView: UIView {
    var skinManager: SkinManager?
    private var scale: CGFloat = 1.0
    
    // Body part structure for intuitive layout with multiple views
    private struct BodyPart {
        let name: String
        let rect: CGRect
        let minecraftMapping: (x: Int, y: Int, width: Int, height: Int)
        let color: UIColor
        let viewType: ViewType
    }
    
    private enum ViewType {
        case front, back, left, right, top, bottom
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
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        addGestureRecognizer(pinchGesture)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Light background
        context.setFillColor(UIColor.systemBackground.cgColor)
        context.fill(rect)
        
        let centerX = bounds.width / 2
        let centerY = bounds.height / 2
        let bodyParts = getBodyParts(centerX: centerX, centerY: centerY)
        
        // Draw view labels
        drawViewLabels(context: context, centerX: centerX, centerY: centerY)
        
        // Draw all body parts
        for part in bodyParts {
            drawBodyPart(context: context, part: part)
        }
        
        // Draw connection lines between views
        drawConnectionLines(context: context, bodyParts: bodyParts)
    }
    
    private func drawViewLabels(context: CGContext, centerX: CGFloat, centerY: CGFloat) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        // Label the different view sections
        let topY = centerY - bounds.height * 0.4
        "FRONT VIEW".draw(at: CGPoint(x: centerX - 30, y: topY), withAttributes: attributes)
        "BACK VIEW".draw(at: CGPoint(x: centerX - 120, y: topY), withAttributes: attributes)
        "SIDE VIEWS".draw(at: CGPoint(x: centerX + 80, y: topY), withAttributes: attributes)
    }
    
    private func drawConnectionLines(context: CGContext, bodyParts: [BodyPart]) {
        context.setStrokeColor(UIColor.systemGray5.cgColor)
        context.setLineWidth(0.5)
        context.setLineDash(phase: 0, lengths: [2, 2])
        
        // Draw subtle connection lines between related parts
        for part in bodyParts where part.viewType == .front {
            if let backPart = bodyParts.first(where: { $0.name == part.name && $0.viewType == .back }) {
                context.move(to: CGPoint(x: part.rect.minX, y: part.rect.midY))
                context.addLine(to: CGPoint(x: backPart.rect.maxX, y: backPart.rect.midY))
            }
        }
        
        context.strokePath()
        context.setLineDash(phase: 0, lengths: [])
    }
    
    private func getBodyParts(centerX: CGFloat, centerY: CGFloat) -> [BodyPart] {
        // Scale based on available space
        let availableWidth = bounds.width * 0.9
        let availableHeight = bounds.height * 0.85
        
        // Calculate optimal scale to fill space
        let baseWidth: CGFloat = 52  // Total width in base units
        let baseHeight: CGFloat = 36  // Total height in base units
        let widthScale = availableWidth / baseWidth
        let heightScale = availableHeight / baseHeight
        let p = min(widthScale, heightScale) * scale
        
        var parts: [BodyPart] = []
        
        // HEAD - Front, Back, Sides
        parts.append(BodyPart(name: "HEAD", rect: CGRect(x: centerX - 4*p, y: centerY - 18*p, width: 8*p, height: 8*p),
                    minecraftMapping: (8, 8, 8, 8), color: .systemPurple, viewType: .front))
        parts.append(BodyPart(name: "HEAD", rect: CGRect(x: centerX - 14*p, y: centerY - 18*p, width: 8*p, height: 8*p),
                    minecraftMapping: (24, 8, 8, 8), color: .systemPurple.withAlphaComponent(0.8), viewType: .back))
        parts.append(BodyPart(name: "HEAD", rect: CGRect(x: centerX + 6*p, y: centerY - 18*p, width: 8*p, height: 8*p),
                    minecraftMapping: (0, 8, 8, 8), color: .systemPurple.withAlphaComponent(0.7), viewType: .left))
        parts.append(BodyPart(name: "HEAD", rect: CGRect(x: centerX + 16*p, y: centerY - 18*p, width: 8*p, height: 8*p),
                    minecraftMapping: (16, 8, 8, 8), color: .systemPurple.withAlphaComponent(0.7), viewType: .right))
        
        // BODY - Front, Back and Sides
        parts.append(BodyPart(name: "BODY", rect: CGRect(x: centerX - 4*p, y: centerY - 8*p, width: 8*p, height: 12*p),
                    minecraftMapping: (20, 20, 8, 12), color: .systemTeal, viewType: .front))
        parts.append(BodyPart(name: "BODY", rect: CGRect(x: centerX - 14*p, y: centerY - 8*p, width: 8*p, height: 12*p),
                    minecraftMapping: (32, 20, 8, 12), color: .systemTeal.withAlphaComponent(0.8), viewType: .back))
        parts.append(BodyPart(name: "BODY", rect: CGRect(x: centerX + 6*p, y: centerY - 8*p, width: 4*p, height: 12*p),
                    minecraftMapping: (16, 20, 4, 12), color: .systemTeal.withAlphaComponent(0.7), viewType: .left))
        parts.append(BodyPart(name: "BODY", rect: CGRect(x: centerX + 12*p, y: centerY - 8*p, width: 4*p, height: 12*p),
                    minecraftMapping: (28, 20, 4, 12), color: .systemTeal.withAlphaComponent(0.7), viewType: .right))
        
        // ARMS - Front, Back and Side views
        // Left Arm
        parts.append(BodyPart(name: "L ARM", rect: CGRect(x: centerX - 20*p, y: centerY - 8*p, width: 4*p, height: 12*p),
                    minecraftMapping: (36, 52, 4, 12), color: .systemBlue, viewType: .front))
        parts.append(BodyPart(name: "L ARM", rect: CGRect(x: centerX - 26*p, y: centerY - 8*p, width: 4*p, height: 12*p),
                    minecraftMapping: (44, 52, 4, 12), color: .systemBlue.withAlphaComponent(0.8), viewType: .back))
        parts.append(BodyPart(name: "L ARM", rect: CGRect(x: centerX + 22*p, y: centerY - 8*p, width: 4*p, height: 12*p),
                    minecraftMapping: (32, 52, 4, 12), color: .systemBlue.withAlphaComponent(0.7), viewType: .left))
        parts.append(BodyPart(name: "L ARM", rect: CGRect(x: centerX + 28*p, y: centerY - 8*p, width: 4*p, height: 12*p),
                    minecraftMapping: (40, 52, 4, 12), color: .systemBlue.withAlphaComponent(0.7), viewType: .right))
        
        // Right Arm
        parts.append(BodyPart(name: "R ARM", rect: CGRect(x: centerX + 16*p, y: centerY - 8*p, width: 4*p, height: 12*p),
                    minecraftMapping: (44, 20, 4, 12), color: .systemBlue, viewType: .front))
        parts.append(BodyPart(name: "R ARM", rect: CGRect(x: centerX + 10*p, y: centerY - 8*p, width: 4*p, height: 12*p),
                    minecraftMapping: (52, 20, 4, 12), color: .systemBlue.withAlphaComponent(0.8), viewType: .back))
        parts.append(BodyPart(name: "R ARM", rect: CGRect(x: centerX + 34*p, y: centerY - 8*p, width: 4*p, height: 12*p),
                    minecraftMapping: (40, 20, 4, 12), color: .systemBlue.withAlphaComponent(0.7), viewType: .left))
        parts.append(BodyPart(name: "R ARM", rect: CGRect(x: centerX + 40*p, y: centerY - 8*p, width: 4*p, height: 12*p),
                    minecraftMapping: (48, 20, 4, 12), color: .systemBlue.withAlphaComponent(0.7), viewType: .right))
        
        // LEGS - Front, Back and Side views
        // Left Leg
        parts.append(BodyPart(name: "L LEG", rect: CGRect(x: centerX - 6*p, y: centerY + 5*p, width: 4*p, height: 12*p),
                    minecraftMapping: (20, 52, 4, 12), color: .systemIndigo, viewType: .front))
        parts.append(BodyPart(name: "L LEG", rect: CGRect(x: centerX - 14*p, y: centerY + 5*p, width: 4*p, height: 12*p),
                    minecraftMapping: (28, 52, 4, 12), color: .systemIndigo.withAlphaComponent(0.8), viewType: .back))
        parts.append(BodyPart(name: "L LEG", rect: CGRect(x: centerX + 22*p, y: centerY + 5*p, width: 4*p, height: 12*p),
                    minecraftMapping: (24, 52, 4, 12), color: .systemIndigo.withAlphaComponent(0.7), viewType: .left))
        parts.append(BodyPart(name: "L LEG", rect: CGRect(x: centerX + 28*p, y: centerY + 5*p, width: 4*p, height: 12*p),
                    minecraftMapping: (16, 52, 4, 12), color: .systemIndigo.withAlphaComponent(0.7), viewType: .right))
        
        // Right Leg
        parts.append(BodyPart(name: "R LEG", rect: CGRect(x: centerX + 2*p, y: centerY + 5*p, width: 4*p, height: 12*p),
                    minecraftMapping: (4, 20, 4, 12), color: .systemIndigo, viewType: .front))
        parts.append(BodyPart(name: "R LEG", rect: CGRect(x: centerX - 20*p, y: centerY + 5*p, width: 4*p, height: 12*p),
                    minecraftMapping: (12, 20, 4, 12), color: .systemIndigo.withAlphaComponent(0.8), viewType: .back))
        parts.append(BodyPart(name: "R LEG", rect: CGRect(x: centerX + 10*p, y: centerY + 5*p, width: 4*p, height: 12*p),
                    minecraftMapping: (0, 20, 4, 12), color: .systemIndigo.withAlphaComponent(0.7), viewType: .left))
        parts.append(BodyPart(name: "R LEG", rect: CGRect(x: centerX + 16*p, y: centerY + 5*p, width: 4*p, height: 12*p),
                    minecraftMapping: (8, 20, 4, 12), color: .systemIndigo.withAlphaComponent(0.7), viewType: .right))
        
        return parts
    }
    
    private func drawBodyPart(context: CGContext, part: BodyPart) {
        // Draw background with rounded corners
        let path = UIBezierPath(roundedRect: part.rect, cornerRadius: 2)
        context.setFillColor(part.color.withAlphaComponent(0.1).cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
        
        // Draw border
        context.setStrokeColor(part.color.cgColor)
        context.setLineWidth(1.5)
        context.addPath(path.cgPath)
        context.strokePath()
        
        // Draw label with view type
        let viewLabel: String
        switch part.viewType {
            case .front: viewLabel = "Front"
            case .back: viewLabel = "Back"
            case .left: viewLabel = "Left"
            case .right: viewLabel = "Right"
            case .top: viewLabel = "Top"
            case .bottom: viewLabel = "Bottom"
        }
        
        let fontSize: CGFloat = min(10, part.rect.height / 4)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .medium),
            .foregroundColor: part.color
        ]
        
        let fullLabel = "\(part.name)\n\(viewLabel)"
        let labelSize = fullLabel.size(withAttributes: attributes)
        let labelPoint = CGPoint(
            x: part.rect.midX - labelSize.width / 2,
            y: part.rect.minY - labelSize.height - 2
        )
        fullLabel.draw(at: labelPoint, withAttributes: attributes)
        
        // Draw skin pixels if available
        if let skinManager = skinManager {
            drawSkinPixels(context: context, part: part, skin: skinManager.currentSkin)
        }
    }
    
    private func drawSkinPixels(context: CGContext, part: BodyPart, skin: CharacterSkin) {
        let (startX, startY, width, height) = part.minecraftMapping
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelColor = skin.getPixel(x: startX + x, y: startY + y, layer: .base)
                if pixelColor != .clear {
                    context.setFillColor(UIColor(pixelColor).cgColor)
                    
                    let pixelRect = CGRect(
                        x: part.rect.minX + CGFloat(x) * part.rect.width / CGFloat(width),
                        y: part.rect.minY + CGFloat(y) * part.rect.height / CGFloat(height),
                        width: part.rect.width / CGFloat(width),
                        height: part.rect.height / CGFloat(height)
                    )
                    context.fill(pixelRect)
                }
            }
        }
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
              skinManager != nil else { return }
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
        
        for part in bodyParts {
            if part.rect.contains(point) {
                let relativeX = (point.x - part.rect.minX) / part.rect.width
                let relativeY = (point.y - part.rect.minY) / part.rect.height
                
                let (startX, startY, width, height) = part.minecraftMapping
                let pixelX = startX + Int(relativeX * CGFloat(width))
                let pixelY = startY + Int(relativeY * CGFloat(height))
                
                applyTool(at: pixelX, y: pixelY, skinManager: skinManager)
                
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

struct MainEditorView_Previews: PreviewProvider {
    static var previews: some View {
        MainEditorView()
            .environmentObject(SkinManager())
    }
}