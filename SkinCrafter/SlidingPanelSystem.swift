import SwiftUI

// MARK: - Sliding Panel System for Mobile
struct SlidingPreviewPanel: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var skinManager: SkinManager
    @State private var selectedAnimation: AnimationType = .idle
    @State private var panelOffset: CGFloat = 0
    
    enum AnimationType: String, CaseIterable {
        case idle = "Idle"
        case walk = "Walk"  
        case run = "Run"
        case jump = "Jump"
        case swim = "Swim"
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Transparent tap area to close
                Color.clear
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isShowing = false
                        }
                    }
                
                // Preview Panel
                VStack(spacing: 0) {
                    // Panel Header
                    HStack {
                        Text("3D Preview")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                isShowing = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    // Animation Selector
                    Picker("Animation", selection: $selectedAnimation) {
                        ForEach(AnimationType.allCases, id: \.self) { animation in
                            Text(animation.rawValue)
                                .tag(animation)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    // 3D Preview
                    Skin3DPreview()
                        .frame(maxHeight: .infinity)
                        .background(
                            LinearGradient(
                                colors: [.purple.opacity(0.1), .blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .padding()
                    
                    // Quick Actions
                    HStack {
                        Button("Reset View") {
                            // Reset 3D view
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Button("Export Preview") {
                            // Export 3D view
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
                .frame(width: min(geometry.size.width * 0.85, 320))
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.2), radius: 12, x: -4, y: 0)
                .offset(x: panelOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            panelOffset = max(0, value.translation.width)
                        }
                        .onEnded { value in
                            if value.translation.width > 100 {
                                withAnimation(.spring()) {
                                    isShowing = false
                                }
                            } else {
                                withAnimation(.spring()) {
                                    panelOffset = 0
                                }
                            }
                        }
                )
            }
        }
        .transition(.move(edge: .trailing))
        .zIndex(1)
    }
}

struct SlidingLayerPanel: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var skinManager: SkinManager
    @State private var panelOffset: CGFloat = 0
    @State private var layerOpacity: Double = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Layer Panel
                VStack(spacing: 0) {
                    // Panel Header
                    HStack {
                        Text("Layers")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                isShowing = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    // Layer List
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            CompactLayerRow(
                                name: "Overlay",
                                isSelected: skinManager.selectedLayer == .overlay,
                                opacity: layerOpacity,
                                isVisible: true
                            ) {
                                skinManager.selectedLayer = .overlay
                                HapticManager.shared.selectionChanged()
                            }
                            
                            CompactLayerRow(
                                name: "Base",
                                isSelected: skinManager.selectedLayer == .base,
                                opacity: 1.0,
                                isVisible: true
                            ) {
                                skinManager.selectedLayer = .base
                                HapticManager.shared.selectionChanged()
                            }
                        }
                        .padding()
                    }
                    
                    Divider()
                    
                    // Layer Controls
                    VStack(spacing: 12) {
                        HStack {
                            Text("Opacity")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(Int(layerOpacity * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $layerOpacity, in: 0...1) {
                            Text("Opacity")
                        }
                        .tint(.purple)
                        
                        HStack(spacing: 12) {
                            Button(action: {}) {
                                Label("Add Layer", systemImage: "plus.circle")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Label("Duplicate", systemImage: "doc.on.doc")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                            
                            Button(action: {}) {
                                Label("Delete", systemImage: "trash")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.red)
                        }
                    }
                    .padding()
                }
                .frame(width: min(geometry.size.width * 0.75, 280))
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.2), radius: 12, x: 4, y: 0)
                .offset(x: panelOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            panelOffset = min(0, value.translation.width)
                        }
                        .onEnded { value in
                            if value.translation.width < -100 {
                                withAnimation(.spring()) {
                                    isShowing = false
                                }
                            } else {
                                withAnimation(.spring()) {
                                    panelOffset = 0
                                }
                            }
                        }
                )
                
                // Transparent tap area to close
                Color.clear
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isShowing = false
                        }
                    }
            }
        }
        .transition(.move(edge: .leading))
        .zIndex(1)
    }
}

struct CompactLayerRow: View {
    let name: String
    let isSelected: Bool
    let opacity: Double
    let isVisible: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Layer thumbnail (simplified)
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 40, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? Color.purple : Color.gray.opacity(0.5), lineWidth: isSelected ? 2 : 1)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(.body, design: .rounded, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .purple : .primary)
                
                Text("Opacity: \(Int(opacity * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Visibility toggle
            Button(action: {}) {
                Image(systemName: isVisible ? "eye.fill" : "eye.slash.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isVisible ? .primary : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.purple.opacity(0.1) : Color.clear)
        )
        .onTapGesture(perform: action)
    }
}

// MARK: - Floating Color Picker
struct FloatingColorPicker: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var skinManager: SkinManager
    @StateObject private var paletteManager = PaletteManager()
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Colors")
                    .font(.headline)
                
                Spacer()
                
                Button("Done") {
                    withAnimation(.spring()) {
                        isShowing = false
                    }
                }
            }
            .padding()
            
            // Current Color Display
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(skinManager.selectedColor)
                    .frame(width: 60, height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                
                VStack(alignment: .leading) {
                    Text("Current Color")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ColorPicker("", selection: $skinManager.selectedColor)
                        .labelsHidden()
                        .scaleEffect(1.2)
                        .frame(width: 40, height: 40)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Quick Color Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                ForEach(paletteManager.palettes.first?.colors ?? [], id: \.red) { codableColor in
                    Button(action: {
                        skinManager.selectedColor = codableColor.color
                        paletteManager.addColorToRecent(codableColor.color)
                        HapticManager.shared.selectionChanged()
                    }) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(codableColor.color)
                            .frame(height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
            
            // Recent Colors
            if !paletteManager.recentColors.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(paletteManager.recentColors.prefix(10), id: \.description) { color in
                                Button(action: {
                                    skinManager.selectedColor = color
                                }) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(color)
                                        .frame(width: 35, height: 35)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            Spacer()
        }
        .frame(width: min(UIScreen.main.bounds.width * 0.9, 320), height: 400)
        .background(.regularMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
        .scaleEffect(isShowing ? 1.0 : 0.8)
        .opacity(isShowing ? 1.0 : 0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isShowing)
    }
}