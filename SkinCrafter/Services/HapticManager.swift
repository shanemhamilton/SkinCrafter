import UIKit
import SwiftUI

// MARK: - Haptic Manager
/// Manages all haptic feedback in the app with COPPA-compliant settings
class HapticManager: ObservableObject {
    static let shared = HapticManager()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()
    
    private var isEnabled: Bool {
        // Check user preferences (can be disabled for younger users or accessibility)
        UserDefaults.standard.bool(forKey: "haptics_enabled") != false
    }
    
    private init() {
        // Prepare generators to reduce latency
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selectionGenerator.prepare()
        notification.prepare()
    }
    
    // MARK: - Impact Feedback
    
    /// Light impact for subtle interactions (color selection, tool switching)
    func lightImpact() {
        guard isEnabled else { return }
        impactLight.impactOccurred()
        impactLight.prepare() // Re-prepare for next use
    }
    
    /// Convenience method for light impact
    func light() {
        lightImpact()
    }
    
    /// Convenience method for medium impact
    func medium() {
        impact(.medium)
    }
    
    /// Convenience method for heavy impact
    func heavy() {
        impact(.heavy)
    }
    
    /// Convenience method for selection feedback
    func selection() {
        selectionChanged()
    }
    
    /// Medium impact for standard interactions (button taps, mode switches)
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard isEnabled else { return }
        switch style {
        case .light:
            lightImpact()
        case .medium:
            impactMedium.impactOccurred()
            impactMedium.prepare()
        case .heavy:
            impactHeavy.impactOccurred()
            impactHeavy.prepare()
        default:
            impactMedium.impactOccurred()
            impactMedium.prepare()
        }
    }
    
    // MARK: - Selection Feedback
    
    /// Selection changed feedback (scrolling through options, changing values)
    func selectionChanged() {
        guard isEnabled else { return }
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }
    
    // MARK: - Notification Feedback
    
    /// Success feedback (task completed, skin saved)
    func success() {
        guard isEnabled else { return }
        notification.notificationOccurred(.success)
        notification.prepare()
    }
    
    /// Warning feedback (invalid action, limit reached)
    func warning() {
        guard isEnabled else { return }
        notification.notificationOccurred(.warning)
        notification.prepare()
    }
    
    /// Error feedback (action failed, export error)
    func error() {
        guard isEnabled else { return }
        notification.notificationOccurred(.error)
        notification.prepare()
    }
    
    // MARK: - Custom Patterns
    
    /// Play a celebration pattern for achievements
    func celebration() {
        guard isEnabled else { return }
        
        DispatchQueue.main.async {
            self.impactLight.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.impactMedium.impactOccurred()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.success()
                }
            }
        }
    }
    
    /// Play a painting pattern for drawing actions
    func paint() {
        guard isEnabled else { return }
        impactLight.impactOccurred()
        impactLight.prepare()
    }
    
    /// Play a tool selection pattern
    func toolSelected() {
        guard isEnabled else { return }
        selectionChanged()
    }
    
    // MARK: - Settings
    
    /// Enable or disable haptic feedback
    func setEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "haptics_enabled")
    }
    
    /// Check if haptics are supported on this device
    var isSupported: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}