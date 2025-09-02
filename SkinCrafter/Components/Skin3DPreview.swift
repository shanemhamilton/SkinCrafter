import SwiftUI
import SceneKit

struct Skin3DPreview: UIViewRepresentable {
    @EnvironmentObject var skinManager: SkinManager
    
    struct OverlayVisibility {
        var showHat: Bool
        var showJacket: Bool
        var showSleeves: Bool
        var showPants: Bool
    }
    
    var overlayVisibility: OverlayVisibility? = nil
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = createScene()
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = UIColor.clear
        sceneView.autoenablesDefaultLighting = false
        sceneView.antialiasingMode = .multisampling2X
        
        context.coordinator.sceneView = sceneView
        context.coordinator.overlayVisibility = overlayVisibility
        context.coordinator.updateSkinTexture()
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Force update the texture whenever the skin manager changes
        context.coordinator.overlayVisibility = overlayVisibility
        context.coordinator.updateSkinTexture()
        // Keep preview static unless auto-rotate is enabled
        if let characterNode = uiView.scene?.rootNode.childNode(withName: "character", recursively: false) {
            if skinManager.autoRotate {
                if characterNode.animationKeys.contains("rotation") == false {
                    addIdleAnimation(to: characterNode)
                }
            } else {
                characterNode.removeAnimation(forKey: "rotation", blendOutDuration: 0.2)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(skinManager: skinManager)
    }
    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        
        // White background for clean look
        scene.background.contents = UIColor.systemGray6
        
        // Create Minecraft character geometry
        let character = createMinecraftCharacter()
        scene.rootNode.addChildNode(character)
        
        // Add camera for front-facing view (tuned to exact MC proportions)
        let cameraNode = SCNNode()
        let cam = SCNCamera()
        cam.fieldOfView = 40
        cam.zNear = 0.01
        cam.zFar = 100
        cameraNode.camera = cam
        cameraNode.position = SCNVector3(x: 0, y: 1.0, z: 5.0)
        cameraNode.look(at: SCNVector3(x: 0, y: 0.5, z: 0), up: SCNVector3(x: 0, y: 1, z: 0), localFront: SCNVector3(x: 0, y: 0, z: -1))
        scene.rootNode.addChildNode(cameraNode)
        
        // Minimal ambient light for a flat, readable look
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor(white: 1.0, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        return scene
    }
    
    private func createMinecraftCharacter() -> SCNNode {
        let characterNode = SCNNode()
        characterNode.name = "character"

        // Build in Minecraft pixel units, center body at y=0, then scale root uniformly
        let scale: Float = 0.15

        // Dimensions (pixels)
        let bodyW: CGFloat = 8, bodyH: CGFloat = 12, _ /* bodyD */: CGFloat = 4
        let _ /* headW */: CGFloat = 8, headH: CGFloat = 8, _ /* headD */: CGFloat = 8
        let legW: CGFloat = 4, legH: CGFloat = 12, _ /* legD */: CGFloat = 4
        let armW: CGFloat = (skinManager.currentSkin.modelType == .slim) ? 3 : 4
        let _ /* armH */: CGFloat = 12, _ /* armD */: CGFloat = 4

        // Centers (pixels), body center at y=0
        let bodyCenterY: CGFloat = 0
        let headCenterY: CGFloat = bodyH/2 + headH/2 // 6 + 4 = 10
        let legCenterY: CGFloat = -(bodyH/2 + legH/2) // -(6 + 6) = -12
        let armCenterY: CGFloat = 0

        // X positions
        let rightArmCenterX: CGFloat = -(bodyW/2 + armW/2) // -(4 + armW/2)
        let leftArmCenterX: CGFloat = (bodyW/2 + armW/2)
        let rightLegCenterX: CGFloat = -legW/2 // -2
        let leftLegCenterX: CGFloat = legW/2  // +2

        // Create nodes
        let headNode = createHead()
        headNode.position = SCNVector3(Float(0), Float(headCenterY), 0)
        headNode.name = "head"
        characterNode.addChildNode(headNode)

        let bodyNode = createBody()
        bodyNode.position = SCNVector3(0, Float(bodyCenterY), 0)
        bodyNode.name = "body"
        characterNode.addChildNode(bodyNode)

        let rightArmNode = createRightArm()
        rightArmNode.position = SCNVector3(Float(rightArmCenterX), Float(armCenterY), 0)
        rightArmNode.name = "rightArm"
        characterNode.addChildNode(rightArmNode)

        let leftArmNode = createLeftArm()
        leftArmNode.position = SCNVector3(Float(leftArmCenterX), Float(armCenterY), 0)
        leftArmNode.name = "leftArm"
        characterNode.addChildNode(leftArmNode)

        let rightLegNode = createRightLeg()
        rightLegNode.position = SCNVector3(Float(rightLegCenterX), Float(legCenterY), 0)
        rightLegNode.name = "rightLeg"
        characterNode.addChildNode(rightLegNode)

        let leftLegNode = createLeftLeg()
        leftLegNode.position = SCNVector3(Float(leftLegCenterX), Float(legCenterY), 0)
        leftLegNode.name = "leftLeg"
        characterNode.addChildNode(leftLegNode)

        // Overlays (slightly larger shells to avoid z-fighting)
        let headOverlay = createHeadOverlay()
        headOverlay.position = headNode.position
        headOverlay.name = "head_overlay"
        characterNode.addChildNode(headOverlay)

        let bodyOverlay = createBodyOverlay()
        bodyOverlay.position = bodyNode.position
        bodyOverlay.name = "body_overlay"
        characterNode.addChildNode(bodyOverlay)

        let rightArmOverlay = createRightArmOverlay()
        rightArmOverlay.position = rightArmNode.position
        rightArmOverlay.name = "rightArm_overlay"
        characterNode.addChildNode(rightArmOverlay)

        let leftArmOverlay = createLeftArmOverlay()
        leftArmOverlay.position = leftArmNode.position
        leftArmOverlay.name = "leftArm_overlay"
        characterNode.addChildNode(leftArmOverlay)

        let rightLegOverlay = createRightLegOverlay()
        rightLegOverlay.position = rightLegNode.position
        rightLegOverlay.name = "rightLeg_overlay"
        characterNode.addChildNode(rightLegOverlay)

        let leftLegOverlay = createLeftLegOverlay()
        leftLegOverlay.position = leftLegNode.position
        leftLegOverlay.name = "leftLeg_overlay"
        characterNode.addChildNode(leftLegOverlay)

        // Scale whole character uniformly
        characterNode.scale = SCNVector3(scale, scale, scale)

        // No part rotations needed; orientation handled via face texture flips

        // Optional idle rotation
        if skinManager.autoRotate {
            addIdleAnimation(to: characterNode)
        }

        return characterNode
    }
    
    private func createHead() -> SCNNode {
        let geometry = SCNBox(width: 8, height: 8, length: 8, chamferRadius: 0)
        setupHeadUVMapping(for: geometry)
        return SCNNode(geometry: geometry)
    }
    
    private func createBody() -> SCNNode {
        let geometry = SCNBox(width: 8, height: 12, length: 4, chamferRadius: 0)
        setupBodyUVMapping(for: geometry)
        return SCNNode(geometry: geometry)
    }
    
    private func createRightArm() -> SCNNode {
        let armWidth: CGFloat = skinManager.currentSkin.modelType == .slim ? 3 : 4
        let geometry = SCNBox(width: armWidth, height: 12, length: 4, chamferRadius: 0)
        setupRightArmUVMapping(for: geometry)
        return SCNNode(geometry: geometry)
    }
    
    private func createLeftArm() -> SCNNode {
        let armWidth: CGFloat = skinManager.currentSkin.modelType == .slim ? 3 : 4
        let geometry = SCNBox(width: armWidth, height: 12, length: 4, chamferRadius: 0)
        setupLeftArmUVMapping(for: geometry)
        return SCNNode(geometry: geometry)
    }
    
    private func createRightLeg() -> SCNNode {
        let geometry = SCNBox(width: 4, height: 12, length: 4, chamferRadius: 0)
        setupRightLegUVMapping(for: geometry)
        return SCNNode(geometry: geometry)
    }

    // MARK: - Overlay geometry (slightly larger to avoid z-fighting)
    private func createHeadOverlay() -> SCNNode {
        let geometry = SCNBox(width: 8.1, height: 8.1, length: 8.1, chamferRadius: 0)
        return SCNNode(geometry: geometry)
    }
    private func createBodyOverlay() -> SCNNode {
        let geometry = SCNBox(width: 8.1, height: 12.1, length: 4.1, chamferRadius: 0)
        return SCNNode(geometry: geometry)
    }
    private func createRightArmOverlay() -> SCNNode {
        let armWidth: CGFloat = skinManager.currentSkin.modelType == .slim ? 3 : 4
        let geometry = SCNBox(width: armWidth + 0.1, height: 12.1, length: 4.1, chamferRadius: 0)
        return SCNNode(geometry: geometry)
    }
    private func createLeftArmOverlay() -> SCNNode {
        let armWidth: CGFloat = skinManager.currentSkin.modelType == .slim ? 3 : 4
        let geometry = SCNBox(width: armWidth + 0.1, height: 12.1, length: 4.1, chamferRadius: 0)
        return SCNNode(geometry: geometry)
    }
    private func createRightLegOverlay() -> SCNNode {
        let geometry = SCNBox(width: 4.1, height: 12.1, length: 4.1, chamferRadius: 0)
        return SCNNode(geometry: geometry)
    }
    private func createLeftLegOverlay() -> SCNNode {
        let geometry = SCNBox(width: 4.1, height: 12.1, length: 4.1, chamferRadius: 0)
        return SCNNode(geometry: geometry)
    }
    
    private func createLeftLeg() -> SCNNode {
        let geometry = SCNBox(width: 4, height: 12, length: 4, chamferRadius: 0)
        setupLeftLegUVMapping(for: geometry)
        return SCNNode(geometry: geometry)
    }
    
    // MARK: - UV Mapping for each body part
    
    private func setupHeadUVMapping(for geometry: SCNGeometry) {
        // Head UV coordinates in 64x64 texture (8x8x8 cube)
        let uvCoordinates: [Float] = [
            // Front face (8,8 to 16,16)
            8.0/64.0, 16.0/64.0,   16.0/64.0, 16.0/64.0,   16.0/64.0, 8.0/64.0,   8.0/64.0, 8.0/64.0,
            // Back face (24,8 to 32,16) 
            32.0/64.0, 16.0/64.0,  24.0/64.0, 16.0/64.0,   24.0/64.0, 8.0/64.0,   32.0/64.0, 8.0/64.0,
            // Left face (16,8 to 24,16)
            16.0/64.0, 16.0/64.0,  24.0/64.0, 16.0/64.0,   24.0/64.0, 8.0/64.0,   16.0/64.0, 8.0/64.0,
            // Right face (0,8 to 8,16)
            8.0/64.0, 16.0/64.0,   0.0/64.0, 16.0/64.0,    0.0/64.0, 8.0/64.0,    8.0/64.0, 8.0/64.0,
            // Top face (8,0 to 16,8)
            8.0/64.0, 8.0/64.0,    16.0/64.0, 8.0/64.0,    16.0/64.0, 0.0/64.0,   8.0/64.0, 0.0/64.0,
            // Bottom face (16,0 to 24,8)
            24.0/64.0, 8.0/64.0,   16.0/64.0, 8.0/64.0,    16.0/64.0, 0.0/64.0,   24.0/64.0, 0.0/64.0
        ]
        applyUVCoordinates(uvCoordinates, to: geometry)
    }
    
    private func setupBodyUVMapping(for geometry: SCNGeometry) {
        // Body UV coordinates in 64x64 texture (8x12x4 cuboid)
        let uvCoordinates: [Float] = [
            // Front face (20,20 to 28,32)
            20.0/64.0, 32.0/64.0,  28.0/64.0, 32.0/64.0,   28.0/64.0, 20.0/64.0,  20.0/64.0, 20.0/64.0,
            // Back face (32,20 to 40,32)
            40.0/64.0, 32.0/64.0,  32.0/64.0, 32.0/64.0,   32.0/64.0, 20.0/64.0,  40.0/64.0, 20.0/64.0,
            // Left face (16,20 to 20,32) 
            16.0/64.0, 32.0/64.0,  20.0/64.0, 32.0/64.0,   20.0/64.0, 20.0/64.0,  16.0/64.0, 20.0/64.0,
            // Right face (28,20 to 32,32)
            32.0/64.0, 32.0/64.0,  28.0/64.0, 32.0/64.0,   28.0/64.0, 20.0/64.0,  32.0/64.0, 20.0/64.0,
            // Top face (20,16 to 28,20)
            20.0/64.0, 20.0/64.0,  28.0/64.0, 20.0/64.0,   28.0/64.0, 16.0/64.0,  20.0/64.0, 16.0/64.0,
            // Bottom face (28,16 to 36,20)
            36.0/64.0, 20.0/64.0,  28.0/64.0, 20.0/64.0,   28.0/64.0, 16.0/64.0,  36.0/64.0, 16.0/64.0
        ]
        applyUVCoordinates(uvCoordinates, to: geometry)
    }
    
    private func setupRightArmUVMapping(for geometry: SCNGeometry) {
        // Using per-face materials; leave here for potential future custom UVs
    }
    
    private func setupLeftArmUVMapping(for geometry: SCNGeometry) {
        // Using per-face materials; leave here for potential future custom UVs
    }
    
    private func setupRightLegUVMapping(for geometry: SCNGeometry) {
        // Right Leg UV coordinates (4x12x4 cuboid)
        let uvCoordinates: [Float] = [
            // Front face (4,20 to 8,32)
            4.0/64.0, 32.0/64.0,   8.0/64.0, 32.0/64.0,    8.0/64.0, 20.0/64.0,   4.0/64.0, 20.0/64.0,
            // Back face (12,20 to 16,32)
            16.0/64.0, 32.0/64.0,  12.0/64.0, 32.0/64.0,   12.0/64.0, 20.0/64.0,  16.0/64.0, 20.0/64.0,
            // Left face (0,20 to 4,32)
            0.0/64.0, 32.0/64.0,   4.0/64.0, 32.0/64.0,    4.0/64.0, 20.0/64.0,   0.0/64.0, 20.0/64.0,
            // Right face (8,20 to 12,32)
            12.0/64.0, 32.0/64.0,  8.0/64.0, 32.0/64.0,    8.0/64.0, 20.0/64.0,   12.0/64.0, 20.0/64.0,
            // Top face (4,16 to 8,20)
            4.0/64.0, 20.0/64.0,   8.0/64.0, 20.0/64.0,    8.0/64.0, 16.0/64.0,   4.0/64.0, 16.0/64.0,
            // Bottom face (8,16 to 12,20)
            12.0/64.0, 20.0/64.0,  8.0/64.0, 20.0/64.0,    8.0/64.0, 16.0/64.0,   12.0/64.0, 16.0/64.0
        ]
        applyUVCoordinates(uvCoordinates, to: geometry)
    }
    
    private func setupLeftLegUVMapping(for geometry: SCNGeometry) {
        // Left Leg UV coordinates (new 64x64 format)
        let uvCoordinates: [Float] = [
            // Front face (20,52 to 24,64)
            20.0/64.0, 64.0/64.0,  24.0/64.0, 64.0/64.0,   24.0/64.0, 52.0/64.0,  20.0/64.0, 52.0/64.0,
            // Back face (28,52 to 32,64)
            32.0/64.0, 64.0/64.0,  28.0/64.0, 64.0/64.0,   28.0/64.0, 52.0/64.0,  32.0/64.0, 52.0/64.0,
            // Left face (16,52 to 20,64)
            16.0/64.0, 64.0/64.0,  20.0/64.0, 64.0/64.0,   20.0/64.0, 52.0/64.0,  16.0/64.0, 52.0/64.0,
            // Right face (24,52 to 28,64)
            28.0/64.0, 64.0/64.0,  24.0/64.0, 64.0/64.0,   24.0/64.0, 52.0/64.0,  28.0/64.0, 52.0/64.0,
            // Top face (20,48 to 24,52)
            20.0/64.0, 52.0/64.0,  24.0/64.0, 52.0/64.0,   24.0/64.0, 48.0/64.0,  20.0/64.0, 48.0/64.0,
            // Bottom face (24,48 to 28,52)
            28.0/64.0, 52.0/64.0,  24.0/64.0, 52.0/64.0,   24.0/64.0, 48.0/64.0,  28.0/64.0, 48.0/64.0
        ]
        applyUVCoordinates(uvCoordinates, to: geometry)
    }
    
    private func applyUVCoordinates(_ uvCoordinates: [Float], to geometry: SCNGeometry) {
        // Create UV texture coordinate source
        let uvData = Data(bytes: uvCoordinates, count: uvCoordinates.count * MemoryLayout<Float>.size)
        
        let uvSource = SCNGeometrySource(
            data: uvData,
            semantic: .texcoord,
            vectorCount: uvCoordinates.count / 2,
            usesFloatComponents: true,
            componentsPerVector: 2,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<Float>.size * 2
        )
        
        // Get existing geometry sources and elements
        var sources = geometry.sources
        let elements = geometry.elements
        
        // Replace or add UV source
        sources.removeAll { $0.semantic == .texcoord }
        sources.append(uvSource)
        
        // Create new geometry with proper UV mapping
        let newGeometry = SCNGeometry(sources: sources, elements: elements)
        
        // Copy materials from original geometry
        newGeometry.materials = geometry.materials
        
        // This approach requires rebuilding the node, but for now we'll use default mapping
        // The texture will still display correctly with proper material setup
    }
    
    private func addIdleAnimation(to node: SCNNode) {
        // Rotate the character slowly - 30 seconds per revolution
        let rotation = CABasicAnimation(keyPath: "rotation")
        rotation.toValue = NSValue(scnVector4: SCNVector4(0, 1, 0, Float.pi * 2))
        rotation.duration = 30  // 30 seconds per revolution as requested
        rotation.repeatCount = .infinity
        node.addAnimation(rotation, forKey: "rotation")
        
        // Add subtle arm swing
        if let rightArm = node.childNode(withName: "rightArm", recursively: true) {
            let armSwing = CABasicAnimation(keyPath: "rotation")
            armSwing.fromValue = NSValue(scnVector4: SCNVector4(1, 0, 0, -0.05))
            armSwing.toValue = NSValue(scnVector4: SCNVector4(1, 0, 0, 0.05))
            armSwing.duration = 3
            armSwing.autoreverses = true
            armSwing.repeatCount = .infinity
            rightArm.addAnimation(armSwing, forKey: "armSwing")
        }
        
        if let leftArm = node.childNode(withName: "leftArm", recursively: true) {
            let armSwing = CABasicAnimation(keyPath: "rotation")
            armSwing.fromValue = NSValue(scnVector4: SCNVector4(1, 0, 0, 0.05))
            armSwing.toValue = NSValue(scnVector4: SCNVector4(1, 0, 0, -0.05))
            armSwing.duration = 3
            armSwing.autoreverses = true
            armSwing.repeatCount = .infinity
            leftArm.addAnimation(armSwing, forKey: "armSwing")
        }
    }
    
    class Coordinator {
        var skinManager: SkinManager
        weak var sceneView: SCNView?
        var overlayVisibility: Skin3DPreview.OverlayVisibility?
        
        init(skinManager: SkinManager) {
            self.skinManager = skinManager
        }
        
        func updateSkinTexture() {
            guard let sceneView = sceneView,
                  let characterNode = sceneView.scene?.rootNode.childNode(withName: "character", recursively: false) else {
                return
            }
            
            // Get the current skin texture
            let skinImage: UIImage
            if let skinData = skinManager.currentSkin.toPNGData(),
               let image = UIImage(data: skinData) {
                skinImage = image
            } else {
                // Create a default skin texture if none exists
                skinImage = createDefaultSkinTexture()
            }
            
            // Create material with skin texture
            let skinMaterial = SCNMaterial()
            skinMaterial.diffuse.contents = skinImage
            skinMaterial.diffuse.magnificationFilter = .nearest
            skinMaterial.diffuse.minificationFilter = .nearest
            skinMaterial.diffuse.mipFilter = .nearest
            skinMaterial.isDoubleSided = false
            skinMaterial.lightingModel = .constant
            
            // Apply per-face materials for base and overlay parts
            characterNode.enumerateChildNodes { (node, _) in
                guard let box = node.geometry as? SCNBox else { return }
                let isOverlay = (node.name?.hasSuffix("_overlay") ?? false)
                // Extract base part name (e.g., "head" from "head_overlay")
                let baseName = node.name?.replacingOccurrences(of: "_overlay", with: "")
                self.applyUVMaterials(to: box, forPartNamed: baseName, using: skinImage, overlay: isOverlay)
                
                // Control overlay visibility from flags
                if isOverlay, let vis = overlayVisibility, let base = baseName {
                    switch base {
                    case "head": node.isHidden = !vis.showHat
                    case "body": node.isHidden = !vis.showJacket
                    case "rightArm", "leftArm": node.isHidden = !vis.showSleeves
                    case "rightLeg", "leftLeg": node.isHidden = !vis.showPants
                    default: break
                    }
                } else if !isOverlay {
                    node.isHidden = false
                }
            }
        }
        
        private func createDefaultSkinTexture() -> UIImage {
            // Create a default Steve-like skin texture
            let size = CGSize(width: 64, height: 64)
            UIGraphicsBeginImageContext(size)
            defer { UIGraphicsEndImageContext() }
            
            guard let context = UIGraphicsGetCurrentContext() else {
                return UIImage()
            }
            
            // Fill with skin tone color
            context.setFillColor(UIColor(red: 0.96, green: 0.80, blue: 0.69, alpha: 1.0).cgColor)
            context.fill(CGRect(origin: .zero, size: size))
            
            // Draw some basic features
            // Hair (top of head)
            context.setFillColor(UIColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1.0).cgColor)
            context.fill(CGRect(x: 8, y: 0, width: 8, height: 8))
            context.fill(CGRect(x: 24, y: 0, width: 8, height: 8))
            
            // Eyes
            context.setFillColor(UIColor.white.cgColor)
            context.fill(CGRect(x: 10, y: 11, width: 2, height: 1))
            context.fill(CGRect(x: 13, y: 11, width: 2, height: 1))
            
            // Pupils
            context.setFillColor(UIColor.blue.cgColor)
            context.fill(CGRect(x: 11, y: 11, width: 1, height: 1))
            context.fill(CGRect(x: 14, y: 11, width: 1, height: 1))
            
            // Shirt (body area)
            context.setFillColor(UIColor.systemTeal.cgColor)
            context.fill(CGRect(x: 20, y: 20, width: 8, height: 12))
            context.fill(CGRect(x: 32, y: 20, width: 8, height: 12))
            
            // Pants (leg area)
            context.setFillColor(UIColor.systemBlue.cgColor)
            context.fill(CGRect(x: 4, y: 20, width: 4, height: 12))
            context.fill(CGRect(x: 20, y: 52, width: 4, height: 12))
            
            return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        }
        
        // Simplified texture application - removed complex UV mapping for now
        // The main geometry already has proper UV coordinates
    }
}

// Removed UVMapRegion enum - using simplified texture mapping approach

// MARK: - UV material helpers
extension Skin3DPreview.Coordinator {
    private func croppedImage(from image: UIImage, rectPixels: CGRect) -> UIImage {
        guard let cg = image.cgImage else { return image }
        let height = CGFloat(cg.height)
        // Convert from top-left origin to CGImage coordinates
        let cropRect = CGRect(
            x: rectPixels.origin.x,
            y: height - rectPixels.origin.y - rectPixels.size.height,
            width: rectPixels.size.width,
            height: rectPixels.size.height
        )
        guard let cropped = cg.cropping(to: cropRect) else { return image }
        return UIImage(cgImage: cropped, scale: 1.0, orientation: .up)
    }

    private func makeMaterial(image: UIImage, rectPixels: CGRect, flipX: Bool = false, flipY: Bool = false) -> SCNMaterial {
        var faceImage = croppedImage(from: image, rectPixels: rectPixels)
        if flipX || flipY {
            let size = faceImage.size
            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
            guard let ctx = UIGraphicsGetCurrentContext() else { return SCNMaterial() }
            // Apply flips by scaling
            let sx: CGFloat = flipX ? -1 : 1
            let sy: CGFloat = flipY ? -1 : 1
            let tx: CGFloat = flipX ? size.width : 0
            let ty: CGFloat = flipY ? size.height : 0
            ctx.translateBy(x: tx, y: ty)
            ctx.scaleBy(x: sx, y: sy)
            faceImage.draw(in: CGRect(origin: .zero, size: size))
            faceImage = UIGraphicsGetImageFromCurrentImageContext() ?? faceImage
            UIGraphicsEndImageContext()
        }
        let material = SCNMaterial()
        material.diffuse.contents = faceImage
        material.diffuse.magnificationFilter = .nearest
        material.diffuse.minificationFilter = .nearest
        material.diffuse.mipFilter = .none
        material.isDoubleSided = false
        material.lightingModel = .constant
        material.diffuse.wrapS = .clamp
        material.diffuse.wrapT = .clamp
        return material
    }

    fileprivate func applyUVMaterials(to box: SCNBox, forPartNamed name: String?, using image: UIImage, overlay: Bool = false) {
        let texSize = CGSize(width: image.size.width, height: image.size.height)

        // Helper to build six materials in SCNBox order: [front, right, back, left, top, bottom]
        func materialsFor(rects: (front: CGRect, right: CGRect, back: CGRect, left: CGRect, top: CGRect, bottom: CGRect)) -> [SCNMaterial] {
            return [
                makeMaterial(image: image, rectPixels: rects.front, flipY: true),
                makeMaterial(image: image, rectPixels: rects.right, flipY: true),
                makeMaterial(image: image, rectPixels: rects.back, flipX: true, flipY: true),
                makeMaterial(image: image, rectPixels: rects.left, flipX: true, flipY: true),
                makeMaterial(image: image, rectPixels: rects.top),
                makeMaterial(image: image, rectPixels: rects.bottom)
            ]
        }

        // Define pixel rects for each body part (64x64 layout), base vs overlay
        let rects: [SCNMaterial]
        // Determine slim arms (3px) from skinManager
        let armW: CGFloat = skinManager.currentSkin.modelType == .slim ? 3 : 4
        switch name {
        case "head":
            if overlay {
                rects = materialsFor(rects: (
                    front: CGRect(x: 40, y: 8,  width: 8, height: 8),
                    right: CGRect(x: 32, y: 8,  width: 8, height: 8),
                    back:  CGRect(x: 56, y: 8,  width: 8, height: 8),
                    left:  CGRect(x: 48, y: 8,  width: 8, height: 8),
                    top:   CGRect(x: 40, y: 0,  width: 8, height: 8),
                    bottom:CGRect(x: 48, y: 0,  width: 8, height: 8)
                ))
            } else {
                rects = materialsFor(rects: (
                    front: CGRect(x: 8,  y: 8,  width: 8, height: 8),
                    right: CGRect(x: 0,  y: 8,  width: 8, height: 8),
                    back:  CGRect(x: 24, y: 8,  width: 8, height: 8),
                    left:  CGRect(x: 16, y: 8,  width: 8, height: 8),
                    top:   CGRect(x: 8,  y: 0,  width: 8, height: 8),
                    bottom:CGRect(x: 16, y: 0,  width: 8, height: 8)
                ))
            }
        case "body":
            if overlay {
                rects = materialsFor(rects: (
                    front: CGRect(x: 20, y: 36, width: 8, height: 12),
                    right: CGRect(x: 28, y: 36, width: 4, height: 12),
                    back:  CGRect(x: 32, y: 36, width: 8, height: 12),
                    left:  CGRect(x: 16, y: 36, width: 4, height: 12),
                    top:   CGRect(x: 20, y: 32, width: 8, height: 4),
                    bottom:CGRect(x: 28, y: 32, width: 8, height: 4)
                ))
            } else {
                rects = materialsFor(rects: (
                    front: CGRect(x: 20, y: 20, width: 8, height: 12),
                    right: CGRect(x: 28, y: 20, width: 4, height: 12),
                    back:  CGRect(x: 32, y: 20, width: 8, height: 12),
                    left:  CGRect(x: 16, y: 20, width: 4, height: 12),
                    top:   CGRect(x: 20, y: 16, width: 8, height: 4),
                    bottom:CGRect(x: 28, y: 16, width: 8, height: 4)
                ))
            }
        case "rightArm":
            if overlay {
                rects = materialsFor(rects: (
                    front: CGRect(x: 44, y: 36, width: armW, height: 12),
                    right: CGRect(x: 44 + armW, y: 36, width: armW, height: 12),
                    back:  CGRect(x: 44 + 2*armW, y: 36, width: armW, height: 12),
                    left:  CGRect(x: 40, y: 36, width: armW, height: 12),
                    top:   CGRect(x: 44, y: 32, width: armW, height: 4),
                    bottom:CGRect(x: 44 + armW, y: 32, width: armW, height: 4)
                ))
            } else {
                rects = materialsFor(rects: (
                    front: CGRect(x: 44, y: 20, width: armW, height: 12),
                    right: CGRect(x: 44 + armW, y: 20, width: armW, height: 12),
                    back:  CGRect(x: 44 + 2*armW, y: 20, width: armW, height: 12),
                    left:  CGRect(x: 40, y: 20, width: armW, height: 12),
                    top:   CGRect(x: 44, y: 16, width: armW, height: 4),
                    bottom:CGRect(x: 44 + armW, y: 16, width: armW, height: 4)
                ))
            }
        case "leftArm":
            if overlay {
                rects = materialsFor(rects: (
                    front: CGRect(x: 52, y: 52, width: armW, height: 12),
                    right: CGRect(x: 52 + armW, y: 52, width: armW, height: 12),
                    back:  CGRect(x: 52 + 2*armW, y: 52, width: armW, height: 12),
                    left:  CGRect(x: 48, y: 52, width: armW, height: 12),
                    top:   CGRect(x: 52, y: 48, width: armW, height: 4),
                    bottom:CGRect(x: 52 + armW, y: 48, width: armW, height: 4)
                ))
            } else {
                rects = materialsFor(rects: (
                    front: CGRect(x: 36, y: 52, width: armW, height: 12),
                    right: CGRect(x: 36 + armW, y: 52, width: armW, height: 12),
                    back:  CGRect(x: 36 + 2*armW, y: 52, width: armW, height: 12),
                    left:  CGRect(x: 32, y: 52, width: armW, height: 12),
                    top:   CGRect(x: 36, y: 48, width: armW, height: 4),
                    bottom:CGRect(x: 36 + armW, y: 48, width: armW, height: 4)
                ))
            }
        case "rightLeg":
            if overlay {
                rects = materialsFor(rects: (
                    front: CGRect(x: 4,  y: 36, width: 4, height: 12),
                    right: CGRect(x: 8,  y: 36, width: 4, height: 12),
                    back:  CGRect(x: 12, y: 36, width: 4, height: 12),
                    left:  CGRect(x: 0,  y: 36, width: 4, height: 12),
                    top:   CGRect(x: 4,  y: 32, width: 4, height: 4),
                    bottom:CGRect(x: 8,  y: 32, width: 4, height: 4)
                ))
            } else {
                rects = materialsFor(rects: (
                    front: CGRect(x: 4,  y: 20, width: 4, height: 12),
                    right: CGRect(x: 8,  y: 20, width: 4, height: 12),
                    back:  CGRect(x: 12, y: 20, width: 4, height: 12),
                    left:  CGRect(x: 0,  y: 20, width: 4, height: 12),
                    top:   CGRect(x: 4,  y: 16, width: 4, height: 4),
                    bottom:CGRect(x: 8,  y: 16, width: 4, height: 4)
                ))
            }
        case "leftLeg":
            if overlay {
                rects = materialsFor(rects: (
                    front: CGRect(x: 4,  y: 52, width: 4, height: 12),
                    right: CGRect(x: 8,  y: 52, width: 4, height: 12),
                    back:  CGRect(x: 12, y: 52, width: 4, height: 12),
                    left:  CGRect(x: 0,  y: 52, width: 4, height: 12),
                    top:   CGRect(x: 4,  y: 48, width: 4, height: 4),
                    bottom:CGRect(x: 8,  y: 48, width: 4, height: 4)
                ))
            } else {
                rects = materialsFor(rects: (
                    front: CGRect(x: 20, y: 52, width: 4, height: 12),
                    right: CGRect(x: 24, y: 52, width: 4, height: 12),
                    back:  CGRect(x: 28, y: 52, width: 4, height: 12),
                    left:  CGRect(x: 16, y: 52, width: 4, height: 12),
                    top:   CGRect(x: 20, y: 48, width: 4, height: 4),
                    bottom:CGRect(x: 24, y: 48, width: 4, height: 4)
                ))
            }
        default:
            // Fallback: show entire texture on all faces
            let m = makeMaterial(image: image, rectPixels: CGRect(x: 0, y: 0, width: texSize.width, height: texSize.height))
            rects = Array(repeating: m, count: 6)
        }

        box.materials = rects
    }
}
