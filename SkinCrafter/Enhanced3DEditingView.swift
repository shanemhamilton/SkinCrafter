import SwiftUI
import SceneKit

// MARK: - Enhanced 3D Editing View
struct Enhanced3DEditingView: View {
    @EnvironmentObject var skinManager: SkinManager
    @State private var currentRotation = CGSize.zero
    @State private var accumulatedRotation = CGSize.zero
    @State private var selectedTool: DrawingTool = .pencil
    @State private var selectedColor = Color.blue
    @State private var brushSize: CGFloat = 1
    @State private var isDrawingMode = false
    @State private var showColorPicker = false
    @State private var show2DView = false
    @State private var currentZoom: CGFloat = 1.0
    @State private var showingTemplateSelector = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundView
                main3DView(geometry: geometry)
                floatingUIControls
                overlay2DView(geometry: geometry)
            }
        }
        .sheet(isPresented: $showColorPicker) {
            ColorPickerSheet(selectedColor: $selectedColor)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingTemplateSelector) {
            SkinTemplateSelector(isPresented: $showingTemplateSelector)
                .environmentObject(skinManager)
        }
        .onAppear {
            // Skin is already initialized with default template in SkinManager
        }
    }
    
    // MARK: - View Components
    private var backgroundView: some View {
        LinearGradient(
            colors: [Color.black.opacity(0.9), Color.purple.opacity(0.3)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private func main3DView(geometry: GeometryProxy) -> some View {
        Interactive3DSkinView(
            rotation: $accumulatedRotation,
            currentRotation: $currentRotation,
            isDrawingMode: $isDrawingMode,
            selectedColor: $selectedColor,
            selectedTool: $selectedTool,
            brushSize: $brushSize,
            zoom: $currentZoom
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    currentZoom = min(max(value, 0.5), 3.0)
                }
        )
    }
    
    private var floatingUIControls: some View {
        VStack {
            topControlBar
            Spacer()
            if isDrawingMode {
                bottomToolsPanel
            }
        }
    }
    
    private var topControlBar: some View {
        HStack {
            modeToggleButton
            Spacer()
            templateSelectorButton
            view2DToggleButton
            resetViewButton
        }
        .padding()
    }
    
    private var modeToggleButton: some View {
        Button(action: { isDrawingMode.toggle() }) {
            Label(
                isDrawingMode ? "Paint Mode" : "Rotate Mode",
                systemImage: isDrawingMode ? "paintbrush.fill" : "rotate.3d"
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isDrawingMode ? Color.purple : Color.blue)
            )
            .foregroundColor(.white)
        }
    }
    
    private var templateSelectorButton: some View {
        Button(action: { showingTemplateSelector = true }) {
            Image(systemName: "person.2.fill")
                .font(.title2)
                .foregroundColor(.white)
                .padding(8)
                .background(Circle().fill(Color.purple.opacity(0.7)))
        }
    }
    
    private var view2DToggleButton: some View {
        Button(action: { show2DView.toggle() }) {
            Image(systemName: show2DView ? "square.grid.3x3.fill" : "square.grid.3x3")
                .font(.title2)
                .foregroundColor(.white)
                .padding(8)
                .background(Circle().fill(Color.black.opacity(0.5)))
        }
    }
    
    private var resetViewButton: some View {
        Button(action: resetView) {
            Image(systemName: "arrow.counterclockwise")
                .font(.title2)
                .foregroundColor(.white)
                .padding(8)
                .background(Circle().fill(Color.black.opacity(0.5)))
        }
    }
    
    private var bottomToolsPanel: some View {
        VStack(spacing: 12) {
            toolSelectionRow
            colorAndSizeControls
        }
        .padding()
    }
    
    private var toolSelectionRow: some View {
        HStack(spacing: 16) {
            ForEach([DrawingTool.pencil, .eraser, .bucket, .eyedropper], id: \.self) { tool in
                ToolButton(
                    tool: tool,
                    isSelected: selectedTool == tool,
                    action: { selectedTool = tool }
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.7))
        )
    }
    
    private var colorAndSizeControls: some View {
        HStack(spacing: 20) {
            colorPickerButton
            quickColorsRow
            brushSizeSlider
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.7))
        )
    }
    
    private var colorPickerButton: some View {
        Button(action: { showColorPicker.toggle() }) {
            Circle()
                .fill(selectedColor)
                .frame(width: 44, height: 44)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
        }
    }
    
    private var quickColorsRow: some View {
        HStack(spacing: 8) {
            ForEach(quickColors, id: \.self) { color in
                Button(action: { selectedColor = color }) {
                    Circle()
                        .fill(color)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(
                                    selectedColor == color ? Color.white : Color.clear,
                                    lineWidth: 2
                                )
                        )
                }
            }
        }
    }
    
    private var brushSizeSlider: some View {
        HStack {
            Image(systemName: "circle.fill")
                .font(.system(size: 8))
            Slider(value: $brushSize, in: 1...5, step: 1)
                .frame(width: 100)
            Image(systemName: "circle.fill")
                .font(.system(size: 16))
        }
        .foregroundColor(.white)
    }
    
    private func overlay2DView(geometry: GeometryProxy) -> some View {
        Group {
            if show2DView {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Compact2DSkinView()
                            .frame(width: min(geometry.size.width * 0.4, 200),
                                   height: min(geometry.size.width * 0.4, 200))
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.8))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .padding()
                    }
                }
            }
        }
    }
    
    private func resetView() {
        withAnimation(.spring()) {
            accumulatedRotation = .zero
            currentRotation = .zero
            currentZoom = 1.0
        }
    }
    
    private var quickColors: [Color] {
        [.red, .orange, .yellow, .green, .blue, .purple, .pink, .brown, .black, .white]
    }
}

// MARK: - Interactive 3D Skin View
struct Interactive3DSkinView: View {
    @EnvironmentObject var skinManager: SkinManager
    @Binding var rotation: CGSize
    @Binding var currentRotation: CGSize
    @Binding var isDrawingMode: Bool
    @Binding var selectedColor: Color
    @Binding var selectedTool: DrawingTool
    @Binding var brushSize: CGFloat
    @Binding var zoom: CGFloat
    
    var body: some View {
        Interactive3DSkinViewRepresentable(
            skinManager: skinManager,
            rotation: $rotation,
            currentRotation: $currentRotation,
            isDrawingMode: $isDrawingMode,
            selectedColor: $selectedColor,
            selectedTool: $selectedTool,
            brushSize: $brushSize,
            zoom: $zoom
        )
    }
}

struct Interactive3DSkinViewRepresentable: UIViewRepresentable {
    let skinManager: SkinManager
    @Binding var rotation: CGSize
    @Binding var currentRotation: CGSize
    @Binding var isDrawingMode: Bool
    @Binding var selectedColor: Color
    @Binding var selectedTool: DrawingTool
    @Binding var brushSize: CGFloat
    @Binding var zoom: CGFloat
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.autoenablesDefaultLighting = true
        scnView.allowsCameraControl = false // We'll handle rotation manually
        
        // Create scene
        let scene = SCNScene()
        scnView.scene = scene
        
        // Add camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        scene.rootNode.addChildNode(cameraNode)
        
        // Add light
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // Create Minecraft character
        let character = createMinecraftCharacter()
        scene.rootNode.addChildNode(character)
        
        // Add gesture recognizers
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePan(_:)))
        scnView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        context.coordinator.scnView = scnView
        context.coordinator.characterNode = character
        
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        // Update texture if skin image changed
        // Get texture from skin manager
        if let skinData = skinManager.currentSkin.toPNGData(),
           let skinImage = UIImage(data: skinData) {
            updateCharacterTexture(scnView: scnView, image: skinImage)
        }
        
        // Update rotation
        if let character = scnView.scene?.rootNode.childNode(withName: "character", recursively: false) {
            let rotationX = Float(rotation.height + currentRotation.height) * .pi / 180
            let rotationY = Float(rotation.width + currentRotation.width) * .pi / 180
            character.eulerAngles = SCNVector3(x: rotationX, y: rotationY, z: 0)
            
            // Update zoom
            if let camera = scnView.scene?.rootNode.childNode(withName: "camera", recursively: true) {
                camera.position.z = Float(15 / zoom)
            }
        }
        
        context.coordinator.isDrawingMode = isDrawingMode
        context.coordinator.selectedColor = selectedColor
        context.coordinator.selectedTool = selectedTool
        context.coordinator.brushSize = brushSize
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func createMinecraftCharacter() -> SCNNode {
        let character = SCNNode()
        character.name = "character"
        
        // Head
        let head = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
        let headNode = SCNNode(geometry: head)
        headNode.position = SCNVector3(x: 0, y: 3, z: 0)
        headNode.name = "head"
        character.addChildNode(headNode)
        
        // Body
        let body = SCNBox(width: 2, height: 3, length: 1, chamferRadius: 0)
        let bodyNode = SCNNode(geometry: body)
        bodyNode.position = SCNVector3(x: 0, y: 0, z: 0)
        bodyNode.name = "body"
        character.addChildNode(bodyNode)
        
        // Arms
        let rightArm = SCNBox(width: 1, height: 3, length: 1, chamferRadius: 0)
        let rightArmNode = SCNNode(geometry: rightArm)
        rightArmNode.position = SCNVector3(x: 1.5, y: 0, z: 0)
        rightArmNode.name = "rightArm"
        character.addChildNode(rightArmNode)
        
        let leftArm = SCNBox(width: 1, height: 3, length: 1, chamferRadius: 0)
        let leftArmNode = SCNNode(geometry: leftArm)
        leftArmNode.position = SCNVector3(x: -1.5, y: 0, z: 0)
        leftArmNode.name = "leftArm"
        character.addChildNode(leftArmNode)
        
        // Legs
        let rightLeg = SCNBox(width: 1, height: 3, length: 1, chamferRadius: 0)
        let rightLegNode = SCNNode(geometry: rightLeg)
        rightLegNode.position = SCNVector3(x: 0.5, y: -3, z: 0)
        rightLegNode.name = "rightLeg"
        character.addChildNode(rightLegNode)
        
        let leftLeg = SCNBox(width: 1, height: 3, length: 1, chamferRadius: 0)
        let leftLegNode = SCNNode(geometry: leftLeg)
        leftLegNode.position = SCNVector3(x: -0.5, y: -3, z: 0)
        leftLegNode.name = "leftLeg"
        character.addChildNode(leftLegNode)
        
        // Apply default material
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemBlue
        material.isDoubleSided = true
        
        for child in character.childNodes {
            child.geometry?.materials = [material]
        }
        
        return character
    }
    
    private func updateCharacterTexture(scnView: SCNView, image: UIImage) {
        guard let character = scnView.scene?.rootNode.childNode(withName: "character", recursively: false) else { return }
        
        let material = SCNMaterial()
        material.diffuse.contents = image
        material.diffuse.minificationFilter = .nearest
        material.diffuse.magnificationFilter = .nearest
        material.isDoubleSided = true
        
        // Apply texture to all body parts
        for child in character.childNodes {
            child.geometry?.materials = [material]
        }
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject {
        var parent: Interactive3DSkinViewRepresentable
        var scnView: SCNView?
        var characterNode: SCNNode?
        var isDrawingMode = false
        var selectedColor = Color.blue
        var selectedTool = DrawingTool.pencil
        var brushSize: CGFloat = 1
        var lastPanLocation: CGPoint?
        
        init(_ parent: Interactive3DSkinViewRepresentable) {
            self.parent = parent
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let scnView = scnView else { return }
            
            if isDrawingMode {
                // Drawing mode - paint on the model
                handleDrawing(gesture: gesture, in: scnView)
            } else {
                // Rotation mode - rotate the model
                handleRotation(gesture: gesture, in: scnView)
            }
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard isDrawingMode, let scnView = scnView else { return }
            
            let location = gesture.location(in: scnView)
            paintAt(location: location, in: scnView)
        }
        
        private func handleRotation(gesture: UIPanGestureRecognizer, in scnView: SCNView) {
            let translation = gesture.translation(in: scnView)
            
            switch gesture.state {
            case .changed:
                parent.currentRotation = CGSize(
                    width: Double(translation.x),
                    height: Double(translation.y)
                )
            case .ended:
                parent.rotation.width += parent.currentRotation.width
                parent.rotation.height += parent.currentRotation.height
                parent.currentRotation = .zero
            default:
                break
            }
        }
        
        private func handleDrawing(gesture: UIPanGestureRecognizer, in scnView: SCNView) {
            let location = gesture.location(in: scnView)
            
            switch gesture.state {
            case .began:
                lastPanLocation = location
                paintAt(location: location, in: scnView)
            case .changed:
                if let lastLocation = lastPanLocation {
                    // Draw line from last location to current
                    drawLine(from: lastLocation, to: location, in: scnView)
                }
                lastPanLocation = location
            case .ended:
                lastPanLocation = nil
            default:
                break
            }
        }
        
        private func paintAt(location: CGPoint, in scnView: SCNView) {
            // Perform hit test to find which part of the model was touched
            let hitResults = scnView.hitTest(location, options: [:])
            
            guard let hit = hitResults.first,
                  let nodeName = hit.node.name else { return }
            
            // Convert hit location to texture coordinates
            let textureCoord = hit.textureCoordinates(withMappingChannel: 0)
            
            // Paint on the texture at the calculated coordinates
            applyPaint(at: textureCoord, on: nodeName)
        }
        
        private func drawLine(from: CGPoint, to: CGPoint, in scnView: SCNView) {
            // Interpolate points along the line for smooth drawing
            let distance = hypot(to.x - from.x, to.y - from.y)
            let steps = Int(distance / 2) + 1
            
            for i in 0...steps {
                let t = CGFloat(i) / CGFloat(steps)
                let point = CGPoint(
                    x: from.x + (to.x - from.x) * t,
                    y: from.y + (to.y - from.y) * t
                )
                paintAt(location: point, in: scnView)
            }
        }
        
        private func applyPaint(at textureCoord: CGPoint, on bodyPart: String) {
            // Map texture coordinates to skin image pixels (64x64)
            let x = Int(textureCoord.x * 64)
            let y = Int((1.0 - textureCoord.y) * 64) // Flip Y coordinate
            
            // Apply the paint based on selected tool
            switch selectedTool {
            case .pencil:
                parent.skinManager.currentSkin.setPixel(
                    x: x, y: y,
                    color: selectedColor,
                    layer: parent.skinManager.selectedLayer
                )
            case .eraser:
                parent.skinManager.currentSkin.setPixel(
                    x: x, y: y,
                    color: Color.clear,
                    layer: parent.skinManager.selectedLayer
                )
            case .bucket:
                parent.skinManager.currentSkin.fill(
                    x: x, y: y,
                    color: selectedColor,
                    layer: parent.skinManager.selectedLayer
                )
            default:
                break
            }
            
            // Update the 3D model texture
            updateModelTexture()
        }
        
        private func updateModelTexture() {
            // Update the texture on the 3D model
            if let skinData = parent.skinManager.currentSkin.toPNGData(),
               let skinImage = UIImage(data: skinData) {
                parent.updateCharacterTexture(scnView: scnView!, image: skinImage)
            }
        }
    }
}

// MARK: - Compact 2D Skin View
struct Compact2DSkinView: View {
    @EnvironmentObject var skinManager: SkinManager
    
    var body: some View {
        VStack(spacing: 8) {
            Text("2D View")
                .font(.caption)
                .foregroundColor(.white)
            
            if let skinData = skinManager.currentSkin.toPNGData(),
               let image = UIImage(data: skinData) {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(1, contentMode: .fit)
                    .border(Color.white.opacity(0.3), width: 1)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Text("No Skin")
                            .foregroundColor(.white.opacity(0.5))
                    )
            }
        }
        .padding(8)
    }
}

// MARK: - Tool Button
struct ToolButton: View {
    let tool: DrawingTool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: tool.iconName)
                .font(.title2)
                .foregroundColor(isSelected ? .black : .white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isSelected ? Color.white : Color.white.opacity(0.2))
                )
        }
    }
}

// MARK: - Color Picker Sheet
struct ColorPickerSheet: View {
    @Binding var selectedColor: Color
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                ColorPicker("Choose Color", selection: $selectedColor, supportsOpacity: false)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Color Picker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}