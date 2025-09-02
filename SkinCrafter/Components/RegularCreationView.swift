import SwiftUI
import SceneKit

// MARK: - Regular Creation View (iPad)
struct RegularCreationView: View {
    @ObservedObject var flowState: AdaptiveFlowState
    @EnvironmentObject var skinManager: SkinManager
    @State private var sidebarWidth: CGFloat = 320
    @State private var showingColorPanel = false
    @State private var showingToolPanel = false
    @State private var canvasScale: CGFloat = 1.0
    @State private var canvasRotation: Angle = .zero
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Main Canvas Area (60%)
                VStack(spacing: 0) {
                    // Top Toolbar
                    RegularTopToolbar(flowState: flowState)
                        .frame(height: 60)
                        .background(.regularMaterial)
                        .overlay(alignment: .bottom) {
                            Divider()
                        }
                    
                    // 3D Canvas
                    Enhanced3DCanvas(
                        flowState: flowState,
                        canvasScale: $canvasScale,
                        canvasRotation: $canvasRotation
                    )
                    .background(
                        RadialGradient(
                            colors: [
                                Color(.systemBackground),
                                Color(.secondarySystemBackground)
                            ],
                            center: .center,
                            startRadius: 100,
                            endRadius: 500
                        )
                    )
                    
                    // Bottom Tool Palette
                    RegularToolPalette(
                        flowState: flowState,
                        showingColorPanel: $showingColorPanel,
                        showingToolPanel: $showingToolPanel
                    )
                    .frame(height: 120)
                    .background(.regularMaterial)
                    .overlay(alignment: .top) {
                        Divider()
                    }
                }
                .frame(width: geometry.size.width - sidebarWidth)
                
                // Divider with resize handle
                ResizableDivider(width: $sidebarWidth, totalWidth: geometry.size.width)
                
                // Sidebar (40%)
                RegularSidebar(flowState: flowState)
                    .frame(width: sidebarWidth)
                    .background(Color(.secondarySystemBackground))
            }
            
            // Floating Panels
            .overlay(alignment: .topTrailing) {
                if showingColorPanel {
                    FloatingColorPanel(flowState: flowState, isShowing: $showingColorPanel)
                        .frame(width: 400, height: 500)
                        .offset(x: -20, y: 80)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if showingToolPanel {
                    FloatingToolPanel(flowState: flowState, isShowing: $showingToolPanel)
                        .frame(width: 360, height: 400)
                        .offset(x: -20, y: -140)
                }
            }
            
            // Completion Overlay
            .overlay {
                if flowState.isComplete {
                    CompletionCelebrationView(flowState: flowState)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Regular Top Toolbar
struct RegularTopToolbar: View {
    @ObservedObject var flowState: AdaptiveFlowState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack(spacing: CleanDesignSystem.spacing20) {
            // Navigation
            HStack(spacing: CleanDesignSystem.spacing12) {
                Button(action: { dismiss() }) {
                    Label("Back", systemImage: "chevron.left")
                        .labelStyle(.iconOnly)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                Button(action: { flowState.previousPart() }) {
                    Image(systemName: "arrow.left")
                        .font(.title3)
                        .foregroundStyle(flowState.hasPreviousPart ? .primary : .tertiary)
                }
                .disabled(!flowState.hasPreviousPart)
                
                Button(action: { flowState.nextPart() }) {
                    Image(systemName: "arrow.right")
                        .font(.title3)
                        .foregroundStyle(flowState.hasNextPart ? .primary : .tertiary)
                }
                .disabled(!flowState.hasNextPart)
            }
            
            // Progress Bar
            ProgressBarView(progress: flowState.progress)
                .frame(maxWidth: 300)
            
            Spacer()
            
            // Quick Actions
            HStack(spacing: CleanDesignSystem.spacing12) {
                Button(action: { /* Undo */ }) {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                        .labelStyle(.iconOnly)
                        .font(.title3)
                }
                
                Button(action: { /* Redo */ }) {
                    Label("Redo", systemImage: "arrow.uturn.forward")
                        .labelStyle(.iconOnly)
                        .font(.title3)
                }
                
                Divider()
                    .frame(height: 30)
                
                Button(action: { flowState.showingExport = true }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, CleanDesignSystem.spacing12)
                        .padding(.vertical, CleanDesignSystem.spacing8)
                        .background(CleanDesignSystem.accent)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, CleanDesignSystem.spacing20)
    }
}

// MARK: - Progress Bar View
struct ProgressBarView: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Capsule()
                    .fill(Color(.tertiarySystemFill))
                    .frame(height: 8)
                
                // Progress
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [CleanDesignSystem.accent, CleanDesignSystem.success],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 8)
                    .animation(CleanDesignSystem.smoothSpring, value: progress)
            }
        }
        .frame(height: 8)
    }
}

// MARK: - Regular Sidebar
struct RegularSidebar: View {
    @ObservedObject var flowState: AdaptiveFlowState
    
    var body: some View {
        ScrollView {
            VStack(spacing: CleanDesignSystem.spacing24) {
                // Character Preview
                CharacterPreviewCard()
                    .frame(height: 300)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Body Parts Navigator
                BodyPartsList(flowState: flowState)
                    .padding(.horizontal)
                
                // Quick Settings
                QuickSettingsCard(flowState: flowState)
                    .padding(.horizontal)
                
                // Tips & Hints
                TipsCard(for: flowState.currentPart)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
    }
}

// MARK: - Character Preview Card
struct CharacterPreviewCard: View {
    @EnvironmentObject var skinManager: SkinManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: CleanDesignSystem.spacing12) {
            HStack {
                Text("Full Preview")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button(action: { /* Reset view */ }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 3D Preview
            Skin3DPreview()
                .background(
                    RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius16, style: .continuous)
                        .fill(Color(.tertiarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius16, style: .continuous)
                        .strokeBorder(Color(.separator), lineWidth: 1)
                )
        }
    }
}

// MARK: - Body Parts List
struct BodyPartsList: View {
    @ObservedObject var flowState: AdaptiveFlowState
    
    var body: some View {
        VStack(alignment: .leading, spacing: CleanDesignSystem.spacing12) {
            Text("Body Parts")
                .font(.headline)
                .foregroundStyle(.primary)
            
            VStack(spacing: CleanDesignSystem.spacing8) {
                ForEach(BodyPart.allCases, id: \.self) { part in
                    BodyPartListItem(
                        part: part,
                        isActive: flowState.currentPart == part,
                        isCompleted: flowState.editedParts.contains(part),
                        action: { flowState.selectPart(part) }
                    )
                }
            }
        }
    }
}

// MARK: - Body Part List Item
struct BodyPartListItem: View {
    let part: BodyPart
    let isActive: Bool
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: CleanDesignSystem.spacing16) {
                // Icon with background
                ZStack {
                    RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius8, style: .continuous)
                        .fill(isActive ? CleanDesignSystem.accent : Color(.tertiarySystemFill))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: part.icon)
                        .font(.title3)
                        .foregroundStyle(isActive ? .white : .secondary)
                }
                
                // Label
                VStack(alignment: .leading, spacing: 2) {
                    Text(part.rawValue)
                        .font(.subheadline.weight(isActive ? .semibold : .regular))
                        .foregroundStyle(isActive ? .primary : .secondary)
                    
                    if isCompleted {
                        Text("Completed")
                            .font(.caption)
                            .foregroundStyle(CleanDesignSystem.success)
                    }
                }
                
                Spacer()
                
                // Status indicator
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(CleanDesignSystem.success)
                } else if isActive {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                        .foregroundStyle(CleanDesignSystem.accent)
                }
            }
            .padding(CleanDesignSystem.spacing12)
            .background(
                RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius12, style: .continuous)
                    .fill(isActive ? CleanDesignSystem.accent.opacity(0.1) : Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius12, style: .continuous)
                    .strokeBorder(isActive ? CleanDesignSystem.accent : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quick Settings Card
struct QuickSettingsCard: View {
    @ObservedObject var flowState: AdaptiveFlowState
    
    var body: some View {
        VStack(alignment: .leading, spacing: CleanDesignSystem.spacing16) {
            Text("Quick Settings")
                .font(.headline)
                .foregroundStyle(.primary)
            
            // Mirror Mode Toggle
            Toggle(isOn: $flowState.enableMirroring) {
                Label("Mirror Mode", systemImage: "arrow.left.and.right")
                    .font(.subheadline)
            }
            .tint(CleanDesignSystem.accent)
            
            // Brush Size
            VStack(alignment: .leading, spacing: CleanDesignSystem.spacing8) {
                HStack {
                    Text("Brush Size")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(flowState.brushSize))px")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.primary)
                }
                
                Slider(value: $flowState.brushSize, in: 1...10, step: 1)
                    .tint(CleanDesignSystem.accent)
            }
        }
        .padding(CleanDesignSystem.spacing16)
        .background(
            RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius12, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }
}

// MARK: - Tips Card
struct TipsCard: View {
    let part: BodyPart
    
    var tips: [String] {
        switch part {
        case .head:
            return [
                "Start with the skin tone",
                "Add eyes and mouth details",
                "Don't forget the hair!"
            ]
        case .body:
            return [
                "Design a shirt or outfit",
                "Add logos or patterns",
                "Use contrasting colors"
            ]
        case .leftArm, .rightArm:
            return [
                "Match the torso design",
                "Consider sleeves length",
                "Mirror mode saves time"
            ]
        case .leftLeg, .rightLeg:
            return [
                "Design pants or shorts",
                "Add shoe details",
                "Use darker colors for depth"
            ]
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: CleanDesignSystem.spacing12) {
            Label("Tips for \(part.rawValue)", systemImage: "lightbulb.fill")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.orange)
            
            ForEach(tips.indices, id: \.self) { index in
                HStack(alignment: .top, spacing: CleanDesignSystem.spacing8) {
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text(tips[index])
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(CleanDesignSystem.spacing16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius12, style: .continuous)
                .fill(Color.orange.opacity(0.1))
        )
    }
}

// MARK: - Regular Tool Palette
struct RegularToolPalette: View {
    @ObservedObject var flowState: AdaptiveFlowState
    @Binding var showingColorPanel: Bool
    @Binding var showingToolPanel: Bool
    
    var body: some View {
        HStack(spacing: CleanDesignSystem.spacing32) {
            // Color Preview & Picker
            HStack(spacing: CleanDesignSystem.spacing16) {
                // Current Color
                VStack(spacing: CleanDesignSystem.spacing8) {
                    Text("Color")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Button(action: { showingColorPanel.toggle() }) {
                        RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius12, style: .continuous)
                            .fill(flowState.selectedColor)
                            .frame(width: 60, height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius12, style: .continuous)
                                    .strokeBorder(Color.primary.opacity(0.2), lineWidth: 2)
                            )
                    }
                }
                
                // Quick Color Palette
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: CleanDesignSystem.spacing12) {
                        ForEach(flowState.currentPart.suggestedColors.indices, id: \.self) { index in
                            ColorCircle(
                                color: flowState.currentPart.suggestedColors[index],
                                isSelected: flowState.selectedColor == flowState.currentPart.suggestedColors[index],
                                action: {
                                    flowState.selectColor(flowState.currentPart.suggestedColors[index])
                                }
                            )
                        }
                    }
                }
                .frame(maxWidth: 400)
            }
            
            Divider()
                .frame(height: 60)
            
            // Quick Tools
            HStack(spacing: CleanDesignSystem.spacing16) {
                ToolButton(icon: "paintbrush.fill", label: "Paint", isActive: true) {
                    showingToolPanel.toggle()
                }
                
                ToolButton(icon: "eraser.fill", label: "Erase") {
                    // Erase action
                }
                
                ToolButton(icon: "eyedropper", label: "Pick") {
                    // Color picker action
                }
                
                ToolButton(icon: "square.grid.3x3", label: "Grid") {
                    // Toggle grid
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: CleanDesignSystem.spacing12) {
                Button(action: { /* Fill */ }) {
                    Label("Fill Part", systemImage: "paintbrush.fill")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, CleanDesignSystem.spacing16)
                        .padding(.vertical, CleanDesignSystem.spacing8)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(Capsule())
                }
                
                Button(action: { /* Clear */ }) {
                    Label("Clear", systemImage: "trash")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, CleanDesignSystem.spacing16)
                        .padding(.vertical, CleanDesignSystem.spacing8)
                        .background(Color.red.opacity(0.1))
                        .foregroundStyle(.red)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, CleanDesignSystem.spacing24)
    }
}

// MARK: - Color Circle
struct ColorCircle: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .strokeBorder(isSelected ? Color.primary : Color.primary.opacity(0.2), lineWidth: isSelected ? 3 : 1)
                )
                .scaleEffect(isSelected ? 1.15 : 1.0)
        }
        .animation(CleanDesignSystem.quickSpring, value: isSelected)
    }
}

// MARK: - Tool Button
struct ToolButton: View {
    let icon: String
    let label: String
    var isActive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: CleanDesignSystem.spacing4) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isActive ? CleanDesignSystem.accent : .secondary)
                
                Text(label)
                    .font(.caption)
                    .foregroundStyle(isActive ? .primary : .secondary)
            }
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius12, style: .continuous)
                    .fill(isActive ? CleanDesignSystem.accent.opacity(0.1) : Color.clear)
            )
        }
    }
}

// MARK: - Resizable Divider
struct ResizableDivider: View {
    @Binding var width: CGFloat
    let totalWidth: CGFloat
    @State private var isDragging = false
    
    var body: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(width: 1)
            .overlay(
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 20)
                    .contentShape(Rectangle())
                    .cursor(.resizeLeftRight)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                let newWidth = width - value.translation.width
                                width = min(max(280, newWidth), totalWidth * 0.5)
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
            )
            .background(
                isDragging ?
                Color.accentColor.opacity(0.2)
                    .frame(width: 3)
                    .animation(CleanDesignSystem.quickSpring, value: isDragging)
                : nil
            )
    }
}

// MARK: - Floating Panels
struct FloatingColorPanel: View {
    @ObservedObject var flowState: AdaptiveFlowState
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Color Palette")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            
            // Color Grid
            ScrollView {
                VStack(spacing: CleanDesignSystem.spacing20) {
                    // Color wheel or grid implementation
                    ColorGrid(selectedColor: $flowState.selectedColor)
                        .padding()
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius16, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 20, y: 10)
    }
}

struct FloatingToolPanel: View {
    @ObservedObject var flowState: AdaptiveFlowState
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Tools")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { isShowing = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            
            // Tool Options
            ScrollView {
                VStack(alignment: .leading, spacing: CleanDesignSystem.spacing20) {
                    // Tool settings implementation
                    Text("Tool settings go here")
                        .padding()
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius16, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 20, y: 10)
    }
}

// MARK: - Color Grid
struct ColorGrid: View {
    @Binding var selectedColor: Color
    
    let colors: [[Color]] = [
        [.red, .orange, .yellow, .green, .mint, .teal],
        [.cyan, .blue, .indigo, .purple, .pink, .brown],
        [.gray, .gray2, .gray3, .gray4, .gray5, .gray6]
    ]
    
    var body: some View {
        VStack(spacing: CleanDesignSystem.spacing12) {
            ForEach(colors.indices, id: \.self) { row in
                HStack(spacing: CleanDesignSystem.spacing12) {
                    ForEach(colors[row].indices, id: \.self) { col in
                        ColorGridItem(
                            color: colors[row][col],
                            isSelected: selectedColor == colors[row][col],
                            action: {
                                selectedColor = colors[row][col]
                            }
                        )
                    }
                }
            }
        }
    }
}

struct ColorGridItem: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius8, style: .continuous)
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius8, style: .continuous)
                        .strokeBorder(isSelected ? Color.primary : Color.clear, lineWidth: 3)
                )
                .scaleEffect(isSelected ? 1.1 : 1.0)
        }
        .animation(CleanDesignSystem.quickSpring, value: isSelected)
    }
}

// Extension for cursor support on macOS Catalyst
extension View {
    func cursor(_ cursor: NSCursor) -> some View {
        self
    }
}

extension NSCursor {
    static let resizeLeftRight = NSCursor.resizeLeftRight
}