import SwiftUI
import UIKit
import Photos

class ExportManager: ObservableObject {
    @Published var isExporting = false
    @Published var exportProgress: Double = 0.0
    @Published var showParentGate = false
    @Published var parentGateQuestion: ParentGateQuestion?
    @Published var pendingExportAction: (() -> Void)?
    
    enum ExportFormat {
        case png64x64
        case png64x32  // Legacy format
        case png128x128  // HD for Bedrock
        case minecraftReady  // With proper metadata
    }
    
    enum ExportDestination {
        case photoLibrary
        case files
        case airdrop
        case minecraft
        case share
    }
    
    // MARK: - Parent Gate System
    
    struct ParentGateQuestion {
        let question: String
        let correctAnswer: Int
        let options: [Int]
        
        static func generateRandom() -> ParentGateQuestion {
            let operations = [
                (5, 3, "+"),
                (9, 4, "+"),
                (7, 2, "+"),
                (8, 3, "-"),
                (10, 6, "-"),
                (12, 7, "-")
            ]
            
            let operation = operations.randomElement()!
            let question: String
            let answer: Int
            
            switch operation.2 {
            case "+":
                question = "What is \(operation.0) + \(operation.1)?"
                answer = operation.0 + operation.1
            case "-":
                question = "What is \(operation.0) - \(operation.1)?"
                answer = operation.0 - operation.1
            default:
                question = "What is 5 + 3?"
                answer = 8
            }
            
            // Generate wrong options
            var options = [answer]
            while options.count < 4 {
                let wrongAnswer = answer + Int.random(in: -3...3)
                if wrongAnswer != answer && wrongAnswer > 0 && !options.contains(wrongAnswer) {
                    options.append(wrongAnswer)
                }
            }
            
            return ParentGateQuestion(
                question: question,
                correctAnswer: answer,
                options: options.shuffled()
            )
        }
    }
    
    // MARK: - Parent Gate Check
    
    private func requiresParentGate(for destination: ExportDestination) -> Bool {
        switch destination {
        case .photoLibrary:
            return false // Local save doesn't need gate
        case .files:
            return false // Local save doesn't need gate
        case .airdrop:
            return true // Sharing needs gate
        case .minecraft:
            return true // External app needs gate
        case .share:
            return true // Sharing needs gate
        }
    }
    
    func verifyParentGate(answer: Int, completion: @escaping (Bool) -> Void) {
        guard let question = parentGateQuestion else {
            completion(false)
            return
        }
        
        let isCorrect = answer == question.correctAnswer
        
        if isCorrect {
            // Execute pending export action
            pendingExportAction?()
            pendingExportAction = nil
            parentGateQuestion = nil
        }
        
        completion(isCorrect)
    }
    
    func exportSkin(_ skin: CharacterSkin, format: ExportFormat = .png64x64, destination: ExportDestination, completion: @escaping (Bool, String?) -> Void) {
        // Check if parent gate is required
        if requiresParentGate(for: destination) {
            parentGateQuestion = ParentGateQuestion.generateRandom()
            showParentGate = true
            
            // Store the export action to execute after successful parent gate
            pendingExportAction = { [weak self] in
                self?.performExport(skin, format: format, destination: destination, completion: completion)
            }
            
            return
        }
        
        // No parent gate required, proceed with export
        performExport(skin, format: format, destination: destination, completion: completion)
    }
    
    private func performExport(_ skin: CharacterSkin, format: ExportFormat, destination: ExportDestination, completion: @escaping (Bool, String?) -> Void) {
        isExporting = true
        exportProgress = 0.0
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Generate skin data based on format
            let exportData: Data?
            switch format {
            case .png64x64:
                exportData = skin.toPNGData()
            case .png64x32:
                exportData = self.convertToLegacyFormat(skin)
            case .png128x128:
                exportData = self.upscaleForBedrock(skin)
            case .minecraftReady:
                exportData = self.prepareForMinecraft(skin)
            }
            
            guard let data = exportData else {
                DispatchQueue.main.async {
                    self.isExporting = false
                    completion(false, "Failed to generate skin data")
                }
                return
            }
            
            // Export to chosen destination
            DispatchQueue.main.async {
                self.exportProgress = 0.5
                
                switch destination {
                case .photoLibrary:
                    self.saveToPhotoLibrary(data, completion: completion)
                case .files:
                    self.saveToFiles(data, completion: completion)
                case .airdrop:
                    self.shareViaAirDrop(data, completion: completion)
                case .minecraft:
                    self.openInMinecraft(data, completion: completion)
                case .share:
                    self.showShareSheet(data, completion: completion)
                }
            }
        }
    }
    
    private func saveToPhotoLibrary(_ imageData: Data, completion: @escaping (Bool, String?) -> Void) {
        guard let image = UIImage(data: imageData) else {
            completion(false, "Invalid image data")
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    self.isExporting = false
                    completion(false, "Photo library access denied")
                }
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                DispatchQueue.main.async {
                    self.exportProgress = 1.0
                    self.isExporting = false
                    if success {
                        completion(true, "Skin saved to Photos!")
                    } else {
                        completion(false, error?.localizedDescription ?? "Failed to save")
                    }
                }
            }
        }
    }
    
    private func saveToFiles(_ data: Data, completion: @escaping (Bool, String?) -> Void) {
        let fileName = "minecraft_skin_\(Date().timeIntervalSince1970).png"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: tempURL)
            
            DispatchQueue.main.async {
                let documentPicker = UIDocumentPickerViewController(forExporting: [tempURL], asCopy: true)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(documentPicker, animated: true)
                    self.exportProgress = 1.0
                    self.isExporting = false
                    completion(true, "Ready to save to Files")
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isExporting = false
                completion(false, "Failed to prepare file: \(error.localizedDescription)")
            }
        }
    }
    
    private func shareViaAirDrop(_ data: Data, completion: @escaping (Bool, String?) -> Void) {
        let fileName = "minecraft_skin.png"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: tempURL)
            
            DispatchQueue.main.async {
                let activityVC = UIActivityViewController(
                    activityItems: [tempURL],
                    applicationActivities: nil
                )
                
                // Prioritize AirDrop
                activityVC.excludedActivityTypes = [
                    .postToFacebook,
                    .postToTwitter,
                    .postToWeibo,
                    .message,
                    .mail,
                    .print,
                    .copyToPasteboard,
                    .assignToContact,
                    .saveToCameraRoll,
                    .addToReadingList,
                    .postToFlickr,
                    .postToVimeo,
                    .postToTencentWeibo,
                    .openInIBooks,
                    .markupAsPDF
                ]
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    
                    if let popover = activityVC.popoverPresentationController {
                        popover.sourceView = rootViewController.view
                        popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX,
                                                   y: rootViewController.view.bounds.midY,
                                                   width: 0, height: 0)
                        popover.permittedArrowDirections = []
                    }
                    
                    rootViewController.present(activityVC, animated: true)
                    self.exportProgress = 1.0
                    self.isExporting = false
                    completion(true, "Ready to AirDrop")
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isExporting = false
                completion(false, "Failed to prepare for AirDrop")
            }
        }
    }
    
    private func openInMinecraft(_ data: Data, completion: @escaping (Bool, String?) -> Void) {
        // Check if Minecraft is installed
        guard let minecraftURL = URL(string: "minecraft://") else {
            completion(false, "Invalid Minecraft URL")
            return
        }
        
        if UIApplication.shared.canOpenURL(minecraftURL) {
            // Save skin to Documents directory with proper name
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let skinPath = documentsPath.appendingPathComponent("custom_skin.png")
            
            do {
                try data.write(to: skinPath)
                
                DispatchQueue.main.async {
                    // Open Minecraft
                    UIApplication.shared.open(minecraftURL) { success in
                        self.exportProgress = 1.0
                        self.isExporting = false
                        if success {
                            completion(true, "Opening in Minecraft. Import the skin from Files in Minecraft's skin selector.")
                        } else {
                            completion(false, "Failed to open Minecraft")
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isExporting = false
                    completion(false, "Failed to save skin for Minecraft")
                }
            }
        } else {
            DispatchQueue.main.async {
                self.isExporting = false
                completion(false, "Minecraft is not installed")
            }
        }
    }
    
    private func showShareSheet(_ data: Data, completion: @escaping (Bool, String?) -> Void) {
        let fileName = "minecraft_skin.png"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: tempURL)
            
            DispatchQueue.main.async {
                let activityVC = UIActivityViewController(
                    activityItems: [tempURL, "Check out my awesome Minecraft skin created with SkinCrafter!"],
                    applicationActivities: nil
                )
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    
                    if let popover = activityVC.popoverPresentationController {
                        popover.sourceView = rootViewController.view
                        popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX,
                                                   y: rootViewController.view.bounds.midY,
                                                   width: 0, height: 0)
                        popover.permittedArrowDirections = []
                    }
                    
                    rootViewController.present(activityVC, animated: true)
                    self.exportProgress = 1.0
                    self.isExporting = false
                    completion(true, "Share sheet opened")
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isExporting = false
                completion(false, "Failed to prepare for sharing")
            }
        }
    }
    
    private func convertToLegacyFormat(_ skin: CharacterSkin) -> Data? {
        // Convert 64x64 to 64x32 legacy format
        // This involves remapping the texture coordinates
        return skin.toPNGData() // Simplified for now
    }
    
    private func upscaleForBedrock(_ skin: CharacterSkin) -> Data? {
        // Upscale to 128x128 for Bedrock Edition
        guard let originalData = skin.toPNGData(),
              let originalImage = UIImage(data: originalData) else {
            return nil
        }
        
        let newSize = CGSize(width: 128, height: 128)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        originalImage.draw(in: CGRect(origin: .zero, size: newSize))
        let upscaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return upscaledImage?.pngData()
    }
    
    private func prepareForMinecraft(_ skin: CharacterSkin) -> Data? {
        // Add any Minecraft-specific metadata if needed
        return skin.toPNGData()
    }
    
    func importSkin(from url: URL, completion: @escaping (CharacterSkin?) -> Void) {
        guard url.startAccessingSecurityScopedResource() else {
            completion(nil)
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        do {
            let data = try Data(contentsOf: url)
            let skin = CharacterSkin(pngData: data)
            completion(skin)
        } catch {
            print("Failed to import skin: \(error)")
            completion(nil)
        }
    }
}

// MARK: - Parent Gate View
struct ParentGateView: View {
    @ObservedObject var exportManager: ExportManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedAnswer: Int?
    @State private var showIncorrect = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                Text("Parent Verification")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                
                Text("Please ask a grown-up to help")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            // Question
            if let question = exportManager.parentGateQuestion {
                VStack(spacing: 20) {
                    Text(question.question)
                        .font(.system(size: 20, weight: .medium))
                        .multilineTextAlignment(.center)
                    
                    // Answer options with 70x70pt buttons for Express mode
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 15) {
                        ForEach(question.options, id: \.self) { option in
                            Button(action: {
                                selectedAnswer = option
                                verifyAnswer(option)
                            }) {
                                Text("\(option)")
                                    .font(.system(size: 24, weight: .bold))
                                    .frame(width: 70, height: 70)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(selectedAnswer == option ? Color.blue : Color.gray.opacity(0.2))
                                    )
                                    .foregroundColor(selectedAnswer == option ? .white : .primary)
                            }
                        }
                    }
                }
            }
            
            if showIncorrect {
                Text("That's not quite right. Please try again!")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .transition(.scale)
            }
            
            Spacer()
            
            // Cancel button
            Button(action: {
                exportManager.showParentGate = false
                exportManager.pendingExportAction = nil
                dismiss()
            }) {
                Text("Cancel")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.red)
                    .frame(width: 120, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.red, lineWidth: 2)
                    )
            }
            .padding(.bottom, 30)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
    }
    
    private func verifyAnswer(_ answer: Int) {
        exportManager.verifyParentGate(answer: answer) { success in
            if success {
                exportManager.showParentGate = false
                dismiss()
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    showIncorrect = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showIncorrect = false
                        selectedAnswer = nil
                    }
                }
            }
        }
    }
}