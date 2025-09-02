import Foundation
import SwiftUI

// MARK: - Analytics Manager
// COPPA-compliant anonymous analytics for UX improvement
// NO personal data collection, NO tracking IDs, NO cross-session tracking

class AnalyticsManager: ObservableObject {
    static let shared = AnalyticsManager()
    
    // MARK: - Session Metrics (memory only, cleared on app close)
    @Published private(set) var sessionMetrics = SessionMetrics()
    
    // MARK: - Express Mode Metrics
    @Published private(set) var expressMetrics = ExpressMetrics()
    
    // MARK: - Studio Mode Metrics
    @Published private(set) var studioMetrics = StudioMetrics()
    
    // MARK: - Feature Discovery Metrics
    @Published private(set) var featureMetrics = FeatureDiscoveryMetrics()
    
    private let sessionStart = Date()
    private var isTrackingEnabled = true // Can be disabled by parents
    
    // MARK: - Data Structures
    
    struct SessionMetrics {
        var appLaunches = 0
        var totalSessionTime: TimeInterval = 0
        var lastActiveTime = Date()
        var mode: AppMode = .express
        var ageGroup: AgeGroup = .unknown
        
        enum AppMode {
            case express
            case studio
        }
        
        enum AgeGroup {
            case tier1 // 5-8 (pre/early readers)
            case tier2 // 9-12 (confident readers)
            case tier3 // 13-17 (teens)
            case unknown
        }
    }
    
    struct ExpressMetrics {
        var tapsToFirstCreation = 0
        var timeToFirstCreation: TimeInterval = 0
        var colorChanges = 0
        var toolSwitches = 0
        var successfulExports = 0
        var abandonedSessions = 0
        var threeTapSuccessRate: Double = 0
        var averageSessionLength: TimeInterval = 0
        var mostUsedColors: [Color] = []
        var preferredTools: [DrawingTool] = []
        
        mutating func recordFirstCreation(taps: Int, time: TimeInterval) {
            tapsToFirstCreation = taps
            timeToFirstCreation = time
            
            // Update 3-tap success rate
            if taps <= 3 {
                threeTapSuccessRate = min(1.0, threeTapSuccessRate + 0.1)
            }
        }
    }
    
    struct StudioMetrics {
        var toolUsageCount: [String: Int] = [:]
        var layerSwitches = 0
        var undoRedoActions = 0
        var advancedFeaturesUsed: Set<String> = []
        var timeInDetailWork: TimeInterval = 0
        var precisionToolUsage = 0
        var customBrushCreations = 0
        var exportFormats: [String: Int] = [:]
        
        mutating func trackToolUsage(_ tool: String) {
            toolUsageCount[tool, default: 0] += 1
        }
        
        mutating func trackAdvancedFeature(_ feature: String) {
            advancedFeaturesUsed.insert(feature)
        }
    }
    
    struct FeatureDiscoveryMetrics {
        var microlessonsViewed: Set<String> = []
        var microlessonsCompleted: Set<String> = []
        var tooltipsShown = 0
        var hintsRequested = 0
        var tutorialStepsCompleted = 0
        var featureDiscoveryPath: [String] = []
        
        mutating func trackMicrolesson(_ id: String, completed: Bool) {
            microlessonsViewed.insert(id)
            if completed {
                microlessonsCompleted.insert(id)
            }
        }
        
        mutating func trackFeatureDiscovery(_ feature: String) {
            featureDiscoveryPath.append(feature)
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        sessionMetrics.appLaunches = 1
        sessionMetrics.lastActiveTime = Date()
    }
    
    // MARK: - Express Mode Tracking
    
    func trackExpressPaint(tapCount: Int) {
        guard isTrackingEnabled else { return }
        
        if expressMetrics.tapsToFirstCreation == 0 {
            let timeElapsed = Date().timeIntervalSince(sessionStart)
            expressMetrics.recordFirstCreation(taps: tapCount, time: timeElapsed)
        }
    }
    
    func trackExpressColorChange(to color: Color) {
        guard isTrackingEnabled else { return }
        
        expressMetrics.colorChanges += 1
        
        // Track most used colors (keep top 5)
        if !expressMetrics.mostUsedColors.contains(color) {
            expressMetrics.mostUsedColors.append(color)
            if expressMetrics.mostUsedColors.count > 5 {
                expressMetrics.mostUsedColors.removeFirst()
            }
        }
    }
    
    func trackExpressToolSwitch(to tool: DrawingTool) {
        guard isTrackingEnabled else { return }
        
        expressMetrics.toolSwitches += 1
        
        // Track preferred tools
        if !expressMetrics.preferredTools.contains(tool) {
            expressMetrics.preferredTools.append(tool)
        }
    }
    
    func trackExpressExport(success: Bool) {
        guard isTrackingEnabled else { return }
        
        if success {
            expressMetrics.successfulExports += 1
        }
    }
    
    func trackExpressSessionEnd(completed: Bool) {
        guard isTrackingEnabled else { return }
        
        let sessionLength = Date().timeIntervalSince(sessionStart)
        expressMetrics.averageSessionLength = sessionLength
        
        if !completed && expressMetrics.successfulExports == 0 {
            expressMetrics.abandonedSessions += 1
        }
    }
    
    // MARK: - Studio Mode Tracking
    
    func trackStudioToolUsage(_ tool: String) {
        guard isTrackingEnabled else { return }
        
        studioMetrics.trackToolUsage(tool)
    }
    
    func trackStudioLayerSwitch() {
        guard isTrackingEnabled else { return }
        
        studioMetrics.layerSwitches += 1
        studioMetrics.trackAdvancedFeature("layers")
    }
    
    func trackStudioUndoRedo(action: String) {
        guard isTrackingEnabled else { return }
        
        studioMetrics.undoRedoActions += 1
        
        if studioMetrics.undoRedoActions == 5 {
            studioMetrics.trackAdvancedFeature("undo_mastery")
        }
    }
    
    func trackStudioPrecisionWork(duration: TimeInterval) {
        guard isTrackingEnabled else { return }
        
        studioMetrics.timeInDetailWork += duration
        studioMetrics.precisionToolUsage += 1
        
        if studioMetrics.timeInDetailWork > 300 { // 5 minutes
            studioMetrics.trackAdvancedFeature("detail_oriented")
        }
    }
    
    func trackStudioExport(format: String) {
        guard isTrackingEnabled else { return }
        
        studioMetrics.exportFormats[format, default: 0] += 1
    }
    
    // MARK: - Feature Discovery Tracking
    
    func trackMicrolesson(id: String, completed: Bool = false) {
        guard isTrackingEnabled else { return }
        
        featureMetrics.trackMicrolesson(id, completed: completed)
    }
    
    func trackTooltipShown() {
        guard isTrackingEnabled else { return }
        
        featureMetrics.tooltipsShown += 1
    }
    
    func trackHintRequested() {
        guard isTrackingEnabled else { return }
        
        featureMetrics.hintsRequested += 1
    }
    
    func trackFeatureDiscovered(_ feature: String) {
        guard isTrackingEnabled else { return }
        
        featureMetrics.trackFeatureDiscovery(feature)
    }
    
    // MARK: - Mode Switching
    
    func trackModeSwitch(to mode: SessionMetrics.AppMode) {
        guard isTrackingEnabled else { return }
        
        sessionMetrics.mode = mode
        
        // Track discovery of studio mode
        if mode == .studio {
            featureMetrics.trackFeatureDiscovery("studio_mode")
        }
    }
    
    // MARK: - Age Group Detection (Anonymous)
    
    func detectAgeGroup(fromInteractions: [String]) {
        // Infer age group from interaction patterns (no personal data)
        // This is based on UI interaction patterns only
        
        let readingSpeed = calculateReadingSpeed(fromInteractions: fromInteractions)
        let toolComplexity = calculateToolComplexity(fromInteractions: fromInteractions)
        
        if readingSpeed < 0.3 && toolComplexity < 0.3 {
            sessionMetrics.ageGroup = .tier1
        } else if readingSpeed < 0.7 && toolComplexity < 0.7 {
            sessionMetrics.ageGroup = .tier2
        } else {
            sessionMetrics.ageGroup = .tier3
        }
    }
    
    private func calculateReadingSpeed(fromInteractions: [String]) -> Double {
        // Anonymous calculation based on UI interaction speed
        return 0.5 // Placeholder
    }
    
    private func calculateToolComplexity(fromInteractions: [String]) -> Double {
        // Anonymous calculation based on tool usage patterns
        return 0.5 // Placeholder
    }
    
    // MARK: - Privacy Controls
    
    func disableTracking() {
        isTrackingEnabled = false
        clearAllMetrics()
    }
    
    func enableTracking() {
        isTrackingEnabled = true
    }
    
    private func clearAllMetrics() {
        sessionMetrics = SessionMetrics()
        expressMetrics = ExpressMetrics()
        studioMetrics = StudioMetrics()
        featureMetrics = FeatureDiscoveryMetrics()
    }
    
    // MARK: - Metrics Export (Anonymous Aggregates Only)
    
    func generateAnonymousReport() -> [String: Any] {
        guard isTrackingEnabled else { return [:] }
        
        return [
            "session": [
                "mode": sessionMetrics.mode == .express ? "express" : "studio",
                "duration": Int(Date().timeIntervalSince(sessionStart))
            ],
            "express": [
                "three_tap_success": expressMetrics.threeTapSuccessRate > 0.5,
                "exports": expressMetrics.successfulExports,
                "tool_switches": expressMetrics.toolSwitches
            ],
            "studio": [
                "features_discovered": studioMetrics.advancedFeaturesUsed.count,
                "layer_usage": studioMetrics.layerSwitches > 0,
                "precision_work": studioMetrics.precisionToolUsage > 0
            ],
            "learning": [
                "microlessons_completed": featureMetrics.microlessonsCompleted.count,
                "hints_used": featureMetrics.hintsRequested
            ]
        ]
    }
    
    // MARK: - Cognitive Skill Tracking (Educational Purpose)
    
    func trackCognitiveSkill(_ skill: CognitiveSkill, level: Int) {
        guard isTrackingEnabled else { return }
        
        // Track cognitive skill development (anonymous, educational metrics)
        switch skill {
        case .spatialReasoning:
            featureMetrics.trackFeatureDiscovery("3d_rotation_used")
        case .workingMemory:
            if studioMetrics.layerSwitches > 5 {
                featureMetrics.trackFeatureDiscovery("layer_memory_challenge")
            }
        case .attention:
            if studioMetrics.timeInDetailWork > 180 {
                featureMetrics.trackFeatureDiscovery("sustained_attention")
            }
        case .creativity:
            if expressMetrics.colorChanges > 10 {
                featureMetrics.trackFeatureDiscovery("creative_exploration")
            }
        case .planning:
            if studioMetrics.undoRedoActions < 3 && studioMetrics.precisionToolUsage > 5 {
                featureMetrics.trackFeatureDiscovery("thoughtful_planning")
            }
        }
    }
    
    enum CognitiveSkill {
        case spatialReasoning
        case workingMemory
        case attention
        case creativity
        case planning
    }
}

// MARK: - Analytics Event Helper
struct AnalyticsEvent {
    let category: String
    let action: String
    let label: String?
    let value: Int?
    
    static func expressMode(_ action: String, label: String? = nil, value: Int? = nil) -> AnalyticsEvent {
        return AnalyticsEvent(category: "express", action: action, label: label, value: value)
    }
    
    static func studioMode(_ action: String, label: String? = nil, value: Int? = nil) -> AnalyticsEvent {
        return AnalyticsEvent(category: "studio", action: action, label: label, value: value)
    }
    
    static func learning(_ action: String, label: String? = nil, value: Int? = nil) -> AnalyticsEvent {
        return AnalyticsEvent(category: "learning", action: action, label: label, value: value)
    }
}