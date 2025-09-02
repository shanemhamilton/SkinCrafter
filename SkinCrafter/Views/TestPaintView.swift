import SwiftUI

// MARK: - Test Paint View
// Simple test view to verify 3D painting functionality
struct TestPaintView: View {
    @StateObject private var skinManager = SkinManager()
    @State private var selectedColor: Color = .red
    @State private var paintCount = 0
    @State private var lastPaintLocation = "None"
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("3D Paint Test")
                .font(.largeTitle)
                .bold()
            
            // Paint count
            HStack {
                Text("Paint Count: \(paintCount)")
                    .font(.headline)
                Spacer()
                Text("Last: \(lastPaintLocation)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            // Color picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach([Color.red, .orange, .yellow, .green, .blue, .purple, .pink, .brown, .black, .white], id: \.description) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(selectedColor == color ? Color.purple : Color.gray.opacity(0.3), lineWidth: selectedColor == color ? 3 : 1)
                            )
                            .onTapGesture {
                                selectedColor = color
                                skinManager.selectedColor = color
                            }
                    }
                }
                .padding(.horizontal)
            }
            
            // Static 3D Preview (painting disabled in this test)
            Skin3DPreview()
            .environmentObject(skinManager)
            .frame(maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .padding()
            
            // Controls
            HStack(spacing: 20) {
                Button(action: {
                    skinManager.undo()
                }) {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                }
                .disabled(!skinManager.canUndo)
                
                Button(action: {
                    skinManager.redo()
                }) {
                    Label("Redo", systemImage: "arrow.uturn.forward")
                }
                .disabled(!skinManager.canRedo)
                
                Button(action: {
                    skinManager.resetSkin()
                    paintCount = 0
                    lastPaintLocation = "None"
                }) {
                    Label("Reset", systemImage: "arrow.clockwise")
                }
                .foregroundColor(.red)
            }
            .padding()
            
            // Instructions
            Text("Use the 2D editor; 3D shows live preview")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .onAppear {
            // Set initial color in skin manager
            skinManager.selectedColor = selectedColor
        }
    }
}

// MARK: - Preview
struct TestPaintView_Previews: PreviewProvider {
    static var previews: some View {
        TestPaintView()
    }
}
