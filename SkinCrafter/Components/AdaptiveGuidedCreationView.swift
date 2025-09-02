import SwiftUI
import SceneKit

// MARK: - Adaptive Guided Creation View
/// Main container that switches between compact (iPhone) and regular (iPad) layouts
struct AdaptiveGuidedCreationView: View {
    @EnvironmentObject var skinManager: SkinManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @StateObject private var flowState = AdaptiveFlowState()
    
    var isCompact: Bool {
        horizontalSizeClass == .compact || verticalSizeClass == .compact
    }
    
    var body: some View {
        Group {
            if isCompact {
                CompactCreationView(flowState: flowState)
            } else {
                RegularCreationView(flowState: flowState)
            }
        }
        .environmentObject(flowState)
    }
}

// MARK: - Adaptive Flow State
class AdaptiveFlowState: ObservableObject {
    @Published var currentPart: BodyPart = .head
    @Published var editedParts: Set<BodyPart> = []
    @Published var selectedColor: Color = .blue
    @Published var enableMirroring = true
    @Published var brushSize: CGFloat = 2
    @Published var isComplete = false
    @Published var showingExport = false
    @Published var showingTools = false
    @Published var isPainting = false
    
    // Computed properties
    var progress: Double {
        Double(editedParts.count) / Double(BodyPart.allCases.count)
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
    
    var currentPartIndex: Int {
        BodyPart.allCases.firstIndex(of: currentPart) ?? 0
    }
    
    var hasNextPart: Bool {
        currentPartIndex < BodyPart.allCases.count - 1
    }
    
    var hasPreviousPart: Bool {
        currentPartIndex > 0
    }
    
    // Navigation methods
    func nextPart() {
        let allParts = BodyPart.allCases
        if currentPartIndex < allParts.count - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentPart = allParts[currentPartIndex + 1]
            }
            HapticManager.shared.lightImpact()
        } else {
            completeFlow()
        }
    }
    
    func previousPart() {
        let allParts = BodyPart.allCases
        if currentPartIndex > 0 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentPart = allParts[currentPartIndex - 1]
            }
            HapticManager.shared.lightImpact()
        }
    }
    
    func selectPart(_ part: BodyPart) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            currentPart = part
        }
        HapticManager.shared.selectionChanged()
    }
    
    func markPartAsEdited(_ part: BodyPart) {
        editedParts.insert(part)
        
        // Check if all parts are complete
        if editedParts.count == BodyPart.allCases.count {
            completeFlow()
        }
    }
    
    func completeFlow() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isComplete = true
        }
        HapticManager.shared.success()
    }
    
    func selectColor(_ color: Color) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedColor = color
        }
        HapticManager.shared.lightImpact()
    }
    
    func toggleMirroring() {
        withAnimation(.easeInOut(duration: 0.2)) {
            enableMirroring.toggle()
        }
        HapticManager.shared.lightImpact()
    }
    
    func resetPart() {
        editedParts.remove(currentPart)
        HapticManager.shared.lightImpact()
    }
}

// MARK: - Clean Design System
struct CleanDesignSystem {
    // Colors
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    static let label = Color(.label)
    static let secondaryLabel = Color(.secondaryLabel)
    static let accent = Color.blue
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    
    // Spacing
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24
    static let spacing32: CGFloat = 32
    
    // Corner Radius
    static let cornerRadius8: CGFloat = 8
    static let cornerRadius12: CGFloat = 12
    static let cornerRadius16: CGFloat = 16
    static let cornerRadius20: CGFloat = 20
    static let cornerRadiusFull: CGFloat = 9999
    
    // Touch Targets
    static let minTouchTarget: CGFloat = 44
    static let standardTouchTarget: CGFloat = 56
    static let largeTouchTarget: CGFloat = 72
    
    // Shadows
    static func lightShadow() -> some View {
        return Color.black.opacity(0.08)
    }
    
    static func mediumShadow() -> some View {
        return Color.black.opacity(0.12)
    }
    
    // Animations
    static let standardSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.8)
    static let smoothSpring = Animation.spring(response: 0.5, dampingFraction: 0.9)
}

// MARK: - Preview Provider
struct AdaptiveGuidedCreationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // iPhone Preview
            AdaptiveGuidedCreationView()
                .environmentObject(SkinManager())
                .previewDevice("iPhone 15")
                .previewDisplayName("iPhone 15")
            
            // iPad Preview
            AdaptiveGuidedCreationView()
                .environmentObject(SkinManager())
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
                .previewDisplayName("iPad Pro")
        }
    }
}