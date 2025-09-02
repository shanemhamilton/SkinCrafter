import SwiftUI

struct StudioModeView: View {
    @EnvironmentObject var skinManager: SkinManager
    
    var body: some View {
        VStack {
            Text("Studio Mode")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Text("Professional editing tools coming soon!")
                .font(.title2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            // Placeholder for now - can use ProfessionalEditorView later
            ProfessionalEditorView()
                .environmentObject(skinManager)
        }
    }
}

struct StudioModeView_Previews: PreviewProvider {
    static var previews: some View {
        StudioModeView()
            .environmentObject(SkinManager())
    }
}