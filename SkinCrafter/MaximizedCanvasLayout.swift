import SwiftUI

// MARK: - Compact Top Bar
struct CompactTopBar: View {
    @ObservedObject var undoManager: UndoRedoManager
    @Binding var currentZoom: CGFloat
    @Binding var showingPreview: Bool
    @Binding var showingLayers: Bool
    
    var body: some View {
        HStack {
            // Undo/Redo
            HStack(spacing: 8) {
                Button(action: { _ = undoManager.undo() }) {
                    Image(systemName: "arrow.uturn.backward")
                        .foregroundColor(undoManager.canUndo ? .primary : .gray)
                }
                .disabled(!undoManager.canUndo)
                
                Button(action: { _ = undoManager.redo() }) {
                    Image(systemName: "arrow.uturn.forward")
                        .foregroundColor(undoManager.canRedo ? .primary : .gray)
                }
                .disabled(!undoManager.canRedo)
            }
            
            Spacer()
            
            // Zoom controls
            HStack(spacing: 8) {
                Button(action: { currentZoom = max(0.5, currentZoom - 0.25) }) {
                    Image(systemName: "minus.magnifyingglass")
                }
                
                Text("\(Int(currentZoom * 100))%")
                    .font(.caption)
                    .frame(width: 50)
                
                Button(action: { currentZoom = min(4.0, currentZoom + 0.25) }) {
                    Image(systemName: "plus.magnifyingglass")
                }
            }
            
            Spacer()
            
            // View toggles
            HStack(spacing: 8) {
                Button(action: { showingPreview.toggle() }) {
                    Image(systemName: showingPreview ? "cube.fill" : "cube")
                }
                
                Button(action: { showingLayers.toggle() }) {
                    Image(systemName: showingLayers ? "square.stack.3d.up.fill" : "square.stack.3d.up")
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Maximized Canvas Layout
struct MaximizedCanvasLayout: View {
    @EnvironmentObject var skinManager: SkinManager
    @StateObject private var undoManager = UndoRedoManager()
    @StateObject private var gridSystem = GridSystem()
    @State private var selectedTool: AdvancedTool = .pencil
    @State private var currentZoom: CGFloat = 1.0
    @State private var canvasOffset: CGSize = .zero
    @State private var fitTrigger: Int = 0
    @State private var showingTools = true
    @State private var showingPreview = false
    @State private var showingColorPicker = false
    @State private var showingLayers = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main Canvas Area
                VStack(spacing: 0) {
                    // Compact Top Bar
                    if showingTools {
                        CompactTopBar(
                            undoManager: undoManager,
                            currentZoom: $currentZoom,
                            showingPreview: $showingPreview,
                            showingLayers: $showingLayers
                        )
                        .frame(height: 44)
                        .background(Color.black.opacity(0.05))
                    }
                    
                    // Canvas with overlaid controls
                    ZStack {
                        // Enhanced Canvas with better touch handling
                        EnhancedSkinCanvas(
                            undoManager: undoManager,
                            gridSystem: gridSystem,
                            selectedTool: selectedTool,
                            brushSettings: BrushSettings(),
                            currentZoom: $currentZoom,
                            canvasOffset: $canvasOffset,
                            fitTrigger: $fitTrigger
                        )
                        
                        // Floating Controls Overlay
                        VStack {
                            HStack {
                                // Quick Zoom Controls
                                if showingTools {
                                    FloatingZoomControls(currentZoom: $currentZoom)
                                        .padding(.leading, 16)
                                }
                                
                                Spacer()
                                
                                // Quick Actions Panel
                                if showingTools {
                                    FloatingQuickActions(
                                        showingPreview: $showingPreview,
                                        showingLayers: $showingLayers,
                                        showingColorPicker: $showingColorPicker
                                    )
                                    .padding(.trailing, 16)
                                }
                            }
                            .padding(.top, 16)
                            
                            Spacer()
                            
                            // Tool Carousel (bottom)
                            if showingTools {
                                CompactToolCarousel(
                                    selectedTool: $selectedTool,
                                    showingToolSettings: .constant(false)
                                )
                                .padding(.horizontal, 16)
                                .padding(.bottom, geometry.safeAreaInsets.bottom + 16)
                            }
                        }
                        
                        // Sliding Preview Panel
                        if showingPreview {
                            SlidingPreviewPanel(isShowing: $showingPreview)
                                .transition(.move(edge: .trailing))
                        }
                        
                        // Sliding Layer Panel
                        if showingLayers {
                            SlidingLayerPanel(isShowing: $showingLayers)
                                .transition(.move(edge: .leading))
                        }
                        
                        // Color Picker Panel
                        if showingColorPicker {
                            FloatingColorPicker(isShowing: $showingColorPicker)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                
                // Hide/Show Tools Gesture Area
                Rectangle()
                    .fill(.clear)
                    .frame(height: 20)
                    .position(x: geometry.size.width / 2, y: showingTools ? 0 : geometry.size.height)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showingTools.toggle()
                        }
                    }
            }
        }
        .navigationBarHidden(true)
        .statusBarHidden(!showingTools)
    }
}

// Removed duplicate CompactTopBar - already defined above

// MARK: - Floating Controls
struct FloatingZoomControls: View {
    @Binding var currentZoom: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: { currentZoom = min(4.0, currentZoom + 0.5) }) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.05))
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            
            Button(action: { currentZoom = max(0.5, currentZoom - 0.5) }) {
                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.05))
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
        }
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}

struct FloatingQuickActions: View {
    @Binding var showingPreview: Bool
    @Binding var showingLayers: Bool
    @Binding var showingColorPicker: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: { showingColorPicker.toggle() }) {
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(showingColorPicker ? .white : .primary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(showingColorPicker ? Color.purple : Color.black.opacity(0.05))
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: showingColorPicker ? 0 : 1)
                            )
                    )
            }
        }
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}

// MARK: - Enhanced Touch Canvas with Precision Tools
struct EnhancedTouchCanvas: View {
    @EnvironmentObject var skinManager: SkinManager
    @ObservedObject var undoManager: UndoRedoManager
    @ObservedObject var gridSystem: GridSystem
    let selectedTool: AdvancedTool
    @Binding var currentZoom: CGFloat
    @Binding var canvasOffset: CGSize
    @State private var showingMagnifier = false
    @State private var magnifierPosition: CGPoint = .zero
    @State private var lastTouchPoint: CGPoint = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main Canvas
                Canvas { context, size in
                    drawSkin(context: context, size: size, geometry: geometry)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.1))
                .gesture(
                    SimultaneousGesture(
                        // Drawing gesture
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                handleDraw(at: value.location, in: geometry)
                                
                                // Show magnifier for precision work
                                if currentZoom < 2.0 {
                                    magnifierPosition = value.location
                                    showingMagnifier = true
                                    lastTouchPoint = value.location
                                }
                            }
                            .onEnded { _ in
                                showingMagnifier = false
                                undoManager.recordState(skinManager.currentSkin)
                            },
                        
                        // Zoom/pan gesture
                        MagnificationGesture()
                            .onChanged { value in
                                currentZoom = max(0.5, min(4.0, value))
                            }
                    )
                )
                
                // Precision Magnifier
                if showingMagnifier {
                    PrecisionMagnifier(
                        position: magnifierPosition,
                        zoomLevel: 4.0,
                        skinData: skinManager.currentSkin
                    )
                    .allowsHitTesting(false)
                }
            }
        }
    }
    
    private func drawSkin(context: GraphicsContext, size: CGSize, geometry: GeometryProxy) {
        let pixelSize = calculatePixelSize(for: size)
        let canvasRect = calculateCanvasRect(size: size, geometry: geometry)
        
        // Draw skin pixels
        for y in 0..<CharacterSkin.height {
            for x in 0..<CharacterSkin.width {
                let rect = CGRect(
                    x: canvasRect.minX + CGFloat(x) * pixelSize,
                    y: canvasRect.minY + CGFloat(y) * pixelSize,
                    width: pixelSize,
                    height: pixelSize
                )
                
                // Base layer
                let baseColor = skinManager.currentSkin.getPixel(x: x, y: y, layer: .base)
                if baseColor != .clear {
                    context.fill(Path(rect), with: .color(baseColor))
                }
                
                // Overlay layer
                let overlayColor = skinManager.currentSkin.getPixel(x: x, y: y, layer: .overlay)
                if overlayColor != .clear {
                    context.fill(Path(rect), with: .color(overlayColor.opacity(0.8)))
                }
                
                // Grid overlay
                if gridSystem.showGrid && pixelSize > 4 {
                    context.stroke(Path(rect), with: .color(.gray.opacity(0.3)), lineWidth: 0.5)
                }
            }
        }
    }
    
    private func calculatePixelSize(for size: CGSize) -> CGFloat {
        let baseSize = min(size.width / CGFloat(CharacterSkin.width), 
                          size.height / CGFloat(CharacterSkin.height))
        return baseSize * currentZoom
    }
    
    private func calculateCanvasRect(size: CGSize, geometry: GeometryProxy) -> CGRect {
        let pixelSize = calculatePixelSize(for: size)
        let canvasWidth = CGFloat(CharacterSkin.width) * pixelSize
        let canvasHeight = CGFloat(CharacterSkin.height) * pixelSize
        
        return CGRect(
            x: (geometry.size.width - canvasWidth) / 2 + canvasOffset.width,
            y: (geometry.size.height - canvasHeight) / 2 + canvasOffset.height,
            width: canvasWidth,
            height: canvasHeight
        )
    }
    
    private func handleDraw(at location: CGPoint, in geometry: GeometryProxy) {
        let pixelSize = calculatePixelSize(for: geometry.size)
        let canvasRect = calculateCanvasRect(size: geometry.size, geometry: geometry)
        
        let x = Int((location.x - canvasRect.minX) / pixelSize)
        let y = Int((location.y - canvasRect.minY) / pixelSize)
        
        guard x >= 0, x < CharacterSkin.width, y >= 0, y < CharacterSkin.height else { return }
        
        // Apply tool with haptic feedback
        switch selectedTool {
        case .pencil:
            skinManager.currentSkin.setPixel(x: x, y: y, color: skinManager.selectedColor, layer: skinManager.selectedLayer)
            HapticManager.shared.impact(.light)
        case .eraser:
            skinManager.currentSkin.setPixel(x: x, y: y, color: .clear, layer: skinManager.selectedLayer)
            HapticManager.shared.impact(.light)
        case .fillBucket:
            skinManager.currentSkin.fill(x: x, y: y, color: skinManager.selectedColor, layer: skinManager.selectedLayer)
            HapticManager.shared.impact(.medium)
        case .eyedropper:
            let color = skinManager.currentSkin.getPixel(x: x, y: y, layer: skinManager.selectedLayer)
            if color != .clear {
                skinManager.selectedColor = color
                HapticManager.shared.selectionChanged()
            }
        default:
            break
        }
        
        skinManager.objectWillChange.send()
    }
}

// MARK: - Precision Magnifier
struct PrecisionMagnifier: View {
    let position: CGPoint
    let zoomLevel: CGFloat
    let skinData: CharacterSkin
    
    var body: some View {
        Circle()
            .fill(Color.black.opacity(0.05))
            .frame(width: 120, height: 120)
            .overlay(
                Circle()
                    .stroke(Color.purple, lineWidth: 3)
            )
            .overlay(
                // Magnified content would go here
                // This is a simplified representation
                Circle()
                    .fill(Color.purple.opacity(0.3))
                    .frame(width: 80, height: 80)
            )
            .position(x: position.x, y: max(60, position.y - 80))
            .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
    }
}
