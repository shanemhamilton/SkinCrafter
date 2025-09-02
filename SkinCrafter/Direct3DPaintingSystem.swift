import SwiftUI
import SceneKit

// MARK: - 3D Painting System for Direct Model Editing
class Direct3DPaintingSystem: ObservableObject {
    @Published var skinTexture: UIImage
    @Published var currentColor: Color = .red
    @Published var brushSize: CGFloat = 2.0
    @Published var isPainting = false
    
    private var textureSize = CGSize(width: 64, height: 64)
    private var pixelBuffer: [[Color]]
    
    init() {
        // Initialize with default skin template
        let defaultSkin = DefaultSkinTemplates.createDefaultSkin()
        self.skinTexture = defaultSkin
        self.pixelBuffer = Direct3DPaintingSystem.imageToPixelBuffer(defaultSkin)
    }
    
    // MARK: - Ray Casting & Hit Detection
    func handleTouch(at location: CGPoint, in sceneView: SCNView) {
        guard isPainting else { return }
        
        // Perform hit test to find where on the 3D model was touched
        let hitResults = sceneView.hitTest(location, options: [:])
        
        guard let hit = hitResults.first else { return }
        
        // Get the body part that was hit
        guard let bodyPart = Direct3DBodyPart(nodeName: hit.node.name ?? "") else { return }
        
        // Convert 3D hit coordinates to texture UV coordinates
        let uvCoordinate = convertHitToUV(hit: hit, bodyPart: bodyPart)
        
        // Paint on the texture at the UV coordinate
        paintAtUV(uvCoordinate, bodyPart: bodyPart)
    }
    
    // MARK: - UV Coordinate Mapping
    private func convertHitToUV(hit: SCNHitTestResult, bodyPart: Direct3DBodyPart) -> CGPoint {
        // Get the local coordinates of the hit on the geometry
        let localCoords = hit.localCoordinates
        
        // Get the UV mapping region for this body part
        let uvRegion = bodyPart.uvRegion
        
        // Calculate the UV coordinates based on which face was hit
        let faceNormal = hit.localNormal
        var u: CGFloat = 0
        var v: CGFloat = 0
        
        // Determine which face of the box was hit based on normal
        if abs(faceNormal.z) > 0.5 {
            // Front or back face
            u = CGFloat((localCoords.x + Float(bodyPart.dimensions.width / 2)) / Float(bodyPart.dimensions.width))
            v = 1.0 - CGFloat((localCoords.y + Float(bodyPart.dimensions.height / 2)) / Float(bodyPart.dimensions.height))
            
            if faceNormal.z > 0 {
                // Front face
                u = uvRegion.front.minX + u * (uvRegion.front.maxX - uvRegion.front.minX)
                v = uvRegion.front.minY + v * (uvRegion.front.maxY - uvRegion.front.minY)
            } else {
                // Back face
                u = uvRegion.back.minX + u * (uvRegion.back.maxX - uvRegion.back.minX)
                v = uvRegion.back.minY + v * (uvRegion.back.maxY - uvRegion.back.minY)
            }
        } else if abs(faceNormal.x) > 0.5 {
            // Left or right face
            u = CGFloat((localCoords.z + Float(bodyPart.dimensions.depth / 2)) / Float(bodyPart.dimensions.depth))
            v = 1.0 - CGFloat((localCoords.y + Float(bodyPart.dimensions.height / 2)) / Float(bodyPart.dimensions.height))
            
            if faceNormal.x > 0 {
                // Right face
                u = uvRegion.right.minX + u * (uvRegion.right.maxX - uvRegion.right.minX)
                v = uvRegion.right.minY + v * (uvRegion.right.maxY - uvRegion.right.minY)
            } else {
                // Left face
                u = uvRegion.left.minX + u * (uvRegion.left.maxX - uvRegion.left.minX)
                v = uvRegion.left.minY + v * (uvRegion.left.maxY - uvRegion.left.minY)
            }
        } else {
            // Top or bottom face
            u = CGFloat((localCoords.x + Float(bodyPart.dimensions.width / 2)) / Float(bodyPart.dimensions.width))
            v = CGFloat((localCoords.z + Float(bodyPart.dimensions.depth / 2)) / Float(bodyPart.dimensions.depth))
            
            if faceNormal.y > 0 {
                // Top face
                u = uvRegion.top.minX + u * (uvRegion.top.maxX - uvRegion.top.minX)
                v = uvRegion.top.minY + v * (uvRegion.top.maxY - uvRegion.top.minY)
            } else {
                // Bottom face
                u = uvRegion.bottom.minX + u * (uvRegion.bottom.maxX - uvRegion.bottom.minX)
                v = uvRegion.bottom.minY + v * (uvRegion.bottom.maxY - uvRegion.bottom.minY)
            }
        }
        
        // Convert UV to pixel coordinates
        let pixelX = u * textureSize.width
        let pixelY = v * textureSize.height
        
        return CGPoint(x: pixelX, y: pixelY)
    }
    
    // MARK: - Painting Logic
    private func paintAtUV(_ point: CGPoint, bodyPart: Direct3DBodyPart) {
        let x = Int(point.x)
        let y = Int(point.y)
        
        // Apply brush with size
        let brushRadius = Int(brushSize)
        
        for dy in -brushRadius...brushRadius {
            for dx in -brushRadius...brushRadius {
                let px = x + dx
                let py = y + dy
                
                // Check if within texture bounds
                guard px >= 0, px < Int(textureSize.width),
                      py >= 0, py < Int(textureSize.height) else { continue }
                
                // Check if within brush circle
                let distance = sqrt(Double(dx * dx + dy * dy))
                if distance <= Double(brushRadius) {
                    // Apply color with soft edges
                    let alpha = 1.0 - (distance / Double(brushRadius))
                    let blendedColor = blendColors(
                        base: pixelBuffer[py][px],
                        overlay: currentColor.opacity(alpha)
                    )
                    pixelBuffer[py][px] = blendedColor
                }
            }
        }
        
        // Update the texture
        updateTexture()
    }
    
    private func blendColors(base: Color, overlay: Color) -> Color {
        // Simple alpha blending
        let baseUIColor = UIColor(base)
        let overlayUIColor = UIColor(overlay)
        
        var baseR: CGFloat = 0, baseG: CGFloat = 0, baseB: CGFloat = 0, baseA: CGFloat = 0
        var overlayR: CGFloat = 0, overlayG: CGFloat = 0, overlayB: CGFloat = 0, overlayA: CGFloat = 0
        
        baseUIColor.getRed(&baseR, green: &baseG, blue: &baseB, alpha: &baseA)
        overlayUIColor.getRed(&overlayR, green: &overlayG, blue: &overlayB, alpha: &overlayA)
        
        let finalAlpha = overlayA + baseA * (1 - overlayA)
        let finalR = (overlayR * overlayA + baseR * baseA * (1 - overlayA)) / finalAlpha
        let finalG = (overlayG * overlayA + baseG * baseA * (1 - overlayA)) / finalAlpha
        let finalB = (overlayB * overlayA + baseB * baseA * (1 - overlayA)) / finalAlpha
        
        return Color(red: finalR, green: finalG, blue: finalB).opacity(finalAlpha)
    }
    
    // MARK: - Texture Management
    private func updateTexture() {
        UIGraphicsBeginImageContextWithOptions(textureSize, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        for y in 0..<Int(textureSize.height) {
            for x in 0..<Int(textureSize.width) {
                let color = pixelBuffer[y][x]
                let uiColor = UIColor(color)
                context.setFillColor(uiColor.cgColor)
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            self.skinTexture = image
        }
        UIGraphicsEndImageContext()
    }
    
    static func imageToPixelBuffer(_ image: UIImage) -> [[Color]] {
        let width = 64
        let height = 64
        var buffer: [[Color]] = Array(repeating: Array(repeating: .clear, count: width), count: height)
        
        guard let cgImage = image.cgImage else { return buffer }
        
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
        ) else { return buffer }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let pixelData = context.data else { return buffer }
        let data = pixelData.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * bytesPerPixel
                let r = CGFloat(data[pixelIndex]) / 255.0
                let g = CGFloat(data[pixelIndex + 1]) / 255.0
                let b = CGFloat(data[pixelIndex + 2]) / 255.0
                let a = CGFloat(data[pixelIndex + 3]) / 255.0
                
                // Unpremultiply alpha
                if a > 0 {
                    buffer[y][x] = Color(red: r/a, green: g/a, blue: b/a).opacity(a)
                } else {
                    buffer[y][x] = .clear
                }
            }
        }
        
        return buffer
    }
    
    // MARK: - Utility Methods
    func reset() {
        self.skinTexture = DefaultSkinTemplates.createDefaultSkin()
        self.pixelBuffer = Direct3DPaintingSystem.imageToPixelBuffer(skinTexture)
    }
    
    func exportTexture() -> UIImage {
        return skinTexture
    }
}

// MARK: - Body Part Definitions
enum Direct3DBodyPart {
    case head
    case body
    case rightArm
    case leftArm
    case rightLeg
    case leftLeg
    
    init?(nodeName: String) {
        switch nodeName {
        case "head": self = .head
        case "body": self = .body
        case "rightArm": self = .rightArm
        case "leftArm": self = .leftArm
        case "rightLeg": self = .rightLeg
        case "leftLeg": self = .leftLeg
        default: return nil
        }
    }
    
    var dimensions: (width: CGFloat, height: CGFloat, depth: CGFloat) {
        switch self {
        case .head:
            return (8, 8, 8)
        case .body:
            return (8, 12, 4)
        case .rightArm, .leftArm:
            return (4, 12, 4)
        case .rightLeg, .leftLeg:
            return (4, 12, 4)
        }
    }
    
    var uvRegion: UVRegions {
        switch self {
        case .head:
            return UVRegions(
                front: CGRect(x: 8/64, y: 8/64, width: 8/64, height: 8/64),
                back: CGRect(x: 24/64, y: 8/64, width: 8/64, height: 8/64),
                left: CGRect(x: 16/64, y: 8/64, width: 8/64, height: 8/64),
                right: CGRect(x: 0/64, y: 8/64, width: 8/64, height: 8/64),
                top: CGRect(x: 8/64, y: 0/64, width: 8/64, height: 8/64),
                bottom: CGRect(x: 16/64, y: 0/64, width: 8/64, height: 8/64)
            )
        case .body:
            return UVRegions(
                front: CGRect(x: 20/64, y: 20/64, width: 8/64, height: 12/64),
                back: CGRect(x: 32/64, y: 20/64, width: 8/64, height: 12/64),
                left: CGRect(x: 28/64, y: 20/64, width: 4/64, height: 12/64),
                right: CGRect(x: 16/64, y: 20/64, width: 4/64, height: 12/64),
                top: CGRect(x: 20/64, y: 16/64, width: 8/64, height: 4/64),
                bottom: CGRect(x: 28/64, y: 16/64, width: 8/64, height: 4/64)
            )
        case .rightArm:
            return UVRegions(
                front: CGRect(x: 44/64, y: 20/64, width: 4/64, height: 12/64),
                back: CGRect(x: 52/64, y: 20/64, width: 4/64, height: 12/64),
                left: CGRect(x: 48/64, y: 20/64, width: 4/64, height: 12/64),
                right: CGRect(x: 40/64, y: 20/64, width: 4/64, height: 12/64),
                top: CGRect(x: 44/64, y: 16/64, width: 4/64, height: 4/64),
                bottom: CGRect(x: 48/64, y: 16/64, width: 4/64, height: 4/64)
            )
        case .leftArm:
            return UVRegions(
                front: CGRect(x: 36/64, y: 52/64, width: 4/64, height: 12/64),
                back: CGRect(x: 44/64, y: 52/64, width: 4/64, height: 12/64),
                left: CGRect(x: 32/64, y: 52/64, width: 4/64, height: 12/64),
                right: CGRect(x: 40/64, y: 52/64, width: 4/64, height: 12/64),
                top: CGRect(x: 36/64, y: 48/64, width: 4/64, height: 4/64),
                bottom: CGRect(x: 40/64, y: 48/64, width: 4/64, height: 4/64)
            )
        case .rightLeg:
            return UVRegions(
                front: CGRect(x: 4/64, y: 20/64, width: 4/64, height: 12/64),
                back: CGRect(x: 12/64, y: 20/64, width: 4/64, height: 12/64),
                left: CGRect(x: 8/64, y: 20/64, width: 4/64, height: 12/64),
                right: CGRect(x: 0/64, y: 20/64, width: 4/64, height: 12/64),
                top: CGRect(x: 4/64, y: 16/64, width: 4/64, height: 4/64),
                bottom: CGRect(x: 8/64, y: 16/64, width: 4/64, height: 4/64)
            )
        case .leftLeg:
            return UVRegions(
                front: CGRect(x: 20/64, y: 52/64, width: 4/64, height: 12/64),
                back: CGRect(x: 28/64, y: 52/64, width: 4/64, height: 12/64),
                left: CGRect(x: 16/64, y: 52/64, width: 4/64, height: 12/64),
                right: CGRect(x: 24/64, y: 52/64, width: 4/64, height: 12/64),
                top: CGRect(x: 20/64, y: 48/64, width: 4/64, height: 4/64),
                bottom: CGRect(x: 24/64, y: 48/64, width: 4/64, height: 4/64)
            )
        }
    }
}

struct UVRegions {
    let front: CGRect
    let back: CGRect
    let left: CGRect
    let right: CGRect
    let top: CGRect
    let bottom: CGRect
}