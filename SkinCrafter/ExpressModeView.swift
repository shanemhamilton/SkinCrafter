import SwiftUI

// MARK: - Express Mode View (Ages 5-12)
// Guarantees 3-tap success with big touch targets and quick wins
struct ExpressModeView: View {
    @EnvironmentObject var skinManager: SkinManager
    @State private var showingStickers = false
    @State private var selectedQuickColor: Color = .blue
    @State private var showingCelebration = false
    @State private var tapCount = 0
    @State private var hasCreatedSomething = false
    @State private var currentHint: ExpressHint? = nil
    @State private var showingExport = false
    
    // Quick-win colors optimized for kids
    let quickColors: [Color] = [
        Color(red: 0.96, green: 0.80, blue: 0.69), // Skin tone
        .blue, .green, .purple, .pink, .orange,
        .red, .yellow, .brown, .black
    ]
    
    // Cognitive hints system
    enum ExpressHint: String {
        case firstTap = "Tap the skin to paint! 🎨"
        case colorChange = "Try a new color! 🌈"
        case useSticker = "Add fun stickers! ⭐"
        case rotate3D = "Swipe to see all sides! 👆"
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Friendly gradient background
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Simplified Header (10% height)
                    ExpressHeaderBar(
                        hasCreatedSomething: $hasCreatedSomething,
                        showingExport: $showingExport
                    )
                    .frame(height: geometry.size.height * 0.1)
                    
                    // Main Creation Area (70% height)
                    ZStack {
                        // 3D Preview (always visible for instant feedback)
                        Express3DCanvas(
                            selectedColor: $selectedQuickColor,
                            tapCount: $tapCount,
                            hasCreatedSomething: $hasCreatedSomething,
                            showingCelebration: $showingCelebration
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        // Floating hint bubble
                        if let hint = currentHint {
                            VStack {
                                HintBubble(text: hint.rawValue)
                                    .padding(.top, 20)
                                Spacer()
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Celebration overlay
                        if showingCelebration {
                            CelebrationOverlay()
                                .allowsHitTesting(false)
                        }
                    }
                    .frame(height: geometry.size.height * 0.7)
                    
                    // Quick Tools Bar (20% height)
                    ExpressToolBar(
                        selectedColor: $selectedQuickColor,
                        quickColors: quickColors,
                        showingStickers: $showingStickers,
                        tapCount: $tapCount
                    )
                    .frame(height: geometry.size.height * 0.2)
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
                }
                
                // Sticker overlay sheet
                if showingStickers {
                    StickerPicker(
                        isShowing: $showingStickers,
                        onSelect: { sticker in
                            applySticker(sticker)
                            triggerCelebration()
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .onAppear {
            showInitialHint()
        }
        .sheet(isPresented: $showingExport) {
            ExpressExportView()
                .presentationDetents([.medium])
        }
    }
    
    private func showInitialHint() {
        withAnimation(.easeInOut(duration: 0.5).delay(0.5)) {
            currentHint = .firstTap
        }
        
        // Auto-hide hint after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                currentHint = nil
            }
        }
    }
    
    private func applySticker(_ sticker: StickerTemplate) {
        // Apply sticker to current skin
        // Implementation depends on sticker system
        hasCreatedSomething = true
    }
    
    private func triggerCelebration() {
        showingCelebration = true
        HapticManager.shared.success()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showingCelebration = false
        }
    }
}

// MARK: - Express Header Bar
struct ExpressHeaderBar: View {
    @EnvironmentObject var skinManager: SkinManager
    @Binding var hasCreatedSomething: Bool
    @Binding var showingExport: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            // Big Reset Button (70x70pt for better touch)
            Button(action: {
                skinManager.resetSkin()
                hasCreatedSomething = false
                HapticManager.shared.lightImpact()
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title)
                    Text("New")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .frame(width: 70, height: 70)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(18)
            }
            
            Spacer()
            
            // Title with fun animation
            Text("Create!")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.purple)
                .scaleEffect(hasCreatedSomething ? 1.1 : 1.0)
                .animation(.spring(response: 0.3), value: hasCreatedSomething)
            
            Spacer()
            
            // Big Save Button (70x70pt) - Pulses when something created
            Button(action: { 
                showingExport = true
                HapticManager.shared.success()
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.title)
                    Text("Save")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .frame(width: 70, height: 70)
                .background(hasCreatedSomething ? Color.green : Color.gray.opacity(0.15))
                .foregroundColor(hasCreatedSomething ? .white : .primary)
                .cornerRadius(18)
                .shadow(color: hasCreatedSomething ? Color.green.opacity(0.3) : Color.clear, radius: 8)
                .scaleEffect(hasCreatedSomething ? 1.08 : 1.0)
                .animation(
                    hasCreatedSomething ?
                    Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true) :
                    .default,
                    value: hasCreatedSomething
                )
            }
            .disabled(!hasCreatedSomething)
        }
        .padding(.horizontal)
    }
}

// MARK: - Express 3D Canvas
struct Express3DCanvas: View {
    @EnvironmentObject var skinManager: SkinManager
    @Binding var selectedColor: Color
    @Binding var tapCount: Int
    @Binding var hasCreatedSomething: Bool
    @Binding var showingCelebration: Bool
    
    @State private var rotation = CGSize.zero
    @State private var previousRotation = CGSize.zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Enhanced 3D Preview with direct painting
                Direct3DPaintableView(
                    selectedColor: $selectedColor,
                    onPaint: {
                        tapCount += 1
                        hasCreatedSomething = true
                        
                        // Celebrate on first tap
                        if tapCount == 1 {
                            showingCelebration = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showingCelebration = false
                            }
                        }
                        
                        // Haptic feedback
                        HapticManager.shared.lightImpact()
                    }
                )
                .rotation3DEffect(
                    .degrees(Double(rotation.width + previousRotation.width)),
                    axis: (x: 0, y: 1, z: 0)
                )
                .rotation3DEffect(
                    .degrees(Double(rotation.height + previousRotation.height) * 0.5),
                    axis: (x: 1, y: 0, z: 0)
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            rotation = CGSize(
                                width: value.translation.width,
                                height: value.translation.height
                            )
                        }
                        .onEnded { _ in
                            previousRotation.width += rotation.width
                            previousRotation.height += rotation.height
                            rotation = .zero
                        }
                )
                
                // Tap indicator ripple
                if tapCount > 0 && tapCount < 4 {
                    RippleEffect()
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

// MARK: - Express Tool Bar
struct ExpressToolBar: View {
    @Binding var selectedColor: Color
    let quickColors: [Color]
    @Binding var showingStickers: Bool
    @Binding var tapCount: Int
    
    @State private var selectedToolIndex = 0
    @State private var showingColorHint = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Main Tools Row
            HStack(spacing: 15) {
                // Paint Tool (Selected by default) - 60x60pt
                ExpressToolButton(
                    icon: "paintbrush.fill",
                    label: "Paint",
                    isSelected: selectedToolIndex == 0,
                    color: .purple
                ) {
                    selectedToolIndex = 0
                }
                
                // Stickers Tool - 60x60pt
                ExpressToolButton(
                    icon: "star.fill",
                    label: "Stickers",
                    isSelected: false,
                    color: .orange
                ) {
                    withAnimation(.spring()) {
                        showingStickers = true
                    }
                }
                
                // Magic Randomize - 60x60pt
                ExpressToolButton(
                    icon: "sparkles",
                    label: "Surprise!",
                    isSelected: false,
                    color: .pink
                ) {
                    applySurpriseSkin()
                }
            }
            
            // Color Palette Row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(quickColors, id: \.description) { color in
                        Button(action: {
                            selectedColor = color
                            tapCount += 1
                            showingColorHint = false
                        }) {
                            Circle()
                                .fill(color)
                                .frame(width: 55, height: 55)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            selectedColor == color ? Color.black : Color.gray.opacity(0.3),
                                            lineWidth: selectedColor == color ? 3 : 1
                                        )
                                )
                                .shadow(color: selectedColor == color ? color.opacity(0.3) : Color.clear, radius: 4)
                                .scaleEffect(selectedColor == color ? 1.18 : 1.0)
                        }
                        .animation(.spring(response: 0.3), value: selectedColor == color)
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 60)
            
            // Cognitive hint for colors
            if showingColorHint {
                Text("Tap a color to change your paint! 🎨")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .transition(.opacity)
            }
        }
        .padding(.vertical, 12)
        .onAppear {
            // Show color hint after 5 taps
            if tapCount == 5 {
                withAnimation {
                    showingColorHint = true
                }
            }
        }
    }
    
    private func applySurpriseSkin() {
        // Apply random template with fun colors
        // Implementation for random skin generation
        HapticManager.shared.success()
    }
}

// MARK: - Express Tool Button
struct ExpressToolButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : color)
                
                Text(label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 90, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected ? color : Color.gray.opacity(0.08))
            )
            .shadow(color: isSelected ? color.opacity(0.3) : Color.clear, radius: 5)
        }
    }
}

// MARK: - Hint Bubble
struct HintBubble: View {
    let text: String
    @State private var bounce = false
    
    var body: some View {
        HStack {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
        )
        .scaleEffect(bounce ? 1.05 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatCount(3, autoreverses: true)) {
                bounce = true
            }
        }
    }
}

// MARK: - Celebration Overlay
struct CelebrationOverlay: View {
    @State private var particles: [ConfettiParticle] = []
    
    struct ConfettiParticle: Identifiable {
        let id = UUID()
        let color: Color
        let startX: CGFloat
        let endX: CGFloat
        let startY: CGFloat
        let emoji: String
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Text(particle.emoji)
                    .font(.system(size: 30))
                    .position(x: particle.startX, y: particle.startY)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            }
            
            Text("Great job! 🎉")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.purple)
                )
                .scaleEffect(1.2)
                .transition(.scale.combined(with: .opacity))
        }
        .onAppear {
            createParticles()
        }
    }
    
    private func createParticles() {
        let emojis = ["⭐", "🎨", "✨", "🌟", "💫", "🎉"]
        for i in 0..<20 {
            let particle = ConfettiParticle(
                color: [Color.purple, .pink, .blue, .green, .orange, .yellow].randomElement()!,
                startX: CGFloat.random(in: 50...350),
                endX: CGFloat.random(in: 50...350),
                startY: CGFloat.random(in: 100...500),
                emoji: emojis.randomElement()!
            )
            
            withAnimation(.easeOut(duration: 2).delay(Double(i) * 0.1)) {
                particles.append(particle)
            }
        }
    }
}

// MARK: - Sticker Picker
struct StickerPicker: View {
    @Binding var isShowing: Bool
    let onSelect: (StickerTemplate) -> Void
    
    let stickers = StickerTemplate.defaultStickers
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
            
            // Title
            HStack {
                Text("Choose a Sticker!")
                    .font(.title2.bold())
                Spacer()
                Button("Done") {
                    withAnimation {
                        isShowing = false
                    }
                }
            }
            .padding()
            
            // Sticker Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(stickers) { sticker in
                        Button(action: {
                            onSelect(sticker)
                            isShowing = false
                        }) {
                            VStack {
                                Text(sticker.emoji)
                                    .font(.system(size: 50))
                                Text(sticker.name)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 100, height: 100)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(15)
                        }
                    }
                }
                .padding()
            }
        }
        .frame(maxHeight: 400)
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
}

// MARK: - Sticker Template
struct StickerTemplate: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let pattern: [[Color]]
    
    static let defaultStickers = [
        StickerTemplate(name: "Heart", emoji: "❤️", pattern: []),
        StickerTemplate(name: "Star", emoji: "⭐", pattern: []),
        StickerTemplate(name: "Flower", emoji: "🌸", pattern: []),
        StickerTemplate(name: "Rainbow", emoji: "🌈", pattern: []),
        StickerTemplate(name: "Lightning", emoji: "⚡", pattern: []),
        StickerTemplate(name: "Crown", emoji: "👑", pattern: []),
        StickerTemplate(name: "Fire", emoji: "🔥", pattern: []),
        StickerTemplate(name: "Snowflake", emoji: "❄️", pattern: []),
        StickerTemplate(name: "Music", emoji: "🎵", pattern: [])
    ]
}



// MARK: - Ripple Effect
struct RippleEffect: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.8
    
    var body: some View {
        Circle()
            .stroke(Color.purple, lineWidth: 2)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1)) {
                    scale = 2
                    opacity = 0
                }
            }
    }
}