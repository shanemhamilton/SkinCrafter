import SwiftUI
import SceneKit

// MARK: - Enhanced 3D Canvas
struct Enhanced3DCanvas: View {
    @ObservedObject var flowState: AdaptiveFlowState
    @EnvironmentObject var skinManager: SkinManager
    @Binding var canvasScale: CGFloat
    @Binding var canvasRotation: Angle
    @State private var sceneView: SCNView?
    @State private var characterNode: SCNNode?
    @State private var lastPaintLocation: CGPoint?
    @State private var showGrid = false
    @State private var showWireframe = false
    
    var body: some View {
        ZStack {
            // Clean gradient background (no checkerboard!)
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemBackground).opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 3D Scene
            Clean3DSceneView(
                flowState: flowState,
                sceneView: $sceneView,
                characterNode: $characterNode,
                showGrid: $showGrid,
                showWireframe: $showWireframe
            )
            .scaleEffect(canvasScale)
            .rotationEffect(canvasRotation)
            
            // Overlay Controls
            VStack {
                HStack {
                    // View Options
                    HStack(spacing: CleanDesignSystem.spacing8) {
                        ViewOptionButton(
                            icon: "square.grid.3x3",
                            isActive: $showGrid,
                            label: "Grid"
                        )
                        
                        ViewOptionButton(
                            icon: "cube.transparent",
                            isActive: $showWireframe,
                            label: "Wireframe"
                        )
                    }
                    .padding(CleanDesignSystem.spacing8)
                    .background(.regularMaterial)
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    // Camera Controls
                    HStack(spacing: CleanDesignSystem.spacing8) {
                        Button(action: resetCamera) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(.regularMaterial))
                        }
                        
                        Button(action: toggleRotation) {
                            Image(systemName: "rotate.3d")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(.regularMaterial))
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius20, style: .continuous))
    }
    
    private func resetCamera() {
        guard let scene = sceneView?.scene else { return }
        
        let cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        focusOnBodyPart(cameraNode: cameraNode, part: flowState.currentPart)
        
        SCNTransaction.commit()
        
        HapticManager.shared.lightImpact()
    }
    
    private func toggleRotation() {
        guard let character = characterNode else { return }
        
        // Rotation disabled for painting canvas
        // Only allow manual rotation via user gestures
        // Auto-rotation would make painting difficult
        
        HapticManager.shared.lightImpact()
    }
    
    private func focusOnBodyPart(cameraNode: SCNNode?, part: BodyPart) {
        guard let cameraNode = cameraNode else { return }
        
        switch part {
        case .head:
            cameraNode.position = SCNVector3(x: 0, y: 0.8, z: 2.5)
            cameraNode.look(at: SCNVector3(x: 0, y: 0.75, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        case .body:
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 2.5)
            cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        case .leftArm:
            cameraNode.position = SCNVector3(x: -1.8, y: 0, z: 2)
            cameraNode.look(at: SCNVector3(x: -0.375, y: 0, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        case .rightArm:
            cameraNode.position = SCNVector3(x: 1.8, y: 0, z: 2)
            cameraNode.look(at: SCNVector3(x: 0.375, y: 0, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        case .leftLeg:
            cameraNode.position = SCNVector3(x: -1, y: -0.5, z: 2.5)
            cameraNode.look(at: SCNVector3(x: -0.125, y: -0.75, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        case .rightLeg:
            cameraNode.position = SCNVector3(x: 1, y: -0.5, z: 2.5)
            cameraNode.look(at: SCNVector3(x: 0.125, y: -0.75, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        }
    }
}

// MARK: - View Option Button
struct ViewOptionButton: View {
    let icon: String
    @Binding var isActive: Bool
    let label: String
    
    var body: some View {
        Button(action: { isActive.toggle() }) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.caption2)
            }
            .foregroundStyle(isActive ? CleanDesignSystem.accent : .secondary)
            .frame(width: 50, height: 40)
            .background(
                isActive ?
                CleanDesignSystem.accent.opacity(0.1) :
                Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: CleanDesignSystem.cornerRadius8, style: .continuous))
        }
    }
}

// MARK: - Clean 3D Scene View
struct Clean3DSceneView: UIViewRepresentable {
    @ObservedObject var flowState: AdaptiveFlowState
    @EnvironmentObject var skinManager: SkinManager
    @Binding var sceneView: SCNView?
    @Binding var characterNode: SCNNode?
    @Binding var showGrid: Bool
    @Binding var showWireframe: Bool
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.autoenablesDefaultLighting = false
        view.allowsCameraControl = true
        view.scene = createCleanScene()
        view.antialiasingMode = .multisampling4X
        
        // Add gesture recognizers for painting
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handleTap(_:))
        )
        view.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handlePan(_:))
        )
        panGesture.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGesture)
        
        sceneView = view
        
        // Initial setup
        updateTextures(in: view)
        if let camera = view.scene?.rootNode.childNode(withName: "camera", recursively: true) {
            focusOnBodyPart(cameraNode: camera, part: flowState.currentPart, animated: false)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update coordinator
        context.coordinator.selectedColor = flowState.selectedColor
        context.coordinator.enableMirroring = flowState.enableMirroring
        context.coordinator.currentPart = flowState.currentPart
        context.coordinator.brushSize = Int(flowState.brushSize)
        
        // Update visual options
        updateGrid(in: uiView, show: showGrid)
        updateWireframe(in: uiView, show: showWireframe)
        
        // Update body part highlighting
        updateBodyPartHighlighting(in: uiView)
        
        // Update textures
        updateTextures(in: uiView)
        
        // Update camera focus when part changes
        if context.coordinator.lastFocusedPart != flowState.currentPart {
            if let camera = uiView.scene?.rootNode.childNode(withName: "camera", recursively: true) {
                focusOnBodyPart(cameraNode: camera, part: flowState.currentPart, animated: true)
            }
            context.coordinator.lastFocusedPart = flowState.currentPart
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func createCleanScene() -> SCNScene {
        let scene = SCNScene()
        
        // Camera setup
        let camera = SCNCamera()
        camera.zNear = 0.1
        camera.zFar = 100
        camera.fieldOfView = 45
        camera.wantsDepthOfField = true
        camera.focusDistance = 2.5
        camera.fStop = 5.6
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.name = "camera"
        cameraNode.position = SCNVector3(x: 0, y: 0.5, z: 3)
        scene.rootNode.addChildNode(cameraNode)
        
        // Professional lighting setup
        setupProfessionalLighting(in: scene)
        
        // Character model
        let character = createCleanCharacterModel()
        characterNode = character
        scene.rootNode.addChildNode(character)
        
        // Optional floor/grid
        let floor = createFloor()
        floor.name = "floor"
        scene.rootNode.addChildNode(floor)
        
        return scene
    }
    
    private func setupProfessionalLighting(in scene: SCNScene) {
        // Key light (main light from above-right)
        let keyLight = SCNLight()
        keyLight.type = .spot
        keyLight.intensity = 1000
        keyLight.temperature = 6500
        keyLight.castsShadow = true
        keyLight.shadowMode = .forward
        keyLight.shadowSampleCount = 8
        keyLight.shadowRadius = 8
        keyLight.shadowColor = UIColor.black.withAlphaComponent(0.3)
        
        let keyLightNode = SCNNode()
        keyLightNode.light = keyLight
        keyLightNode.position = SCNVector3(x: 2, y: 3, z: 2)
        keyLightNode.look(at: SCNVector3(0, 0, 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        scene.rootNode.addChildNode(keyLightNode)
        
        // Fill light (softer light from left)
        let fillLight = SCNLight()
        fillLight.type = .omni
        fillLight.intensity = 400
        fillLight.temperature = 5000
        fillLight.castsShadow = false
        
        let fillLightNode = SCNNode()
        fillLightNode.light = fillLight
        fillLightNode.position = SCNVector3(x: -2, y: 1, z: 3)
        scene.rootNode.addChildNode(fillLightNode)
        
        // Rim light (back light for edge definition)
        let rimLight = SCNLight()
        rimLight.type = .spot
        rimLight.intensity = 600
        rimLight.temperature = 7000
        rimLight.castsShadow = false
        
        let rimLightNode = SCNNode()
        rimLightNode.light = rimLight
        rimLightNode.position = SCNVector3(x: 0, y: 2, z: -3)
        rimLightNode.look(at: SCNVector3(0, 0.5, 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        scene.rootNode.addChildNode(rimLightNode)
        
        // Ambient light (overall fill)
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 200
        ambientLight.temperature = 6000
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    private func createCleanCharacterModel() -> SCNNode {
        let node = SCNNode()
        node.name = "character"
        
        // Create materials
        let skinMaterial = createSkinMaterial()
        
        // Head
        let head = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
        head.materials = [skinMaterial]
        let headNode = SCNNode(geometry: head)
        headNode.name = "head"
        headNode.position = SCNVector3(0, 0.75, 0)
        node.addChildNode(headNode)
        
        // Body
        let body = SCNBox(width: 0.5, height: 0.75, length: 0.25, chamferRadius: 0)
        body.materials = [skinMaterial.copy() as! SCNMaterial]
        let bodyNode = SCNNode(geometry: body)
        bodyNode.name = "body"
        bodyNode.position = SCNVector3(0, 0, 0)
        node.addChildNode(bodyNode)
        
        // Arms
        let armWidth: CGFloat = skinManager.currentSkin.modelType == .slim ? 0.1875 : 0.25
        
        let leftArm = SCNBox(width: armWidth, height: 0.75, length: 0.25, chamferRadius: 0)
        leftArm.materials = [skinMaterial.copy() as! SCNMaterial]
        let leftArmNode = SCNNode(geometry: leftArm)
        leftArmNode.name = "leftarm"
        leftArmNode.position = SCNVector3(-0.375, 0, 0)
        node.addChildNode(leftArmNode)
        
        let rightArm = SCNBox(width: armWidth, height: 0.75, length: 0.25, chamferRadius: 0)
        rightArm.materials = [skinMaterial.copy() as! SCNMaterial]
        let rightArmNode = SCNNode(geometry: rightArm)
        rightArmNode.name = "rightarm"
        rightArmNode.position = SCNVector3(0.375, 0, 0)
        node.addChildNode(rightArmNode)
        
        // Legs
        let leftLeg = SCNBox(width: 0.25, height: 0.75, length: 0.25, chamferRadius: 0)
        leftLeg.materials = [skinMaterial.copy() as! SCNMaterial]
        let leftLegNode = SCNNode(geometry: leftLeg)
        leftLegNode.name = "leftleg"
        leftLegNode.position = SCNVector3(-0.125, -0.75, 0)
        node.addChildNode(leftLegNode)
        
        let rightLeg = SCNBox(width: 0.25, height: 0.75, length: 0.25, chamferRadius: 0)
        rightLeg.materials = [skinMaterial.copy() as! SCNMaterial]
        let rightLegNode = SCNNode(geometry: rightLeg)
        rightLegNode.name = "rightleg"
        rightLegNode.position = SCNVector3(0.125, -0.75, 0)
        node.addChildNode(rightLegNode)
        
        // Add subtle idle animation
        addIdleAnimation(to: node)
        
        return node
    }
    
    private func createSkinMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        
        // Use actual skin texture
        let textureImage = skinManager.currentSkin.toUIImage()
        material.diffuse.contents = textureImage
        material.diffuse.magnificationFilter = .nearest
        material.diffuse.minificationFilter = .nearest
        material.diffuse.mipFilter = .nearest
        material.isDoubleSided = false
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.8
        material.metalness.contents = 0.0
        
        return material
    }
    
    private func createFloor() -> SCNNode {
        let floor = SCNFloor()
        floor.reflectivity = 0.05
        floor.width = 10
        floor.length = 10
        
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor.systemBackground.withAlphaComponent(0.95)
        floorMaterial.lightingModel = .physicallyBased
        floorMaterial.roughness.contents = 0.9
        floor.materials = [floorMaterial]
        
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, -1.5, 0)
        floorNode.isHidden = true // Hidden by default
        
        return floorNode
    }
    
    private func addIdleAnimation(to node: SCNNode) {
        // Gentle breathing animation for body
        if let body = node.childNode(withName: "body", recursively: false) {
            let breathe = SCNAction.sequence([
                SCNAction.scale(to: 1.02, duration: 2),
                SCNAction.scale(to: 1.0, duration: 2)
            ])
            body.runAction(SCNAction.repeatForever(breathe))
        }
        
        // Subtle arm swing
        if let leftArm = node.childNode(withName: "leftarm", recursively: false) {
            leftArm.pivot = SCNMatrix4MakeTranslation(0, Float(0.375), 0)
            let swing = SCNAction.sequence([
                SCNAction.rotateBy(x: 0.1, y: 0, z: 0, duration: 2),
                SCNAction.rotateBy(x: -0.1, y: 0, z: 0, duration: 2)
            ])
            leftArm.runAction(SCNAction.repeatForever(swing))
        }
        
        if let rightArm = node.childNode(withName: "rightarm", recursively: false) {
            rightArm.pivot = SCNMatrix4MakeTranslation(0, Float(0.375), 0)
            let swing = SCNAction.sequence([
                SCNAction.rotateBy(x: -0.1, y: 0, z: 0, duration: 2),
                SCNAction.rotateBy(x: 0.1, y: 0, z: 0, duration: 2)
            ])
            rightArm.runAction(SCNAction.repeatForever(swing))
        }
    }
    
    private func updateGrid(in view: SCNView, show: Bool) {
        guard let floor = view.scene?.rootNode.childNode(withName: "floor", recursively: false) else { return }
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3
        floor.isHidden = !show
        
        if show {
            // Add grid texture to floor
            if let floorGeometry = floor.geometry as? SCNFloor,
               let material = floorGeometry.firstMaterial {
                material.diffuse.contents = createGridTexture()
            }
        }
        
        SCNTransaction.commit()
    }
    
    private func createGridTexture() -> UIImage {
        let size = CGSize(width: 512, height: 512)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        
        // Background
        context.setFillColor(UIColor.systemBackground.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Grid lines
        context.setStrokeColor(UIColor.separator.cgColor)
        context.setLineWidth(1)
        
        let gridSize: CGFloat = 32
        for i in 0...Int(size.width / gridSize) {
            let x = CGFloat(i) * gridSize
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: size.height))
        }
        
        for i in 0...Int(size.height / gridSize) {
            let y = CGFloat(i) * gridSize
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: size.width, y: y))
        }
        
        context.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func updateWireframe(in view: SCNView, show: Bool) {
        guard let character = characterNode else { return }
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3
        
        character.enumerateChildNodes { (node, _) in
            if let geometry = node.geometry,
               let material = geometry.firstMaterial {
                material.fillMode = show ? .lines : .fill
            }
        }
        
        SCNTransaction.commit()
    }
    
    private func updateBodyPartHighlighting(in view: SCNView) {
        guard let character = characterNode else { return }
        
        character.enumerateChildNodes { (node, _) in
            guard let nodeName = node.name,
                  let geometry = node.geometry,
                  let material = geometry.firstMaterial else { return }
            
            let isCurrentPart = nodeName.lowercased() == flowState.currentPart.rawValue.lowercased().replacingOccurrences(of: " ", with: "")
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.3
            
            if isCurrentPart {
                // Highlight current part with glow
                material.emission.contents = UIColor.systemBlue.withAlphaComponent(0.3)
                material.emission.intensity = 0.5
                node.opacity = 1.0
            } else {
                // Slightly dim other parts
                material.emission.contents = UIColor.black
                material.emission.intensity = 0
                node.opacity = 0.7
            }
            
            SCNTransaction.commit()
        }
    }
    
    private func updateTextures(in view: SCNView) {
        guard let character = characterNode else { return }
        
        let textureImage = skinManager.currentSkin.toUIImage()
        
        character.enumerateChildNodes { (node, _) in
            if let geometry = node.geometry,
               let material = geometry.firstMaterial {
                material.diffuse.contents = textureImage
            }
        }
    }
    
    private func focusOnBodyPart(cameraNode: SCNNode?, part: BodyPart, animated: Bool) {
        guard let cameraNode = cameraNode else { return }
        
        let position: SCNVector3
        let lookAt: SCNVector3
        
        switch part {
        case .head:
            position = SCNVector3(x: 0, y: 0.8, z: 2.5)
            lookAt = SCNVector3(x: 0, y: 0.75, z: 0)
        case .body:
            position = SCNVector3(x: 0, y: 0, z: 2.5)
            lookAt = SCNVector3(x: 0, y: 0, z: 0)
        case .leftArm:
            position = SCNVector3(x: -1.8, y: 0, z: 2)
            lookAt = SCNVector3(x: -0.375, y: 0, z: 0)
        case .rightArm:
            position = SCNVector3(x: 1.8, y: 0, z: 2)
            lookAt = SCNVector3(x: 0.375, y: 0, z: 0)
        case .leftLeg:
            position = SCNVector3(x: -1, y: -0.5, z: 2.5)
            lookAt = SCNVector3(x: -0.125, y: -0.75, z: 0)
        case .rightLeg:
            position = SCNVector3(x: 1, y: -0.5, z: 2.5)
            lookAt = SCNVector3(x: 0.125, y: -0.75, z: 0)
        }
        
        if animated {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        }
        
        cameraNode.position = position
        cameraNode.look(at: lookAt, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        
        if animated {
            SCNTransaction.commit()
        }
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject {
        let parent: Clean3DSceneView
        var selectedColor: Color
        var enableMirroring: Bool
        var currentPart: BodyPart
        var lastFocusedPart: BodyPart?
        var isPainting = false
        var brushSize: Int = 2
        
        init(_ parent: Clean3DSceneView) {
            self.parent = parent
            self.selectedColor = parent.flowState.selectedColor
            self.enableMirroring = parent.flowState.enableMirroring
            self.currentPart = parent.flowState.currentPart
            super.init()
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let sceneView = parent.sceneView else { return }
            let location = gesture.location(in: sceneView)
            paintAt(location: location, in: sceneView)
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let sceneView = parent.sceneView else { return }
            let location = gesture.location(in: sceneView)
            
            switch gesture.state {
            case .began:
                isPainting = true
                paintAt(location: location, in: sceneView)
            case .changed:
                if isPainting {
                    paintAt(location: location, in: sceneView)
                }
            case .ended, .cancelled:
                isPainting = false
            default:
                break
            }
        }
        
        private func paintAt(location: CGPoint, in sceneView: SCNView) {
            let hitResults = sceneView.hitTest(location, options: [
                .searchMode: SCNHitTestSearchMode.closest.rawValue,
                .ignoreHiddenNodes: true
            ])
            
            guard let hit = hitResults.first else { return }
            
            // Only paint on the current body part
            guard let nodeName = hit.node.name,
                  nodeName.lowercased() == currentPart.rawValue.lowercased().replacingOccurrences(of: " ", with: "") else {
                return
            }
            
            // Get UV coordinates from hit
            let textureCoord = hit.textureCoordinates(withMappingChannel: 0)
            
            // Convert to skin coordinates based on body part
            let region = currentPart.textureRegion
            let skinX = region.x + Int(textureCoord.x * CGFloat(region.width))
            let skinY = region.y + Int((1 - textureCoord.y) * CGFloat(region.height))
            
            // Save undo state
            parent.skinManager.saveUndoState()
            
            // Paint with brush
            paintAtSkinCoordinate(x: skinX, y: skinY)
            
            // Handle mirroring
            if enableMirroring, let mirrorPart = currentPart.mirrorPart {
                let mirrorRegion = mirrorPart.textureRegion
                let mirrorX = mirrorRegion.x + Int(textureCoord.x * CGFloat(mirrorRegion.width))
                let mirrorY = mirrorRegion.y + Int((1 - textureCoord.y) * CGFloat(mirrorRegion.height))
                paintAtSkinCoordinate(x: mirrorX, y: mirrorY)
            }
            
            // Mark part as edited
            parent.flowState.markPartAsEdited(currentPart)
            
            // Trigger UI update
            parent.skinManager.objectWillChange.send()
            
            // Update textures
            parent.updateTextures(in: sceneView)
            
            // Haptic feedback
            HapticManager.shared.lightImpact()
        }
        
        private func paintAtSkinCoordinate(x: Int, y: Int) {
            // Paint with circular brush
            for dx in -brushSize...brushSize {
                for dy in -brushSize...brushSize {
                    let distance = sqrt(Double(dx * dx + dy * dy))
                    if distance <= Double(brushSize) {
                        let px = max(0, min(63, x + dx))
                        let py = max(0, min(63, y + dy))
                        
                        parent.skinManager.currentSkin.setPixel(
                            x: px,
                            y: py,
                            color: selectedColor,
                            layer: parent.skinManager.selectedLayer
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Completion Celebration View
struct CompletionCelebrationView: View {
    @ObservedObject var flowState: AdaptiveFlowState
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var confettiOffset: CGFloat = -100
    
    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    flowState.isComplete = false
                }
            
            // Celebration Content
            VStack(spacing: CleanDesignSystem.spacing32) {
                // Success Icon
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 100))
                    .symbolRenderingMode(.multicolor)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(scale)
                    .shadow(color: .yellow.opacity(0.5), radius: 20)
                
                // Title
                Text("Amazing Work!")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                
                // Subtitle
                Text("You've created your first Minecraft skin!")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                // Stats
                HStack(spacing: CleanDesignSystem.spacing32) {
                    StatBadge(icon: "paintbrush.fill", value: "\(flowState.editedParts.count)", label: "Parts")
                    StatBadge(icon: "clock.fill", value: "2:34", label: "Time")
                    StatBadge(icon: "star.fill", value: "100%", label: "Complete")
                }
                .padding(.vertical)
                
                // Action Buttons
                HStack(spacing: CleanDesignSystem.spacing20) {
                    Button(action: {
                        flowState.showingExport = true
                        flowState.isComplete = false
                    }) {
                        Label("Save Skin", systemImage: "square.and.arrow.down")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: 160, height: 50)
                            .background(
                                LinearGradient(
                                    colors: [CleanDesignSystem.success, CleanDesignSystem.success.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Capsule())
                    }
                    
                    Button(action: {
                        flowState.isComplete = false
                    }) {
                        Text("Keep Editing")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(width: 160, height: 50)
                            .background(
                                Capsule()
                                    .strokeBorder(.white.opacity(0.5), lineWidth: 2)
                            )
                    }
                }
            }
            .padding(CleanDesignSystem.spacing32)
            .scaleEffect(scale)
            .opacity(opacity)
            
            // Confetti Effect
            ForEach(0..<20, id: \.self) { index in
                ConfettiPiece(index: index)
                    .offset(y: confettiOffset)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 1.5).delay(0.3)) {
                confettiOffset = UIScreen.main.bounds.height + 100
            }
        }
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: CleanDesignSystem.spacing8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.yellow)
            
            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundStyle(.white)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(width: 80)
    }
}

// MARK: - Confetti Piece
struct ConfettiPiece: View {
    let index: Int
    @State private var rotation = Double.random(in: 0...360)
    @State private var xOffset = CGFloat.random(in: -200...200)
    
    var color: Color {
        [.red, .blue, .green, .yellow, .purple, .orange, .pink].randomElement()!
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 10, height: 20)
            .rotationEffect(.degrees(rotation))
            .offset(x: xOffset)
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    rotation += 360
                }
            }
    }
}