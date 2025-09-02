import SwiftUI

struct ModeSelectorView: View {
    @Binding var selectedMode: ContentView.EditorMode
    let userAgeGroup: String
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 16) {
                Text("SkinCrafter")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.primary)
                
                Text("Choose your creation mode")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 50)
            
            // Mode selection cards
            VStack(spacing: 20) {
                // Express Mode
                Button(action: {
                    withAnimation(.spring()) {
                        selectedMode = .express
                    }
                }) {
                    ModeCard(
                        title: "Express Mode",
                        subtitle: "Quick & Fun",
                        description: "Perfect for kids and quick creations",
                        icon: "paintbrush.fill",
                        color: .purple
                    )
                }
                
                // Studio Mode
                Button(action: {
                    withAnimation(.spring()) {
                        selectedMode = .studio
                    }
                }) {
                    ModeCard(
                        title: "Studio Mode",
                        subtitle: "Professional",
                        description: "Full editing tools and features",
                        icon: "slider.horizontal.3",
                        color: .blue
                    )
                }
                
                // Test Paint Mode (for development)
                Button(action: {
                    withAnimation(.spring()) {
                        selectedMode = .testPaint
                    }
                }) {
                    ModeCard(
                        title: "Test Paint",
                        subtitle: "Development",
                        description: "Test 3D painting functionality",
                        icon: "hammer.fill",
                        color: .orange
                    )
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}

struct ModeCard: View {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .bold()
                    
                    Spacer()
                    
                    Text(subtitle)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.2))
                        .foregroundColor(color)
                        .cornerRadius(8)
                }
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct ModeSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ModeSelectorView(
            selectedMode: .constant(.modeSelector),
            userAgeGroup: "under13"
        )
    }
}