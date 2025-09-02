import SwiftUI

struct LaunchScreen: View {
    @State private var isAnimating = false
    @State private var rotationAngle = 0.0
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.576, green: 0.267, blue: 0.678),
                    Color(red: 0.267, green: 0.576, blue: 0.878)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Animated logo/icon
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.8), .white.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(rotationAngle))
                    
                    // Minecraft-style pixelated block
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color(red: 0.96, green: 0.80, blue: 0.69))
                                .frame(width: 20, height: 20)
                            Rectangle()
                                .fill(Color(red: 0.96, green: 0.80, blue: 0.69))
                                .frame(width: 20, height: 20)
                            Rectangle()
                                .fill(Color(red: 0.96, green: 0.80, blue: 0.69))
                                .frame(width: 20, height: 20)
                        }
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 20, height: 20)
                            Rectangle()
                                .fill(Color(red: 0.96, green: 0.80, blue: 0.69))
                                .frame(width: 20, height: 20)
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 20, height: 20)
                        }
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 20, height: 20)
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 20, height: 20)
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 20, height: 20)
                        }
                    }
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.7)
                }
                
                // App name
                Text("SkinCrafter")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                    .scaleEffect(isAnimating ? 1.0 : 0.9)
                
                // Tagline
                Text("Create Epic Minecraft Skins!")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                Spacer()
                    .frame(height: 50)
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                Text("Loading awesome tools...")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .opacity(isAnimating ? 1.0 : 0.0)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                isAnimating = true
            }
            
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

#Preview {
    LaunchScreen()
}