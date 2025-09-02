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
                        .environmentObject(skinManager)
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
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(8)
                            }
                            .padding()
                        }
                        .transition(.move(edge: .trailing))
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentMode)
        }
        .onAppear {
            // Check if onboarding should be shown
            if !hasCompletedOnboarding {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingOnboarding = true
                }
            }
            
            // Set initial mode based on preferences
            if hasCompletedOnboarding && preferredMode != "selector" {
                currentMode = preferredMode == "express" ? .express : .studio
            }
        }
        .sheet(isPresented: $showingOnboarding) {
            OnboardingView { selectedAgeGroup in
                userAgeGroup = selectedAgeGroup
                hasCompletedOnboarding = true
                preferredMode = selectedAgeGroup == "under13" ? "express" : "studio"
                currentMode = .modeSelector
            }
        }
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    let onComplete: (String) -> Void
    @State private var selectedAgeGroup: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to SkinCrafter!")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("First, let us know your age group to customize your experience")
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                Button(action: {
                    selectedAgeGroup = "under13"
                    completeOnboarding()
                }) {
                    Text("Under 13")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.purple)
                        .cornerRadius(15)
                }
                
                Button(action: {
                    selectedAgeGroup = "teen"
                    completeOnboarding()
                }) {
                    Text("13 or Older")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
            }
            .padding(.horizontal)
            
            Text("This helps us show you the right tools and features")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .interactiveDismissDisabled()
    }
    
    private func completeOnboarding() {
        onComplete(selectedAgeGroup)
        dismiss()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SkinManager())
    }
}