import SwiftUI

struct ContentView: View {
    @EnvironmentObject var skinManager: SkinManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("preferredMode") private var preferredMode = "express"
    @AppStorage("userAgeGroup") private var userAgeGroup = "under13"
    @State private var showingOnboarding = false
    @State private var currentMode: EditorMode = .modeSelector
    
    enum EditorMode {
        case modeSelector
        case express
        case studio
        case settings
        case testPaint // Temporary test mode
    }
    
    var body: some View {
        ZStack {
            // Main content based on mode
            Group {
                switch currentMode {
                case .modeSelector:
                    ModeSelectorView(
                        selectedMode: $currentMode,
                        userAgeGroup: userAgeGroup
                    )
                    .transition(.scale.combined(with: .opacity))
                    
                case .express:
                    ExpressGuidedFlow()
                        .environmentObject(skinManager)
                        .overlay(alignment: .topLeading) {
                            // Mode switcher button - 60x60pt for easy access
                            Button(action: { 
                                withAnimation(.spring()) {
                                    currentMode = .modeSelector
                                }
                            }) {
                                Image(systemName: "square.grid.2x2")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(
                                        Circle()
                                            .fill(Color.purple.opacity(0.8))
                                            .shadow(radius: 4)
                                    )
                            }
                            .padding(.top, 50)
                            .padding(.leading, 16)
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    
                case .studio:
                    StudioModeView()
                        .overlay(alignment: .topLeading) {
                            // Mode switcher button - professional style
                            Button(action: { 
                                withAnimation(.spring()) {
                                    currentMode = .modeSelector
                                }
                            }) {
                                Label("Modes", systemImage: "square.grid.2x2")
                                    .font(.body)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color.black.opacity(0.05))
                                            .background(.ultraThinMaterial)
                                    )
                            }
                            .padding(.top, 50)
                            .padding(.leading, 16)
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                    
                case .settings:
                    SettingsView(currentMode: $currentMode)
                        .transition(.move(edge: .bottom))
                        
                case .testPaint:
                    TestPaintView()
                        .environmentObject(skinManager)
                        .overlay(alignment: .topLeading) {
                            Button(action: { 
                                withAnimation(.spring()) {
                                    currentMode = .modeSelector
                                }
                            }) {
                                Label("Back", systemImage: "arrow.left")
                                    .padding()
                                    .background(Color.black.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .padding()
                        }
                        .transition(.opacity)
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentMode)
        }
        .onAppear {
            setupInitialMode()
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView(
                hasCompletedOnboarding: $hasCompletedOnboarding,
                preferredMode: $preferredMode,
                userAgeGroup: $userAgeGroup
            ) {
                // Completion handler
                showingOnboarding = false
                currentMode = preferredMode == "express" ? .express : .studio
            }
        }
    }
    
    private func setupInitialMode() {
        if !hasCompletedOnboarding {
            showingOnboarding = true
        } else {
            // Quick launch to last used mode
            if preferredMode == "express" {
                currentMode = .express
            } else if preferredMode == "studio" {
                currentMode = .studio
            } else {
                currentMode = .modeSelector
            }
        }
    }
}

struct LegacyContentView: View {
    @EnvironmentObject var skinManager: SkinManager
    @State private var selectedTab = 0
    @State private var showingGallery = false
    @State private var showingSettings = false
    @State private var isProfessionalMode = false
    
    var body: some View {
        if isProfessionalMode {
            ProfessionalEditorView()
                .overlay(alignment: .topTrailing) {
                    Button(action: { isProfessionalMode = false }) {
                        Label("Simple Mode", systemImage: "square.grid.2x2")
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                    }
                    .padding()
                }
        } else {
            TabView(selection: $selectedTab) {
                EditorView()
                    .tabItem {
                        Label("Create", systemImage: "paintbrush.fill")
                    }
                    .tag(0)
            
            TemplatesView()
                .tabItem {
                    Label("Templates", systemImage: "square.grid.3x3.fill")
                }
                .tag(1)
            
            GalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "photo.stack.fill")
                }
                .tag(2)
            
            RequestsView()
                .tabItem {
                    Label("Requests", systemImage: "star.bubble.fill")
                }
                .tag(3)
            }
            .tint(.purple)
            .overlay(alignment: .topTrailing) {
                Button(action: { isProfessionalMode = true }) {
                    Label("Pro Mode", systemImage: "cube.box.fill")
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
    }
}

struct EditorView: View {
    @EnvironmentObject var skinManager: SkinManager
    @State private var currentScale: CGFloat = 1.0
    @State private var showingColorPicker = false
    @State private var showingExportMenu = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // 3D Preview Section
                    if skinManager.isShowingPreview {
                        Skin3DPreview()
                            .frame(height: geometry.size.height * 0.35)
                            .background(
                                LinearGradient(
                                    colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(20)
                            .padding()
                    }
                    
                    // 2D Editor Section
                    ZStack {
                        SkinEditorCanvas()
                            .scaleEffect(currentScale)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        currentScale = value
                                    }
                            )
                    }
                    .frame(maxHeight: .infinity)
                    .background(Color.gray.opacity(0.1))
                    
                    // Drawing Tools
                    DrawingToolsBar()
                        .padding()
                        .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("Skin Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { skinManager.isShowingPreview.toggle() }) {
                        Image(systemName: skinManager.isShowingPreview ? "eye.fill" : "eye.slash.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingExportMenu = true }) {
                            Label("Export Skin", systemImage: "square.and.arrow.up")
                        }
                        Button(action: { skinManager.resetSkin() }) {
                            Label("Reset", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                    }
                }
            }
        }
    }
}

struct DrawingToolsBar: View {
    @EnvironmentObject var skinManager: SkinManager
    
    var body: some View {
        HStack(spacing: 20) {
            // Tool Selection
            ForEach(DrawingTool.allCases, id: \.self) { tool in
                Button(action: { skinManager.selectedTool = tool }) {
                    Image(systemName: tool.iconName)
                        .font(.title2)
                        .foregroundColor(skinManager.selectedTool == tool ? .white : .primary)
                        .frame(width: 44, height: 44)
                        .background(
                            skinManager.selectedTool == tool ?
                            AnyView(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.purple)
                            ) :
                            AnyView(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        )
                }
            }
            
            Spacer()
            
            // Color Picker
            ColorPicker("", selection: $skinManager.selectedColor)
                .labelsHidden()
                .frame(width: 44, height: 44)
            
            // Layer Toggle
            Button(action: {
                skinManager.selectedLayer = skinManager.selectedLayer == .base ? .overlay : .base
            }) {
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.title2)
                    .foregroundColor(skinManager.selectedLayer == .overlay ? .purple : .gray)
            }
        }
        .padding(.horizontal)
    }
}

struct TemplatesView: View {
    @EnvironmentObject var skinManager: SkinManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(DefaultSkinTemplates.availableTemplates) { template in
                        TemplateCard(template: template) {
                            loadTemplate(template)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Templates")
        }
    }
    
    private func loadTemplate(_ template: BaseSkinTemplate) {
        if let skinData = template.generator().pngData(),
           let newSkin = CharacterSkin(pngData: skinData) {
            skinManager.currentSkin = newSkin
            
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
    }
}


struct GalleryView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Your saved skins will appear here!")
                    .foregroundColor(.gray)
                    .padding(.top, 100)
            }
            .navigationTitle("My Gallery")
        }
    }
}

struct RequestsView: View {
    @State private var selectedGame = "Minecraft"
    @State private var userRequest = ""
    
    let supportedGames = ["Minecraft", "Coming Soon: Roblox", "Coming Soon: Fortnite"]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Vote for the next game!")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                
                ForEach(supportedGames, id: \.self) { game in
                    HStack {
                        Image(systemName: game == "Minecraft" ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(game == "Minecraft" ? .green : .gray)
                        Text(game)
                            .foregroundColor(game == "Minecraft" ? .primary : .gray)
                        Spacer()
                        if game != "Minecraft" {
                            Button("Vote") {
                                // Handle voting
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Have a suggestion?")
                        .font(.headline)
                    
                    TextField("Tell us what game you'd like next...", text: $userRequest, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...5)
                    
                    Button(action: {
                        // Submit request
                        userRequest = ""
                    }) {
                        Text("Submit Request")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(userRequest.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Feature Requests")
        }
    }
}

// Removed duplicate ModeSelectorView - it is now in a separate file

// DUMMY ModeSelectorView placeholder (will be removed)
struct DUMMY_ModeSelectorView_REMOVE: View {
    @Binding var selectedMode: ContentView.EditorMode
    let userAgeGroup: String
    @State private var showingParentGate = false
    @State private var animateCards = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradient background
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.15),
                        Color.blue.opacity(0.10),
                        Color.pink.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Choose Your Mode")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Pick the best experience for you")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 60)
                    
                    // Mode Cards
                    VStack(spacing: 20) {
                        // Express Mode Card - 80% width, prominent
                        ModeCard(
                            title: "Express Create",
                            subtitle: "Ages 5-12",
                            description: "Quick & fun creation with big buttons",
                            icon: "sparkles",
                            color: .purple,
                            features: ["3-tap creation", "Fun stickers", "Big buttons"],
                            isRecommended: userAgeGroup == "under13"
                        ) {
                            withAnimation(.spring()) {
                                selectedMode = .express
                            }
                        }
                        .frame(maxWidth: min(geometry.size.width * 0.85, 400))
                        .scaleEffect(animateCards ? 1 : 0.9)
                        .opacity(animateCards ? 1 : 0)
                        .animation(.spring().delay(0.1), value: animateCards)
                        
                        // Studio Mode Card
                        ModeCard(
                            title: "Studio Pro",
                            subtitle: "Ages 13+",
                            description: "Professional tools & advanced features",
                            icon: "cube.box.fill",
                            color: .blue,
                            features: ["15+ tools", "Layers", "Pro export"],
                            isRecommended: userAgeGroup != "under13"
                        ) {
                            withAnimation(.spring()) {
                                selectedMode = .studio
                            }
                        }
                        .frame(maxWidth: min(geometry.size.width * 0.85, 400))
                        .scaleEffect(animateCards ? 1 : 0.9)
                        .opacity(animateCards ? 1 : 0)
                        .animation(.spring().delay(0.2), value: animateCards)
                    }
                    
                    Spacer()
                    
                    // Settings Button
                    HStack(spacing: 20) {
                        // TEST BUTTON - TEMPORARY FOR DEBUGGING
                        Button(action: {
                            selectedMode = .testPaint
                        }) {
                            Label("Test 3D Paint", systemImage: "paintbrush.pointed.fill")
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color.red)
                                )
                        }
                        
                        Button(action: {
                            if userAgeGroup == "under13" {
                                showingParentGate = true
                            } else {
                                selectedMode = .settings
                            }
                        }) {
                            Label("Settings", systemImage: "gearshape.fill")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color.gray.opacity(0.1))
                                )
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            withAnimation {
                animateCards = true
            }
        }
        .sheet(isPresented: $showingParentGate) {
            SimpleParentGateView {
                showingParentGate = false
                selectedMode = .settings
            }
        }
    }
}

// MARK: - Mode Card Component
struct ModeCard: View {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
    let features: [String]
    let isRecommended: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with icon
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(color)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(title)
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                            
                            if isRecommended {
                                Text("RECOMMENDED")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(Color.green)
                                    )
                            }
                        }
                        
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                // Features
                HStack(spacing: 12) {
                    ForEach(features, id: \.self) { feature in
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(color)
                            Text(feature)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: color.opacity(0.2), radius: 10, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isRecommended ? color.opacity(0.3) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @Binding var preferredMode: String
    @Binding var userAgeGroup: String
    let completion: () -> Void
    
    @State private var currentPage = 0
    @State private var selectedAge = "under13"
    
    var body: some View {
        TabView(selection: $currentPage) {
            // Page 1: Welcome
            OnboardingPage1()
                .tag(0)
            
            // Page 2: Age Selection
            OnboardingPage2(selectedAge: $selectedAge)
                .tag(1)
            
            // Page 3: Ready to Create
            OnboardingPage3(
                selectedAge: selectedAge,
                completion: {
                    userAgeGroup = selectedAge
                    preferredMode = selectedAge == "under13" ? "express" : "studio"
                    hasCompletedOnboarding = true
                    completion()
                }
            )
            .tag(2)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct OnboardingPage1: View {
    @State private var animateEmoji = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Animated icon
            Text("🎨")
                .font(.system(size: 100))
                .scaleEffect(animateEmoji ? 1.2 : 1.0)
                .animation(
                    .easeInOut(duration: 2).repeatForever(autoreverses: true),
                    value: animateEmoji
                )
            
            VStack(spacing: 16) {
                Text("Welcome to\nSkinCrafter")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text("Create amazing Minecraft skins\nin seconds!")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Text("Swipe to continue")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 50)
        }
        .padding()
        .onAppear {
            animateEmoji = true
        }
    }
}

struct OnboardingPage2: View {
    @Binding var selectedAge: String
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Who's Creating?")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                
                Text("This helps us show the right tools")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            // Age selection buttons - Large 80x80pt
            VStack(spacing: 20) {
                AgeButton(
                    title: "Under 13",
                    emoji: "🌟",
                    description: "Simple & fun tools",
                    isSelected: selectedAge == "under13"
                ) {
                    selectedAge = "under13"
                }
                
                AgeButton(
                    title: "13 and up",
                    emoji: "🚀",
                    description: "Professional features",
                    isSelected: selectedAge == "over13"
                ) {
                    selectedAge = "over13"
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            Text("You can change this anytime")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 50)
        }
        .padding()
    }
}

struct AgeButton: View {
    let title: String
    let emoji: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Text(emoji)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .purple : .gray)
            }
            .padding(20)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.purple.opacity(0.1) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct OnboardingPage3: View {
    let selectedAge: String
    let completion: () -> Void
    @State private var animateButton = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .scaleEffect(animateButton ? 1.1 : 1.0)
                .animation(
                    .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                    value: animateButton
                )
            
            VStack(spacing: 16) {
                Text("You're All Set!")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                
                Text(selectedAge == "under13" ? 
                     "Let's create something amazing!" : 
                     "Professional tools await you!")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Start button - Large 80pt height
            Button(action: completion) {
                Text("Start Creating")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: .purple.opacity(0.3), radius: 10, y: 5)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .padding()
        .onAppear {
            animateButton = true
        }
    }
}

// Removed duplicate StudioModeView - it is now in a separate file

// Removed duplicate SettingsView - it is now in a separate file

// MARK: - Simple Parent Gate View (for non-export actions)
struct SimpleParentGateView: View {
    let onSuccess: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var answer = ""
    
    private let question = "What is 7 + 5?"
    private let correctAnswer = "12"
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "lock.shield")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Parent Verification")
                    .font(.title.bold())
                
                Text("Please solve this problem to continue")
                    .foregroundColor(.secondary)
                
                VStack(spacing: 20) {
                    Text(question)
                        .font(.title2)
                    
                    TextField("Answer", text: $answer)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                        .multilineTextAlignment(.center)
                }
                
                Button("Verify") {
                    if answer == correctAnswer {
                        onSuccess()
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(answer.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Template Card
struct TemplateCard: View {
    let template: BaseSkinTemplate
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                // Template preview
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 100)
                    .overlay(
                        Image(systemName: template.icon)
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
                
                Text(template.name)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environmentObject(SkinManager())
        .environmentObject(AdManager())
}