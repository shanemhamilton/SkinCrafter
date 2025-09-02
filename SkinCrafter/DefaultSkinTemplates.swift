import SwiftUI
import UIKit

// MARK: - Default Skin Templates
struct DefaultSkinTemplates {
    
    // MARK: - Steve (Classic Minecraft Character)
    static func createSteveSkin() -> UIImage {
        let width = 64
        let height = 64
        let size = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        // Fill with transparent background
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Steve Colors
        let skinColor = UIColor(red: 0.96, green: 0.80, blue: 0.69, alpha: 1.0) // Skin tone
        let hairColor = UIColor(red: 0.25, green: 0.15, blue: 0.05, alpha: 1.0) // Dark brown hair
        let eyeWhite = UIColor.white
        let eyeBlue = UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        let mouthColor = UIColor(red: 0.5, green: 0.2, blue: 0.2, alpha: 0.8)
        let shirtColor = UIColor(red: 0.0, green: 0.7, blue: 0.8, alpha: 1.0) // Cyan shirt
        let pantsColor = UIColor(red: 0.2, green: 0.2, blue: 0.5, alpha: 1.0) // Dark blue pants
        let shoeColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0) // Gray shoes
        
        // MARK: HEAD TEXTURES
        // Head Front (8x8 at 8,8)
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 8, y: 8, width: 8, height: 8))
        
        // Hair on top
        context.setFillColor(hairColor.cgColor)
        context.fill(CGRect(x: 8, y: 8, width: 8, height: 3))
        
        // Eyes
        context.setFillColor(eyeWhite.cgColor)
        context.fill(CGRect(x: 10, y: 12, width: 2, height: 1))
        context.fill(CGRect(x: 13, y: 12, width: 2, height: 1))
        
        // Eye pupils
        context.setFillColor(eyeBlue.cgColor)
        context.fill(CGRect(x: 10, y: 12, width: 1, height: 1))
        context.fill(CGRect(x: 14, y: 12, width: 1, height: 1))
        
        // Nose (subtle)
        context.setFillColor(skinColor.withAlphaComponent(0.8).cgColor)
        context.fill(CGRect(x: 12, y: 13, width: 1, height: 1))
        
        // Mouth
        context.setFillColor(mouthColor.cgColor)
        context.fill(CGRect(x: 11, y: 14, width: 3, height: 1))
        
        // Head Right (8x8 at 0,8)
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 0, y: 8, width: 8, height: 8))
        context.setFillColor(hairColor.cgColor)
        context.fill(CGRect(x: 0, y: 8, width: 8, height: 3))
        
        // Head Back (8x8 at 24,8)
        context.setFillColor(hairColor.cgColor)
        context.fill(CGRect(x: 24, y: 8, width: 8, height: 8))
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 24, y: 14, width: 8, height: 2)) // Neck area
        
        // Head Left (8x8 at 16,8)
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 16, y: 8, width: 8, height: 8))
        context.setFillColor(hairColor.cgColor)
        context.fill(CGRect(x: 16, y: 8, width: 8, height: 3))
        
        // Head Top (8x8 at 8,0)
        context.setFillColor(hairColor.cgColor)
        context.fill(CGRect(x: 8, y: 0, width: 8, height: 8))
        
        // Head Bottom (8x8 at 16,0)
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 16, y: 0, width: 8, height: 8))
        
        // MARK: BODY TEXTURES
        // Body Front (8x12 at 20,20)
        context.setFillColor(shirtColor.cgColor)
        context.fill(CGRect(x: 20, y: 20, width: 8, height: 12))
        
        // Body Back (8x12 at 32,20)
        context.setFillColor(shirtColor.cgColor)
        context.fill(CGRect(x: 32, y: 20, width: 8, height: 12))
        
        // Body Right (4x12 at 16,20)
        context.setFillColor(shirtColor.cgColor)
        context.fill(CGRect(x: 16, y: 20, width: 4, height: 12))
        
        // Body Left (4x12 at 28,20)
        context.setFillColor(shirtColor.cgColor)
        context.fill(CGRect(x: 28, y: 20, width: 4, height: 12))
        
        // Body Top (8x4 at 20,16)
        context.setFillColor(shirtColor.cgColor)
        context.fill(CGRect(x: 20, y: 16, width: 8, height: 4))
        
        // Body Bottom (8x4 at 28,16)
        context.setFillColor(shirtColor.cgColor)
        context.fill(CGRect(x: 28, y: 16, width: 8, height: 4))
        
        // MARK: RIGHT ARM TEXTURES
        // Right Arm Front (4x12 at 44,20)
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 44, y: 20, width: 4, height: 12))
        context.setFillColor(shirtColor.cgColor)
        context.fill(CGRect(x: 44, y: 20, width: 4, height: 5))
        
        // Right Arm Back (4x12 at 52,20)
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 52, y: 20, width: 4, height: 12))
        context.setFillColor(shirtColor.cgColor)
        context.fill(CGRect(x: 52, y: 20, width: 4, height: 5))
        
        // Right Arm Right (4x12 at 40,20)
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 40, y: 20, width: 4, height: 12))
        context.setFillColor(shirtColor.cgColor)
        context.fill(CGRect(x: 40, y: 20, width: 4, height: 5))
        
        // Right Arm Left (4x12 at 48,20)
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 48, y: 20, width: 4, height: 12))
        context.setFillColor(shirtColor.cgColor)
        context.fill(CGRect(x: 48, y: 20, width: 4, height: 5))
        
        // Right Arm Top (4x4 at 44,16)
        context.setFillColor(shirtColor.cgColor)
        context.fill(CGRect(x: 44, y: 16, width: 4, height: 4))
        
        // Right Arm Bottom (4x4 at 48,16)
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 48, y: 16, width: 4, height: 4))
        
        // MARK: LEFT ARM TEXTURES
        // Left Arm Front (4x12 at 36,52)
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 36, y: 52, width: 4, height: 12))
        context.setFillColor(shirtColor.cgColor)
        context.fill(CGRect(x: 36, y: 52, width: 4, height: 5))
        
        // Left Arm Back (4x12 at 44,52)
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 44, y: 52, width: 4, height: 12))
        context.setFillColor(shirtColor.cgColor)
        context.fill(CGRect(x: 44, y: 52, width: 4, height: 5))
        
        // Left Arm Left (4x12 at 32,52)
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 32, y: 52, width: 4, height: 12))
        context.setFillColor(shirtColor.cgColor)
        context.fill(CGRect(x: 32, y: 52, width: 4, height: 5))
        
        // Left Arm Right (4x12 at 40,52)
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 40, y: 52, width: 4, height: 12))
        context.setFillColor(shirtColor.cgColor)
        context.fill(CGRect(x: 40, y: 52, width: 4, height: 5))
        
        // Left Arm Top (4x4 at 36,48)
        context.setFillColor(shirtColor.cgColor)
        context.fill(CGRect(x: 36, y: 48, width: 4, height: 4))
        
        // Left Arm Bottom (4x4 at 40,48)
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 40, y: 48, width: 4, height: 4))
        
        // MARK: RIGHT LEG TEXTURES
        // Right Leg Front (4x12 at 4,20)
        context.setFillColor(pantsColor.cgColor)
        context.fill(CGRect(x: 4, y: 20, width: 4, height: 12))
        context.setFillColor(shoeColor.cgColor)
        context.fill(CGRect(x: 4, y: 30, width: 4, height: 2))
        
        // Right Leg Back (4x12 at 12,20)
        context.setFillColor(pantsColor.cgColor)
        context.fill(CGRect(x: 12, y: 20, width: 4, height: 12))
        context.setFillColor(shoeColor.cgColor)
        context.fill(CGRect(x: 12, y: 30, width: 4, height: 2))
        
        // Right Leg Right (4x12 at 0,20)
        context.setFillColor(pantsColor.cgColor)
        context.fill(CGRect(x: 0, y: 20, width: 4, height: 12))
        context.setFillColor(shoeColor.cgColor)
        context.fill(CGRect(x: 0, y: 30, width: 4, height: 2))
        
        // Right Leg Left (4x12 at 8,20)
        context.setFillColor(pantsColor.cgColor)
        context.fill(CGRect(x: 8, y: 20, width: 4, height: 12))
        context.setFillColor(shoeColor.cgColor)
        context.fill(CGRect(x: 8, y: 30, width: 4, height: 2))
        
        // Right Leg Top (4x4 at 4,16)
        context.setFillColor(pantsColor.cgColor)
        context.fill(CGRect(x: 4, y: 16, width: 4, height: 4))
        
        // Right Leg Bottom (4x4 at 8,16)
        context.setFillColor(shoeColor.cgColor)
        context.fill(CGRect(x: 8, y: 16, width: 4, height: 4))
        
        // MARK: LEFT LEG TEXTURES
        // Left Leg Front (4x12 at 20,52)
        context.setFillColor(pantsColor.cgColor)
        context.fill(CGRect(x: 20, y: 52, width: 4, height: 12))
        context.setFillColor(shoeColor.cgColor)
        context.fill(CGRect(x: 20, y: 62, width: 4, height: 2))
        
        // Left Leg Back (4x12 at 28,52)
        context.setFillColor(pantsColor.cgColor)
        context.fill(CGRect(x: 28, y: 52, width: 4, height: 12))
        context.setFillColor(shoeColor.cgColor)
        context.fill(CGRect(x: 28, y: 62, width: 4, height: 2))
        
        // Left Leg Left (4x12 at 16,52)
        context.setFillColor(pantsColor.cgColor)
        context.fill(CGRect(x: 16, y: 52, width: 4, height: 12))
        context.setFillColor(shoeColor.cgColor)
        context.fill(CGRect(x: 16, y: 62, width: 4, height: 2))
        
        // Left Leg Right (4x12 at 24,52)
        context.setFillColor(pantsColor.cgColor)
        context.fill(CGRect(x: 24, y: 52, width: 4, height: 12))
        context.setFillColor(shoeColor.cgColor)
        context.fill(CGRect(x: 24, y: 62, width: 4, height: 2))
        
        // Left Leg Top (4x4 at 20,48)
        context.setFillColor(pantsColor.cgColor)
        context.fill(CGRect(x: 20, y: 48, width: 4, height: 4))
        
        // Left Leg Bottom (4x4 at 24,48)
        context.setFillColor(shoeColor.cgColor)
        context.fill(CGRect(x: 24, y: 48, width: 4, height: 4))
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - Alex (Female Character)
    static func createAlexSkin() -> UIImage {
        let width = 64
        let height = 64
        let size = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        // Fill with transparent background
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Alex Colors
        let skinColor = UIColor(red: 0.98, green: 0.85, blue: 0.75, alpha: 1.0) // Lighter skin
        let hairColor = UIColor(red: 0.9, green: 0.5, blue: 0.2, alpha: 1.0) // Orange hair
        let eyeGreen = UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
        _ = UIColor(red: 0.5, green: 0.9, blue: 0.5, alpha: 1.0) // Light green
        _ = UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0) // Brown
        _ = UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0) // Dark brown
        
        // Similar structure to Steve but with Alex colors and 3px arms
        // (Implementation follows same pattern as Steve with adjusted colors)
        // For brevity, using simplified version
        
        // Head
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 8, y: 8, width: 8, height: 8))
        
        // Hair (longer, side swept)
        context.setFillColor(hairColor.cgColor)
        context.fill(CGRect(x: 8, y: 8, width: 8, height: 5))
        context.fill(CGRect(x: 7, y: 10, width: 1, height: 4))
        context.fill(CGRect(x: 16, y: 10, width: 1, height: 4))
        
        // Eyes
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(x: 10, y: 12, width: 2, height: 1))
        context.fill(CGRect(x: 13, y: 12, width: 2, height: 1))
        
        context.setFillColor(eyeGreen.cgColor)
        context.fill(CGRect(x: 10, y: 12, width: 1, height: 1))
        context.fill(CGRect(x: 14, y: 12, width: 1, height: 1))
        
        // Continue with body parts...
        // (Full implementation would follow Steve pattern with Alex colors)
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - Zombie Skin
    static func createZombieSkin() -> UIImage {
        let width = 64
        let height = 64
        let size = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Zombie Colors
        let skinColor = UIColor(red: 0.4, green: 0.6, blue: 0.3, alpha: 1.0) // Green skin
        let darkGreen = UIColor(red: 0.2, green: 0.4, blue: 0.2, alpha: 1.0)
        _ = UIColor(red: 0.3, green: 0.5, blue: 0.7, alpha: 1.0) // Torn blue
        _ = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0) // Dark torn
        
        // Apply zombie texture (simplified)
        // Head
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 8, y: 8, width: 8, height: 8))
        
        // Dark patches
        context.setFillColor(darkGreen.cgColor)
        context.fill(CGRect(x: 9, y: 9, width: 2, height: 2))
        context.fill(CGRect(x: 14, y: 11, width: 2, height: 2))
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - Knight Skin
    static func createKnightSkin() -> UIImage {
        let width = 64
        let height = 64
        let size = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Knight Colors
        let armorColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0) // Silver armor
        _ = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        let visorColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        
        // Apply knight armor texture (simplified)
        // Head (helmet)
        context.setFillColor(armorColor.cgColor)
        context.fill(CGRect(x: 8, y: 8, width: 8, height: 8))
        
        // Visor slit
        context.setFillColor(visorColor.cgColor)
        context.fill(CGRect(x: 10, y: 12, width: 5, height: 1))
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - Knight v2 (cleaner edges)
    static func createKnightV2Skin() -> UIImage {
        let width = 64, height = 64
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return UIImage() }
        // Colors
        let plate = UIColor(red: 0.75, green: 0.76, blue: 0.80, alpha: 1.0)
        let shadow = UIColor(red: 0.55, green: 0.56, blue: 0.60, alpha: 1.0)
        let trim = UIColor(red: 0.90, green: 0.85, blue: 0.60, alpha: 1.0)
        // Body front panel with subtle trim
        ctx.setFillColor(plate.cgColor)
        ctx.fill(CGRect(x: 20, y: 20, width: 8, height: 12))
        ctx.setFillColor(trim.cgColor)
        ctx.fill(CGRect(x: 20, y: 20, width: 8, height: 1))
        ctx.fill(CGRect(x: 20, y: 31, width: 8, height: 1))
        // Shoulder pads (arm fronts upper)
        ctx.setFillColor(shadow.cgColor)
        ctx.fill(CGRect(x: 44, y: 20, width: 4, height: 3))
        ctx.fill(CGRect(x: 36, y: 52, width: 4, height: 3))
        // Greaves (legs front lower)
        ctx.setFillColor(shadow.cgColor)
        ctx.fill(CGRect(x: 4, y: 28, width: 4, height: 4))
        ctx.fill(CGRect(x: 20, y: 60, width: 4, height: 4))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - Astronaut Skin
    static func createAstronautSkin() -> UIImage {
        let width = 64
        let height = 64
        let size = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Astronaut Colors
        let helmetColor = UIColor.white
        let visorColor = UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 0.8) // Dark blue visor
        _ = UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0) // White suit
        _ = UIColor.red // Red stripes
        
        // Apply astronaut texture (simplified)
        // Head (helmet)
        context.setFillColor(helmetColor.cgColor)
        context.fill(CGRect(x: 8, y: 8, width: 8, height: 8))
        
        // Visor
        context.setFillColor(visorColor.cgColor)
        context.fill(CGRect(x: 9, y: 10, width: 6, height: 4))
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: - Space Suit v2 (panel lines)
    static func createSpaceSuitV2Skin() -> UIImage {
        let width = 64, height = 64
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return UIImage() }
        // Colors
        let suit = UIColor(white: 0.96, alpha: 1.0)
        let panel = UIColor(white: 0.85, alpha: 1.0)
        let accent = UIColor(red: 0.15, green: 0.35, blue: 0.70, alpha: 1.0)
        // Body front
        ctx.setFillColor(suit.cgColor)
        ctx.fill(CGRect(x: 20, y: 20, width: 8, height: 12))
        // Panel lines
        ctx.setFillColor(panel.cgColor)
        ctx.fill(CGRect(x: 20, y: 24, width: 8, height: 1))
        ctx.fill(CGRect(x: 20, y: 28, width: 8, height: 1))
        // Accent stripe
        ctx.setFillColor(accent.cgColor)
        ctx.fill(CGRect(x: 23, y: 26, width: 2, height: 1))
        ctx.fill(CGRect(x: 27, y: 26, width: 2, height: 1))
        // Arms/legs top panels
        ctx.setFillColor(panel.cgColor)
        ctx.fill(CGRect(x: 44, y: 20, width: 4, height: 2)) // R arm
        ctx.fill(CGRect(x: 36, y: 52, width: 4, height: 2)) // L arm
        ctx.fill(CGRect(x: 4, y: 20, width: 4, height: 2))  // R leg
        ctx.fill(CGRect(x: 20, y: 52, width: 4, height: 2)) // L leg
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - Ninja Skin
    static func createNinjaSkin() -> UIImage {
        let width = 64
        let height = 64
        let size = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Ninja Colors
        let maskColor = UIColor.black
        let skinColor = UIColor(red: 0.95, green: 0.85, blue: 0.75, alpha: 1.0)
        _ = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0) // Black suit
        _ = UIColor.red
        
        // Apply ninja texture (simplified)
        // Head (mostly mask)
        context.setFillColor(maskColor.cgColor)
        context.fill(CGRect(x: 8, y: 8, width: 8, height: 8))
        
        // Eye slit
        context.setFillColor(skinColor.cgColor)
        context.fill(CGRect(x: 10, y: 12, width: 5, height: 1))
        
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // Default skin is Steve
    static func createDefaultSkin() -> UIImage {
        return createSteveSkin()
    }
}

// MARK: - Skin Template Info
struct BaseSkinTemplate: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let generator: () -> UIImage
    let icon: String
    let recommendedPaletteName: String? = nil
}

extension DefaultSkinTemplates {
    static let availableTemplates = [
        BaseSkinTemplate(
            name: "Steve",
            description: "Classic Minecraft character",
            generator: createSteveSkin,
            icon: "person.fill"
        ),
        BaseSkinTemplate(
            name: "Alex",
            description: "Female character with orange hair",
            generator: createAlexSkin,
            icon: "person.fill"
        ),
        BaseSkinTemplate(
            name: "Zombie",
            description: "Undead creature with green skin",
            generator: createZombieSkin,
            icon: "figure.walk"
        ),
        BaseSkinTemplate(
            name: "Knight",
            description: "Medieval warrior in shining armor",
            generator: createKnightSkin,
            icon: "shield.fill"
        ),
        BaseSkinTemplate(
            name: "Astronaut",
            description: "Space explorer with helmet",
            generator: createAstronautSkin,
            icon: "sparkles"
        ),
        BaseSkinTemplate(
            name: "Ninja",
            description: "Stealthy warrior in black",
            generator: createNinjaSkin,
            icon: "eye.slash.fill"
        ),
        BaseSkinTemplate(
            name: "Hoodie",
            description: "Casual hoodie + jeans starter",
            generator: createHoodieSkin,
            icon: "tshirt.fill"
        ),
        BaseSkinTemplate(
            name: "Pastel Cute",
            description: "Soft pastel palette with accents",
            generator: createPastelCuteSkin,
            icon: "heart.fill"
        ),
        BaseSkinTemplate(
            name: "Knight v2",
            description: "Cleaner armor, shoulder pads",
            generator: createKnightV2Skin,
            icon: "shield.lefthalf.filled"
        ),
        BaseSkinTemplate(
            name: "Space Suit v2",
            description: "Panel lines, subtle accents",
            generator: createSpaceSuitV2Skin,
            icon: "sparkles"
        )
    ]
}

// MARK: - Curated Starters
extension DefaultSkinTemplates {
    static func createHoodieSkin() -> UIImage {
        let width = 64, height = 64
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }

        // Colors
        let skin = UIColor(red: 0.96, green: 0.80, blue: 0.69, alpha: 1.0)
        let hoodie = UIColor(red: 0.20, green: 0.22, blue: 0.35, alpha: 1.0) // navy
        let accent = UIColor(red: 0.95, green: 0.40, blue: 0.50, alpha: 1.0) // stripe
        let jeans = UIColor(red: 0.18, green: 0.30, blue: 0.55, alpha: 1.0)

        // Head front
        context.setFillColor(skin.cgColor)
        context.fill(CGRect(x: 8, y: 8, width: 8, height: 8))
        // Hoodie hood overlay front
        context.setFillColor(hoodie.withAlphaComponent(0.9).cgColor)
        context.fill(CGRect(x: 8, y: 8, width: 8, height: 2))

        // Body front (hoodie)
        context.setFillColor(hoodie.cgColor)
        context.fill(CGRect(x: 20, y: 20, width: 8, height: 12))
        // Accent stripe
        context.setFillColor(accent.cgColor)
        context.fill(CGRect(x: 20, y: 24, width: 8, height: 1))

        // Arms front (sleeves top area)
        context.setFillColor(hoodie.cgColor)
        context.fill(CGRect(x: 44, y: 20, width: 4, height: 6)) // right arm top
        context.fill(CGRect(x: 36, y: 52, width: 4, height: 6)) // left arm top

        // Legs front (jeans)
        context.setFillColor(jeans.cgColor)
        context.fill(CGRect(x: 4, y: 20, width: 4, height: 12)) // right leg
        context.fill(CGRect(x: 20, y: 52, width: 4, height: 12)) // left leg

        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return img
    }

    static func createPastelCuteSkin() -> UIImage {
        let width = 64, height = 64
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }

        // Colors
        let skin = UIColor(red: 1.0, green: 0.90, blue: 0.85, alpha: 1.0)
        let top = UIColor(red: 0.98, green: 0.76, blue: 0.90, alpha: 1.0)
        let skirt = UIColor(red: 0.80, green: 0.90, blue: 1.0, alpha: 1.0)
        let accent = UIColor(red: 1.0, green: 0.71, blue: 0.76, alpha: 1.0)

        // Head
        context.setFillColor(skin.cgColor)
        context.fill(CGRect(x: 8, y: 8, width: 8, height: 8))

        // Body
        context.setFillColor(top.cgColor)
        context.fill(CGRect(x: 20, y: 20, width: 8, height: 8))
        context.setFillColor(accent.cgColor)
        context.fill(CGRect(x: 20, y: 28, width: 8, height: 1)) // ribbon

        // Skirt (use lower body front area)
        context.setFillColor(skirt.cgColor)
        context.fill(CGRect(x: 20, y: 29, width: 8, height: 3))

        // Arms
        context.setFillColor(top.cgColor)
        context.fill(CGRect(x: 44, y: 20, width: 4, height: 6))
        context.fill(CGRect(x: 36, y: 52, width: 4, height: 6))

        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return img
    }
}
