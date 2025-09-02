import SwiftUI

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

struct SkinTemplateSelector: View {
    @EnvironmentObject var skinManager: SkinManager
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Choose a Starting Template")
                        .font(.headline)
                        .padding(.top)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(DefaultSkinTemplates.availableTemplates) { template in
                            TemplateCard(template: template) {
                                loadTemplate(template)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Skin Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func loadTemplate(_ template: BaseSkinTemplate) {
        if let skinData = template.generator().pngData(),
           let newSkin = CharacterSkin(pngData: skinData) {
            skinManager.currentSkin = newSkin
            isPresented = false
            
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()

            // Recommend palette if provided
            if let palette = template.recommendedPaletteName {
                NotificationCenter.default.post(name: .recommendedPalette, object: nil, userInfo: ["paletteName": palette])
            }
        }
    }
}

extension Notification.Name {
    static let recommendedPalette = Notification.Name("SkinCrafterRecommendedPalette")
}
