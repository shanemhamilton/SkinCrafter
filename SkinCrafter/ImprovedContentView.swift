import SwiftUI

// MARK: - Improved Content View with Unified Interface
struct ImprovedContentView: View {
    @EnvironmentObject var skinManager: SkinManager
    @State private var editorMode: EditorMode = .threeDFirst
    @State private var showingModeTransition = false
    
    enum EditorMode: CaseIterable {
        case threeDFirst  // New 3D-first mode (default)
        case simple
        case professional  
        case focused // Fullscreen focused mode
        
        var displayName: String {
            switch self {
            case .threeDFirst: return "3D Edit"
            case .simple: return "Simple"
            case .professional: return "Professional"
            case .focused: return "Focused"
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    colors: [.purple.opacity(0.05), .blue.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Mode-specific content
                Group {
                    switch editorMode {
                    case .threeDFirst:
                        Enhanced3DEditingView()
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                    case .simple:
                        SimplifiedEditorView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .leading),
                                removal: .move(edge: .trailing)
                            ))
                    case .professional:
                        ProfessionalMaximizedView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom),
                                removal: .move(edge: .top)
                            ))
                    case .focused:
                        FocusedCanvasView()
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: editorMode)
                
                // Mode Switch Control (always visible but contextual)
                if editorMode != .focused {
                    VStack {
                        HStack {
                            Spacer()
                            ModeToggleControl(currentMode: $editorMode)
                                .padding(.trailing, 16)
                                .padding(.top, geometry.safeAreaInsets.top + 8)
                        }
                        Spacer()
                    }
                }
                
                // Mode Transition Indicator
                if showingModeTransition {
                    ModeTransitionOverlay(targetMode: editorMode)
                        .transition(.opacity)
                }
            }
        }
        .onChange(of: editorMode) { _ in
            showModeTransition()
        }
    }
    
    private func showModeTransition() {
        showingModeTransition = true
        HapticManager.shared.impact(.medium)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showingModeTransition = false
        }
    }
}

// MARK: - Mode Toggle Control
struct ModeToggleControl: View {
    @Binding var currentMode: ImprovedContentView.EditorMode
    @State private var showingAllModes = false
    
    var body: some View {
        HStack(spacing: 8) {
            if showingAllModes {
                ForEach(ImprovedContentView.EditorMode.allCases, id: \.self) { mode in
                    ModeButton(
                        mode: mode,
                        isSelected: mode == currentMode,
                        action: { 
                            currentMode = mode
                            showingAllModes = false
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            } else {
                ModeButton(
                    mode: currentMode,
                    isSelected: true,
                    action: { showingAllModes = true }
                )
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.05))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showingAllModes)
        .onTapGesture {
            if !showingAllModes {
                showingAllModes = true
            }
        }
        .onChange(of: currentMode) { _ in
            // Auto-hide after selection
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showingAllModes = false
            }
        }
    }
}

struct ModeButton: View {
    let mode: ImprovedContentView.EditorMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: mode.iconName)
                    .font(.system(size: 14, weight: .medium))
                
                if isSelected {
                    Text(mode.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, isSelected ? 12 : 8)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.purple : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Simplified Editor View (Improved Simple Mode)
struct SimplifiedEditorView: View {
    @EnvironmentObject var skinManager: SkinManager
    @State private var showingColorPicker = false
    @State private var showingExport = false
    @State private var currentZoom: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 0) {
            // Simplified Top Bar
            HStack {
                Button("Reset") {
                    skinManager.resetSkin()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Text("Skin Creator")
                    .font(.headline)
                
                Spacer()
                
                Button("Export") {
                    showingExport = true
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color.black.opacity(0.05))
            
            // Canvas Area (70% of screen)
            GeometryReader { geometry in
                VStack(spacing: 16) {
                    // 3D Preview (compact)
                    if skinManager.isShowingPreview {
                        Skin3DPreview()
                            .frame(height: geometry.size.height * 0.3)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.05))
                            )
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // 2D Canvas (maximized)
                    SmartZoomPanView(
                        content: SkinEditorCanvas()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2),
                        currentZoom: $currentZoom,
                        panOffset: .constant(.zero)
                    )
                    .frame(maxHeight: .infinity)
                }
                .padding()
            }
            
            // Simplified Tools (bottom 20% of screen)
            SimplifiedToolBar(showingColorPicker: $showingColorPicker)
                .padding()
                .background(Color.black.opacity(0.05))
        }
        .sheet(isPresented: $showingColorPicker) {
            SimpleColorPicker()
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingExport) {
            SimpleExportView()
                .presentationDetents([.medium])
        }
    }
}

// MARK: - Professional Maximized View
struct ProfessionalMaximizedView: View {
    var body: some View {
        MaximizedCanvasLayout()
            .overlay(
                // Professional mode enhancements
                TouchShortcutOverlay(selectedTool: .constant(.pencil))
                    .allowsHitTesting(false)
            )
    }
}

// MARK: - Focused Canvas View (New Fullscreen Mode)
struct FocusedCanvasView: View {
    @EnvironmentObject var skinManager: SkinManager
    @State private var currentZoom: CGFloat = 2.0 // Start zoomed in
    @State private var panOffset: CGSize = .zero
    @State private var showingMinimalUI = false
    @State private var selectedTool: AdvancedTool = .pencil
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fullscreen Canvas
                SmartZoomPanView(
                    content: EnhancedTouchCanvas(
                        undoManager: UndoRedoManager(),
                        gridSystem: GridSystem(),
                        selectedTool: selectedTool,
                        currentZoom: $currentZoom,
                        canvasOffset: $panOffset
                    ),
                    currentZoom: $currentZoom,
                    panOffset: $panOffset
                )
                
                // Minimal UI (fade in/out with inactivity)
                if showingMinimalUI {
                    VStack {
                        // Top minimal controls
                        HStack {
                            Button(action: {}) {
                                Image(systemName: "arrow.uturn.backward")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Circle().fill(.black.opacity(0.5)))
                            }
                            
                            Spacer()
                            
                            Text("\(Int(currentZoom * 100))%")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Capsule().fill(.black.opacity(0.5)))
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Circle().fill(.black.opacity(0.5)))
                            }
                        }
                        .padding()
                        
                        Spacer()
                        
                        // Bottom tool selector
                        HStack {
                            ForEach([AdvancedTool.pencil, .eraser, .fillBucket, .eyedropper], id: \.self) { tool in
                                Button(action: { selectedTool = tool }) {
                                    Image(systemName: tool.iconName)
                                        .font(.title2)
                                        .foregroundColor(selectedTool == tool ? .purple : .white)
                                        .padding(12)
                                        .background(
                                            Circle()
                                                .fill(selectedTool == tool ? .white : .black.opacity(0.5))
                                        )
                                }
                            }
                        }
                        .padding()
                    }
                    .transition(.opacity)
                }
            }
        }
        .statusBarHidden()
        .onAppear {
            showingMinimalUI = true
            // Auto-hide UI after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showingMinimalUI = false
            }
        }
        .onTapGesture {
            // Toggle UI visibility
            showingMinimalUI.toggle()
        }
    }
}

// MARK: - Supporting Views
struct SimplifiedToolBar: View {
    @EnvironmentObject var skinManager: SkinManager
    @Binding var showingColorPicker: Bool
    
    var body: some View {
        HStack {
            // Essential tools only
            ForEach([DrawingTool.pencil, .eraser, .bucket], id: \.self) { tool in
                Button(action: { skinManager.selectedTool = tool }) {
                    Image(systemName: tool.iconName)
                        .font(.title2)
                        .foregroundColor(skinManager.selectedTool == tool ? .white : .primary)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(skinManager.selectedTool == tool ? Color.purple : Color.clear)
                        )
                }
            }
            
            Spacer()
            
            // Color picker
            Button(action: { showingColorPicker = true }) {
                Circle()
                    .fill(skinManager.selectedColor)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: 2)
                    )
            }
            
            // Preview toggle
            Button(action: { skinManager.isShowingPreview.toggle() }) {
                Image(systemName: skinManager.isShowingPreview ? "eye.fill" : "eye.slash.fill")
                    .font(.title2)
                    .foregroundColor(skinManager.isShowingPreview ? .purple : .gray)
                    .frame(width: 50, height: 50)
            }
        }
    }
}

struct SimpleColorPicker: View {
    @EnvironmentObject var skinManager: SkinManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                ColorPicker("Select Color", selection: $skinManager.selectedColor)
                    .labelsHidden()
                    .scaleEffect(2)
                    .padding()
                
                // Common colors grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6)) {
                    ForEach(commonColors, id: \.description) { color in
                        Button(action: {
                            skinManager.selectedColor = color
                            dismiss()
                        }) {
                            Circle()
                                .fill(color)
                                .frame(height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Choose Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
    }
    
    private var commonColors: [Color] {
        [.red, .orange, .yellow, .green, .blue, .purple,
         .pink, .brown, .gray, .black, .white, Color(red: 0.96, green: 0.80, blue: 0.69)]
    }
}

struct SimpleExportView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Export your creation")
                    .font(.title2)
                    .padding()
                
                VStack(spacing: 16) {
                    ExportButton(title: "Save to Photos", icon: "photo", action: {})
                    ExportButton(title: "Share", icon: "square.and.arrow.up", action: {})
                    ExportButton(title: "Open in Minecraft", icon: "gamecontroller", action: {})
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Cancel") { dismiss() }
            }
        }
    }
}

struct ExportButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .foregroundColor(.primary)
    }
}

struct ModeTransitionOverlay: View {
    let targetMode: ImprovedContentView.EditorMode
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: targetMode.iconName)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    
                    Text("Switched to \(targetMode.displayName)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.black.opacity(0.7))
                )
                Spacer()
            }
            Spacer()
        }
    }
}

// MARK: - Extensions
extension ImprovedContentView.EditorMode {
    var iconName: String {
        switch self {
        case .threeDFirst: return "cube.transparent"
        case .simple: return "square.grid.2x2"
        case .professional: return "cube.box.fill"
        case .focused: return "viewfinder"
        }
    }
}