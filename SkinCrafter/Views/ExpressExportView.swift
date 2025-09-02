import SwiftUI
import Photos

// MARK: - Express Export View
// Kid-friendly export interface with 70x70pt touch targets and celebration animations

struct ExpressExportView: View {
    @EnvironmentObject var skinManager: SkinManager
    @EnvironmentObject var exportManager: ExportManager
    @EnvironmentObject var hapticManager: HapticManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDestination: ExportManager.ExportDestination?
    @State private var showSuccess = false
    @State private var successMessage = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var animateButtons = false
    
    let analytics = AnalyticsManager.shared
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                headerView
                
                // 3D Preview
                previewSection
                
                // Export Options (70x70pt buttons)
                exportOptionsGrid
                
                Spacer()
                
                // Back button
                backButton
            }
            .padding()
            
            // Success overlay
            if showSuccess {
                SuccessOverlay(message: successMessage)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Parent gate sheet
            if exportManager.showParentGate {
                ParentGateView(exportManager: exportManager)
                    .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
                animateButtons = true
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 10) {
            Image(systemName: "square.and.arrow.up.fill")
                .font(.system(size: 50))
                .foregroundColor(.purple)
                .scaleEffect(animateButtons ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateButtons)
            
            Text("Save Your Skin!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Tap where you want to save")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Preview Section
    
    private var previewSection: some View {
        VStack(spacing: 15) {
            // Skin preview
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                
                let image = skinManager.currentSkin.toUIImage()
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
            }
            .frame(width: 180, height: 180)
            .scaleEffect(animateButtons ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: animateButtons)
            
            HStack(spacing: 20) {
                Label("Ready to save!", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.green)
            }
        }
    }
    
    // MARK: - Export Options Grid
    
    private var exportOptionsGrid: some View {
        VStack(spacing: 20) {
            Text("Where to save?")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                // Photos button (no parent gate needed)
                ExpressExportButton(
                    icon: "photo.fill",
                    title: "Photos",
                    color: .blue,
                    delay: 0.1
                ) {
                    exportToPhotos()
                }
                
                // Files button (no parent gate needed)
                ExpressExportButton(
                    icon: "folder.fill",
                    title: "Files",
                    color: .orange,
                    delay: 0.2
                ) {
                    exportToFiles()
                }
                
                // Minecraft button (parent gate required)
                ExpressExportButton(
                    icon: "cube.fill",
                    title: "Minecraft",
                    color: .green,
                    delay: 0.3,
                    requiresParent: true
                ) {
                    exportToMinecraft()
                }
                
                // Share button (parent gate required)
                ExpressExportButton(
                    icon: "square.and.arrow.up",
                    title: "Share",
                    color: .purple,
                    delay: 0.4,
                    requiresParent: true
                ) {
                    shareViaAirDrop()
                }
            }
        }
        .opacity(animateButtons ? 1.0 : 0)
        .animation(.easeInOut(duration: 0.4).delay(0.2), value: animateButtons)
    }
    
    // MARK: - Back Button
    
    private var backButton: some View {
        Button(action: {
            hapticManager.selectionChanged()
            dismiss()
        }) {
            HStack {
                Image(systemName: "arrow.left")
                Text("Back")
            }
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(.white)
            .frame(width: 120, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray)
            )
        }
    }
    
    // MARK: - Export Actions
    
    private func exportToPhotos() {
        hapticManager.selectionChanged()
        analytics.trackExpressExport(success: false)
        
        exportManager.exportSkin(
            skinManager.currentSkin,
            format: .png64x64,
            destination: .photoLibrary
        ) { success, message in
            if success {
                showSuccessMessage("Saved to Photos! 🎨")
                analytics.trackExpressExport(success: true)
                skinManager.trackExport()
                
                // Auto-dismiss after success
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    dismiss()
                }
            } else {
                showErrorMessage(message ?? "Failed to save")
            }
        }
    }
    
    private func exportToFiles() {
        hapticManager.selectionChanged()
        
        exportManager.exportSkin(
            skinManager.currentSkin,
            format: .png64x64,
            destination: .files
        ) { success, message in
            if success {
                analytics.trackExpressExport(success: true)
                skinManager.trackExport()
            }
        }
    }
    
    private func exportToMinecraft() {
        hapticManager.selectionChanged()
        
        exportManager.exportSkin(
            skinManager.currentSkin,
            format: .minecraftReady,
            destination: .minecraft
        ) { success, message in
            if success {
                showSuccessMessage("Opening Minecraft! 🎮")
                analytics.trackExpressExport(success: true)
                skinManager.trackExport()
            } else {
                showErrorMessage(message ?? "Minecraft not found")
            }
        }
    }
    
    private func shareViaAirDrop() {
        hapticManager.selectionChanged()
        
        exportManager.exportSkin(
            skinManager.currentSkin,
            format: .png64x64,
            destination: .share
        ) { success, message in
            if success {
                analytics.trackExpressExport(success: true)
                skinManager.trackExport()
            }
        }
    }
    
    // MARK: - Feedback Messages
    
    private func showSuccessMessage(_ message: String) {
        successMessage = message
        hapticManager.success()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            showSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSuccess = false
            }
        }
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        hapticManager.error()
        
        withAnimation {
            showError = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showError = false
            }
        }
    }
}


// MARK: - Success Overlay

struct SuccessOverlay: View {
    let message: String
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text(message)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

// MARK: - Express Export Button Component

struct ExpressExportButton: View {
    let icon: String
    let title: String
    let color: Color
    let delay: Double
    var requiresParent: Bool = false
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isAnimated = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isPressed = true
            }
            
            action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(color.gradient)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    
                    if requiresParent {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))
                            .offset(x: 30, y: -30)
                    }
                }
                .scaleEffect(isPressed ? 0.9 : (isAnimated ? 1.0 : 0.8))
                .shadow(color: color.opacity(0.3), radius: isPressed ? 5 : 10, y: isPressed ? 2 : 5)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay)) {
                isAnimated = true
            }
        }
    }
}