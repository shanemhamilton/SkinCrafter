import SwiftUI
// TODO: Fix GoogleMobileAds import issue
// import GoogleMobileAds

@main
struct SkinCrafterApp: App {
    @StateObject private var skinManager = SkinManager()
    
    init() {
        // Initialize haptic feedback manager
        _ = HapticManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            MainEditorView()
                .environmentObject(skinManager)
        }
    }
}

class SkinManager: ObservableObject {
    @Published var currentSkin: CharacterSkin
    @Published var selectedTool: DrawingTool = .pencil
    @Published var selectedColor: Color = .black
    @Published var brushSize: CGFloat = 1.0
    @Published var isShowingPreview = true
    @Published var selectedLayer: SkinLayer = .base
    @Published var autoRotate = true
    @Published var rotationSpeed: Double = 30.0 // seconds per revolution
    
    // Undo/Redo support
    private var undoStack: [CharacterSkin] = []
    private var redoStack: [CharacterSkin] = []
    private let maxUndoStates = 50
    
    
    init() {
        // Initialize with Steve skin template by default
        self.currentSkin = CharacterSkin()
        
        // Apply the Steve skin template
        if let defaultSkinData = DefaultSkinTemplates.createSteveSkin().pngData() {
            if let skinWithDefaults = CharacterSkin(pngData: defaultSkinData) {
                self.currentSkin = skinWithDefaults
            }
        }
        
        // Initialize first undo state
        saveUndoState()
    }
    
    func exportSkin() -> Data? {
        return currentSkin.toPNGData()
    }
    
    func importSkin(from data: Data) {
        if let skin = CharacterSkin(pngData: data) {
            self.currentSkin = skin
        }
    }
    
    func resetSkin() {
        // Save current state before reset
        saveUndoState()
        
        // Reset to default skin template instead of empty
        if let defaultSkinData = DefaultSkinTemplates.createDefaultSkin().pngData() {
            if let skinWithDefaults = CharacterSkin(pngData: defaultSkinData) {
                self.currentSkin = skinWithDefaults
            }
        } else {
            self.currentSkin = CharacterSkin()
        }
    }
    
    // MARK: - Undo/Redo Management
    
    func saveUndoState() {
        // Create a deep copy of current skin
        if let pngData = currentSkin.toPNGData(),
           let skinCopy = CharacterSkin(pngData: pngData) {
            undoStack.append(skinCopy)
            
            // Limit undo stack size
            if undoStack.count > maxUndoStates {
                undoStack.removeFirst()
            }
            
            // Clear redo stack when new action is performed
            redoStack.removeAll()
        }
    }
    
    func undo() {
        guard undoStack.count > 1 else { return } // Keep at least one state
        
        // Save current state to redo stack
        if let pngData = currentSkin.toPNGData(),
           let skinCopy = CharacterSkin(pngData: pngData) {
            redoStack.append(skinCopy)
        }
        
        // Remove current state and restore previous
        undoStack.removeLast()
        if let previousState = undoStack.last {
            if let pngData = previousState.toPNGData(),
               let restoredSkin = CharacterSkin(pngData: pngData) {
                currentSkin = restoredSkin
            }
        }
    }
    
    func redo() {
        guard !redoStack.isEmpty else { return }
        
        // Save current state to undo stack
        saveUndoState()
        
        // Restore state from redo stack
        if let redoState = redoStack.popLast() {
            if let pngData = redoState.toPNGData(),
               let restoredSkin = CharacterSkin(pngData: pngData) {
                currentSkin = restoredSkin
            }
        }
    }
    
    var canUndo: Bool {
        return undoStack.count > 1
    }
    
    var canRedo: Bool {
        return !redoStack.isEmpty
    }
    
    func trackPaint() {
        // Placeholder for tracking paint actions/achievements
        // Could be used for analytics or achievement system
    }
    
    func trackExport() {
        // Placeholder for tracking export actions/achievements
        // Could be used for analytics or achievement system
    }
}
