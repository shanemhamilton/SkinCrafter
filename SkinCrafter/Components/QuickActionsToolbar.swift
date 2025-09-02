import SwiftUI

// MARK: - Quick Actions Toolbar for Express Mode
struct QuickActionsToolbar: View {
    @EnvironmentObject var skinManager: SkinManager
    @State private var selectedTemplate: SkinTemplate = .none
    @State private var showingStickers = false
    @State private var showingMicroLesson = false
    @State private var currentLesson: MicroLesson?
    
    enum SkinTemplate: String, CaseIterable {
        case none = "Blank"
        case superhero = "Hero"
        case princess = "Royal"
        case ninja = "Ninja"
        case robot = "Robot"
        case animal = "Animal"
        
        var icon: String {
            switch self {
            case .none: return "square.dashed"
            case .superhero: return "bolt.fill"
            case .princess: return "crown.fill"
            case .ninja: return "eye.slash.fill"
            case .robot: return "gear"
            case .animal: return "pawprint.fill"
            }
        }
        
        var colors: [Color] {
            switch self {
            case .none: return []
            case .superhero: return [.red, .blue, .yellow]
            case .princess: return [.pink, .purple, Color(red: 1.0, green: 0.84, blue: 0)]
            case .ninja: return [.black, .gray, .red]
            case .robot: return [.gray, .blue, Color(red: 0.7, green: 0.7, blue: 0.8)]
            case .animal: return [.brown, .orange, .white]
            }
        }
    }
    
    struct MicroLesson {
        let title: String
        let content: String
        let cognitiveSkill: String
        let icon: String
        let duration: Int // seconds
    }
    
    let microLessons = [
        MicroLesson(
            title: "Mirror Magic",
            content: "Paint one side, then tap Mirror to copy to the other side!",
            cognitiveSkill: "Symmetry & Spatial Reasoning",
            icon: "arrow.left.and.right",
            duration: 10
        ),
        MicroLesson(
            title: "Color Mixing",
            content: "Layer colors to create new shades! Try yellow + blue = green!",
            cognitiveSkill: "Color Theory & Creativity",
            icon: "drop.fill",
            duration: 15
        ),
        MicroLesson(
            title: "Pattern Power",
            content: "Repeat shapes to make patterns. Try: dot-dot-line, dot-dot-line!",
            cognitiveSkill: "Pattern Recognition & Sequencing",
            icon: "square.grid.3x3.fill",
            duration: 12
        )
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            // Quick Win Templates
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(SkinTemplate.allCases, id: \.self) { template in
                        QuickTemplateButton(
                            template: template,
                            isSelected: selectedTemplate == template
                        ) {
                            applyTemplate(template)
                            HapticManager.shared.success()
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 80)
            
            // One-Tap Actions
            HStack(spacing: 20) {
                // Randomize Button
                QuickActionButton(
                    icon: "dice.fill",
                    label: "Surprise!",
                    color: .purple
                ) {
                    randomizeSkin()
                    HapticManager.shared.medium()
                }
                
                // Stickers Button
                QuickActionButton(
                    icon: "star.fill",
                    label: "Stickers",
                    color: .orange
                ) {
                    showingStickers = true
                    HapticManager.shared.light()
                }
                
                // Mirror Mode
                QuickActionButton(
                    icon: "arrow.left.and.right",
                    label: "Mirror",
                    color: .blue,
                    isToggle: true,
                    isOn: skinManager.selectedTool == .mirror
                ) {
                    toggleMirrorMode()
                    HapticManager.shared.selection()
                }
                
                // Learn Button (Micro-lessons)
                QuickActionButton(
                    icon: "lightbulb.fill",
                    label: "Learn",
                    color: .green
                ) {
                    showRandomMicroLesson()
                    HapticManager.shared.light()
                }
            }
            .padding(.horizontal)
            
            // Color Palette (Big touch targets)
            ExpressColorPalette()
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
        )
        .sheet(isPresented: $showingStickers) {
            ExpressStickerSheet()
        }
        .sheet(isPresented: $showingMicroLesson) {
            if let lesson = currentLesson {
                MicroLessonView(lesson: lesson)
            }
        }
    }
    
    private func applyTemplate(_ template: SkinTemplate) {
        selectedTemplate = template
        
        guard template != .none else {
            skinManager.resetSkin()
            return
        }
        
        // Apply template colors to different body parts
        // This would use predefined patterns for each template
        skinManager.saveUndoState()
        
        // Example: Apply superhero template
        switch template {
        case .superhero:
            // Apply cape, logo, mask patterns
            applySuperHeroTemplate()
        case .princess:
            applyPrincessTemplate()
        case .ninja:
            applyNinjaTemplate()
        case .robot:
            applyRobotTemplate()
        case .animal:
            applyAnimalTemplate()
        default:
            break
        }
    }
    
    private func applySuperHeroTemplate() {
        // Red cape on back
        // Blue suit
        // Yellow emblem on chest
        // This would modify skinManager.currentSkin pixels
    }
    
    private func applyPrincessTemplate() {
        // Pink dress
        // Gold crown
        // Purple details
    }
    
    private func applyNinjaTemplate() {
        // Black outfit
        // Red belt
        // Gray armor pieces
    }
    
    private func applyRobotTemplate() {
        // Metallic gray body
        // Blue lights
        // Circuit patterns
    }
    
    private func applyAnimalTemplate() {
        // Brown fur base
        // Cute face features
        // Tail and ears
    }
    
    private func randomizeSkin() {
        skinManager.saveUndoState()
        
        // Generate random but appealing color scheme
        let schemes = [
            [Color.blue, Color.cyan, Color.white],
            [Color.pink, Color.purple, Color.yellow],
            [Color.green, Color.brown, Color.orange],
            [Color.red, Color.black, Color.gray]
        ]
        
        let selectedScheme = schemes.randomElement()!
        
        // Apply random patterns with selected colors
        // This would create interesting designs procedurally
        
        // Show celebration
        withAnimation(.spring()) {
            // Trigger celebration animation
        }
    }
    
    private func toggleMirrorMode() {
        if skinManager.selectedTool == .mirror {
            skinManager.selectedTool = .pencil
        } else {
            skinManager.selectedTool = .mirror
        }
    }
    
    private func showRandomMicroLesson() {
        currentLesson = microLessons.randomElement()
        showingMicroLesson = true
    }
}

// MARK: - Quick Template Button
struct QuickTemplateButton: View {
    let template: QuickActionsToolbar.SkinTemplate
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: template.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : .primary)
                }
                
                Text(template.rawValue)
                    .font(.caption2)
                    .fontWeight(isSelected ? .bold : .medium)
            }
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let label: String
    let color: Color
    var isToggle: Bool = false
    var isOn: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(isToggle && isOn ? color : color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isToggle && isOn ? .white : color)
                }
                
                Text(label)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
        .scaleEffect(isToggle && isOn ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isOn)
    }
}

// MARK: - Express Color Palette
struct ExpressColorPalette: View {
    @EnvironmentObject var skinManager: SkinManager
    
    // Kid-friendly color selection
    let expressColors: [[Color]] = [
        // Row 1: Basic colors
        [.red, .orange, .yellow, .green, .blue, .purple],
        // Row 2: Skin tones and neutrals
        [
            Color(red: 0.96, green: 0.80, blue: 0.69),
            Color(red: 0.87, green: 0.66, blue: 0.53),
            Color(red: 0.71, green: 0.49, blue: 0.36),
            .brown, .gray, .black
        ]
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<expressColors.count, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(expressColors[row], id: \.self) { color in
                        ColorButton(
                            color: color,
                            isSelected: skinManager.selectedColor == color
                        ) {
                            skinManager.selectedColor = color
                            HapticManager.shared.selection()
                        }
                    }
                }
            }
            
            // Eraser as special color
            HStack {
                Button(action: {
                    skinManager.selectedTool = skinManager.selectedTool == .eraser ? .pencil : .eraser
                    HapticManager.shared.selection()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(skinManager.selectedTool == .eraser ? Color.red.opacity(0.2) : Color.gray.opacity(0.1))
                            .frame(height: 44)
                        
                        HStack {
                            Image(systemName: "eraser.fill")
                                .foregroundColor(skinManager.selectedTool == .eraser ? .red : .gray)
                            Text("Eraser")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                Spacer()
                
                // Undo/Redo buttons
                HStack(spacing: 12) {
                    Button(action: {
                        skinManager.undo()
                        HapticManager.shared.light()
                    }) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        skinManager.redo()
                        HapticManager.shared.light()
                    }) {
                        Image(systemName: "arrow.uturn.forward")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                            .frame(width: 44, height: 44)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Color Button
struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 44, height: 44) // iOS HIG minimum
                
                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 44, height: 44)
                    
                    Circle()
                        .stroke(Color.black, lineWidth: 1)
                        .frame(width: 46, height: 46)
                }
            }
        }
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
        .shadow(color: color.opacity(0.4), radius: isSelected ? 4 : 2)
    }
}

// MARK: - Sticker Sheet
struct ExpressStickerSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let stickers = [
        "⭐", "❤️", "😊", "🌈", "⚡", "🔥",
        "💎", "🌟", "✨", "🎨", "🦄", "🐻",
        "🤖", "👑", "🎮", "⚔️", "🛡️", "🏹"
    ]
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(stickers, id: \.self) { sticker in
                        Button(action: {
                            applySticker(sticker)
                            HapticManager.shared.success()
                            dismiss()
                        }) {
                            Text(sticker)
                                .font(.system(size: 40))
                                .frame(width: 70, height: 70)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Pick a Sticker!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func applySticker(_ sticker: String) {
        // Apply sticker to the skin
        // This would add the sticker as a decal or pattern
    }
}

// MARK: - Micro Lesson View
struct MicroLessonView: View {
    let lesson: QuickActionsToolbar.MicroLesson
    @Environment(\.dismiss) var dismiss
    @State private var progress: Double = 0
    @State private var showingContent = false
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Icon
                Image(systemName: lesson.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .scaleEffect(showingContent ? 1.0 : 0.5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showingContent)
                
                // Title
                Text(lesson.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Content
                Text(lesson.content)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 40)
                    .opacity(showingContent ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.5).delay(0.3), value: showingContent)
                
                // Cognitive skill badge
                HStack {
                    Image(systemName: "brain")
                    Text(lesson.cognitiveSkill)
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.white.opacity(0.2)))
                
                Spacer()
                
                // Progress bar
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .tint(.white)
                    .scaleEffect(y: 2)
                    .padding(.horizontal, 40)
                
                // Got it button
                Button(action: {
                    dismiss()
                }) {
                    Text("Got it! 👍")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .padding(.horizontal, 40)
                }
            }
            .padding(.vertical, 60)
        }
        .onAppear {
            showingContent = true
            startProgressTimer()
        }
    }
    
    private func startProgressTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            progress += 1.0 / Double(lesson.duration * 10)
            
            if progress >= 1.0 {
                timer.invalidate()
                HapticManager.shared.success()
            }
        }
    }
}