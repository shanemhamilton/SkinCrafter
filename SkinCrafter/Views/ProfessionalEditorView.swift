import SwiftUI

struct ProfessionalEditorView: View {
    @EnvironmentObject var skinManager: SkinManager
    @StateObject private var undoManager = UndoRedoManager()
    @StateObject private var paletteManager = PaletteManager()
    @StateObject private var gridSystem = GridSystem()
    @StateObject private var exportManager = ExportManager()
    
    @State private var selectedTool: AdvancedTool = .pencil
    @State private var brushSettings = BrushSettings()
    @State private var showingToolSettings = false
    @State private var showingExportMenu = false
    @State private var showingLayerPanel = false
    @State private var showingColorPalette = false
    @State private var currentZoom: CGFloat = 1.0
    @State private var canvasOffset: CGSize = .zero
    @State private var fitTrigger: Int = 0
    @State private var showingAnimationPreview = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main Editor Area
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        // Maximized canvas area - tools moved to bottom (temporarily disabled)
                        /*
                        VStack(spacing: 0) {
                            // Canvas takes full width
                            MaximizedCanvasLayout()
                        }
                        */
                        
                        // Canvas Area
                        VStack(spacing: 0) {
                            // Top Controls
                            EditorControlBar(
                                undoManager: undoManager,
                                gridSystem: gridSystem,
                                currentZoom: $currentZoom,
                                onFocus: { focusOnIsolatedPart() },
                                onFit: { fitTrigger &+= 1 }
                            )
                            .frame(height: 44)
                            .background(.ultraThinMaterial)
                            
                            // Split View: 2D Editor + 3D Preview
                            GeometryReader { canvasGeometry in
                                if horizontalSizeClass == .regular {
                                    // iPad Layout - Proper split view with clear separation
                                    HStack(spacing: 1) {
                                        // 2D Editor on the left (55%)
                                        VStack(spacing: 0) {
                                            // 2D Editor Header
                                            HStack {
                                                Text("2D Texture Map")
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                
                                                // Zoom controls
                                                HStack(spacing: 8) {
                                                    Button(action: { currentZoom = max(0.5, currentZoom - 0.25) }) {
                                                        Image(systemName: "minus.magnifyingglass")
                                                            .font(.body)
                                                    }
                                                    
                                                    Text("\(Int(currentZoom * 100))%")
                                                        .font(.caption)
                                                        .monospacedDigit()
                                                        .frame(width: 45)
                                                    
                                                    Button(action: { currentZoom = min(4.0, currentZoom + 0.25) }) {
                                                        Image(systemName: "plus.magnifyingglass")
                                                            .font(.body)
                                                    }
                                                    
                                                    Divider()
                                                        .frame(height: 20)
                                                    
                                                    Button(action: { currentZoom = 1.0 }) {
                                                        Text("Reset")
                                                            .font(.caption)
                                                    }
                                                }
                                            }
                                            .padding(.horizontal)
                                            .padding(.vertical, 12)
                                            .background(.ultraThinMaterial)
                                            
                                            // Tool palette
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 8) {
                                                    ForEach(AdvancedTool.allCases, id: \.self) { tool in
                                                        ProfessionalToolButton(
                                                            tool: tool,
                                                            isSelected: selectedTool == tool,
                                                            action: { 
                                                                selectedTool = tool
                                                                if tool.hasSettings {
                                                                    showingToolSettings = true
                                                                }
                                                            }
                                                        )
                                                    }
                                                }
                                                .padding(.horizontal)
                                            }
                                            .frame(height: 60)
                                            .background(Color(.secondarySystemBackground))
                                            
                                            // 2D Canvas
                                            ZStack {
                                                Color(.systemBackground)
                                                
                                                EnhancedSkinCanvas(
                                                    undoManager: undoManager,
                                                    gridSystem: gridSystem,
                                                    selectedTool: selectedTool,
                                                    brushSettings: brushSettings,
                                                    currentZoom: $currentZoom,
                                                    canvasOffset: $canvasOffset,
                                                    fitTrigger: $fitTrigger
                                                )
                                                // Quick isolate bar for compact layout
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 8) {
                                                        Button("All") { gridSystem.isolatedParts.removeAll() }
                                                            .buttonStyle(.bordered)
                                                        ForEach(BodyPart.allCases.filter { $0 != .hat && $0 != .jacket }, id: \.self) { part in
                                                            Button(action: { gridSystem.isolatedParts = [part] }) {
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
                                                    .padding(.horizontal)
                                                    .padding(.vertical, 8)
                                                }
                                                .background(.ultraThinMaterial)
                                            }
                                        }
                                        .frame(width: canvasGeometry.size.width * 0.55)
                                        .background(Color(.systemBackground))
                                        
                                        // Vertical Divider
                                        Rectangle()
                                            .fill(Color(.separator))
                                            .frame(width: 1)
                                        
                                        // 3D Preview on the right (45%)
                                        VStack(spacing: 0) {
                                            // 3D Preview Header
                                            HStack {
                                                Text("3D Model Preview")
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                                
                                                // Animation controls
                                                HStack(spacing: 12) {
                                                    Menu {
                                                        Button("Walk", action: { /* Set walk animation */ })
                                                        Button("Run", action: { /* Set run animation */ })
                                                        Button("Jump", action: { /* Set jump animation */ })
                                                        Button("Idle", action: { /* Set idle animation */ })
                                                    } label: {
                                                        Label("Animation", systemImage: "figure.walk")
                                                            .font(.caption)
                                                    }
                                                    
                                                    Button(action: { showingAnimationPreview.toggle() }) {
                                                        Image(systemName: showingAnimationPreview ? "pause.fill" : "play.fill")
                                                            .font(.body)
                                                            .foregroundColor(showingAnimationPreview ? .orange : .primary)
                                                    }
                                                }
                                            }
                                            .padding(.horizontal)
                                            .padding(.vertical, 12)
                                            .background(.ultraThinMaterial)
                                            
                                            // 3D Model (static)
                                            Skin3DPreview(
                                                overlayVisibility: .init(
                                                    showHat: gridSystem.showHatOverlay,
                                                    showJacket: gridSystem.showJacketOverlay,
                                                    showSleeves: gridSystem.showSleevesOverlay,
                                                    showPants: gridSystem.showPantsOverlay
                                                )
                                            )
                                                .padding()
                                            
                                            // Body part quick selector
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Quick Select")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                
                                                LazyVGrid(columns: [
                                                    GridItem(.flexible()),
                                                    GridItem(.flexible()),
                                                    GridItem(.flexible())
                                                ], spacing: 8) {
                                                    ForEach(BodyPart.allCases.filter { $0 != .hat && $0 != .jacket }, id: \.self) { part in
                                                        Button(action: {
                                                            // Focus on body part
                                                            gridSystem.isolatedParts = [part]
                                                        }) {
                                                            VStack(spacing: 4) {
                                                                Image(systemName: part.iconName)
                                                                    .font(.caption)
                                                                Text(part.rawValue)
                                                                    .font(.caption2)
                                                            }
                                                            .frame(maxWidth: .infinity)
                                                            .padding(.vertical, 8)
                                                            .background(
                                                                gridSystem.isolatedParts.contains(part) ?
                                                                Color.purple.opacity(0.2) :
                                                                Color(.tertiarySystemFill)
                                                            )
                                                            .cornerRadius(8)
                                                        }
                                                        .buttonStyle(.plain)
                                                    }
                                                }
                                            }
                                            .padding()
                                            .background(Color(.secondarySystemBackground))
                                        }
                                        .frame(width: canvasGeometry.size.width * 0.45)
                                        .background(Color(.systemBackground))
                                    }
                                } else {
                                    // iPhone/Compact Layout - Tab based switching
                                    VStack(spacing: 0) {
                                        // Tab selector
                                        Picker("View", selection: $skinManager.isShowingPreview) {
                                            Text("2D Editor").tag(false)
                                            Text("3D Preview").tag(true)
                                        }
                                        .pickerStyle(.segmented)
                                        .padding()
                                        .background(.ultraThinMaterial)
                                        
                                        if skinManager.isShowingPreview {
                                            // 3D Preview (static)
                                            Skin3DPreview(
                                                overlayVisibility: .init(
                                                    showHat: gridSystem.showHatOverlay,
                                                    showJacket: gridSystem.showJacketOverlay,
                                                    showSleeves: gridSystem.showSleevesOverlay,
                                                    showPants: gridSystem.showPantsOverlay
                                                )
                                            )
                                        } else {
                                            // 2D Editor
                                            VStack(spacing: 0) {
                                                // Tool palette
                                                ScrollView(.horizontal, showsIndicators: false) {
                                                    HStack(spacing: 8) {
                                                        ForEach(AdvancedTool.allCases, id: \.self) { tool in
                                                            Button(action: {
                                                                selectedTool = tool
                                                                if tool.hasSettings {
                                                                    showingToolSettings = true
                                                                }
                                                            }) {
                                                                VStack(spacing: 2) {
                                                                    Image(systemName: tool.iconName)
                                                                        .font(.title3)
                                                                    Text(tool.rawValue)
                                                                        .font(.caption2)
                                                                }
                                                                .frame(width: 60, height: 50)
                                                                .background(
                                                                    selectedTool == tool ?
                                                                    Color.purple.opacity(0.2) :
                                                                    Color.clear
                                                                )
                                                                .cornerRadius(8)
                                                            }
                                                            .buttonStyle(.plain)
                                                        }
                                                    }
                                                    .padding(.horizontal)
                                                }
                                                .frame(height: 60)
                                                .background(.ultraThinMaterial)
                                                
                                                EnhancedSkinCanvas(
                                                    undoManager: undoManager,
                                                    gridSystem: gridSystem,
                                                    selectedTool: selectedTool,
                                                    brushSettings: brushSettings,
                                                    currentZoom: $currentZoom,
                                                    canvasOffset: $canvasOffset,
                                                    fitTrigger: $fitTrigger
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Bottom Color Bar
                            ColorBar(
                                paletteManager: paletteManager,
                                showingFullPalette: $showingColorPalette
                            )
                            .frame(height: 60)
                            .background(.ultraThinMaterial)
                        }
                        
                        // Right Panel (Layers)
                        if showingLayerPanel {
                            LayerPanel()
                                .frame(width: 200)
                                .background(.ultraThinMaterial)
                        }
                    }
                }
                
                // Floating Panels
                if showingToolSettings {
                    ToolSettingsPanel(
                        tool: selectedTool,
                        settings: $brushSettings,
                        isShowing: $showingToolSettings
                    )
                }
                
                if showingColorPalette {
                    ColorPalettePanel(
                        paletteManager: paletteManager,
                        isShowing: $showingColorPalette
                    )
                }
            }
            .navigationTitle("Professional Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingLayerPanel.toggle() }) {
                        Image(systemName: "square.stack.3d.up")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingExportMenu = true }) {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: importSkin) {
                            Label("Import", systemImage: "square.and.arrow.down")
                        }
                        
                        Divider()
                        
                        Button(action: { skinManager.resetSkin() }) {
                            Label("New Skin", systemImage: "doc.badge.plus")
                        }
                        
                        Button(action: duplicateSkin) {
                            Label("Duplicate", systemImage: "doc.on.doc")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingExportMenu) {
                ExportView(exportManager: exportManager, skin: skinManager.currentSkin)
            }
            .onAppear {
                // Apply recommended palette if a template suggests it
                NotificationCenter.default.addObserver(forName: .recommendedPalette, object: nil, queue: .main) { note in
                    if let name = note.userInfo?["paletteName"] as? String {
                        paletteManager.setCurrentPalette(named: name)
                    }
                }
            }
        }
    }
    
    private func importSkin() {
        // Show document picker for importing
    }
    
    private func duplicateSkin() {
        // Duplicate current skin
    }
}

// MARK: - Focus helper
extension ProfessionalEditorView {
    func focusOnIsolatedPart() {
        guard let part = gridSystem.isolatedParts.first else { return }
        // Calculate zoom and offset to center the part in view; mimic EnhancedSkinCanvas logic
        // Since EnhancedSkinCanvas is inside a GeometryReader, approximate using a default area width
        // Here, we apply a reasonable zoom and zero offset; user can refine via pinch/pan
        let region = part.getRegion()
        let partWidth = CGFloat(region.x.count) * 10
        let partHeight = CGFloat(region.y.count) * 10
        let containerWidth: CGFloat = 600 // heuristic for focus target
        let containerHeight: CGFloat = 500
        let zoomX = (containerWidth * 0.7) / max(partWidth * currentZoom, 1)
        let zoomY = (containerHeight * 0.7) / max(partHeight * currentZoom, 1)
        let newZoom = max(0.5, min(4.0, min(zoomX, zoomY) * currentZoom))
        withAnimation(.easeInOut(duration: 0.25)) {
            currentZoom = newZoom
            canvasOffset = .zero
        }
    }
}

// MARK: - Professional Tool Button (For iPad Layout)
struct ProfessionalToolButton: View {
    let tool: AdvancedTool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tool.iconName)
                    .font(.title2)
                Text(tool.rawValue)
                    .font(.caption)
            }
            .frame(width: 70, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.purple.opacity(0.2) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tool Panel
struct ToolPanel: View {
    @Binding var selectedTool: AdvancedTool
    @Binding var brushSettings: BrushSettings
    @Binding var showingSettings: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(AdvancedTool.allCases, id: \.self) { tool in
                    Button(action: {
                        selectedTool = tool
                        if tool.hasSettings {
                            showingSettings = true
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tool.iconName)
                                .font(.title3)
                            Text(tool.rawValue)
                                .font(.caption2)
                        }
                        .frame(width: 50, height: 50)
                        .background(
                            selectedTool == tool ?
                            Color.purple.opacity(0.3) :
                            Color.clear
                        )
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Editor Control Bar
struct EditorControlBar: View {
    @ObservedObject var undoManager: UndoRedoManager
    @ObservedObject var gridSystem: GridSystem
    @Binding var currentZoom: CGFloat
    let onFocus: () -> Void
    let onFit: () -> Void
    
    var body: some View {
        HStack {
            // Undo/Redo
            HStack(spacing: 4) {
                Button(action: { _ = undoManager.undo() }) {
                    Image(systemName: "arrow.uturn.backward")
                }
                .disabled(!undoManager.canUndo)
                
                Button(action: { _ = undoManager.redo() }) {
                    Image(systemName: "arrow.uturn.forward")
                }
                .disabled(!undoManager.canRedo)
            }
            
            Divider()
                .frame(height: 20)
            
            // Grid Controls
            HStack(spacing: 4) {
                Toggle(isOn: $gridSystem.showGrid) {
                    Image(systemName: "grid")
                }
                .toggleStyle(.button)
                
                Toggle(isOn: $gridSystem.showGuides) {
                    Image(systemName: "ruler")
                }
                .toggleStyle(.button)
                
                Toggle(isOn: $gridSystem.snapToGrid) {
                    Image(systemName: "circle.grid.3x3.fill")
                }
                .toggleStyle(.button)
            }
            
            Divider()
                .frame(height: 20)
            
            // Symmetry Mode
            Menu {
                ForEach(GridSystem.SymmetryMode.allCases, id: \.self) { mode in
                    Button(action: { gridSystem.symmetryMode = mode }) {
                        HStack {
                            Text(mode.rawValue)
                            if gridSystem.symmetryMode == mode {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "arrow.left.and.right")
            }
            
            // Overlays menu
            Menu {
                Toggle(isOn: $gridSystem.showHatOverlay) {
                    Label("Hat", systemImage: "graduationcap")
                }
                Toggle(isOn: $gridSystem.showJacketOverlay) {
                    Label("Jacket", systemImage: "tshirt")
                }
                Toggle(isOn: $gridSystem.showSleevesOverlay) {
                    Label("Sleeves", systemImage: "hand.raised")
                }
                Toggle(isOn: $gridSystem.showPantsOverlay) {
                    Label("Pants", systemImage: "figure.walk")
                }
            } label: {
                Image(systemName: "rectangle.on.rectangle.angled")
            }
            
            // Focus button when a single part is isolated
            if gridSystem.isolatedParts.count == 1 {
                Button(action: onFocus) {
                    Label("Focus", systemImage: "scope")
                }
            }

            Divider().frame(height: 20)
            // Layer visibility
            Picker("Layers", selection: Binding<DisplayLayers>(
                get: {
                    if gridSystem.showBase && gridSystem.showOverlay { return .both }
                    else if gridSystem.showOverlay { return .overlay }
                    else { return .base }
                },
                set: { sel in
                    gridSystem.showBase = (sel == .base || sel == .both)
                    gridSystem.showOverlay = (sel == .overlay || sel == .both)
                }
            )) {
                Text("Base").tag(DisplayLayers.base)
                Text("Overlay").tag(DisplayLayers.overlay)
                Text("Both").tag(DisplayLayers.both)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 260)

            Spacer()

            // Fit button
            Button(action: onFit) {
                Label("Fit", systemImage: "arrow.up.left.and.arrow.down.right")
            }

            // Zoom Controls
            HStack {
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
        }
        .padding(.horizontal)
    }
}

private enum DisplayLayers: Hashable { case base, overlay, both }

// MARK: - Body Part Selector
struct BodyPartSelector: View {
    @ObservedObject var gridSystem: GridSystem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Isolate Parts")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(BodyPart.allCases, id: \.self) { part in
                    Toggle(isOn: Binding(
                        get: { gridSystem.isolatedParts.contains(part) },
                        set: { isOn in
                            if isOn {
                                gridSystem.isolatedParts.insert(part)
                            } else {
                                gridSystem.isolatedParts.remove(part)
                            }
                        }
                    )) {
                        HStack {
                            Circle()
                                .fill(part.color)
                                .frame(width: 8, height: 8)
                            Text(part.rawValue)
                                .font(.caption)
                        }
                    }
                    .toggleStyle(.button)
                    .buttonStyle(.bordered)
                }
            }
        }
    }
}

// MARK: - Export View
struct ExportView: View {
    @ObservedObject var exportManager: ExportManager
    let skin: CharacterSkin
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFormat: ExportManager.ExportFormat = .png64x64
    @State private var exportMessage: String?
    @State private var showingAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Format") {
                    Picker("Export Format", selection: $selectedFormat) {
                        Text("Standard (64x64)").tag(ExportManager.ExportFormat.png64x64)
                        Text("Legacy (64x32)").tag(ExportManager.ExportFormat.png64x32)
                        Text("HD Bedrock (128x128)").tag(ExportManager.ExportFormat.png128x128)
                        Text("Minecraft Ready").tag(ExportManager.ExportFormat.minecraftReady)
                    }
                }
                
                Section("Export To") {
                    Button(action: { exportTo(.photoLibrary) }) {
                        Label("Save to Photos", systemImage: "photo")
                    }
                    
                    Button(action: { exportTo(.files) }) {
                        Label("Save to Files", systemImage: "folder")
                    }
                    
                    Button(action: { exportTo(.airdrop) }) {
                        Label("AirDrop", systemImage: "wifi")
                    }
                    
                    Button(action: { exportTo(.minecraft) }) {
                        Label("Open in Minecraft", systemImage: "gamecontroller")
                    }
                    
                    Button(action: { exportTo(.share) }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
                
                if exportManager.isExporting {
                    Section {
                        HStack {
                            ProgressView(value: exportManager.exportProgress)
                            Text("Exporting...")
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Export Skin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Export Result", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(exportMessage ?? "")
            }
        }
    }
    
    private func exportTo(_ destination: ExportManager.ExportDestination) {
        exportManager.exportSkin(
            skin,
            format: selectedFormat,
            destination: destination
        ) { success, message in
            exportMessage = message
            showingAlert = true
            if success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    ProfessionalEditorView()
        .environmentObject(SkinManager())
}
