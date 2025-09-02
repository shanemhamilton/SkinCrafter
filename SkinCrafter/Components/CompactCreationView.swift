import SwiftUI
import SceneKit

// MARK: - Compact Creation View (iPhone)
struct CompactCreationView: View {
    @ObservedObject var flowState: AdaptiveFlowState
    @EnvironmentObject var skinManager: SkinManager
    @State private var dragOffset: CGSize = .zero
    @State private var showToolSheet = false
    @State private var showColorPicker = false
    @State private var canvasScale: CGFloat = 1.0
    @State private var canvasRotation: Angle = .zero
    
    var body: some View {
        ZStack {
            // Clean background
            CleanDesignSystem.background
                .ignoresSafeArea()
            
            // Fullscreen 3D Canvas (80% of screen)
            Enhanced3DCanvas(
                flowState: flowState,
                canvasScale: $canvasScale,
                canvasRotation: $canvasRotation
            )
            .ignoresSafeArea(edges: .top)
            .gesture(swipeGesture)
            .gesture(pinchGesture)
            
            // Overlay UI Elements
            VStack {
                // Top Bar
                CompactTopBar(flowState: flowState)
                    .background(.ultraThinMaterial)
                
                Spacer()
                
                // Bottom Controls
                VStack(spacing: 0) {
                    // Current Part Indicator
                    CurrentPartPill(flowState: flowState)
                        .padding(.bottom, CleanDesignSystem.spacing16)
                    
                    // Floating Action Buttons
                    CompactFloatingActions(
                        flowState: flowState,
                        showToolSheet: $showToolSheet,
                        showColorPicker: $showColorPicker
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, CleanDesignSystem.spacing32)
            }
            
            // Tool Sheet (Bottom Sheet)
            if showToolSheet {
                CompactToolSheet(
                    flowState: flowState,
                    isShowing: $showToolSheet
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
            
            // Color Picker Sheet
            if showColorPicker {
                CompactColorPicker(
                    flowState: flowState,
                    isShowing: $showColorPicker
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
            
            // Completion Celebration
            if flowState.isComplete {
                CompletionCelebrationView(flowState: flowState)
            }
        }
        .statusBarHidden(true)
    }
    
    // MARK: - Gestures
    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                let horizontalAmount = value.translation.width
                let verticalAmount = value.translation.height
                
                withAnimation(CleanDesignSystem.standardSpring) {
                    if abs(horizontalAmount) > abs(verticalAmount) {
                        // Horizontal swipe - navigate parts
                        if horizontalAmount < -50 && flowState.hasNextPart {
                            flowState.nextPart()
                        } else if horizontalAmount > 50 && flowState.hasPreviousPart {
                            flowState.previousPart()
                        }
                    } else {
                        // Vertical swipe - show/hide tools
                        if verticalAmount < -50 {
                            showToolSheet = true
                        } else if verticalAmount > 50 {
                            showToolSheet = false
                        }
                    }
                    dragOffset = .zero
                }
            }
    }
    
    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                canvasScale = value
            }
            .onEnded { _ in
                withAnimation(CleanDesignSystem.quickSpring) {
                    canvasScale = 1.0
                }
            }
    }
}

// MARK: - Compact Top Bar
struct CompactTopBar: View {
    @ObservedObject var flowState: AdaptiveFlowState
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack {
            // Back Button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Progress Indicator
            CompactProgressIndicator(progress: flowState.progress)
            
            Spacer()
            
            // Skip Tutorial
            Button(action: { flowState.completeFlow() }) {
                Text("Skip")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, CleanDesignSystem.spacing12)
    }
}

// MARK: - Compact Progress Indicator
struct CompactProgressIndicator: View {
    let progress: Double
    
    var body: some View {
        HStack(spacing: CleanDesignSystem.spacing8) {
            ForEach(BodyPart.allCases, id: \.self) { part in
                Circle()
                    .fill(progressColor(for: part))
                    .frame(width: 8, height: 8)
                    .animation(CleanDesignSystem.quickSpring, value: progress)
            }
        }
        .padding(.horizontal, CleanDesignSystem.spacing16)
        .padding(.vertical, CleanDesignSystem.spacing8)
        .background(Capsule().fill(.regularMaterial))
    }
    
    private func progressColor(for part: BodyPart) -> Color {
        let index = BodyPart.allCases.firstIndex(of: part) ?? 0
        let currentProgress = Int(progress * Double(BodyPart.allCases.count))
        
        if index < currentProgress {
            return CleanDesignSystem.success
        } else if index == currentProgress {
            return CleanDesignSystem.accent
        } else {
            return Color(.tertiaryLabel)
        }
    }
}

// MARK: - Current Part Pill
struct CurrentPartPill: View {
    @ObservedObject var flowState: AdaptiveFlowState
    
    var body: some View {
        HStack(spacing: CleanDesignSystem.spacing12) {
            Image(systemName: flowState.currentPart.icon)
                .font(.title3)
                .foregroundStyle(CleanDesignSystem.accent)
            
            Text(flowState.currentPart.rawValue)
                .font(.headline)
            
            if flowState.editedParts.contains(flowState.currentPart) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(CleanDesignSystem.success)
            }
        }
        .padding(.horizontal, CleanDesignSystem.spacing20)
        .padding(.vertical, CleanDesignSystem.spacing12)
        .background(.regularMaterial)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
    }
}

// MARK: - Compact Floating Actions
struct CompactFloatingActions: View {
    @ObservedObject var flowState: AdaptiveFlowState
    @Binding var showToolSheet: Bool
    @Binding var showColorPicker: Bool
    
    var body: some View {
        HStack(spacing: CleanDesignSystem.spacing20) {
            // Previous Part
            FloatingActionButton(
                icon: "chevron.left",
                isEnabled: flowState.hasPreviousPart,
                action: { flowState.previousPart() }
            )
            
            // Color Picker
            FloatingActionButton(
                icon: "paintpalette.fill",
                color: flowState.selectedColor,
                action: { 
                    withAnimation(CleanDesignSystem.standardSpring) {
                        showColorPicker.toggle()
                    }
                }
            )
            
            // Main Paint Button (Largest)
            Button(action: {
                withAnimation(CleanDesignSystem.standardSpring) {
                    showToolSheet.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [CleanDesignSystem.accent, CleanDesignSystem.accent.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: CleanDesignSystem.largeTouchTarget, height: CleanDesignSystem.largeTouchTarget)
                    
                    Image(systemName: "paintbrush.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                }
            }
            .shadow(color: CleanDesignSystem.accent.opacity(0.3), radius: 12, y: 6)
            
            // Tools
            FloatingActionButton(
                icon: "slider.horizontal.3",
                action: {
                    withAnimation(CleanDesignSystem.standardSpring) {
                        showToolSheet.toggle()
                    }
                }
            )
            
            // Next Part
            FloatingActionButton(
                icon: "chevron.right",
                isEnabled: flowState.hasNextPart,
                action: { flowState.nextPart() }
            )
        }
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let icon: String
    var color: Color = CleanDesignSystem.secondaryBackground
    var isEnabled: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(isEnabled ? CleanDesignSystem.label : .tertiary)
                .frame(width: CleanDesignSystem.standardTouchTarget, height: CleanDesignSystem.standardTouchTarget)
                .background(
                    Circle()
                        .fill(color == CleanDesignSystem.secondaryBackground ? .regularMaterial : color.opacity(0.2))
                        .overlay(
                            Circle()
                                .strokeBorder(color == CleanDesignSystem.secondaryBackground ? Color.clear : color, lineWidth: 2)
                        )
                )
        }
        .disabled(!isEnabled)
        .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
    }
}

// MARK: - Compact Tool Sheet
struct CompactToolSheet: View {
    @ObservedObject var flowState: AdaptiveFlowState
    @Binding var isShowing: Bool
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color(.tertiaryLabel))
                .frame(width: 40, height: 4)
                .padding(.top, CleanDesignSystem.spacing8)
                .padding(.bottom, CleanDesignSystem.spacing16)
            
            // Quick Actions
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CleanDesignSystem.spacing16) {
                    QuickActionChip(icon: "paintbrush.fill", label: "Fill", color: .blue) {
                        fillCurrentPart()
                    }
                    
                    QuickActionChip(icon: "eraser.fill", label: "Clear", color: .red) {
                        clearCurrentPart()
                    }
                    
                    QuickActionChip(icon: "sparkles", label: "Random", color: .purple) {
                        randomizeCurrentPart()
                    }
                    
                    QuickActionChip(icon: "arrow.left.and.right", label: "Mirror", color: .green, isToggle: true, isOn: flowState.enableMirroring) {
                        flowState.toggleMirroring()
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, CleanDesignSystem.spacing16)
            
            // Brush Size Slider
            VStack(alignment: .leading, spacing: CleanDesignSystem.spacing8) {
                Text("Brush Size")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                
                HStack {
                    Image(systemName: "scribble")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Slider(value: $flowState.brushSize, in: 1...5, step: 1)
                        .tint(CleanDesignSystem.accent)
                    
                    Text("\(Int(flowState.brushSize))")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 30)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, CleanDesignSystem.spacing24)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius20, style: .continuous)
                .fill(.regularMaterial)
                .ignoresSafeArea()
        )
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height > 0 {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height > 100 {
                        withAnimation(CleanDesignSystem.standardSpring) {
                            isShowing = false
                        }
                    } else {
                        withAnimation(CleanDesignSystem.quickSpring) {
                            dragOffset = 0
                        }
                    }
                }
        )
    }
    
    private func fillCurrentPart() {
        flowState.markPartAsEdited(flowState.currentPart)
        HapticManager.shared.success()
    }
    
    private func clearCurrentPart() {
        flowState.resetPart()
        HapticManager.shared.lightImpact()
    }
    
    private func randomizeCurrentPart() {
        flowState.selectColor(flowState.currentPart.suggestedColors.randomElement() ?? .blue)
        flowState.markPartAsEdited(flowState.currentPart)
        HapticManager.shared.success()
    }
}

// MARK: - Quick Action Chip
struct QuickActionChip: View {
    let icon: String
    let label: String
    let color: Color
    var isToggle: Bool = false
    var isOn: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: CleanDesignSystem.spacing8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isToggle && isOn ? .white : color)
                
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(isToggle && isOn ? .white : .primary)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius16, style: .continuous)
                    .fill(isToggle && isOn ? color : Color(.tertiarySystemBackground))
            )
        }
    }
}

// MARK: - Compact Color Picker
struct CompactColorPicker: View {
    @ObservedObject var flowState: AdaptiveFlowState
    @Binding var isShowing: Bool
    
    let suggestedColors: [Color]
    let standardColors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal,
        .cyan, .blue, .indigo, .purple, .pink, .brown
    ]
    
    init(flowState: AdaptiveFlowState, isShowing: Binding<Bool>) {
        self.flowState = flowState
        self._isShowing = isShowing
        self.suggestedColors = flowState.currentPart.suggestedColors
    }
    
    var body: some View {
        VStack(spacing: CleanDesignSystem.spacing20) {
            // Handle
            Capsule()
                .fill(Color(.tertiaryLabel))
                .frame(width: 40, height: 4)
                .padding(.top, CleanDesignSystem.spacing8)
            
            // Suggested Colors
            VStack(alignment: .leading, spacing: CleanDesignSystem.spacing12) {
                Text("Suggested for \(flowState.currentPart.rawValue)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: CleanDesignSystem.spacing12), count: 6), spacing: CleanDesignSystem.spacing12) {
                    ForEach(suggestedColors.indices, id: \.self) { index in
                        ColorSwatch(
                            color: suggestedColors[index],
                            isSelected: flowState.selectedColor == suggestedColors[index],
                            action: {
                                flowState.selectColor(suggestedColors[index])
                                withAnimation(CleanDesignSystem.quickSpring) {
                                    isShowing = false
                                }
                            }
                        )
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // All Colors
            VStack(alignment: .leading, spacing: CleanDesignSystem.spacing12) {
                Text("All Colors")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: CleanDesignSystem.spacing12), count: 6), spacing: CleanDesignSystem.spacing12) {
                    ForEach(standardColors.indices, id: \.self) { index in
                        ColorSwatch(
                            color: standardColors[index],
                            isSelected: flowState.selectedColor == standardColors[index],
                            action: {
                                flowState.selectColor(standardColors[index])
                                withAnimation(CleanDesignSystem.quickSpring) {
                                    isShowing = false
                                }
                            }
                        )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, CleanDesignSystem.spacing32)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius20, style: .continuous)
                .fill(.regularMaterial)
                .ignoresSafeArea()
        )
    }
}

// MARK: - Color Swatch
struct ColorSwatch: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius12, style: .continuous)
                .fill(color)
                .frame(height: CleanDesignSystem.standardTouchTarget)
                .overlay(
                    RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius12, style: .continuous)
                        .strokeBorder(isSelected ? Color.primary : Color.clear, lineWidth: 3)
                )
                .overlay(
                    isSelected ?
                    Image(systemName: "checkmark")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                    : nil
                )
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(CleanDesignSystem.quickSpring, value: isSelected)
    }
}