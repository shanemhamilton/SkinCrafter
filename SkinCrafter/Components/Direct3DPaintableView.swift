import SwiftUI
import SceneKit

// MARK: - Direct 3D Paintable View
// Enables direct painting on 3D model for Express Mode with 3-tap guarantee
struct Direct3DPaintableView: View {
    @EnvironmentObject var skinManager: SkinManager
    @EnvironmentObject var hapticManager: HapticManager
    @Binding var selectedColor: Color
    let onPaint: () -> Void
    
    @State private var sceneView: SCNView?
    @State private var cameraNode: SCNNode?
    @State private var modelNode: SCNNode?
    @State private var paintCount = 0
    @State private var showCelebration = false
    @State private var lastPaintTime = Date()
    
    var body: some View {
        ZStack {
            SceneKitView(
                skinManager: skinManager,
                selectedColor: $selectedColor,
                onPaint: handlePaint,
                sceneView: $sceneView,
                cameraNode: $cameraNode,
                modelNode: $modelNode
            )
            .background(
                RadialGradient(
                    colors: [Color.purple.opacity(0.1), Color.clear],
                    center: .center,
                    startRadius: 100,
                    endRadius: 400
                )
            )
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            
            // Celebration overlay for first 3 taps
            if showCelebration {
                CelebrationView()
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            setupScene()
        }
    }
    
    private func handlePaint() {
        paintCount += 1
        hapticManager.selectionChanged()
        onPaint()
        
        // Celebrate milestones
        if paintCount == 1 {
            showFirstPaintCelebration()
        } else if paintCount == 3 {
            show3TapSuccessCelebration()
        }
    }
    
    private func showFirstPaintCelebration() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            showCelebration = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showCelebration = false
            }
        }
    }
    
    private func show3TapSuccessCelebration() {
        hapticManager.success()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
            showCelebration = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showCelebration = false
            }
        }
    }
    
    private func setupScene() {
        // Scene setup will be handled in SceneKitView
    }
}

// MARK: - Celebration View
struct CelebrationView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
                .scaleEffect(scale)
                .opacity(opacity)
            
            Text("Great job!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
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

// MARK: - SceneKit View Representable
struct SceneKitView: UIViewRepresentable {
    let skinManager: SkinManager
    @Binding var selectedColor: Color
    let onPaint: () -> Void
    @Binding var sceneView: SCNView?
    @Binding var cameraNode: SCNNode?
    @Binding var modelNode: SCNNode?
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.autoenablesDefaultLighting = true
        view.allowsCameraControl = true
        view.scene = createScene()
        
        // Add tap gesture for painting
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        sceneView = view
        
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update coordinator with latest values
        context.coordinator.selectedColor = selectedColor
        context.coordinator.skinManager = skinManager
        
        // Update all body part textures when skin changes
        updateModelTextures()
    }
    
    private func updateModelTextures() {
        guard let model = modelNode else { return }
        
        // Update texture for all child nodes (body parts)
        model.enumerateChildNodes { (node, _) in
            if let geometry = node.geometry,
               let material = geometry.firstMaterial {
                material.diffuse.contents = createTextureImage()
                material.diffuse.magnificationFilter = .nearest
                material.diffuse.minificationFilter = .nearest
                material.diffuse.mipFilter = .nearest
            }
        }
    }
    
    private func createTextureImage() -> UIImage {
        return skinManager.currentSkin.toUIImage()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        
        // Add camera
        let camera = SCNCamera()
        camera.zNear = 0.1
        camera.zFar = 100
        let cameraNodeLocal = SCNNode()
        cameraNodeLocal.camera = camera
        cameraNodeLocal.position = SCNVector3(x: 0, y: 1, z: 3)
        scene.rootNode.addChildNode(cameraNodeLocal)
        cameraNode = cameraNodeLocal
        
        // Add lights
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.intensity = 1000
        lightNode.position = SCNVector3(x: 0, y: 5, z: 5)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.intensity = 200
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Create Minecraft-style character model
        let model = createMinecraftModel()
        scene.rootNode.addChildNode(model)
        modelNode = model
        
        return scene
    }
    
    private func createMinecraftModel() -> SCNNode {
        let node = SCNNode()
        
        // Create texture image with proper UV mapping
        let textureImage = createTextureImage()
        
        // Create body parts with proper proportions and UV mapping
        // Head (8x8x8 pixels in skin)
        let head = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
        let headMaterial = SCNMaterial()
        headMaterial.diffuse.contents = textureImage
        headMaterial.diffuse.magnificationFilter = .nearest
        headMaterial.diffuse.minificationFilter = .nearest
        headMaterial.isDoubleSided = true
        head.materials = [headMaterial]
        let headNode = SCNNode(geometry: head)
        headNode.position = SCNVector3(0, 0.75, 0)
        headNode.name = "head"
        node.addChildNode(headNode)
        
        // Body (8x12x4 pixels in skin)
        let body = SCNBox(width: 0.5, height: 0.75, length: 0.25, chamferRadius: 0)
        let bodyMaterial = SCNMaterial()
        bodyMaterial.diffuse.contents = textureImage
        bodyMaterial.diffuse.magnificationFilter = .nearest
        bodyMaterial.diffuse.minificationFilter = .nearest
        bodyMaterial.isDoubleSided = true
        body.materials = [bodyMaterial]
        let bodyNode = SCNNode(geometry: body)
        bodyNode.position = SCNVector3(0, 0, 0)
        bodyNode.name = "body"
        node.addChildNode(bodyNode)
        
        // Arms (4x12x4 pixels in skin)
        let armWidth = skinManager.currentSkin.modelType == .slim ? 0.1875 : 0.25
        let leftArmGeometry = SCNBox(width: armWidth, height: 0.75, length: 0.25, chamferRadius: 0)
        let leftArmMaterial = SCNMaterial()
        leftArmMaterial.diffuse.contents = textureImage
        leftArmMaterial.diffuse.magnificationFilter = .nearest
        leftArmMaterial.diffuse.minificationFilter = .nearest
        leftArmMaterial.isDoubleSided = true
        leftArmGeometry.materials = [leftArmMaterial]
        let leftArm = SCNNode(geometry: leftArmGeometry)
        leftArm.position = SCNVector3(-0.375, 0, 0)
        leftArm.name = "leftArm"
        node.addChildNode(leftArm)
        
        let rightArmGeometry = SCNBox(width: armWidth, height: 0.75, length: 0.25, chamferRadius: 0)
        let rightArmMaterial = SCNMaterial()
        rightArmMaterial.diffuse.contents = textureImage
        rightArmMaterial.diffuse.magnificationFilter = .nearest
        rightArmMaterial.diffuse.minificationFilter = .nearest
        rightArmMaterial.isDoubleSided = true
        rightArmGeometry.materials = [rightArmMaterial]
        let rightArm = SCNNode(geometry: rightArmGeometry)
        rightArm.position = SCNVector3(0.375, 0, 0)
        rightArm.name = "rightArm"
        node.addChildNode(rightArm)
        
        // Legs (4x12x4 pixels in skin)
        let leftLegGeometry = SCNBox(width: 0.25, height: 0.75, length: 0.25, chamferRadius: 0)
        let leftLegMaterial = SCNMaterial()
        leftLegMaterial.diffuse.contents = textureImage
        leftLegMaterial.diffuse.magnificationFilter = .nearest
        leftLegMaterial.diffuse.minificationFilter = .nearest
        leftLegMaterial.isDoubleSided = true
        leftLegGeometry.materials = [leftLegMaterial]
        let leftLeg = SCNNode(geometry: leftLegGeometry)
        leftLeg.position = SCNVector3(-0.125, -0.75, 0)
        leftLeg.name = "leftLeg"
        node.addChildNode(leftLeg)
        
        let rightLegGeometry = SCNBox(width: 0.25, height: 0.75, length: 0.25, chamferRadius: 0)
        let rightLegMaterial = SCNMaterial()
        rightLegMaterial.diffuse.contents = textureImage
        rightLegMaterial.diffuse.magnificationFilter = .nearest
        rightLegMaterial.diffuse.minificationFilter = .nearest
        rightLegMaterial.isDoubleSided = true
        rightLegGeometry.materials = [rightLegMaterial]
        let rightLeg = SCNNode(geometry: rightLegGeometry)
        rightLeg.position = SCNVector3(0.125, -0.75, 0)
        rightLeg.name = "rightLeg"
        node.addChildNode(rightLeg)
        
        // No auto-rotation on painting canvas
        // Users need stable model to paint accurately
        // Rotation only for display/preview, not editing
        
        return node
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject {
        let parent: SceneKitView
        var selectedColor: Color
        var skinManager: SkinManager
        var brushSize: Int = 2 // Express mode uses larger brush
        
        init(_ parent: SceneKitView) {
            self.parent = parent
            self.selectedColor = parent.selectedColor
            self.skinManager = parent.skinManager
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let sceneView = parent.sceneView else { return }
            
            let location = gesture.location(in: sceneView)
            let hitResults = sceneView.hitTest(location, options: [:])
            
            if let hit = hitResults.first {
                // Paint at the hit location
                paintAtLocation(hit)
                parent.onPaint()
            }
        }
        
        private func paintAtLocation(_ hit: SCNHitTestResult) {
            // Save state for undo
            skinManager.saveUndoState()
            
            // Determine which body part was hit
            guard let nodeName = hit.node.name else { return }
            
            // Get the local point on the face that was hit
            let localPoint = hit.localCoordinates
            let localNormal = hit.localNormal
            
            // Determine which face of the box was hit and calculate UV coordinates
            let (u, v) = calculateUVFromHit(localPoint: localPoint, localNormal: localNormal, nodeName: nodeName)
            
            // Get texture offset for this body part
            let (startX, startY) = getBodyPartTextureOffset(for: nodeName)
            let bodyPartSize = getBodyPartSize(for: nodeName)
            
            // Convert UV to skin pixel coordinates
            let x = startX + Int(u * CGFloat(bodyPartSize.width))
            let y = startY + Int(v * CGFloat(bodyPartSize.height))
            
            // Paint with larger brush for Express mode (kid-friendly)
            let brushRadius = brushSize
            for dx in -brushRadius...brushRadius {
                for dy in -brushRadius...brushRadius {
                    let px = max(0, min(63, x + dx))
                    let py = max(0, min(63, y + dy))
                    
                    // Circular brush
                    let distance = sqrt(Double(dx * dx + dy * dy))
                    if distance <= Double(brushRadius) {
                        skinManager.currentSkin.setPixel(
                            x: px,
                            y: py,
                            color: selectedColor,
                            layer: skinManager.selectedLayer
                        )
                    }
                }
            }
            
            // Trigger UI update
            DispatchQueue.main.async {
                self.skinManager.objectWillChange.send()
            }
            
            // Update all textures
            parent.updateModelTextures()
        }
        
        private func getBodyPartTextureOffset(for nodeName: String) -> (Int, Int) {
            // Return UV offset for each body part front face in the 64x64 texture
            // These match the Minecraft skin layout specification
            switch nodeName {
            case "head":
                return (8, 8) // Head front face
            case "body":
                return (20, 20) // Body front
            case "leftArm":
                return (36, 52) // Left arm front (new format)
            case "rightArm":
                return (44, 20) // Right arm front
            case "leftLeg":
                return (20, 52) // Left leg front (new format)
            case "rightLeg":
                return (4, 20) // Right leg front
            default:
                return (0, 0)
            }
        }
        
        private func getBodyPartSize(for nodeName: String) -> (width: Int, height: Int) {
            // Return size of body part in texture pixels
            switch nodeName {
            case "head":
                return (8, 8)
            case "body":
                return (8, 12)
            case "leftArm", "rightArm":
                return skinManager.currentSkin.modelType == .slim ? (3, 12) : (4, 12)
            case "leftLeg", "rightLeg":
                return (4, 12)
            default:
                return (8, 8)
            }
        }
        
        private func calculateUVFromHit(localPoint: SCNVector3, localNormal: SCNVector3, nodeName: String) -> (CGFloat, CGFloat) {
            // Determine which face was hit based on the normal
            let threshold: Float = 0.9
            
            var u: CGFloat = 0.5
            var v: CGFloat = 0.5
            
            // Get box dimensions for the body part
            let (width, height, depth) = getBodyPartDimensions(for: nodeName)
            
            if abs(localNormal.z - 1) < threshold {
                // Front face
                u = CGFloat((localPoint.x + width/2) / width)
                v = CGFloat(1 - (localPoint.y + height/2) / height)
            } else if abs(localNormal.z + 1) < threshold {
                // Back face
                u = CGFloat(1 - (localPoint.x + width/2) / width)
                v = CGFloat(1 - (localPoint.y + height/2) / height)
            } else if abs(localNormal.x - 1) < threshold {
                // Right face
                u = CGFloat((localPoint.z + depth/2) / depth)
                v = CGFloat(1 - (localPoint.y + height/2) / height)
            } else if abs(localNormal.x + 1) < threshold {
                // Left face
                u = CGFloat(1 - (localPoint.z + depth/2) / depth)
                v = CGFloat(1 - (localPoint.y + height/2) / height)
            } else if abs(localNormal.y - 1) < threshold {
                // Top face
                u = CGFloat((localPoint.x + width/2) / width)
                v = CGFloat((localPoint.z + depth/2) / depth)
            } else if abs(localNormal.y + 1) < threshold {
                // Bottom face
                u = CGFloat((localPoint.x + width/2) / width)
                v = CGFloat(1 - (localPoint.z + depth/2) / depth)
            }
            
            // Clamp UV coordinates
            u = max(0, min(1, u))
            v = max(0, min(1, v))
            
            return (u, v)
        }
        
        private func getBodyPartDimensions(for nodeName: String) -> (Float, Float, Float) {
            // Return width, height, depth for each body part
            switch nodeName {
            case "head":
                return (0.5, 0.5, 0.5)
            case "body":
                return (0.5, 0.75, 0.25)
            case "leftArm", "rightArm":
                let width: Float = skinManager.currentSkin.modelType == .slim ? 0.1875 : 0.25
                return (width, 0.75, 0.25)
            case "leftLeg", "rightLeg":
                return (0.25, 0.75, 0.25)
            default:
                return (0.5, 0.5, 0.5)
            }
        }
    }
}

// CharacterSkin extension moved to Paintable3DPreview.swift to avoid duplication