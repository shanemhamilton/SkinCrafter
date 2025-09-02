import SwiftUI
import SceneKit

// MARK: - Body Part Definition

// MARK: - Guided Creation View
struct GuidedCreationView: View {
    @EnvironmentObject var skinManager: SkinManager
    @StateObject private var flowState = GuidedFlowState()
    @State private var showingExport = false
    @State private var selectedColor: Color = .blue
    @State private var enableMirroring = true
    @State private var showingSkipDialog = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.purple.opacity(0.15), Color.blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress Header (8% height)
                    GuidedProgressHeader(
                        flowState: flowState,
                        showingSkipDialog: $showingSkipDialog
                    )
                    .frame(height: geometry.size.height * 0.08)
                    .background(Color.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                    
                    // Main Content Area (72% height)
                    HStack(spacing: 20) {
                        // 3D Preview with focused body part (60% width)
                        FocusedBodyPartView(
                            currentPart: flowState.currentPart,
                            selectedColor: $selectedColor,
                            enableMirroring: $enableMirroring,
                            onPaint: {
                                flowState.markPartAsEdited(flowState.currentPart)
                                HapticManager.shared.lightImpact()
                            }
                        )
                        .frame(width: geometry.size.width * 0.6)
                        .padding()
                        
                        // Side Panel with mini preview and controls (40% width)
                        VStack(spacing: 20) {
                            // Mini full-body preview
                            MiniPreviewCard()
                                .frame(height: 200)
                            
                            // Body part navigation
                            BodyPartNavigator(
                                flowState: flowState,
                                currentPart: $flowState.currentPart
                            )
                            
                            // Mirroring toggle
                            if flowState.currentPart.mirrorPart != nil {
                                MirrorToggle(enabled: $enableMirroring)
                            }
                            
                            Spacer()
                        }
                        .frame(width: geometry.size.width * 0.35)
                        .padding()
                    }
                    .frame(height: geometry.size.height * 0.72)
                    
                    // Tool Panel (20% height)
                    GuidedToolPanel(
                        currentPart: flowState.currentPart,
                        selectedColor: $selectedColor,
                        enableMirroring: $enableMirroring
                    )
                    .frame(height: geometry.size.height * 0.20)
                    .background(Color.white.opacity(0.98))
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
                }
                
                // Completion celebration
                if flowState.isComplete {
                    CompletionCelebration(
                        onContinue: {
                            showingExport = true
                        }
                    )
                }
                
                // Skip to freeform dialog
                if showingSkipDialog {
                    SkipToFreeformDialog(
                        isShowing: $showingSkipDialog,
                        onSkip: {
                            // Transition to freeform mode
                            flowState.skipToFreeform()
                        }
                    )
                }
            }
        }
        .sheet(isPresented: $showingExport) {
            ExpressExportView()
        }
    }
}

// MARK: - Guided Flow State
class GuidedFlowState: ObservableObject {
    @Published var currentPart: BodyPart = .head
    @Published var editedParts: Set<BodyPart> = []
    @Published var isComplete = false
    @Published var isFreeformMode = false
    
    var progress: Double {
        Double(editedParts.count) / Double(BodyPart.allCases.count)
    }
    
    var currentPartIndex: Int {
        BodyPart.allCases.firstIndex(of: currentPart) ?? 0
    }
    
    func nextPart() {
        let allParts = BodyPart.allCases
        if let currentIndex = allParts.firstIndex(of: currentPart),
           currentIndex < allParts.count - 1 {
            currentPart = allParts[currentIndex + 1]
        } else {
            // Completed all parts
            isComplete = true
        }
    }
    
    func previousPart() {
        let allParts = BodyPart.allCases
        if let currentIndex = allParts.firstIndex(of: currentPart),
           currentIndex > 0 {
            currentPart = allParts[currentIndex - 1]
        }
    }
    
    func markPartAsEdited(_ part: BodyPart) {
        editedParts.insert(part)
        
        // Auto-advance after 2 seconds if this is the first edit
        if editedParts.count == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if !self.isFreeformMode {
                    self.nextPart()
                }
            }
        }
    }
    
    func skipToFreeform() {
        isFreeformMode = true
    }
}

// MARK: - Progress Header
struct GuidedProgressHeader: View {
    @ObservedObject var flowState: GuidedFlowState
    @Binding var showingSkipDialog: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            // Back button
            Button(action: { flowState.previousPart() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            .disabled(flowState.currentPartIndex == 0)
            .opacity(flowState.currentPartIndex == 0 ? 0.3 : 1)
            
            // Progress indicator
            HStack(spacing: 8) {
                ForEach(BodyPart.allCases, id: \.self) { part in
                    ProgressDot(
                        isActive: part == flowState.currentPart,
                        isCompleted: flowState.editedParts.contains(part)
                    )
                }
            }
            .padding(.horizontal, 20)
            
            // Current part label
            VStack(alignment: .leading, spacing: 4) {
                Text("Step \(flowState.currentPartIndex + 1) of 6")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Paint the \(flowState.currentPart.rawValue)")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Skip to freeform button
            Button(action: { showingSkipDialog = true }) {
                Text("Skip Tutorial")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Next button
            Button(action: { flowState.nextPart() }) {
                HStack {
                    Text(flowState.currentPartIndex == 5 ? "Finish" : "Next")
                    Image(systemName: "chevron.right")
                }
                .font(.title3.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .frame(height: 44)
                .background(
                    flowState.editedParts.contains(flowState.currentPart) ?
                    Color.green : Color.gray
                )
                .cornerRadius(12)
            }
            .disabled(!flowState.editedParts.contains(flowState.currentPart))
        }
        .padding(.horizontal)
    }
}

// MARK: - Progress Dot
struct ProgressDot: View {
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        Circle()
            .fill(
                isCompleted ? Color.green :
                isActive ? Color.purple :
                Color.gray.opacity(0.3)
            )
            .frame(width: isActive ? 12 : 8, height: isActive ? 12 : 8)
            .overlay(
                isCompleted ?
                Image(systemName: "checkmark")
                    .font(.system(size: 6))
                    .foregroundColor(.white)
                : nil
            )
            .animation(.spring(response: 0.3), value: isActive)
            .animation(.spring(response: 0.3), value: isCompleted)
    }
}

// MARK: - Body Part Navigator
struct BodyPartNavigator: View {
    @ObservedObject var flowState: GuidedFlowState
    @Binding var currentPart: BodyPart
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Body Parts")
                .font(.headline)
                .foregroundColor(.gray)
            
            ForEach(BodyPart.allCases, id: \.self) { part in
                BodyPartRow(
                    part: part,
                    isActive: part == currentPart,
                    isCompleted: flowState.editedParts.contains(part),
                    action: {
                        currentPart = part
                        HapticManager.shared.selectionChanged()
                    }
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(15)
    }
}

// MARK: - Body Part Row
struct BodyPartRow: View {
    let part: BodyPart
    let isActive: Bool
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: part.icon)
                    .font(.title3)
                    .foregroundColor(isActive ? .white : .primary)
                    .frame(width: 30)
                
                Text(part.rawValue)
                    .font(.body)
                    .foregroundColor(isActive ? .white : .primary)
                
                Spacer()
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(isActive ? .white : .green)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isActive ? Color.purple : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Mirror Toggle
struct MirrorToggle: View {
    @Binding var enabled: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "arrow.left.and.right")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text("Mirror Mode")
                    .font(.headline)
                
                Spacer()
                
                Toggle("", isOn: $enabled)
                    .labelsHidden()
                    .tint(.purple)
            }
            
            Text(enabled ? "Changes will apply to both sides" : "Paint each side separately")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.purple.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Mini Preview Card
struct MiniPreviewCard: View {
    @EnvironmentObject var skinManager: SkinManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Full Preview")
                .font(.caption)
                .foregroundColor(.gray)
            
            Skin3DPreview()
                .background(
                    CheckerboardPattern()
                        .opacity(0.1)
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

// MARK: - Guided Tool Panel
struct GuidedToolPanel: View {
    let currentPart: BodyPart
    @Binding var selectedColor: Color
    @Binding var enableMirroring: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Suggested colors for current body part
            VStack(alignment: .leading, spacing: 8) {
                Text("Suggested Colors for \(currentPart.rawValue)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(currentPart.suggestedColors.enumerated()), id: \.offset) { index, color in
                            ColorButton(
                                color: color,
                                isSelected: selectedColor == color,
                                action: {
                                    selectedColor = color
                                    HapticManager.shared.lightImpact()
                                }
                            )
                        }
                        
                        Divider()
                            .frame(height: 40)
                            .padding(.horizontal, 8)
                        
                        // Additional colors
                        ForEach([Color.yellow, .cyan, .mint, .indigo], id: \.description) { color in
                            ColorButton(
                                color: color,
                                isSelected: selectedColor == color,
                                action: {
                                    selectedColor = color
                                    HapticManager.shared.lightImpact()
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Quick actions
            HStack(spacing: 16) {
                QuickActionButton(
                    icon: "paintbrush.fill",
                    label: "Fill Part",
                    color: .blue,
                    action: {
                        fillCurrentPart()
                    }
                )
                
                QuickActionButton(
                    icon: "eraser.fill",
                    label: "Clear Part",
                    color: .red,
                    action: {
                        clearCurrentPart()
                    }
                )
                
                QuickActionButton(
                    icon: "sparkles",
                    label: "Random",
                    color: .purple,
                    action: {
                        randomizeCurrentPart()
                    }
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    private func fillCurrentPart() {
        // Implementation for filling the current body part
        HapticManager.shared.success()
    }
    
    private func clearCurrentPart() {
        // Implementation for clearing the current body part
        HapticManager.shared.lightImpact()
    }
    
    private func randomizeCurrentPart() {
        // Implementation for randomizing the current body part
        HapticManager.shared.success()
    }
}

// MARK: - Color Button
struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(
                            isSelected ? Color.black : Color.gray.opacity(0.3),
                            lineWidth: isSelected ? 3 : 1
                        )
                )
                .scaleEffect(isSelected ? 1.15 : 1.0)
                .shadow(color: isSelected ? color.opacity(0.4) : .clear, radius: 4)
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.08))
            .cornerRadius(12)
        }
    }
}

// MARK: - Completion Celebration
struct CompletionCelebration: View {
    let onContinue: () -> Void
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .scaleEffect(scale)
                
                Text("Amazing Work!")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text("You've completed your first skin!")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                
                HStack(spacing: 20) {
                    Button(action: onContinue) {
                        Label("Save Skin", systemImage: "square.and.arrow.down")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 150)
                            .background(Color.green)
                            .cornerRadius(15)
                    }
                    
                    Button(action: { /* Continue editing */ }) {
                        Text("Keep Editing")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 150)
                            .background(Color.purple)
                            .cornerRadius(15)
                    }
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

// MARK: - Skip Dialog
struct SkipToFreeformDialog: View {
    @Binding var isShowing: Bool
    let onSkip: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isShowing = false
                }
            
            VStack(spacing: 20) {
                Text("Skip Tutorial?")
                    .font(.title2.bold())
                
                Text("You can always come back to the guided mode later")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 20) {
                    Button(action: {
                        isShowing = false
                    }) {
                        Text("Continue Tutorial")
                            .frame(width: 140)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        onSkip()
                        isShowing = false
                    }) {
                        Text("Skip")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 140)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(30)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 20)
            .frame(maxWidth: 400)
        }
    }
}

// MARK: - Checkerboard Pattern
struct CheckerboardPattern: View {
    let squareSize: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let columns = Int(geometry.size.width / squareSize)
                let rows = Int(geometry.size.height / squareSize)
                
                for row in 0..<rows {
                    for col in 0..<columns {
                        if (row + col) % 2 == 0 {
                            let rect = CGRect(
                                x: CGFloat(col) * squareSize,
                                y: CGFloat(row) * squareSize,
                                width: squareSize,
                                height: squareSize
                            )
                            path.addRect(rect)
                        }
                    }
                }
            }
            .fill(Color.gray.opacity(0.2))
        }
    }
}