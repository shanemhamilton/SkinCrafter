import SwiftUI
import UIKit

enum SkinLayer {
    case base
    case overlay
}

enum DrawingTool: CaseIterable {
    case brush
    case pencil
    case eraser
    case bucket
    case eyedropper
    case line
    case rectangle
    case circle
    case spray
    case mirror
    
    var iconName: String {
        switch self {
        case .brush:
            return "paintbrush.fill"
        case .pencil:
            return "pencil"
        case .eraser:
            return "eraser.fill"
        case .bucket:
            return "drop.fill"
        case .eyedropper:
            return "eyedropper.full"
        case .line:
            return "line.diagonal"
        case .rectangle:
            return "rectangle"
        case .circle:
            return "circle"
        case .spray:
            return "spray.fill"
        case .mirror:
            return "arrow.left.and.right"
        }
    }
    
    var displayName: String {
        switch self {
        case .brush:
            return "Brush"
        case .pencil:
            return "Pencil"
        case .eraser:
            return "Eraser"
        case .bucket:
            return "Fill"
        case .eyedropper:
            return "Color Picker"
        case .line:
            return "Line"
        case .rectangle:
            return "Rectangle"
        case .circle:
            return "Circle"
        case .spray:
            return "Spray"
        case .mirror:
            return "Mirror"
        }
    }
}

struct CharacterSkin {
    static let width = 64
    static let height = 64
    
    private var baseLayer: [[Color]]
    private var overlayLayer: [[Color]]
    
    var modelType: ModelType = .standard
    
    enum ModelType {
        case standard  // 4px arms (compatible with block-game characters)
        case slim      // 3px arms (compatible with slim models)
    }
    
    init() {
        baseLayer = Array(repeating: Array(repeating: Color.clear, count: Self.width), count: Self.height)
        overlayLayer = Array(repeating: Array(repeating: Color.clear, count: Self.width), count: Self.height)
        
        // Initialize with default skin color
        initializeDefaultSkin()
    }
    
    init?(pngData: Data) {
        guard let uiImage = UIImage(data: pngData),
              let cgImage = uiImage.cgImage else { return nil }
        
        baseLayer = Array(repeating: Array(repeating: Color.clear, count: Self.width), count: Self.height)
        overlayLayer = Array(repeating: Array(repeating: Color.clear, count: Self.width), count: Self.height)
        
        // Extract pixels from image
        loadFromCGImage(cgImage)
    }
    
    mutating func setPixel(x: Int, y: Int, color: Color, layer: SkinLayer) {
        guard x >= 0, x < Self.width, y >= 0, y < Self.height else { return }
        
        switch layer {
        case .base:
            baseLayer[y][x] = color
        case .overlay:
            overlayLayer[y][x] = color
        }
    }
    
    func getPixel(x: Int, y: Int, layer: SkinLayer) -> Color {
        guard x >= 0, x < Self.width, y >= 0, y < Self.height else { return .clear }
        
        switch layer {
        case .base:
            return baseLayer[y][x]
        case .overlay:
            return overlayLayer[y][x]
        }
    }
    
    mutating func fill(x: Int, y: Int, color: Color, layer: SkinLayer) {
        guard x >= 0, x < Self.width, y >= 0, y < Self.height else { return }
        
        let targetColor = getPixel(x: x, y: y, layer: layer)
        if targetColor == color { return }
        
        var stack = [(x, y)]
        var visited = Set<String>()
        
        while !stack.isEmpty {
            let (px, py) = stack.removeLast()
            let key = "\(px),\(py)"
            
            if visited.contains(key) { continue }
            visited.insert(key)
            
            if px < 0 || px >= Self.width || py < 0 || py >= Self.height { continue }
            if getPixel(x: px, y: py, layer: layer) != targetColor { continue }
            
            setPixel(x: px, y: py, color: color, layer: layer)
            
            stack.append((px + 1, py))
            stack.append((px - 1, py))
            stack.append((px, py + 1))
            stack.append((px, py - 1))
        }
    }

    // Region-bounded flood fill: limits fill to the provided region ranges (inclusive lowerBound, exclusive upperBound)
    mutating func fillInRegion(x: Int, y: Int, color: Color, layer: SkinLayer, regionX: Range<Int>, regionY: Range<Int>) {
        guard regionX.contains(x), regionY.contains(y) else { return }
        let targetColor = getPixel(x: x, y: y, layer: layer)
        if targetColor == color { return }

        var stack = [(x, y)]
        var visited = Set<String>()

        while let (px, py) = stack.popLast() {
            let key = "\(px),\(py)"
            if visited.contains(key) { continue }
            visited.insert(key)

            if !regionX.contains(px) || !regionY.contains(py) { continue }
            if getPixel(x: px, y: py, layer: layer) != targetColor { continue }

            setPixel(x: px, y: py, color: color, layer: layer)

            stack.append((px + 1, py))
            stack.append((px - 1, py))
            stack.append((px, py + 1))
            stack.append((px, py - 1))
        }
    }
    
    mutating func mirrorHorizontally(fromX: Int, layer: SkinLayer) {
        for y in 0..<Self.height {
            for x in 0..<Self.width/2 {
                let mirroredX = Self.width - 1 - x
                let color = getPixel(x: x, y: y, layer: layer)
                setPixel(x: mirroredX, y: y, color: color, layer: layer)
            }
        }
    }
    
    func hasContent() -> Bool {
        // Check if any pixels have been painted (not clear or default skin tone)
        let defaultSkinTone = Color(red: 0.96, green: 0.80, blue: 0.69)
        
        for row in baseLayer {
            for color in row {
                if color != .clear && color != defaultSkinTone {
                    return true
                }
            }
        }
        for row in overlayLayer {
            for color in row {
                if color != .clear {
                    return true
                }
            }
        }
        return false
    }
    
    private mutating func initializeDefaultSkin() {
        // Initialize with a visible template that covers all body parts
        // This prevents transparent/invisible sections in the 3D model
        
        let skinTone = Color(red: 0.96, green: 0.80, blue: 0.69)
        let shirtColor = Color(red: 0.2, green: 0.6, blue: 0.9) // Light blue
        let pantsColor = Color(red: 0.2, green: 0.3, blue: 0.6) // Dark blue
        let shoeColor = Color(red: 0.3, green: 0.2, blue: 0.15) // Brown
        
        // Head (8x8x8) - All faces
        // Front face (8,8 to 16,16)
        for y in 8..<16 {
            for x in 8..<16 {
                baseLayer[y][x] = skinTone
            }
        }
        // Top (8,0 to 16,8)
        for y in 0..<8 {
            for x in 8..<16 {
                baseLayer[y][x] = Color(red: 0.4, green: 0.25, blue: 0.15) // Hair
            }
        }
        // Right (0,8 to 8,16)
        for y in 8..<16 {
            for x in 0..<8 {
                baseLayer[y][x] = skinTone
            }
        }
        // Back (24,8 to 32,16)
        for y in 8..<16 {
            for x in 24..<32 {
                baseLayer[y][x] = Color(red: 0.4, green: 0.25, blue: 0.15) // Hair back
            }
        }
        // Left (16,8 to 24,16)
        for y in 8..<16 {
            for x in 16..<24 {
                baseLayer[y][x] = skinTone
            }
        }
        // Bottom (16,0 to 24,8)
        for y in 0..<8 {
            for x in 16..<24 {
                baseLayer[y][x] = skinTone
            }
        }
        
        // Body/Torso (8x12x4) - All faces
        // Front (20,20 to 28,32)
        for y in 20..<32 {
            for x in 20..<28 {
                baseLayer[y][x] = shirtColor
            }
        }
        // Back (32,20 to 40,32)
        for y in 20..<32 {
            for x in 32..<40 {
                baseLayer[y][x] = shirtColor
            }
        }
        // Right (16,20 to 20,32)
        for y in 20..<32 {
            for x in 16..<20 {
                baseLayer[y][x] = shirtColor
            }
        }
        // Left (28,20 to 32,32)
        for y in 20..<32 {
            for x in 28..<32 {
                baseLayer[y][x] = shirtColor
            }
        }
        // Top (20,16 to 28,20)
        for y in 16..<20 {
            for x in 20..<28 {
                baseLayer[y][x] = shirtColor
            }
        }
        // Bottom (28,16 to 36,20)
        for y in 16..<20 {
            for x in 28..<36 {
                baseLayer[y][x] = shirtColor
            }
        }
        
        // Right Arm (4x12x4) - All faces
        // Front (44,20 to 48,32)
        for y in 20..<32 {
            for x in 44..<48 {
                baseLayer[y][x] = skinTone
            }
        }
        // Back (52,20 to 56,32)
        for y in 20..<32 {
            for x in 52..<56 {
                baseLayer[y][x] = skinTone
            }
        }
        // Right (40,20 to 44,32)
        for y in 20..<32 {
            for x in 40..<44 {
                baseLayer[y][x] = skinTone
            }
        }
        // Left (48,20 to 52,32)
        for y in 20..<32 {
            for x in 48..<52 {
                baseLayer[y][x] = skinTone
            }
        }
        // Top (44,16 to 48,20)
        for y in 16..<20 {
            for x in 44..<48 {
                baseLayer[y][x] = skinTone
            }
        }
        // Bottom (48,16 to 52,20)
        for y in 16..<20 {
            for x in 48..<52 {
                baseLayer[y][x] = skinTone
            }
        }
        
        // Left Arm (4x12x4) - New format position
        // Front (36,52 to 40,64)
        for y in 52..<64 {
            for x in 36..<40 {
                baseLayer[y][x] = skinTone
            }
        }
        // Back (44,52 to 48,64)
        for y in 52..<64 {
            for x in 44..<48 {
                baseLayer[y][x] = skinTone
            }
        }
        // Right (32,52 to 36,64)
        for y in 52..<64 {
            for x in 32..<36 {
                baseLayer[y][x] = skinTone
            }
        }
        // Left (40,52 to 44,64)
        for y in 52..<64 {
            for x in 40..<44 {
                baseLayer[y][x] = skinTone
            }
        }
        // Top (36,48 to 40,52)
        for y in 48..<52 {
            for x in 36..<40 {
                baseLayer[y][x] = skinTone
            }
        }
        // Bottom (40,48 to 44,52)
        for y in 48..<52 {
            for x in 40..<44 {
                baseLayer[y][x] = skinTone
            }
        }
        
        // Right Leg (4x12x4) - All faces
        // Front (4,20 to 8,32)
        for y in 20..<32 {
            for x in 4..<8 {
                baseLayer[y][x] = pantsColor
            }
        }
        // Back (12,20 to 16,32)
        for y in 20..<32 {
            for x in 12..<16 {
                baseLayer[y][x] = pantsColor
            }
        }
        // Right (0,20 to 4,32)
        for y in 20..<32 {
            for x in 0..<4 {
                baseLayer[y][x] = pantsColor
            }
        }
        // Left (8,20 to 12,32)
        for y in 20..<32 {
            for x in 8..<12 {
                baseLayer[y][x] = pantsColor
            }
        }
        // Top (4,16 to 8,20)
        for y in 16..<20 {
            for x in 4..<8 {
                baseLayer[y][x] = pantsColor
            }
        }
        // Bottom (8,16 to 12,20) - Shoes
        for y in 16..<20 {
            for x in 8..<12 {
                baseLayer[y][x] = shoeColor
            }
        }
        
        // Left Leg (4x12x4) - New format position
        // Front (20,52 to 24,64)
        for y in 52..<64 {
            for x in 20..<24 {
                baseLayer[y][x] = pantsColor
            }
        }
        // Back (28,52 to 32,64)
        for y in 52..<64 {
            for x in 28..<32 {
                baseLayer[y][x] = pantsColor
            }
        }
        // Right (16,52 to 20,64)
        for y in 52..<64 {
            for x in 16..<20 {
                baseLayer[y][x] = pantsColor
            }
        }
        // Left (24,52 to 28,64)
        for y in 52..<64 {
            for x in 24..<28 {
                baseLayer[y][x] = pantsColor
            }
        }
        // Top (20,48 to 24,52)
        for y in 48..<52 {
            for x in 20..<24 {
                baseLayer[y][x] = pantsColor
            }
        }
        // Bottom (24,48 to 28,52) - Shoes
        for y in 48..<52 {
            for x in 24..<28 {
                baseLayer[y][x] = shoeColor
            }
        }
        
        // Add simple face features
        // Eyes
        baseLayer[12][10] = Color.white
        baseLayer[12][11] = Color.blue
        baseLayer[12][13] = Color.blue
        baseLayer[12][14] = Color.white
        
        // Mouth
        for x in 10..<15 {
            baseLayer[14][x] = Color(red: 0.8, green: 0.4, blue: 0.3)
        }
    }
    
    private mutating func loadFromCGImage(_ cgImage: CGImage) {
        let width = cgImage.width
        let height = cgImage.height
        
        guard width == Self.width && height == Self.height else { return }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let pixelData = context.data else { return }
        
        let data = pixelData.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * bytesPerPixel
                let r = CGFloat(data[pixelIndex]) / 255.0
                let g = CGFloat(data[pixelIndex + 1]) / 255.0
                let b = CGFloat(data[pixelIndex + 2]) / 255.0
                let a = CGFloat(data[pixelIndex + 3]) / 255.0
                
                baseLayer[y][x] = Color(red: r, green: g, blue: b).opacity(a)
            }
        }
    }
    
    func toPNGData() -> Data? {
        let width = Self.width
        let height = Self.height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }
        
        for y in 0..<height {
            for x in 0..<width {
                let baseColor = baseLayer[y][x]
                let overlayColor = overlayLayer[y][x]
                
                // Composite overlay on base
                let finalColor = overlayColor == .clear ? baseColor : overlayColor
                
                if let components = UIColor(finalColor).cgColor.components {
                    let rect = CGRect(x: x, y: y, width: 1, height: 1)
                    context.setFillColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
                    context.fill(rect)
                }
            }
        }
        
        guard let cgImage = context.makeImage() else { return nil }
        let uiImage = UIImage(cgImage: cgImage)
        return uiImage.pngData()
    }
}
