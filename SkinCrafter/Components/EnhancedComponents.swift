import SwiftUI
import SceneKit

// MARK: - Supporting Types
extension UndoRedoManager {
    // This will be implemented in EditingSystem.swift
}

// MARK: - Enhanced Skin Canvas
struct EnhancedSkinCanvas: View {
    @EnvironmentObject var skinManager: SkinManager
    @ObservedObject var undoManager: UndoRedoManager
    @ObservedObject var gridSystem: GridSystem
    let selectedTool: AdvancedTool
    let brushSettings: BrushSettings
    @Binding var currentZoom: CGFloat
    @Binding var canvasOffset: CGSize
    @Binding var fitTrigger: Int
    @State private var didAutoFit: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.gray.opacity(0.1)
                
                // Canvas with zoom and pan
                ScrollView([.horizontal, .vertical], showsIndicators: true) {
                    ZStack {
                        // Grid overlay
                        if gridSystem.showGrid {
                            GridOverlay(gridSize: gridSystem.gridSize)
                                .scaleEffect(currentZoom)
                        }
                        
                        // Main canvas
                        Canvas { context, size in
                            drawSkin(context: context, size: size)
                            
                            if gridSystem.showBodyPartOutlines {
                                drawBodyPartOutlines(context: context, size: size)
                            }
                            
                            if gridSystem.showGuides {
                                drawGuides(context: context, size: size)
                            }
                        }
                        .frame(
                            width: CGFloat(CharacterSkin.width) * 10 * currentZoom,
                            height: CGFloat(CharacterSkin.height) * 10 * currentZoom
                        )
                        .background(Color.white)
                        // Double-tap clears isolation
                        .onTapGesture(count: 2) {
                            gridSystem.isolatedParts.removeAll()
                        }
                        // Single-tap paints
                        .onTapGesture { location in
                            handleTap(at: location)
                        }
                        // Clickable hotspots for quick isolation + focus
                        .overlay(hotspotOverlay(containerSize: geometry.size))

                        // Top Part Tabs (quick isolate + focus)
                        partTabs(containerSize: geometry.size)
                            .padding(.top, 8)
                            .frame(maxWidth: .infinity, alignment: .top)
                            .allowsHitTesting(true)

                        // Mini map overlay (bottom-right)
                        miniMap(containerSize: geometry.size)
                            .padding(8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        // Clickable labels near regions
                        labelOverlay(containerSize: geometry.size)
                            .padding(.top, 30)
                            .frame(maxWidth: .infinity, alignment: .top)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    handleDrag(value: value)
                                }
                                .onEnded { _ in
                                    undoManager.recordState(skinManager.currentSkin)
                                }
                        )
                        .simultaneousGesture(
                            MagnificationGesture()
                                .onChanged { scale in
                                    // Smooth zoom around center
                                    let newZoom = max(0.5, min(8.0, scale))
                                    currentZoom = newZoom
                                }
                        )
                    }
                    .offset(canvasOffset)
                }
                .onAppear {
                    if !didAutoFit {
                        fitToAllParts(containerSize: geometry.size)
                        didAutoFit = true
                    }
                }
                .onChange(of: fitTrigger) { _ in
                    fitToAllParts(containerSize: geometry.size)
                }
                
                // Zoom controls overlay
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            Button(action: { currentZoom = min(4.0, currentZoom + 0.5) }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.purple)
                            }
                            
                            Button(action: { currentZoom = 1.0 }) {
                                Text("\(Int(currentZoom * 100))%")
                                    .font(.caption)
                                    .padding(8)
                                    .background(Color.purple.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            Button(action: { currentZoom = max(0.5, currentZoom - 0.5) }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.purple)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    private func drawSkin(context: GraphicsContext, size: CGSize) {
        let pixelSize = 10 * currentZoom
        
        for y in 0..<CharacterSkin.height {
            for x in 0..<CharacterSkin.width {
                let rect = CGRect(
                    x: CGFloat(x) * pixelSize,
                    y: CGFloat(y) * pixelSize,
                    width: pixelSize,
                    height: pixelSize
                )
                
                // Draw base layer
                if gridSystem.showBase {
                    let baseColor = skinManager.currentSkin.getPixel(x: x, y: y, layer: .base)
                    if baseColor != .clear {
                        context.fill(Path(rect), with: .color(baseColor))
                    }
                }
                
                // Draw overlay layer
                if gridSystem.showOverlay {
                    // Determine overlay category visibility by coordinates
                    let shouldShow: Bool = {
                        // Hat overlay: (32..64, 0..16)
                        if (32..<64).contains(x) && (0..<16).contains(y) { return gridSystem.showHatOverlay }
                        // Jacket overlay: (16..40, 32..48)
                        if (16..<40).contains(x) && (32..<48).contains(y) { return gridSystem.showJacketOverlay }
                        // Right arm sleeve overlay: (40..56, 32..48)
                        if (40..<56).contains(x) && (32..<48).contains(y) { return gridSystem.showSleevesOverlay }
                        // Left arm sleeve overlay: (48..64, 48..64)
                        if (48..<64).contains(x) && (48..<64).contains(y) { return gridSystem.showSleevesOverlay }
                        // Right leg pants overlay: (0..16, 32..48)
                        if (0..<16).contains(x) && (32..<48).contains(y) { return gridSystem.showPantsOverlay }
                        // Left leg pants overlay: (0..16, 48..64)
                        if (0..<16).contains(x) && (48..<64).contains(y) { return gridSystem.showPantsOverlay }
                        return true
                    }()
                    if shouldShow {
                        let overlayColor = skinManager.currentSkin.getPixel(x: x, y: y, layer: .overlay)
                        if overlayColor != .clear {
                            let alpha: Double = gridSystem.showBase ? 0.8 : 1.0
                            context.fill(Path(rect), with: .color(overlayColor.opacity(alpha)))
                        }
                    }
                }
                
                // Highlight isolated parts
                if !gridSystem.isolatedParts.isEmpty && !gridSystem.isPixelInIsolatedPart(x: x, y: y) {
                    context.fill(Path(rect), with: .color(.black.opacity(0.05)))
                }
            }
        }
    }
    
    private func drawBodyPartOutlines(context: GraphicsContext, size: CGSize) {
        let pixelSize = 10 * currentZoom
        
        for part in BodyPart.allCases {
            let region = part.getRegion()
            let rect = CGRect(
                x: CGFloat(region.x.lowerBound) * pixelSize,
                y: CGFloat(region.y.lowerBound) * pixelSize,
                width: CGFloat(region.x.count) * pixelSize,
                height: CGFloat(region.y.count) * pixelSize
            )
            
            context.stroke(Path(rect), with: .color(part.color), lineWidth: 2)
            
            // Draw label
            let text = Text(part.rawValue)
                .font(.caption)
                .foregroundColor(part.color)
            context.draw(text, at: CGPoint(x: rect.midX, y: rect.minY - 10))
        }
    }
    
    private func drawGuides(context: GraphicsContext, size: CGSize) {
        let pixelSize = 10 * currentZoom
        
        // Center lines
        let centerX = CGFloat(CharacterSkin.width / 2) * pixelSize
        let centerY = CGFloat(CharacterSkin.height / 2) * pixelSize
        
        context.stroke(
            Path { path in
                path.move(to: CGPoint(x: centerX, y: 0))
                path.addLine(to: CGPoint(x: centerX, y: size.height))
            },
            with: .color(.blue.opacity(0.3)),
            lineWidth: 1
        )
        
        context.stroke(
            Path { path in
                path.move(to: CGPoint(x: 0, y: centerY))
                path.addLine(to: CGPoint(x: size.width, y: centerY))
            },
            with: .color(.blue.opacity(0.3)),
            lineWidth: 1
        )
    }
    
    private func handleTap(at location: CGPoint) {
        let pixelSize = 10 * currentZoom
        let x = Int(location.x / pixelSize)
        let y = Int(location.y / pixelSize)
        
        applyTool(at: x, y: y)
    }
    
    private func handleDrag(value: DragGesture.Value) {
        let pixelSize = 10 * currentZoom
        let x = Int(value.location.x / pixelSize)
        let y = Int(value.location.y / pixelSize)
        
        applyTool(at: x, y: y)
    }
    
    private func applyTool(at x: Int, y: Int) {
        guard x >= 0, x < CharacterSkin.width, y >= 0, y < CharacterSkin.height else { return }
        guard gridSystem.isPixelInIsolatedPart(x: x, y: y) else { return }
        
        // Determine part under cursor for region-safe actions
        func partAt(_ x: Int, _ y: Int) -> BodyPart? {
            for p in BodyPart.allCases {
                let r = p.getRegion()
                if r.x.contains(x) && r.y.contains(y) { return p }
            }
            return nil
        }

        let primaryPart = partAt(x, y)
        
        // Compute mirrored coordinate in mirror part region if autoSymmetry
        func mirrorCoordinate(of x: Int, _ y: Int, from part: BodyPart, to mirror: BodyPart) -> (Int, Int) {
            let a = part.getRegion()
            let b = mirror.getRegion()
            let dx = b.x.lowerBound - a.x.lowerBound
            let dy = b.y.lowerBound - a.y.lowerBound
            return (x + dx, y + dy)
        }
        
        // Apply tool at primary coordinate
        func applyAt(_ px: Int, _ py: Int, in part: BodyPart?) {
            switch selectedTool {
            case .pencil:
                skinManager.currentSkin.setPixel(x: px, y: py, color: skinManager.selectedColor, layer: skinManager.selectedLayer)
            case .eraser:
                skinManager.currentSkin.setPixel(x: px, y: py, color: .clear, layer: skinManager.selectedLayer)
            case .fillBucket:
                if let p = part {
                    let r = p.getRegion()
                    skinManager.currentSkin.fillInRegion(x: px, y: py, color: skinManager.selectedColor, layer: skinManager.selectedLayer, regionX: r.x, regionY: r.y)
                } else {
                    skinManager.currentSkin.fill(x: px, y: py, color: skinManager.selectedColor, layer: skinManager.selectedLayer)
                }
            case .eyedropper:
                let color = skinManager.currentSkin.getPixel(x: px, y: py, layer: skinManager.selectedLayer)
                if color != .clear { skinManager.selectedColor = color }
            default:
                break
            }
        }

        // Apply to primary
        applyAt(x, y, in: primaryPart)

        // Optional region-aware mirroring when editing arms/legs
        if gridSystem.autoSymmetry, let p = primaryPart, let mirror = p.mirrorPart {
            let (mx, my) = mirrorCoordinate(of: x, y, from: p, to: mirror)
            if mx >= 0 && mx < CharacterSkin.width && my >= 0 && my < CharacterSkin.height {
                applyAt(mx, my, in: mirror)
            }
        }
        
        skinManager.objectWillChange.send()
    }
}

// MARK: - Hotspots + Focus helpers
extension EnhancedSkinCanvas {
    fileprivate func hotspotOverlay(containerSize: CGSize) -> some View {
        let pixelSize = 10 * currentZoom
        return ZStack {
            ForEach(BodyPart.allCases, id: \.self) { part in
                let region = part.getRegion()
                let rect = CGRect(
                    x: CGFloat(region.x.lowerBound) * pixelSize,
                    y: CGFloat(region.y.lowerBound) * pixelSize,
                    width: CGFloat(region.x.count) * pixelSize,
                    height: CGFloat(region.y.count) * pixelSize
                )
                Color.clear
                    .contentShape(Rectangle())
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                    .onTapGesture {
                        gridSystem.isolatedParts = [part]
                        focusOn(part: part, containerSize: containerSize)
                    }
            }
        }
        .allowsHitTesting(true)
    }

    fileprivate func focusOn(part: BodyPart, containerSize: CGSize) {
        // Compute target zoom so part fills ~70% of container
        let partWidth = CGFloat(part.getRegion().x.count) * 10
        let partHeight = CGFloat(part.getRegion().y.count) * 10
        let zoomX = (containerSize.width * 0.7) / max(partWidth * currentZoom, 1)
        let zoomY = (containerSize.height * 0.7) / max(partHeight * currentZoom, 1)
        let newZoom = max(0.5, min(4.0, min(zoomX, zoomY) * currentZoom))

        // Compute new offset so part center aligns to container center
        let fullWidth = CGFloat(CharacterSkin.width) * 10 * newZoom
        let fullHeight = CGFloat(CharacterSkin.height) * 10 * newZoom
        let region = part.getRegion()
        let rect = CGRect(
            x: CGFloat(region.x.lowerBound) * 10 * newZoom,
            y: CGFloat(region.y.lowerBound) * 10 * newZoom,
            width: CGFloat(region.x.count) * 10 * newZoom,
            height: CGFloat(region.y.count) * 10 * newZoom
        )
        let targetCenter = CGPoint(x: containerSize.width / 2, y: containerSize.height / 2)
        let rectCenter = CGPoint(x: rect.midX, y: rect.midY)
        let dx = targetCenter.x - rectCenter.x
        let dy = targetCenter.y - rectCenter.y

        withAnimation(.easeInOut(duration: 0.25)) {
            currentZoom = newZoom
            canvasOffset = CGSize(
                width: max(min(dx, fullWidth/2), -fullWidth/2),
                height: max(min(dy, fullHeight/2), -fullHeight/2)
            )
        }
    }

    fileprivate func fitToAllParts(containerSize: CGSize) {
        // Union of all primary parts (exclude pure overlay-only regions)
        let regions = BodyPart.allCases.map { $0.getRegion() }
        let minX = regions.map { $0.x.lowerBound }.min() ?? 0
        let minY = regions.map { $0.y.lowerBound }.min() ?? 0
        let maxX = regions.map { $0.x.upperBound }.max() ?? CharacterSkin.width
        let maxY = regions.map { $0.y.upperBound }.max() ?? CharacterSkin.height

        let widthPx = CGFloat(maxX - minX) * 10
        let heightPx = CGFloat(maxY - minY) * 10

        let targetWidth = containerSize.width * 0.9
        let targetHeight = containerSize.height * 0.9
        let zoomX = targetWidth / max(widthPx, 1)
        let zoomY = targetHeight / max(heightPx, 1)
        let newZoom = max(0.5, min(4.0, min(zoomX, zoomY)))

        // Compute new offset to center the union rect
        let fullW = CGFloat(CharacterSkin.width) * 10 * newZoom
        let fullH = CGFloat(CharacterSkin.height) * 10 * newZoom
        let rect = CGRect(x: CGFloat(minX) * 10 * newZoom,
                          y: CGFloat(minY) * 10 * newZoom,
                          width: CGFloat(maxX - minX) * 10 * newZoom,
                          height: CGFloat(maxY - minY) * 10 * newZoom)
        let targetCenter = CGPoint(x: containerSize.width / 2, y: containerSize.height / 2)
        let rectCenter = CGPoint(x: rect.midX, y: rect.midY)
        let dx = targetCenter.x - rectCenter.x
        let dy = targetCenter.y - rectCenter.y

        withAnimation(.easeInOut(duration: 0.25)) {
            currentZoom = newZoom
            canvasOffset = CGSize(
                width: max(min(dx, fullW/2), -fullW/2),
                height: max(min(dy, fullH/2), -fullH/2)
            )
        }
    }

    // MARK: - Part Tabs
    fileprivate func partTabs(containerSize: CGSize) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach([BodyPart.head, .body, .rightArm, .leftArm, .rightLeg, .leftLeg], id: \.self) { part in
                    Button(action: {
                        gridSystem.isolatedParts = [part]
                        focusOn(part: part, containerSize: containerSize)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: part.iconName)
                            Text(part.rawValue)
                                .font(.caption)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            gridSystem.isolatedParts.contains(part) ?
                            Color.purple.opacity(0.2) : Color(.tertiarySystemFill)
                        )
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            .padding(.top, 4)
        }
    }

    // MARK: - Mini Map
    fileprivate func miniMap(containerSize: CGSize) -> some View {
        let miniSize: CGFloat = 110
        let border: CGFloat = 1
        let img = skinUIImage()
        let viewport = viewportRect(containerSize: containerSize)
        return ZStack(alignment: .topLeading) {
            Image(uiImage: img)
                .interpolation(.none)
                .resizable()
                .frame(width: miniSize, height: miniSize)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.4), lineWidth: border)
                )
            // Viewport rectangle
            Rectangle()
                .stroke(Color.purple, lineWidth: 2)
                .frame(width: miniSize * viewport.width / 64,
                       height: miniSize * viewport.height / 64)
                .offset(x: miniSize * viewport.minX / 64,
                        y: miniSize * viewport.minY / 64)
        }
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 3, y: 1)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }

    // Compute current visible rectangle in texture coordinates (0..64)
    fileprivate func viewportRect(containerSize: CGSize) -> CGRect {
        let scalePx = 10 * currentZoom
        let ox = canvasOffset.width
        let oy = canvasOffset.height
        let visMinX = max(0, (0 - ox) / scalePx)
        let visMinY = max(0, (0 - oy) / scalePx)
        let visMaxX = min(CGFloat(CharacterSkin.width), (containerSize.width - ox) / scalePx)
        let visMaxY = min(CGFloat(CharacterSkin.height), (containerSize.height - oy) / scalePx)
        return CGRect(x: visMinX, y: visMinY, width: max(0, visMaxX - visMinX), height: max(0, visMaxY - visMinY))
    }

    fileprivate func skinUIImage() -> UIImage {
        let width = CharacterSkin.width
        let height = CharacterSkin.height
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 1.0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return UIImage() }
        for y in 0..<height {
            for x in 0..<width {
                let base = skinManager.currentSkin.getPixel(x: x, y: y, layer: .base)
                let over = skinManager.currentSkin.getPixel(x: x, y: y, layer: .overlay)
                let c = over == .clear ? base : over
                ctx.setFillColor(UIColor(c).cgColor)
                ctx.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return img
    }

    // MARK: - Clickable Region Labels
    fileprivate func labelOverlay(containerSize: CGSize) -> some View {
        let pixelSize = 10 * currentZoom
        return ZStack {
            ForEach([BodyPart.head, .body, .rightArm, .leftArm, .rightLeg, .leftLeg], id: \.self) { part in
                let region = part.getRegion()
                let rect = CGRect(
                    x: CGFloat(region.x.lowerBound) * pixelSize,
                    y: CGFloat(region.y.lowerBound) * pixelSize,
                    width: CGFloat(region.x.count) * pixelSize,
                    height: CGFloat(region.y.count) * pixelSize
                )
                Button(action: {
                    gridSystem.isolatedParts = [part]
                    focusOn(part: part, containerSize: containerSize)
                }) {
                    Text(part.displayName)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.ultraThinMaterial)
                        .cornerRadius(6)
                }
                .position(x: rect.midX, y: max(12, rect.minY - 10))
            }
        }
        .allowsHitTesting(true)
    }
}

// MARK: - Grid Overlay
struct GridOverlay: View {
    let gridSize: Int
    
    var body: some View {
        Canvas { context, size in
            let px = CGFloat(10)
            let major = CGFloat(gridSize) * px // typically every 8 pixels

            // Minor grid: every pixel (subtle)
            for x in stride(from: 0, through: size.width, by: px) {
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    },
                    with: .color(.gray.opacity(0.08)),
                    lineWidth: 0.3
                )
            }
            for y in stride(from: 0, through: size.height, by: px) {
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    },
                    with: .color(.gray.opacity(0.08)),
                    lineWidth: 0.3
                )
            }

            // Major grid: every 8 pixels (stronger)
            for x in stride(from: 0, through: size.width, by: major) {
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    },
                    with: .color(.gray.opacity(0.35)),
                    lineWidth: 0.8
                )
            }
            for y in stride(from: 0, through: size.height, by: major) {
                context.stroke(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    },
                    with: .color(.gray.opacity(0.35)),
                    lineWidth: 0.8
                )
            }
        }
    }
}

// MARK: - Enhanced 3D Preview
struct Enhanced3DPreview: View {
    @EnvironmentObject var skinManager: SkinManager
    let showingAnimation: Bool
    @State private var rotation: Double = 0
    @State private var selectedAnimation: AnimationType = .idle
    
    enum AnimationType: String, CaseIterable {
        case idle = "Idle"
        case walk = "Walk"
        case run = "Run"
        case jump = "Jump"
        case swim = "Swim"
        case sneak = "Sneak"
        case attack = "Attack"
    }
    
    var body: some View {
        VStack {
            if showingAnimation {
                Picker("Animation", selection: $selectedAnimation) {
                    ForEach(AnimationType.allCases, id: \.self) { animation in
                        Text(animation.rawValue).tag(animation)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }
            
            Skin3DPreview()
                .rotation3DEffect(
                    .degrees(rotation),
                    axis: (x: 0, y: 1, z: 0)
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            rotation += Double(value.translation.width)
                        }
                )
                .onAppear {
                    if showingAnimation {
                        startAnimation()
                    }
                }
        }
    }
    
    private func startAnimation() {
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
}

// MARK: - Layer Panel
struct LayerPanel: View {
    @EnvironmentObject var skinManager: SkinManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Layers")
                .font(.headline)
                .padding()
            
            Divider()
            
            ScrollView {
                VStack(spacing: 8) {
                    LayerRow(
                        name: "Overlay",
                        isSelected: skinManager.selectedLayer == .overlay,
                        opacity: 1.0
                    ) {
                        skinManager.selectedLayer = .overlay
                    }
                    
                    LayerRow(
                        name: "Base",
                        isSelected: skinManager.selectedLayer == .base,
                        opacity: 1.0
                    ) {
                        skinManager.selectedLayer = .base
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Layer controls
            HStack {
                Button(action: {}) {
                    Image(systemName: "plus.circle")
                }
                
                Button(action: {}) {
                    Image(systemName: "trash")
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "eye")
                }
                
                Button(action: {}) {
                    Image(systemName: "lock")
                }
            }
            .padding()
        }
    }
}

struct LayerRow: View {
    let name: String
    let isSelected: Bool
    let opacity: Double
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "eye.fill")
                .foregroundColor(.gray)
            
            Text(name)
                .font(.system(.body, design: .rounded))
            
            Spacer()
            
            Text("\(Int(opacity * 100))%")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(isSelected ? Color.purple.opacity(0.2) : Color.clear)
        .cornerRadius(8)
        .onTapGesture(perform: action)
    }
}

// MARK: - Color Components
struct ColorBar: View {
    @ObservedObject var paletteManager: PaletteManager
    @EnvironmentObject var skinManager: SkinManager
    @Binding var showingFullPalette: Bool
    
    var body: some View {
        HStack {
            // Current color
            ColorPicker("", selection: $skinManager.selectedColor)
                .labelsHidden()
                .frame(width: 50, height: 50)
            
            Divider()
                .frame(height: 40)
            
            // Recent colors
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(paletteManager.recentColors.prefix(10), id: \.self) { color in
                        Button(action: {
                            skinManager.selectedColor = color
                        }) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        }
                    }
                }
            }
            
            Spacer()
            
            Button(action: { showingFullPalette = true }) {
                Image(systemName: "paintpalette.fill")
            }
        }
        .padding(.horizontal)
    }
}

struct ColorPalettePanel: View {
    @ObservedObject var paletteManager: PaletteManager
    @Binding var isShowing: Bool
    @EnvironmentObject var skinManager: SkinManager
    
    var body: some View {
        VStack {
            HStack {
                Text("Color Palettes")
                    .font(.headline)
                
                Spacer()
                
                Button("Done") {
                    isShowing = false
                }
            }
            .padding()
            
            if let currentPalette = paletteManager.currentPalette {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 40))
                ], spacing: 8) {
                    ForEach(currentPalette.colors, id: \.red) { codableColor in
                        Button(action: {
                            skinManager.selectedColor = codableColor.color
                            paletteManager.addColorToRecent(codableColor.color)
                        }) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(codableColor.color)
                                .frame(height: 40)
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .frame(width: 300, height: 400)
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(radius: 10)
        .offset(y: isShowing ? 0 : UIScreen.main.bounds.height)
        .animation(.spring(), value: isShowing)
    }
}

struct ToolSettingsPanel: View {
    let tool: AdvancedTool
    @Binding var settings: BrushSettings
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("\(tool.rawValue) Settings")
                    .font(.headline)
                
                Spacer()
                
                Button("Done") {
                    isShowing = false
                }
            }
            .padding()
            
            Form {
                Section("Brush") {
                    HStack {
                        Text("Size")
                        Slider(value: $settings.size, in: 1...20)
                        Text("\(Int(settings.size))px")
                    }
                    
                    HStack {
                        Text("Opacity")
                        Slider(value: $settings.opacity, in: 0...1)
                        Text("\(Int(settings.opacity * 100))%")
                    }
                    
                    HStack {
                        Text("Hardness")
                        Slider(value: $settings.hardness, in: 0...1)
                        Text("\(Int(settings.hardness * 100))%")
                    }
                }
                
                Section("Advanced") {
                    HStack {
                        Text("Spacing")
                        Slider(value: $settings.spacing, in: 0...1)
                    }
                    
                    HStack {
                        Text("Jitter")
                        Slider(value: $settings.jitter, in: 0...1)
                    }
                    
                    Picker("Mix Mode", selection: $settings.mixMode) {
                        ForEach(BrushSettings.MixMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                }
            }
            .frame(height: 300)
            
            Spacer()
        }
        .frame(width: 350, height: 400)
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(radius: 10)
        .offset(y: isShowing ? 0 : UIScreen.main.bounds.height)
        .animation(.spring(), value: isShowing)
    }
}
