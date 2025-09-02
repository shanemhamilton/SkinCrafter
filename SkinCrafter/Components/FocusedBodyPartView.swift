import SwiftUI
import SceneKit

// MARK: - Focused Body Part View
struct FocusedBodyPartView: View {
    let currentPart: BodyPart
    @Binding var selectedColor: Color
    @Binding var enableMirroring: Bool
    let onPaint: () -> Void
    
    @EnvironmentObject var skinManager: SkinManager
    @State private var sceneView: SCNView?
    @State private var characterNode: SCNNode?
    @State private var lastPaintLocation: CGPoint?
    @State private var showWireframe = false
    
    var body: some View {
        ZStack {
            // Checkerboard background for transparency
            CheckerboardPattern()
                .opacity(0.05)
            
            // Enhanced 3D View
            Enhanced3DBodyPartView(
                currentPart: currentPart,
                selectedColor: $selectedColor,
                enableMirroring: $enableMirroring,
                showWireframe: $showWireframe,
                onPaint: onPaint,
                sceneView: $sceneView,
                characterNode: $characterNode
            )
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.02))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            
            // Overlay controls
            VStack {
                HStack {
                    // Wireframe toggle
                    Button(action: { showWireframe.toggle() }) {
                        Image(systemName: showWireframe ? "square.grid.3x3.fill" : "square.grid.3x3")
                            .font(.title2)
                            .foregroundColor(.purple)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4)
                    }
                    
                    Spacer()
                    
                    // Reset view button
                    Button(action: resetCamera) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                            .foregroundColor(.purple)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4)
                    }
                }
                .padding()
                
                Spacer()
                
                // Current part indicator
                HStack {
                    Image(systemName: currentPart.icon)
                    Text(currentPart.rawValue)
                        .font(.headline)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.9))
                .cornerRadius(20)
                .padding()
            }
        }
    }
    
    private func resetCamera() {
        guard let scene = sceneView?.scene else { return }
        
        // Reset camera to focus on current body part
        let cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        
        switch currentPart {
        case .head:
            cameraNode?.position = SCNVector3(x: 0, y: 1.2, z: 3)
            cameraNode?.look(at: SCNVector3(x: 0, y: 0.8, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        case .body:
            cameraNode?.position = SCNVector3(x: 0, y: 0, z: 3)
            cameraNode?.look(at: SCNVector3(x: 0, y: 0, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        case .leftArm, .rightArm:
            let xOffset: Float = currentPart == .leftArm ? -2 : 2
            cameraNode?.position = SCNVector3(x: xOffset, y: 0, z: 2.5)
            cameraNode?.look(at: SCNVector3(x: xOffset * 0.3, y: 0, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        case .leftLeg, .rightLeg:
            let xOffset: Float = currentPart == .leftLeg ? -1 : 1
            cameraNode?.position = SCNVector3(x: xOffset, y: -0.5, z: 3)
            cameraNode?.look(at: SCNVector3(x: xOffset * 0.2, y: -0.8, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        case .hat:
            cameraNode?.position = SCNVector3(x: 0, y: 1.2, z: 3)
            cameraNode?.look(at: SCNVector3(x: 0, y: 0.8, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        case .jacket:
            cameraNode?.position = SCNVector3(x: 0, y: 0, z: 3)
            cameraNode?.look(at: SCNVector3(x: 0, y: 0, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        }
        
        SCNTransaction.commit()
    }
}

// MARK: - Enhanced 3D Body Part View
struct Enhanced3DBodyPartView: UIViewRepresentable {
    let currentPart: BodyPart
    @Binding var selectedColor: Color
    @Binding var enableMirroring: Bool
    @Binding var showWireframe: Bool
    let onPaint: () -> Void
    @Binding var sceneView: SCNView?
    @Binding var characterNode: SCNNode?
    
    @EnvironmentObject var skinManager: SkinManager
    
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.autoenablesDefaultLighting = false
        view.allowsCameraControl = true
        view.scene = createScene()
        
        // Add gesture recognizers
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handleTap(_:))
        )
        view.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.handlePan(_:))
        )
        view.addGestureRecognizer(panGesture)
        
        sceneView = view
        
        // Initial texture update
        updateTextures(in: view)
        
        // Focus on current body part
        focusOnBodyPart(view: view, part: currentPart)
        
        return view
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.selectedColor = selectedColor
        context.coordinator.enableMirroring = enableMirroring
        context.coordinator.currentPart = currentPart
        
        // Update body part highlighting
        updateBodyPartHighlighting(in: uiView)
        
        // Update wireframe
        updateWireframe(in: uiView, show: showWireframe)
        
        // Update texture
        updateTextures(in: uiView)
        
        // Update camera focus when part changes
        if context.coordinator.lastFocusedPart != currentPart {
            focusOnBodyPart(view: uiView, part: currentPart)
            context.coordinator.lastFocusedPart = currentPart
        }
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
        camera.fieldOfView = 45
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.name = "camera"
        cameraNode.position = SCNVector3(x: 0, y: 1, z: 3)
        scene.rootNode.addChildNode(cameraNode)
        
        // Add lights
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.intensity = 800
        lightNode.light?.castsShadow = false
        lightNode.position = SCNVector3(x: 2, y: 5, z: 5)
        scene.rootNode.addChildNode(lightNode)
        
        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light?.type = .omni
        fillLight.light?.intensity = 400
        fillLight.position = SCNVector3(x: -2, y: 2, z: 5)
        scene.rootNode.addChildNode(fillLight)
        
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 300
        ambientLight.light?.color = UIColor.white
        scene.rootNode.addChildNode(ambientLight)
        
        // Create character model with proper materials
        let character = createEnhancedCharacterModel()
        characterNode = character
        scene.rootNode.addChildNode(character)
        
        return scene
    }
    
    private func createEnhancedCharacterModel() -> SCNNode {
        let node = SCNNode()
        node.name = "character"
        
        // Create base material with checkerboard for transparent areas
        let baseMaterial = createBaseMaterial()
        
        // Head
        let head = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
        head.materials = [baseMaterial.copy() as! SCNMaterial]
        let headNode = SCNNode(geometry: head)
        headNode.name = "head"
        headNode.position = SCNVector3(0, 0.75, 0)
        node.addChildNode(headNode)
        
        // Add head overlay (hat layer)
        let headOverlay = SCNBox(width: 0.55, height: 0.55, length: 0.55, chamferRadius: 0)
        headOverlay.materials = [createOverlayMaterial()]
        let headOverlayNode = SCNNode(geometry: headOverlay)
        headOverlayNode.name = "headOverlay"
        headOverlayNode.position = SCNVector3(0, 0.75, 0)
        node.addChildNode(headOverlayNode)
        
        // Body
        let body = SCNBox(width: 0.5, height: 0.75, length: 0.25, chamferRadius: 0)
        body.materials = [baseMaterial.copy() as! SCNMaterial]
        let bodyNode = SCNNode(geometry: body)
        bodyNode.name = "body"
        bodyNode.position = SCNVector3(0, 0, 0)
        node.addChildNode(bodyNode)
        
        // Arms
        let armWidth: CGFloat = skinManager.currentSkin.modelType == .slim ? 0.1875 : 0.25
        
        let leftArm = SCNBox(width: armWidth, height: 0.75, length: 0.25, chamferRadius: 0)
        leftArm.materials = [baseMaterial.copy() as! SCNMaterial]
        let leftArmNode = SCNNode(geometry: leftArm)
        leftArmNode.name = "leftArm"
        leftArmNode.position = SCNVector3(-0.375, 0, 0)
        node.addChildNode(leftArmNode)
        
        let rightArm = SCNBox(width: armWidth, height: 0.75, length: 0.25, chamferRadius: 0)
        rightArm.materials = [baseMaterial.copy() as! SCNMaterial]
        let rightArmNode = SCNNode(geometry: rightArm)
        rightArmNode.name = "rightArm"
        rightArmNode.position = SCNVector3(0.375, 0, 0)
        node.addChildNode(rightArmNode)
        
        // Legs
        let leftLeg = SCNBox(width: 0.25, height: 0.75, length: 0.25, chamferRadius: 0)
        leftLeg.materials = [baseMaterial.copy() as! SCNMaterial]
        let leftLegNode = SCNNode(geometry: leftLeg)
        leftLegNode.name = "leftLeg"
        leftLegNode.position = SCNVector3(-0.125, -0.75, 0)
        node.addChildNode(leftLegNode)
        
        let rightLeg = SCNBox(width: 0.25, height: 0.75, length: 0.25, chamferRadius: 0)
        rightLeg.materials = [baseMaterial.copy() as! SCNMaterial]
        let rightLegNode = SCNNode(geometry: rightLeg)
        rightLegNode.name = "rightLeg"
        rightLegNode.position = SCNVector3(0.125, -0.75, 0)
        node.addChildNode(rightLegNode)
        
        // No rotation on main painting canvas - user needs stable model to paint
        // Rotation is only for mini preview
        
        return node
    }
    
    private func createBaseMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        
        // Use actual skin texture instead of checkerboard
        let textureImage = skinManager.currentSkin.toUIImage()
        material.diffuse.contents = textureImage
        material.diffuse.magnificationFilter = .nearest
        material.diffuse.minificationFilter = .nearest
        material.diffuse.mipFilter = .nearest
        material.isDoubleSided = false
        material.lightingModel = .blinn
        
        return material
    }
    
    private func createOverlayMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.clear
        material.transparency = 0.0
        material.isDoubleSided = false
        return material
    }
    
    private func createCheckerboardImage() -> UIImage {
        let size = CGSize(width: 64, height: 64)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        
        // Draw light gray background
        context.setFillColor(UIColor.lightGray.withAlphaComponent(0.3).cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Draw darker squares for checkerboard pattern
        let squareSize: CGFloat = 4
        context.setFillColor(UIColor.gray.withAlphaComponent(0.3).cgColor)
        
        for row in 0..<Int(size.height / squareSize) {
            for col in 0..<Int(size.width / squareSize) {
                if (row + col) % 2 == 0 {
                    let rect = CGRect(
                        x: CGFloat(col) * squareSize,
                        y: CGFloat(row) * squareSize,
                        width: squareSize,
                        height: squareSize
                    )
                    context.fill(rect)
                }
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func updateTextures(in view: SCNView) {
        guard let character = characterNode else { return }
        
        // Create texture from current skin
        let textureImage = skinManager.currentSkin.toUIImage()
        
        // Update all body part materials
        character.enumerateChildNodes { (node, _) in
            if let geometry = node.geometry,
               let nodeName = node.name,
               !nodeName.contains("Overlay") {
                geometry.firstMaterial?.diffuse.contents = textureImage
            }
        }
    }
    
    private func updateBodyPartHighlighting(in view: SCNView) {
        guard let character = characterNode else { return }
        
        character.enumerateChildNodes { (node, _) in
            guard let nodeName = node.name,
                  let geometry = node.geometry,
                  let material = geometry.firstMaterial else { return }
            
            // Determine if this body part should be highlighted
            let isCurrentPart = nodeName.lowercased() == currentPart.rawValue.lowercased().replacingOccurrences(of: " ", with: "")
            
            if isCurrentPart {
                // Highlight current part
                material.emission.contents = UIColor.purple.withAlphaComponent(0.2)
                material.emission.intensity = 0.3
                node.opacity = 1.0
            } else {
                // Dim other parts
                material.emission.contents = UIColor.black
                material.emission.intensity = 0
                node.opacity = 0.5
            }
        }
    }
    
    private func updateWireframe(in view: SCNView, show: Bool) {
        guard let character = characterNode else { return }
        
        character.enumerateChildNodes { (node, _) in
            if let geometry = node.geometry,
               let material = geometry.firstMaterial {
                material.fillMode = show ? .lines : .fill
                if show {
                    material.diffuse.contents = UIColor.purple.withAlphaComponent(0.5)
                }
            }
        }
    }
    
    private func focusOnBodyPart(view: SCNView, part: BodyPart) {
        guard let cameraNode = view.scene?.rootNode.childNode(withName: "camera", recursively: true) else { return }
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        
        switch part {
        case .head:
            cameraNode.position = SCNVector3(x: 0, y: 0.8, z: 2)
            cameraNode.look(at: SCNVector3(x: 0, y: 0.75, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        case .body:
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 2)
            cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        case .leftArm:
            cameraNode.position = SCNVector3(x: -1.5, y: 0, z: 1.5)
            cameraNode.look(at: SCNVector3(x: -0.375, y: 0, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        case .rightArm:
            cameraNode.position = SCNVector3(x: 1.5, y: 0, z: 1.5)
            cameraNode.look(at: SCNVector3(x: 0.375, y: 0, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        case .leftLeg:
            cameraNode.position = SCNVector3(x: -0.8, y: -0.5, z: 2)
            cameraNode.look(at: SCNVector3(x: -0.125, y: -0.75, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        case .rightLeg:
            cameraNode.position = SCNVector3(x: 0.8, y: -0.5, z: 2)
            cameraNode.look(at: SCNVector3(x: 0.125, y: -0.75, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        case .hat:
            cameraNode.position = SCNVector3(x: 0, y: 0.8, z: 2)
            cameraNode.look(at: SCNVector3(x: 0, y: 0.75, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        case .jacket:
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 2)
            cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0), up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
        }
        
        SCNTransaction.commit()
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject {
        let parent: Enhanced3DBodyPartView
        var selectedColor: Color
        var enableMirroring: Bool
        var currentPart: BodyPart
        var lastFocusedPart: BodyPart?
        var isPainting = false
        let brushSize: Int = 2
        
        init(_ parent: Enhanced3DBodyPartView) {
            self.parent = parent
            self.selectedColor = parent.selectedColor
            self.enableMirroring = parent.enableMirroring
            self.currentPart = parent.currentPart
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
            
            // Trigger UI update
            parent.skinManager.objectWillChange.send()
            parent.onPaint()
            
            // Update textures
            parent.updateTextures(in: sceneView)
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

// MARK: - CharacterSkin Extension
extension CharacterSkin {
    func toUIImageWithCheckerboard() -> UIImage {
        let width = CharacterSkin.width
        let height = CharacterSkin.height
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        
        // Draw checkerboard background for transparent areas
        context.setFillColor(UIColor.lightGray.withAlphaComponent(0.2).cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        
        let squareSize = 4
        context.setFillColor(UIColor.gray.withAlphaComponent(0.2).cgColor)
        for row in 0..<(height / squareSize) {
            for col in 0..<(width / squareSize) {
                if (row + col) % 2 == 0 {
                    context.fill(CGRect(
                        x: col * squareSize,
                        y: row * squareSize,
                        width: squareSize,
                        height: squareSize
                    ))
                }
            }
        }
        
        // Draw skin pixels
        for y in 0..<height {
            for x in 0..<width {
                let baseColor = getPixel(x: x, y: y, layer: .base)
                let overlayColor = getPixel(x: x, y: y, layer: .overlay)
                
                let finalColor = overlayColor == .clear ? baseColor : overlayColor
                
                if finalColor != .clear {
                    context.setFillColor(UIColor(finalColor).cgColor)
                    context.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return image
    }
}