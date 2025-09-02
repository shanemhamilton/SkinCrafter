import SwiftUI

// MARK: - Gesture-Based Navigation System
struct GestureNavigationWrapper: View {
    @Binding var currentMode: EditorMode
    @State private var dragOffset: CGSize = .zero
    @State private var showingModeIndicator = false
    
    enum EditorMode {
        case simple
        case professional
        case fullscreen
    }
    
    let content: AnyView
    
    var body: some View {
        ZStack {
            content
                .offset(dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            handleDragChanged(value)
                        }
                        .onEnded { value in
                            handleDragEnded(value)
                        }
                )
            
            // Mode Switch Indicator
            if showingModeIndicator {
                ModeIndicatorOverlay(currentMode: currentMode)
                    .transition(.opacity)
            }
        }
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        dragOffset = value.translation
        
        // Show mode indicator when dragging up/down significantly
        if abs(value.translation.height) > 50 {
            withAnimation(.easeInOut(duration: 0.2)) {
                showingModeIndicator = true
            }
        }
    }
    
    private func handleDragEnded(_ value: DragGesture.Value) {
        let threshold: CGFloat = 100
        
        withAnimation(.spring()) {
            dragOffset = .zero
            showingModeIndicator = false
        }
        
        // Vertical swipe for mode switching
        if value.translation.height < -threshold && value.velocity.height < -200 {
            switchToNextMode()
        } else if value.translation.height > threshold && value.velocity.height > 200 {
            switchToPreviousMode()
        }
    }
    
    private func switchToNextMode() {
        HapticManager.shared.impact(.medium)
        
        switch currentMode {
        case .simple:
            currentMode = .professional
        case .professional:
            currentMode = .fullscreen
        case .fullscreen:
            currentMode = .simple
        }
    }
    
    private func switchToPreviousMode() {
        HapticManager.shared.impact(.medium)
        
        switch currentMode {
        case .simple:
            currentMode = .fullscreen
        case .professional:
            currentMode = .simple
        case .fullscreen:
            currentMode = .professional
        }
    }
}

// MARK: - Mode Indicator Overlay
struct ModeIndicatorOverlay: View {
    let currentMode: GestureNavigationWrapper.EditorMode
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: currentMode.iconName)
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Text(currentMode.displayName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Swipe ↑↓ to change modes")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                
                Spacer()
            }
            
            Spacer()
        }
    }
}

extension GestureNavigationWrapper.EditorMode {
    var displayName: String {
        switch self {
        case .simple: return "Simple Mode"
        case .professional: return "Professional Mode"
        case .fullscreen: return "Fullscreen Mode"
        }
    }
    
    var iconName: String {
        switch self {
        case .simple: return "square.grid.2x2"
        case .professional: return "cube.box.fill"
        case .fullscreen: return "rectangle.fill"
        }
    }
}

// MARK: - Quick Action Gesture Handler
struct QuickActionGestureHandler: UIViewRepresentable {
    let onDoubleTab: () -> Void
    let onTripleTab: () -> Void
    let onLongPress: () -> Void
    let onTwoFingerTap: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        // Double tap gesture
        let doubleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        // Triple tap gesture
        let tripleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTripleTap))
        tripleTap.numberOfTapsRequired = 3
        view.addGestureRecognizer(tripleTap)
        
        // Long press gesture
        let longPress = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress))
        longPress.minimumPressDuration = 0.5
        view.addGestureRecognizer(longPress)
        
        // Two finger tap gesture
        let twoFingerTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTwoFingerTap))
        twoFingerTap.numberOfTouchesRequired = 2
        view.addGestureRecognizer(twoFingerTap)
        
        // Gesture precedence
        doubleTap.require(toFail: tripleTap)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            onDoubleTab: onDoubleTab,
            onTripleTab: onTripleTab,
            onLongPress: onLongPress,
            onTwoFingerTap: onTwoFingerTap
        )
    }
    
    class Coordinator {
        let onDoubleTab: () -> Void
        let onTripleTab: () -> Void
        let onLongPress: () -> Void
        let onTwoFingerTap: () -> Void
        
        init(onDoubleTab: @escaping () -> Void, onTripleTab: @escaping () -> Void, onLongPress: @escaping () -> Void, onTwoFingerTap: @escaping () -> Void) {
            self.onDoubleTab = onDoubleTab
            self.onTripleTab = onTripleTab
            self.onLongPress = onLongPress
            self.onTwoFingerTap = onTwoFingerTap
        }
        
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            if gesture.state == .ended {
                onDoubleTab()
            }
        }
        
        @objc func handleTripleTap(_ gesture: UITapGestureRecognizer) {
            if gesture.state == .ended {
                onTripleTab()
            }
        }
        
        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            if gesture.state == .began {
                onLongPress()
            }
        }
        
        @objc func handleTwoFingerTap(_ gesture: UITapGestureRecognizer) {
            if gesture.state == .ended {
                onTwoFingerTap()
            }
        }
    }
}

// MARK: - Smart Zoom and Pan System
struct SmartZoomPanView<Content: View>: View {
    let content: Content
    @Binding var currentZoom: CGFloat
    @Binding var panOffset: CGSize
    @State private var lastScale: CGFloat = 1.0
    @State private var lastPanOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            content
                .scaleEffect(currentZoom)
                .offset(panOffset)
                .gesture(
                    SimultaneousGesture(
                        // Magnification gesture
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScale
                                lastScale = value
                                let newScale = currentZoom * delta
                                currentZoom = min(max(newScale, 0.5), 4.0)
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                                snapToNearestZoomLevel()
                            },
                        
                        // Pan gesture (only when zoomed in)
                        DragGesture()
                            .onChanged { value in
                                if currentZoom > 1.0 {
                                    let newOffset = CGSize(
                                        width: lastPanOffset.width + value.translation.width,
                                        height: lastPanOffset.height + value.translation.height
                                    )
                                    panOffset = constrainPanOffset(newOffset, in: geometry.size)
                                }
                            }
                            .onEnded { _ in
                                lastPanOffset = panOffset
                            }
                    )
                )
                .onTapGesture(count: 2) {
                    // Double tap to reset zoom
                    withAnimation(.spring()) {
                        currentZoom = 1.0
                        panOffset = .zero
                        lastPanOffset = .zero
                    }
                    HapticManager.shared.impact(.light)
                }
        }
    }
    
    private func snapToNearestZoomLevel() {
        let zoomLevels: [CGFloat] = [0.5, 1.0, 1.5, 2.0, 3.0, 4.0]
        let nearestLevel = zoomLevels.min { abs($0 - currentZoom) < abs($1 - currentZoom) } ?? 1.0
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentZoom = nearestLevel
            if nearestLevel == 1.0 {
                panOffset = .zero
                lastPanOffset = .zero
            }
        }
    }
    
    private func constrainPanOffset(_ offset: CGSize, in size: CGSize) -> CGSize {
        let scaledSize = CGSize(
            width: size.width * currentZoom,
            height: size.height * currentZoom
        )
        
        let maxOffsetX = max(0, (scaledSize.width - size.width) / 2)
        let maxOffsetY = max(0, (scaledSize.height - size.height) / 2)
        
        return CGSize(
            width: min(max(offset.width, -maxOffsetX), maxOffsetX),
            height: min(max(offset.height, -maxOffsetY), maxOffsetY)
        )
    }
}

// MARK: - Touch Shortcut System
struct TouchShortcutOverlay: View {
    @Binding var selectedTool: AdvancedTool
    @EnvironmentObject var skinManager: SkinManager
    @State private var showingShortcuts = false
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .background(
                    QuickActionGestureHandler(
                        onDoubleTab: {
                            // Double tap: Toggle between pencil and eraser
                            selectedTool = selectedTool == .pencil ? .eraser : .pencil
                            HapticManager.shared.selectionChanged()
                        },
                        onTripleTab: {
                            // Triple tap: Open color picker quickly
                            showingShortcuts = true
                            HapticManager.shared.impact(.medium)
                        },
                        onLongPress: {
                            // Long press: Eyedropper mode
                            selectedTool = .eyedropper
                            HapticManager.shared.impact(.heavy)
                        },
                        onTwoFingerTap: {
                            // Two finger tap: Undo
                            // This would connect to undo manager
                            HapticManager.shared.impact(.light)
                        }
                    )
                )
            
            if showingShortcuts {
                TouchShortcutIndicator()
                    .transition(.scale.combined(with: .opacity))
                    .onTapGesture {
                        showingShortcuts = false
                    }
            }
        }
    }
}

struct TouchShortcutIndicator: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Touch Shortcuts")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                ShortcutRow(icon: "hand.tap", text: "Double tap: Toggle Pencil/Eraser")
                ShortcutRow(icon: "hand.tap.fill", text: "Triple tap: Quick Actions")
                ShortcutRow(icon: "hand.point.up", text: "Long press: Eyedropper")
                ShortcutRow(icon: "hand.tap", text: "Two finger tap: Undo")
            }
            
            Text("Tap to dismiss")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.black.opacity(0.8))
        )
        .shadow(radius: 10)
    }
}

struct ShortcutRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
        }
    }
}