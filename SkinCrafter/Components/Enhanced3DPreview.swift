import SwiftUI
import SceneKit

// MARK: - Enhanced 3D Preview for both Express and Professional modes
struct Enhanced3DPreview: View {
    @EnvironmentObject var skinManager: SkinManager
    let showingAnimation: Bool
    @State private var rotationAngle: Double = 0
    @State private var selectedAnimation: AnimationType = .idle
    
    enum AnimationType: String, CaseIterable {
        case idle = "Idle"
        case walk = "Walk"
        case run = "Run"
        case jump = "Jump"
        case wave = "Wave"
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Subtle gradient background
                LinearGradient(
                    colors: [
                        Color(.systemGray6),
                        Color(.systemGray5).opacity(0.5)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // 3D Scene
                SceneKitView(
                    skinTexture: skinManager.currentSkin.toUIImage(),
                    showingAnimation: showingAnimation,
                    animationType: selectedAnimation,
                    rotationAngle: $rotationAngle
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Overlay controls (optional)
                if showingAnimation {
                    VStack {
                        Spacer()
                        HStack {
                            ForEach(AnimationType.allCases, id: \.self) { animation in
                                Button(action: {
                                    selectedAnimation = animation
                                }) {
                                    Text(animation.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            selectedAnimation == animation ?
                                            Color.purple.opacity(0.3) :
                                            Color.black.opacity(0.1)
                                        )
                                        .cornerRadius(15)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            if showingAnimation {
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            }
        }
    }
}

// MARK: - SceneKit View
struct SceneKitView: UIViewRepresentable {
    let skinTexture: UIImage
    let showingAnimation: Bool
    let animationType: Enhanced3DPreview.AnimationType
    @Binding var rotationAngle: Double
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .clear
        sceneView.autoenablesDefaultLighting = false
        sceneView.allowsCameraControl = true
        sceneView.antialiasingMode = .multisampling4X
        
        // Create scene
        let scene = createScene()
        sceneView.scene = scene
        
        // Update texture
        updateTexture(in: scene, with: skinTexture)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let scene = uiView.scene else { return }
        
        // Update texture
        updateTexture(in: scene, with: skinTexture)
        
        // Update animation
        if let character = scene.rootNode.childNode(withName: "character", recursively: true) {
            if showingAnimation {
                applyAnimation(to: character, type: animationType)
            } else {
                character.removeAllActions()
            }
        }
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
        
        // Character
        let character = createCharacter()
        scene.rootNode.addChildNode(character)
        
        // Optional floor
        let floor = createFloor()
        scene.rootNode.addChildNode(floor)
        
        return scene
    }
    
    private func setupLighting(in scene: SCNScene) {
        // Key light
        let keyLight = SCNLight()
        keyLight.type = .spot
        keyLight.intensity = 1000
        keyLight.castsShadow = true
        keyLight.shadowMode = .forward
        keyLight.shadowSampleCount = 8
        
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
    
    private func createCharacter() -> SCNNode {
        let characterNode = SCNNode()
        characterNode.name = "character"
        
        // Create material
        let material = SCNMaterial()
        material.diffuse.magnificationFilter = .nearest
        material.diffuse.minificationFilter = .nearest
        material.diffuse.mipFilter = .nearest
        material.isDoubleSided = false
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0.8
        material.metalness.contents = 0.0
        
        // Head (0.5 x 0.5 x 0.5 units)
        let head = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
        head.firstMaterial = material
        let headNode = SCNNode(geometry: head)
        headNode.name = "head"
        headNode.position = SCNVector3(0, 0.75, 0)
        characterNode.addChildNode(headNode)
        
        // Body (0.5 x 0.75 x 0.25 units)
        let body = SCNBox(width: 0.5, height: 0.75, length: 0.25, chamferRadius: 0)
        body.firstMaterial = material.copy() as? SCNMaterial
        let bodyNode = SCNNode(geometry: body)
        bodyNode.name = "body"
        bodyNode.position = SCNVector3(0, 0, 0)
        characterNode.addChildNode(bodyNode)
        
        // Arms (0.25 x 0.75 x 0.25 units each)
        let rightArm = SCNBox(width: 0.25, height: 0.75, length: 0.25, chamferRadius: 0)
        rightArm.firstMaterial = material.copy() as? SCNMaterial
        let rightArmNode = SCNNode(geometry: rightArm)
        rightArmNode.name = "rightArm"
        rightArmNode.position = SCNVector3(0.375, 0, 0)
        characterNode.addChildNode(rightArmNode)
        
        let leftArm = SCNBox(width: 0.25, height: 0.75, length: 0.25, chamferRadius: 0)
        leftArm.firstMaterial = material.copy() as? SCNMaterial
        let leftArmNode = SCNNode(geometry: leftArm)
        leftArmNode.name = "leftArm"
        leftArmNode.position = SCNVector3(-0.375, 0, 0)
        characterNode.addChildNode(leftArmNode)
        
        // Legs (0.25 x 0.75 x 0.25 units each)
        let rightLeg = SCNBox(width: 0.25, height: 0.75, length: 0.25, chamferRadius: 0)
        rightLeg.firstMaterial = material.copy() as? SCNMaterial
        let rightLegNode = SCNNode(geometry: rightLeg)
        rightLegNode.name = "rightLeg"
        rightLegNode.position = SCNVector3(0.125, -0.75, 0)
        characterNode.addChildNode(rightLegNode)
        
        let leftLeg = SCNBox(width: 0.25, height: 0.75, length: 0.25, chamferRadius: 0)
        leftLeg.firstMaterial = material.copy() as? SCNMaterial
        let leftLegNode = SCNNode(geometry: leftLeg)
        leftLegNode.name = "leftLeg"
        leftLegNode.position = SCNVector3(-0.125, -0.75, 0)
        characterNode.addChildNode(leftLegNode)
        
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
    
    private func applyAnimation(to node: SCNNode, type: Enhanced3DPreview.AnimationType) {
        node.removeAllActions()
        
        switch type {
        case .idle:
            // Gentle breathing
            let breathe = SCNAction.sequence([
                SCNAction.scale(to: 1.02, duration: 2),
                SCNAction.scale(to: 1.0, duration: 2)
            ])
            node.runAction(SCNAction.repeatForever(breathe))
            
        case .walk:
            // Walking animation
            if let leftLeg = node.childNode(withName: "leftLeg", recursively: true),
               let rightLeg = node.childNode(withName: "rightLeg", recursively: true),
               let leftArm = node.childNode(withName: "leftArm", recursively: true),
               let rightArm = node.childNode(withName: "rightArm", recursively: true) {
                
                // Leg animation
                let walkLeg = SCNAction.sequence([
                    SCNAction.rotateBy(x: 0.5, y: 0, z: 0, duration: 0.5),
                    SCNAction.rotateBy(x: -0.5, y: 0, z: 0, duration: 0.5)
                ])
                leftLeg.runAction(SCNAction.repeatForever(walkLeg))
                rightLeg.runAction(SCNAction.repeatForever(walkLeg.reversed()))
                
                // Arm animation
                let walkArm = SCNAction.sequence([
                    SCNAction.rotateBy(x: 0.3, y: 0, z: 0, duration: 0.5),
                    SCNAction.rotateBy(x: -0.3, y: 0, z: 0, duration: 0.5)
                ])
                leftArm.runAction(SCNAction.repeatForever(walkArm))
                rightArm.runAction(SCNAction.repeatForever(walkArm.reversed()))
            }
            
        case .run:
            // Running animation (faster walk)
            if let leftLeg = node.childNode(withName: "leftLeg", recursively: true),
               let rightLeg = node.childNode(withName: "rightLeg", recursively: true),
               let leftArm = node.childNode(withName: "leftArm", recursively: true),
               let rightArm = node.childNode(withName: "rightArm", recursively: true) {
                
                let runLeg = SCNAction.sequence([
                    SCNAction.rotateBy(x: 0.8, y: 0, z: 0, duration: 0.25),
                    SCNAction.rotateBy(x: -0.8, y: 0, z: 0, duration: 0.25)
                ])
                leftLeg.runAction(SCNAction.repeatForever(runLeg))
                rightLeg.runAction(SCNAction.repeatForever(runLeg.reversed()))
                
                let runArm = SCNAction.sequence([
                    SCNAction.rotateBy(x: 0.6, y: 0, z: 0, duration: 0.25),
                    SCNAction.rotateBy(x: -0.6, y: 0, z: 0, duration: 0.25)
                ])
                leftArm.runAction(SCNAction.repeatForever(runArm))
                rightArm.runAction(SCNAction.repeatForever(runArm.reversed()))
            }
            
        case .jump:
            // Jump animation
            let jump = SCNAction.sequence([
                SCNAction.moveBy(x: 0, y: 0.5, z: 0, duration: 0.3),
                SCNAction.moveBy(x: 0, y: -0.5, z: 0, duration: 0.3),
                SCNAction.wait(duration: 0.5)
            ])
            node.runAction(SCNAction.repeatForever(jump))
            
        case .wave:
            // Wave animation
            if let rightArm = node.childNode(withName: "rightArm", recursively: true) {
                let wave = SCNAction.sequence([
                    SCNAction.rotateBy(x: 0, y: 0, z: -1.5, duration: 0.5),
                    SCNAction.rotateBy(x: 0, y: 0, z: 1.5, duration: 0.5)
                ])
                rightArm.runAction(SCNAction.repeatForever(wave))
            }
        }
    }
}