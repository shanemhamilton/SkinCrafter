import SwiftUI

// MARK: - Express Creation Mode View
/// Main entry point for Express mode that can switch between guided and freeform creation
struct ExpressCreationModeView: View {
    @EnvironmentObject var skinManager: SkinManager
    @State private var creationMode: CreationMode = .guided
    @State private var hasSeenTutorial = UserDefaults.standard.bool(forKey: "hasSeenGuidedTutorial")
    
    enum CreationMode {
        case guided
        case freeform
    }
    
    var body: some View {
        ZStack {
            switch creationMode {
            case .guided:
                ExpressGuidedFlow()
                    .environmentObject(skinManager)
                    .transition(AnyTransition.asymmetric(
                        insertion: AnyTransition.move(edge: .leading),
                        removal: AnyTransition.move(edge: .trailing)
                    ))
            case .freeform:
                ExpressModeView()
                    .environmentObject(skinManager)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            }
            
            // Mode switcher overlay
            VStack {
                HStack {
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            withAnimation(.spring()) {
                                creationMode = .guided
                            }
                        }) {
                            Label("Guided Mode", systemImage: "person.fill.questionmark")
                        }
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                creationMode = .freeform
                            }
                        }) {
                            Label("Freeform Mode", systemImage: "paintbrush")
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: creationMode == .guided ? "person.fill.questionmark" : "paintbrush")
                            Text(creationMode == .guided ? "Guided" : "Freeform")
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.1), radius: 4)
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .onAppear {
            // Default to guided mode for first-time users
            if !hasSeenTutorial {
                creationMode = .guided
                UserDefaults.standard.set(true, forKey: "hasSeenGuidedTutorial")
            }
        }
    }
}
