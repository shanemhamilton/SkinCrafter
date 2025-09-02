import SwiftUI
import SceneKit

// MARK: - Paintable 3D Preview
// This is the main 3D preview component that supports direct painting on the model
struct Paintable3DPreview: View {
    @EnvironmentObject var skinManager: SkinManager
    @Binding var selectedColor: Color
    let isExpressMode: Bool
    let onPaint: (() -> Void)?
    
    @State private var paintCount = 0
    @State private var showCelebration = false
    
    var body: some View {
        ZStack {
            // 3D Scene with painting capability
            Paintable3DSceneView(
                skinManager: skinManager,
                selectedColor: $selectedColor,
                isExpressMode: isExpressMode,
                onPaint: handlePaint
            )
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemGray6),
                        Color(.systemGray5).opacity(0.5)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(isExpressMode ? 20 : 0)
            
            // Celebration overlay for Express mode
            if isExpressMode && showCelebration {
                PaintCelebrationView(paintCount: paintCount)
                    .allowsHitTesting(false)
            }
        }
    }
    
    private func handlePaint() {
        paintCount += 1
        onPaint?()
        
        // Express mode celebrations
        if isExpressMode {
            HapticManager.shared.selectionChanged()
            
            if paintCount == 1 || paintCount == 3 {
                showCelebration = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showCelebration = false
                }
            }
        }
        
        // Track achievement
        skinManager.trackPaint()
    }
}

// MARK: - Paint Celebration View
struct PaintCelebrationView: View {
    let paintCount: Int
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var celebrationText: String {
        switch paintCount {
        case 1: return "First touch!"
        case 3: return "Quick creator!"
        default: return "Great job!"
        }
    }
    
    var celebrationIcon: String {
        switch paintCount {
        case 1: return "hand.tap.fill"
        case 3: return "star.fill"
        default: return "sparkles"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: celebrationIcon)
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                .scaleEffect(scale)
                .opacity(opacity)
            
            Text(celebrationText)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.purple)
                .cornerRadius(15)
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

// MARK: - Paintable 3D Scene View (UIViewRepresentable)
struct Paintable3DSceneView: UIViewRepresentable {
    let skinManager: SkinManager
    @Binding var selectedColor: Color
    let isExpressMode: Bool
    let onPaint: () -> Void
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .clear
        sceneView.autoenablesDefaultLighting = false
        sceneView.allowsCameraControl = true
        sceneView.antialiasingMode = .multisampling4X
        
        // Create and setup scene
        let scene = createScene()
        sceneView.scene = scene
        
        // Setup coordinator
        context.coordinator.sceneView = sceneView
        context.coordinator.modelNode = scene.rootNode.childNode(withName: "character", recursively: true)
        
        // Add tap gesture for painting
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handleTap(_:))
        )
        sceneView.addGestureRecognizer(tapGesture)
        
        // Add drag gesture for continuous painting
        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handlePan(_:))
        )
        sceneView.addGestureRecognizer(panGesture)
        
        // Update initial texture
        updateTexture(in: scene, with: skinManager.currentSkin.toUIImage())
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update coordinator with latest values
        context.coordinator.selectedColor = selectedColor
        context.coordinator.skinManager = skinManager
        
        // Update texture when skin changes
        if let scene = uiView.scene {
            updateTexture(in: scene, with: skinManager.currentSkin.toUIImage())
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        
        // Camera
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.zNear = 0.1
        camera.zFar = 100
        camera.fieldOfView = 45
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0.5, z: 3)
        scene.rootNode.addChildNode(cameraNode)
        
        // Lighting
        setupLighting(in: scene)
        
        // Character model
        let character = createCharacterModel()
        scene.rootNode.addChildNode(character)
        
        // Optional floor
        if !isExpressMode {
            let floor = createFloor()
            scene.rootNode.addChildNode(floor)
        }
        
        return scene
    }
    
    private func setupLighting(in scene: SCNScene) {
        // Key light
        let keyLight = SCNLight()
        keyLight.type = .spot
        keyLight.intensity = 1000
        keyLight.castsShadow = !isExpressMode // Disable shadows in Express mode for performance
        
        let keyLightNode = SCNNode()
        keyLightNode.light = keyLight
        keyLightNode.position = SCNVector3(x: 2, y: 3, z: 2)
        keyLightNode.look(at: SCNVector3(0, 0, 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        scene.rootNode.addChildNode(keyLightNode)
        
        // Fill light
        let fillLight = SCNLight()
        fillLight.type = .omni
        fillLight.intensity = 400
        
        let fillLightNode = SCNNode()
        fillLightNode.light = fillLight
        fillLightNode.position = SCNVector3(x: -2, y: 1, z: 3)
        scene.rootNode.addChildNode(fillLightNode)
        
        // Ambient light
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 200
        ambientLight.color = UIColor(white: 0.9, alpha: 1.0)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    private func createCharacterModel() -> SCNNode {
        let characterNode = SCNNode()
        characterNode.name = "character"
        
        // Create shared material
        let material = SCNMaterial()
        material.diffuse.magnificationFilter = .nearest
        material.diffuse.minificationFilter = .nearest
        material.diffuse.mipFilter = .nearest
        material.isDoubleSided = false
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.8
        material.metalness.contents = 0.0
        
        // Get arm width based on model type
        let armWidth: CGFloat = skinManager.currentSkin.modelType == .slim ? 0.1875 : 0.25
        
        // Create body parts with proper Minecraft proportions
        let bodyParts: [(name: String, geometry: SCNBox, position: SCNVector3)] = [
            ("head", SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0), SCNVector3(0, 0.75, 0)),
            ("body", SCNBox(width: 0.5, height: 0.75, length: 0.25, chamferRadius: 0), SCNVector3(0, 0, 0)),
            ("rightArm", SCNBox(width: armWidth, height: 0.75, length: 0.25, chamferRadius: 0), SCNVector3(0.375, 0, 0)),
            ("leftArm", SCNBox(width: armWidth, height: 0.75, length: 0.25, chamferRadius: 0), SCNVector3(-0.375, 0, 0)),
            ("rightLeg", SCNBox(width: 0.25, height: 0.75, length: 0.25, chamferRadius: 0), SCNVector3(0.125, -0.75, 0)),
            ("leftLeg", SCNBox(width: 0.25, height: 0.75, length: 0.25, chamferRadius: 0), SCNVector3(-0.125, -0.75, 0))
        ]
        
        for (name, geometry, position) in bodyParts {
            geometry.firstMaterial = material.copy() as? SCNMaterial
            let node = SCNNode(geometry: geometry)
            node.name = name
            node.position = position
            characterNode.addChildNode(node)
        }
        
        return characterNode
    }
    
    private func createFloor() -> SCNNode {
        let floor = SCNFloor()
        floor.reflectivity = 0.1
        floor.width = 10
        floor.length = 10
        
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor.systemGray6
        floorMaterial.lightingModel = .physicallyBased
        floorMaterial.roughness.contents = 0.9
        floor.materials = [floorMaterial]
        
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, -1.5, 0)
        
        return floorNode
    }
    
    private func updateTexture(in scene: SCNScene, with texture: UIImage) {
        scene.rootNode.enumerateChildNodes { (node, _) in
            if let geometry = node.geometry,
               let material = geometry.firstMaterial {
                material.diffuse.contents = texture
            }
        }
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject {
        let parent: Paintable3DSceneView
        var selectedColor: Color
        var skinManager: SkinManager
        weak var sceneView: SCNView?
        weak var modelNode: SCNNode?
        var lastPaintTime = Date()
        var brushSize: Int
        
        init(_ parent: Paintable3DSceneView) {
            self.parent = parent
            self.selectedColor = parent.selectedColor
            self.skinManager = parent.skinManager
            self.brushSize = parent.isExpressMode ? 3 : 1 // Larger brush for Express mode
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            paintAt(gesture: gesture)
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            // Limit paint frequency for performance
            let now = Date()
            if now.timeIntervalSince(lastPaintTime) > 0.05 { // 20 FPS max
                paintAt(gesture: gesture)
                lastPaintTime = now
            }
        }
        
        private func paintAt(gesture: UIGestureRecognizer) {
            guard let sceneView = sceneView else { return }
            
            let location = gesture.location(in: sceneView)
            let hitResults = sceneView.hitTest(location, options: [:])
            
            if let hit = hitResults.first {
                // Save undo state before painting
                if gesture.state == .began || gesture is UITapGestureRecognizer {
                    skinManager.saveUndoState()
                }
                
                // Paint at hit location
                paintAtHit(hit)
                
                // Notify parent
                parent.onPaint()
            }
        }
        
        private func paintAtHit(_ hit: SCNHitTestResult) {
            guard let nodeName = hit.node.name else { return }
            
            // Get hit point details
            let localPoint = hit.localCoordinates
            let localNormal = hit.localNormal
            
            // Calculate UV coordinates from hit
            let (u, v) = calculateUV(
                localPoint: localPoint,
                localNormal: localNormal,
                nodeName: nodeName
            )
            
            // Get texture region for body part
            let region = getTextureRegion(for: nodeName)
            
            // Convert UV to pixel coordinates
            let x = region.x + Int(u * CGFloat(region.width))
            let y = region.y + Int(v * CGFloat(region.height))
            
            // Paint with brush
            paintPixels(centerX: x, centerY: y)
            
            // Update texture immediately
            updateModelTexture()
        }
        
        private func paintPixels(centerX: Int, centerY: Int) {
            let radius = brushSize
            
            for dx in -radius...radius {
                for dy in -radius...radius {
                    let px = centerX + dx
                    let py = centerY + dy
                    
                    // Check bounds
                    guard px >= 0, px < 64, py >= 0, py < 64 else { continue }
                    
                    // Circular brush
                    let distance = sqrt(Double(dx * dx + dy * dy))
                    if distance <= Double(radius) {
                        // Soft brush edge
                        let alpha = parent.isExpressMode ? 1.0 : max(0.3, 1.0 - (distance / Double(radius)))
                        let blendedColor = selectedColor.opacity(alpha)
                        
                        skinManager.currentSkin.setPixel(
                            x: px,
                            y: py,
                            color: blendedColor,
                            layer: skinManager.selectedLayer
                        )
                    }
                }
            }
            
            // Trigger UI update
            DispatchQueue.main.async {
                self.skinManager.objectWillChange.send()
            }
        }
        
        private func updateModelTexture() {
            guard let sceneView = sceneView,
                  let scene = sceneView.scene else { return }
            
            let texture = skinManager.currentSkin.toUIImage()
            parent.updateTexture(in: scene, with: texture)
        }
        
        private func calculateUV(localPoint: SCNVector3, localNormal: SCNVector3, nodeName: String) -> (CGFloat, CGFloat) {
            let dimensions = getBodyPartDimensions(for: nodeName)
            let threshold: Float = 0.9
            
            var u: CGFloat = 0.5
            var v: CGFloat = 0.5
            
            // Determine which face was hit based on normal
            if abs(localNormal.z - 1) < threshold {
                // Front face
                u = CGFloat((localPoint.x + dimensions.width/2) / dimensions.width)
                v = CGFloat(1 - (localPoint.y + dimensions.height/2) / dimensions.height)
            } else if abs(localNormal.z + 1) < threshold {
                // Back face
                u = CGFloat(1 - (localPoint.x + dimensions.width/2) / dimensions.width)
                v = CGFloat(1 - (localPoint.y + dimensions.height/2) / dimensions.height)
            } else if abs(localNormal.x - 1) < threshold {
                // Right face
                u = CGFloat((localPoint.z + dimensions.depth/2) / dimensions.depth)
                v = CGFloat(1 - (localPoint.y + dimensions.height/2) / dimensions.height)
            } else if abs(localNormal.x + 1) < threshold {
                // Left face
                u = CGFloat(1 - (localPoint.z + dimensions.depth/2) / dimensions.depth)
                v = CGFloat(1 - (localPoint.y + dimensions.height/2) / dimensions.height)
            } else if abs(localNormal.y - 1) < threshold {
                // Top face
                u = CGFloat((localPoint.x + dimensions.width/2) / dimensions.width)
                v = CGFloat((localPoint.z + dimensions.depth/2) / dimensions.depth)
            } else if abs(localNormal.y + 1) < threshold {
                // Bottom face
                u = CGFloat((localPoint.x + dimensions.width/2) / dimensions.width)
                v = CGFloat(1 - (localPoint.z + dimensions.depth/2) / dimensions.depth)
            }
            
            // Clamp values
            u = max(0, min(1, u))
            v = max(0, min(1, v))
            
            return (u, v)
        }
        
        private func getTextureRegion(for nodeName: String) -> (x: Int, y: Int, width: Int, height: Int) {
            // Return the front face texture region for each body part
            // Following Minecraft skin layout (64x64 format)
            switch nodeName {
            case "head":
                return (8, 8, 8, 8) // Head front
            case "body":
                return (20, 20, 8, 12) // Body front
            case "rightArm":
                let width = skinManager.currentSkin.modelType == .slim ? 3 : 4
                return (44, 20, width, 12) // Right arm front
            case "leftArm":
                let width = skinManager.currentSkin.modelType == .slim ? 3 : 4
                return (36, 52, width, 12) // Left arm front (64x64 format)
            case "rightLeg":
                return (4, 20, 4, 12) // Right leg front
            case "leftLeg":
                return (20, 52, 4, 12) // Left leg front (64x64 format)
            default:
                return (0, 0, 8, 8)
            }
        }
        
        private func getBodyPartDimensions(for nodeName: String) -> (width: Float, height: Float, depth: Float) {
            switch nodeName {
            case "head":
                return (0.5, 0.5, 0.5)
            case "body":
                return (0.5, 0.75, 0.25)
            case "rightArm", "leftArm":
                let width: Float = skinManager.currentSkin.modelType == .slim ? 0.1875 : 0.25
                return (width, 0.75, 0.25)
            case "rightLeg", "leftLeg":
                return (0.25, 0.75, 0.25)
            default:
                return (0.5, 0.5, 0.5)
            }
        }
    }
}

// MARK: - CharacterSkin Extension
extension CharacterSkin {
    func toUIImage() -> UIImage {
        let width = CharacterSkin.width
        let height = CharacterSkin.height
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        
        // Draw each pixel
        for y in 0..<height {
            for x in 0..<width {
                let baseColor = getPixel(x: x, y: y, layer: .base)
                let overlayColor = getPixel(x: x, y: y, layer: .overlay)
                
                // Composite overlay on base
                let finalColor = overlayColor == .clear ? baseColor : overlayColor
                
                context.setFillColor(UIColor(finalColor).cgColor)
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return image
    }
}