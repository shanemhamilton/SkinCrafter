import SwiftUI
import SceneKit

// MARK: - Mobile-Optimized Express Guided Flow
struct ExpressGuidedFlow: View {
    @EnvironmentObject var skinManager: SkinManager
    @StateObject private var flowState = GuidedFlowState()
    @State private var showingExport = false
    @State private var selectedColor: Color = .blue
    @State private var enableMirroring = true
    @State private var showMiniPreview = false
    @State private var showColorPicker = true
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            let isIPad = horizontalSizeClass == .regular
            
            VStack(spacing: 0) {
                // Simplified Header (60pt)
                ExpressHeader(
                    flowState: flowState,
                    showMiniPreview: $showMiniPreview
                )
                .frame(height: 60)
                .background(Color.white.opacity(0.98))
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                
                if isIPad {
                    // iPad Layout - Split View
                    HStack(spacing: 0) {
                        // 3D Canvas takes 70% of width
                        ZStack {
                            // Clean background
                            LinearGradient(
                                colors: [Color.purple.opacity(0.03), Color.blue.opacity(0.02)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            // Large 3D Model - Hero Element
                            Express3DPaintableCanvas(
                                selectedColor: $selectedColor,
                                currentPart: $flowState.currentPart,
                                enableMirroring: $enableMirroring,
                                flowState: flowState
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                            // Part name indicator overlay
                            VStack {
                                Spacer()
                                HStack {
                                    PartIndicator(part: flowState.currentPart)
                                        .padding()
                                    Spacer()
                                }
                            }
                        }
                        .frame(width: geometry.size.width * 0.7)
                        
                        // Controls Panel - 30% width
                        VStack(spacing: 0) {
                            // Body parts
                            ScrollView {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Body Parts")
                                        .font(.headline)
                                        .padding(.horizontal)
                                        .padding(.top)
                                    
                                    ForEach(BodyPart.allCases.filter { $0 != .hat && $0 != .jacket }, id: \.self) { part in
                                        Button(action: {
                                            flowState.currentPart = part
                                        }) {
                                            HStack {
                                                Image(systemName: part.iconName)
                                                    .frame(width: 30)
                                                Text(part.rawValue)
                                                Spacer()
                                                if flowState.editedParts.contains(part) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                }
                                            }
                                            .padding(.horizontal)
                                            .padding(.vertical, 12)
                                            .background(
                                                flowState.currentPart == part ?
                                                Color.purple.opacity(0.15) : Color.clear
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .frame(maxHeight: geometry.size.height * 0.4)
                            
                            Divider()
                            
                            // Colors
                            ScrollView {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Colors")
                                        .font(.headline)
                                        .padding(.horizontal)
                                        .padding(.top)
                                    
                                    // Mirror toggle
                                    if flowState.currentPart.mirrorPart != nil {
                                        Toggle("Mirror to \(flowState.currentPart.mirrorPart!.rawValue)", isOn: $enableMirroring)
                                            .padding(.horizontal)
                                            .tint(.purple)
                                    }
                                    
                                    // Color grid
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 12) {
                                        ForEach(flowState.currentPart.suggestedColors, id: \.description) { color in
                                            Button(action: { selectedColor = color }) {
                                                Circle()
                                                    .fill(color)
                                                    .frame(width: 44, height: 44)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(
                                                                selectedColor == color ? Color.purple : Color.gray.opacity(0.3),
                                                                lineWidth: selectedColor == color ? 3 : 1
                                                            )
                                                    )
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .frame(width: geometry.size.width * 0.3)
                        .background(Color(.systemBackground))
                    }
                } else {
                    // iPhone Layout - 70% 3D Model, 30% Controls
                    // Main 3D Canvas (70% of remaining height)
                    ZStack {
                        // Clean background
                        LinearGradient(
                            colors: [Color.purple.opacity(0.03), Color.blue.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Large 3D Model - Hero Element
                        Express3DPaintableCanvas(
                            selectedColor: $selectedColor,
                            currentPart: $flowState.currentPart,
                            enableMirroring: $enableMirroring,
                            flowState: flowState
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        // Part name indicator overlay
                        VStack {
                            Spacer()
                            HStack {
                                PartIndicator(part: flowState.currentPart)
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                    .frame(height: (geometry.size.height - 60) * 0.7)
                    
                    // Bottom Controls (30% of remaining height)
                    VStack(spacing: 0) {
                        // Body part selector (horizontal scroll)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(BodyPart.allCases.filter { $0 != .hat && $0 != .jacket }, id: \.self) { part in
                                    ExpressPartButton(
                                        part: part,
                                        isActive: flowState.currentPart == part,
                                        isCompleted: flowState.editedParts.contains(part),
                                        action: { flowState.currentPart = part }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 80)
                        .background(Color.white.opacity(0.95))
                        
                        // Color palette
                        VStack(spacing: 8) {
                            // Mirror toggle
                            if flowState.currentPart.mirrorPart != nil {
                                HStack {
                                    Image(systemName: "arrow.left.and.right")
                                        .font(.caption)
                                    Text("Mirror")
                                        .font(.caption)
                                    Toggle("", isOn: $enableMirroring)
                                        .labelsHidden()
                                        .scaleEffect(0.8)
                                        .tint(.purple)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.purple.opacity(0.1)))
                            }
                            
                            // Colors
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(flowState.currentPart.suggestedColors, id: \.description) { color in
                                        ExpressColorButton(
                                            color: color,
                                            isSelected: selectedColor == color,
                                            action: { selectedColor = color }
                                        )
                                    }
                                    
                                    Divider()
                                        .frame(width: 1, height: 40)
                                    
                                    ForEach([Color.black, .white, .gray, .brown], id: \.description) { color in
                                        ExpressColorButton(
                                            color: color,
                                            isSelected: selectedColor == color,
                                            action: { selectedColor = color }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .frame(maxHeight: .infinity)
                        .background(Color.white)
                    }
                    .frame(height: (geometry.size.height - 60) * 0.3)
                }
                
            }
            
            // Completion overlay
            if flowState.isComplete {
                ExpressCompletion(
                    onContinue: { showingExport = true },
                    onKeepEditing: { flowState.isComplete = false }
                )
            }
        }
        .sheet(isPresented: $showingExport) {
            ExpressExportView()
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Express Header
struct ExpressHeader: View {
    @ObservedObject var flowState: GuidedFlowState
    @Binding var showMiniPreview: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Progress dots
            HStack(spacing: 6) {
                ForEach(BodyPart.allCases, id: \.self) { part in
                    Circle()
                        .fill(
                            flowState.editedParts.contains(part) ? Color.green :
                            part == flowState.currentPart ? Color.purple :
                            Color.gray.opacity(0.3)
                        )
                        .frame(width: 8, height: 8)
                        .overlay(
                            flowState.editedParts.contains(part) ?
                            Image(systemName: "checkmark")
                                .font(.system(size: 5))
                                .foregroundColor(.white)
                            : nil
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.gray.opacity(0.08)))
            
            Spacer()
            
            // Current step
            VStack(alignment: .center, spacing: 2) {
                Text("Step \(flowState.currentPartIndex + 1)/6")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(flowState.currentPart.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Preview toggle
            Button(action: { showMiniPreview.toggle() }) {
                Image(systemName: showMiniPreview ? "eye.fill" : "eye")
                    .font(.title3)
                    .foregroundColor(.purple)
                    .frame(width: 44, height: 44)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
            }
            
            // Next button
            Button(action: {
                if flowState.currentPartIndex < 5 {
                    flowState.nextPart()
                } else {
                    flowState.isComplete = true
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        flowState.editedParts.contains(flowState.currentPart) ?
                        Color.green : Color.gray.opacity(0.5)
                    )
                    .cornerRadius(12)
            }
            .disabled(!flowState.editedParts.contains(flowState.currentPart))
        }
        .padding(.horizontal, 12)
    }
}

// MARK: - Express Part Selector
struct ExpressPartSelector: View {
    @ObservedObject var flowState: GuidedFlowState
    @Binding var currentPart: BodyPart
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(BodyPart.allCases, id: \.self) { part in
                    ExpressPartButton(
                        part: part,
                        isActive: currentPart == part,
                        isCompleted: flowState.editedParts.contains(part),
                        action: { currentPart = part }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Express Part Button
struct ExpressPartButton: View {
    let part: BodyPart
    let isActive: Bool
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(isActive ? Color.purple : Color.gray.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: part.iconName)
                        .font(.title2)
                        .foregroundColor(isActive ? .white : .gray)
                    
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                            .offset(x: 18, y: -18)
                    }
                }
                
                Text(part.rawValue)
                    .font(.caption2)
                    .foregroundColor(isActive ? .purple : .primary)
            }
        }
        .scaleEffect(isActive ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isActive)
    }
}

// MARK: - Express Color Palette
struct ExpressColorPalette: View {
    let currentPart: BodyPart
    @Binding var selectedColor: Color
    @Binding var enableMirroring: Bool
    @EnvironmentObject var skinManager: SkinManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Mirror toggle (compact)
            if currentPart.mirrorPart != nil {
                HStack {
                    Image(systemName: "arrow.left.and.right")
                        .font(.caption)
                    Text("Mirror")
                        .font(.caption)
                    Toggle("", isOn: $enableMirroring)
                        .labelsHidden()
                        .scaleEffect(0.8)
                        .tint(.purple)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.purple.opacity(0.1)))
            }
            
            // Color grid (larger touch targets)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // Suggested colors
                    ForEach(Array(currentPart.suggestedColors.prefix(5).enumerated()), id: \.offset) { _, color in
                        ExpressColorButton(
                            color: color,
                            isSelected: selectedColor == color,
                            action: { selectedColor = color }
                        )
                    }
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1, height: 40)
                    
                    // Common colors
                    ForEach([Color.black, .white, .gray, .brown, .red, .orange, .yellow, .green, .blue, .purple, .pink], id: \.description) { color in
                        ExpressColorButton(
                            color: color,
                            isSelected: selectedColor == color,
                            action: { selectedColor = color }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            // Auto-select first suggested color if none selected
            if !currentPart.suggestedColors.contains(selectedColor) {
                selectedColor = currentPart.suggestedColors.first ?? .blue
            }
        }
        .onChange(of: currentPart) { newPart in
            // Smart color suggestions based on part
            if !newPart.suggestedColors.contains(selectedColor) {
                selectedColor = newPart.suggestedColors.first ?? selectedColor
            }
            HapticManager.shared.success()
        }
    }
}

// MARK: - Express Color Button
struct ExpressColorButton: View {
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
                        .stroke(
                            isSelected ? Color.purple : Color.gray.opacity(0.3),
                            lineWidth: isSelected ? 3 : 1
                        )
                )
                .scaleEffect(isSelected ? 1.1 : 1.0)
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Quick Button
struct QuickButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.purple.opacity(0.1))
            .cornerRadius(20)
        }
    }
}

// MARK: - Mini Floating Preview
struct MiniFloatingPreview: View {
    @EnvironmentObject var skinManager: SkinManager
    
    var body: some View {
        Skin3DPreview()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.2), radius: 8)
            )
    }
}

// MARK: - Part Indicator
struct PartIndicator: View {
    let part: BodyPart
    
    var body: some View {
        HStack {
            Image(systemName: part.iconName)
                .font(.title3)
                .foregroundColor(part.color)
            Text("Paint the \(part.displayName)")
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.1), radius: 4)
        )
    }
}

// MARK: - Express Completion
struct ExpressCompletion: View {
    let onContinue: () -> Void
    let onKeepEditing: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { onKeepEditing() }
            
            VStack(spacing: 20) {
                // Celebration
                VStack(spacing: 12) {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Great Work!")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                    
                    Text("You've customized all the main parts.\nReady to export your skin?")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Actions
                VStack(spacing: 12) {
                    Button(action: onContinue) {
                        Text("Export My Skin")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(16)
                    }
                    
                    Button(action: onKeepEditing) {
                        Text("Keep Editing")
                            .font(.body)
                            .foregroundColor(.purple)
                    }
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 20)
            )
            .padding(20)
        }
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Express 3D Paintable Canvas
struct Express3DPaintableCanvas: View {
    @Binding var selectedColor: Color
    @Binding var currentPart: BodyPart
    @Binding var enableMirroring: Bool
    @ObservedObject var flowState: GuidedFlowState
    @EnvironmentObject var skinManager: SkinManager
    @State private var canvasScale: CGFloat = 1.0
    @State private var canvasRotation: Angle = .zero
    
    var body: some View {
        // Static 3D reference preview (editing happens in 2D)
        Skin3DPreview()
        .scaleEffect(canvasScale)
        .rotationEffect(canvasRotation)
        .onAppear {
            // Mark the part as being worked on
            flowState.currentPart = currentPart
            // Set the selected color in skinManager
            skinManager.selectedColor = selectedColor
        }
        .onChange(of: currentPart) { newPart in
            flowState.currentPart = newPart
        }
        .onChange(of: selectedColor) { newColor in
            // Keep skinManager in sync
            skinManager.selectedColor = newColor
        }
    }
}

// MARK: - iPad-Specific Part Selector
struct ExpressPartSelectorIPad: View {
    @ObservedObject var flowState: GuidedFlowState
    @Binding var currentPart: BodyPart
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Body Parts")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top)
            
            VStack(spacing: 12) {
                ForEach(BodyPart.allCases.filter { $0 != .hat && $0 != .jacket }, id: \.self) { part in
                    ExpressPartButtonIPad(
                        part: part,
                        isActive: currentPart == part,
                        isCompleted: flowState.editedParts.contains(part),
                        action: { 
                            currentPart = part
                            flowState.currentPart = part
                        }
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - iPad Part Button
struct ExpressPartButtonIPad: View {
    let part: BodyPart
    let isActive: Bool
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isActive ? Color.purple : Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: part.iconName)
                        .font(.title2)
                        .foregroundColor(isActive ? .white : .gray)
                    
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                            .offset(x: 22, y: -22)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(part.rawValue)
                        .font(.headline)
                        .foregroundColor(isActive ? .purple : .primary)
                    
                    if isCompleted {
                        Text("Completed")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else if isActive {
                        Text("Editing")
                            .font(.caption)
                            .foregroundColor(.purple)
                    } else {
                        Text("Tap to edit")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? Color.purple.opacity(0.1) : Color.clear)
            )
        }
        .scaleEffect(isActive ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isActive)
    }
}

// MARK: - iPad Color Palette
struct ExpressColorPaletteIPad: View {
    let currentPart: BodyPart
    @Binding var selectedColor: Color
    @Binding var enableMirroring: Bool
    @EnvironmentObject var skinManager: SkinManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Colors")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top)
            
            // Mirror toggle
            if currentPart.mirrorPart != nil {
                HStack {
                    Image(systemName: "arrow.left.and.right")
                        .font(.body)
                    Text("Mirror to \(currentPart.mirrorPart!.rawValue)")
                        .font(.body)
                    Spacer()
                    Toggle("", isOn: $enableMirroring)
                        .labelsHidden()
                        .tint(.purple)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Capsule().fill(Color.purple.opacity(0.1)))
                .padding(.horizontal)
            }
            
            // Suggested colors
            VStack(alignment: .leading, spacing: 8) {
                Text("Suggested")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                    ForEach(Array(currentPart.suggestedColors.enumerated()), id: \.offset) { _, color in
                        ExpressColorButtonIPad(
                            color: color,
                            isSelected: selectedColor == color,
                            action: { selectedColor = color }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Common colors
            VStack(alignment: .leading, spacing: 8) {
                Text("All Colors")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                    ForEach([Color.black, .white, .gray, .brown, .red, .orange, .yellow, .green, .blue, .purple, .pink], id: \.description) { color in
                        ExpressColorButtonIPad(
                            color: color,
                            isSelected: selectedColor == color,
                            action: { selectedColor = color }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}

// MARK: - iPad Color Button
struct ExpressColorButtonIPad: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? Color.purple : Color.gray.opacity(0.3),
                            lineWidth: isSelected ? 3 : 1
                        )
                )
                .scaleEffect(isSelected ? 1.15 : 1.0)
                .shadow(color: isSelected ? color.opacity(0.5) : .clear, radius: 8)
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
