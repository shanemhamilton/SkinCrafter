import SwiftUI
import Combine

// MARK: - Undo/Redo System
class UndoRedoManager: ObservableObject {
    @Published var canUndo = false
    @Published var canRedo = false
    
    private var undoStack: [SkinState] = []
    private var redoStack: [SkinState] = []
    private let maxStackSize = 50
    
    struct SkinState {
        let skin: CharacterSkin
        let description: String
        let timestamp: Date
    }
    
    func recordState(_ skin: CharacterSkin, description: String = "Edit") {
        let state = SkinState(skin: skin, description: description, timestamp: Date())
        undoStack.append(state)
        
        // Limit stack size
        if undoStack.count > maxStackSize {
            undoStack.removeFirst()
        }
        
        // Clear redo stack when new action is performed
        redoStack.removeAll()
        
        updateFlags()
    }
    
    func undo() -> CharacterSkin? {
        guard let state = undoStack.popLast() else { return nil }
        redoStack.append(state)
        updateFlags()
        return undoStack.last?.skin
    }
    
    func redo() -> CharacterSkin? {
        guard let state = redoStack.popLast() else { return nil }
        undoStack.append(state)
        updateFlags()
        return state.skin
    }
    
    private func updateFlags() {
        canUndo = !undoStack.isEmpty
        canRedo = !redoStack.isEmpty
    }
    
    func clear() {
        undoStack.removeAll()
        redoStack.removeAll()
        updateFlags()
    }
}

// MARK: - Advanced Drawing Tools
enum AdvancedTool: String, CaseIterable {
    case pencil = "Pencil"
    case brush = "Brush"
    case airbrush = "Airbrush"
    case eraser = "Eraser"
    case fillBucket = "Fill"
    case gradientFill = "Gradient"
    case eyedropper = "Picker"
    case line = "Line"
    case rectangle = "Rectangle"
    case ellipse = "Ellipse"
    case mirror = "Mirror"
    case smudge = "Smudge"
    case blur = "Blur"
    case noise = "Noise"
    case dither = "Dither"
    
    var iconName: String {
        switch self {
        case .pencil: return "pencil.tip"
        case .brush: return "paintbrush.fill"
        case .airbrush: return "aqi.medium"
        case .eraser: return "eraser.fill"
        case .fillBucket: return "drop.fill"
        case .gradientFill: return "square.fill.on.square.fill"
        case .eyedropper: return "eyedropper"
        case .line: return "line.diagonal"
        case .rectangle: return "rectangle"
        case .ellipse: return "circle"
        case .mirror: return "arrow.left.and.right"
        case .smudge: return "scribble"
        case .blur: return "drop.circle"
        case .noise: return "sparkles"
        case .dither: return "checkerboard.rectangle"
        }
    }
    
    var hasSettings: Bool {
        switch self {
        case .pencil, .eraser, .eyedropper, .fillBucket, .mirror:
            return false
        default:
            return true
        }
    }
}

// MARK: - Brush Settings
struct BrushSettings: Codable {
    var size: CGFloat = 1.0
    var opacity: Double = 1.0
    var hardness: Double = 1.0
    var spacing: Double = 0.1
    var jitter: Double = 0.0
    var angleJitter: Double = 0.0
    var scatterAmount: Double = 0.0
    var mixMode: MixMode = .normal
    
    enum MixMode: String, Codable, CaseIterable {
        case normal = "Normal"
        case multiply = "Multiply"
        case screen = "Screen"
        case overlay = "Overlay"
        case softLight = "Soft Light"
        case hardLight = "Hard Light"
        case colorDodge = "Color Dodge"
        case colorBurn = "Color Burn"
        case darken = "Darken"
        case lighten = "Lighten"
        case difference = "Difference"
        case exclusion = "Exclusion"
    }
}

// MARK: - Color Palette Manager
class PaletteManager: ObservableObject {
    @Published var palettes: [ColorPalette] = []
    @Published var currentPalette: ColorPalette?
    @Published var recentColors: [Color] = []
    
    struct ColorPalette: Identifiable, Codable {
        var id: UUID
        var name: String
        var colors: [CodableColor]
        var isLocked: Bool = false
        
        init(name: String, colors: [CodableColor], isLocked: Bool = false) {
            self.id = UUID()
            self.name = name
            self.colors = colors
            self.isLocked = isLocked
        }
        
        struct CodableColor: Codable {
            let red: Double
            let green: Double
            let blue: Double
            let alpha: Double
            
            var color: Color {
                Color(red: red, green: green, blue: blue, opacity: alpha)
            }
            
            init(color: Color) {
                let uiColor = UIColor(color)
                var r: CGFloat = 0
                var g: CGFloat = 0
                var b: CGFloat = 0
                var a: CGFloat = 0
                uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
                self.red = Double(r)
                self.green = Double(g)
                self.blue = Double(b)
                self.alpha = Double(a)
            }
        }
    }
    
    init() {
        loadDefaultPalettes()
    }
    
    private func loadDefaultPalettes() {
        palettes = [
            ColorPalette(name: "Minecraft Classic", colors: [
                ColorPalette.CodableColor(color: Color(red: 0.96, green: 0.80, blue: 0.69)), // Skin
                ColorPalette.CodableColor(color: Color.brown),
                ColorPalette.CodableColor(color: Color.blue),
                ColorPalette.CodableColor(color: Color.green),
                ColorPalette.CodableColor(color: Color.red),
                ColorPalette.CodableColor(color: Color.purple),
                ColorPalette.CodableColor(color: Color.yellow),
                ColorPalette.CodableColor(color: Color.orange),
                ColorPalette.CodableColor(color: Color.gray),
                ColorPalette.CodableColor(color: Color.black),
                ColorPalette.CodableColor(color: Color.white)
            ], isLocked: true),
            
            ColorPalette(name: "Cool Neutrals", colors: [
                ColorPalette.CodableColor(color: Color(red: 0.90, green: 0.92, blue: 0.95)), // light gray-blue
                ColorPalette.CodableColor(color: Color(red: 0.70, green: 0.75, blue: 0.80)), // mid gray-blue
                ColorPalette.CodableColor(color: Color(red: 0.50, green: 0.55, blue: 0.60)), // steel
                ColorPalette.CodableColor(color: Color(red: 0.30, green: 0.35, blue: 0.40)), // dark slate
                ColorPalette.CodableColor(color: Color(red: 0.15, green: 0.18, blue: 0.22)), // near-black cool
                ColorPalette.CodableColor(color: Color(red: 0.95, green: 0.40, blue: 0.50))  // accent
            ], isLocked: true),
            
            ColorPalette(name: "Nature", colors: [
                ColorPalette.CodableColor(color: Color(red: 0.13, green: 0.55, blue: 0.13)),
                ColorPalette.CodableColor(color: Color(red: 0.54, green: 0.27, blue: 0.07)),
                ColorPalette.CodableColor(color: Color(red: 0.53, green: 0.81, blue: 0.92)),
                ColorPalette.CodableColor(color: Color(red: 1.0, green: 0.84, blue: 0.0)),
                ColorPalette.CodableColor(color: Color(red: 0.86, green: 0.08, blue: 0.24))
            ]),
            
            ColorPalette(name: "Pastel", colors: [
                ColorPalette.CodableColor(color: Color(red: 1.0, green: 0.71, blue: 0.76)),
                ColorPalette.CodableColor(color: Color(red: 0.98, green: 0.98, blue: 0.82)),
                ColorPalette.CodableColor(color: Color(red: 0.69, green: 0.88, blue: 0.90)),
                ColorPalette.CodableColor(color: Color(red: 0.96, green: 0.76, blue: 0.96)),
                ColorPalette.CodableColor(color: Color(red: 0.76, green: 0.96, blue: 0.76))
            ])
        ]
        
        currentPalette = palettes.first
    }
    
    func addColorToRecent(_ color: Color) {
        recentColors.removeAll { UIColor($0) == UIColor(color) }
        recentColors.insert(color, at: 0)
        if recentColors.count > 20 {
            recentColors.removeLast()
        }
    }
    
    func createPalette(from skin: CharacterSkin) -> ColorPalette {
        // Extract dominant colors from skin
        var extractedColors = Set<Color>()
        
        for y in 0..<CharacterSkin.height {
            for x in 0..<CharacterSkin.width {
                let color = skin.getPixel(x: x, y: y, layer: .base)
                if color != .clear {
                    extractedColors.insert(color)
                }
            }
        }
        
        // Limit to top 16 most used colors
        let sortedColors = Array(extractedColors).prefix(16)
        let codableColors = sortedColors.map { ColorPalette.CodableColor(color: $0) }
        
        return ColorPalette(name: "Extracted Palette", colors: codableColors)
    }

    func setCurrentPalette(named name: String) {
        if let found = palettes.first(where: { $0.name == name }) {
            currentPalette = found
        }
    }
}

// MARK: - Grid and Guide System
class GridSystem: ObservableObject {
    @Published var showGrid = true
    @Published var showGuides = true
    @Published var showRulers = false
    @Published var showBodyPartOutlines = true
    @Published var showBase = true
    @Published var showOverlay = true
    // Per-overlay-part visibility
    @Published var showHatOverlay = true
    @Published var showJacketOverlay = true
    @Published var showSleevesOverlay = true
    @Published var showPantsOverlay = true
    @Published var autoSymmetry = true
    @Published var gridSize = 8
    @Published var snapToGrid = false
    @Published var symmetryMode: SymmetryMode = .none
    @Published var isolatedParts: Set<BodyPart> = []
    
    enum SymmetryMode: String, CaseIterable {
        case none = "None"
        case horizontal = "Horizontal"
        case vertical = "Vertical"
        case radial = "Radial"
    }
    
    
    func isPixelInIsolatedPart(x: Int, y: Int) -> Bool {
        guard !isolatedParts.isEmpty else { return true }
        
        for part in isolatedParts {
            let region = part.getRegion()
            if region.x.contains(x) && region.y.contains(y) {
                return true
            }
        }
        return false
    }
    
    func snapToGridPoint(_ point: CGPoint) -> CGPoint {
        guard snapToGrid else { return point }
        
        let gridSizeFloat = CGFloat(gridSize)
        let snappedX = round(point.x / gridSizeFloat) * gridSizeFloat
        let snappedY = round(point.y / gridSizeFloat) * gridSizeFloat
        
        return CGPoint(x: snappedX, y: snappedY)
    }
    
    func getMirroredPoints(x: Int, y: Int) -> [(Int, Int)] {
        var points = [(x, y)]
        
        switch symmetryMode {
        case .none:
            break
        case .horizontal:
            let mirroredX = CharacterSkin.width - 1 - x
            points.append((mirroredX, y))
        case .vertical:
            let mirroredY = CharacterSkin.height - 1 - y
            points.append((x, mirroredY))
        case .radial:
            let centerX = CharacterSkin.width / 2
            let centerY = CharacterSkin.height / 2
            let mirroredX = 2 * centerX - x
            let mirroredY = 2 * centerY - y
            points.append((mirroredX, y))
            points.append((x, mirroredY))
            points.append((mirroredX, mirroredY))
        }
        
        return points.filter { $0.0 >= 0 && $0.0 < CharacterSkin.width && $0.1 >= 0 && $0.1 < CharacterSkin.height }
    }
}
