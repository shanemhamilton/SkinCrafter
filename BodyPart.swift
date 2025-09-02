//
//  BodyPart.swift
//  SkinCrafter
//
//  Created by Claude on 8/31/25.
//

import SwiftUI

enum BodyPart: String, CaseIterable {
    case head = "Head"
    case body = "Body"
    case rightArm = "Right Arm"
    case leftArm = "Left Arm"
    case rightLeg = "Right Leg"
    case leftLeg = "Left Leg"
    case hat = "Hat Layer"
    case jacket = "Jacket"
    
    func getRegion() -> (x: Range<Int>, y: Range<Int>) {
        switch self {
        case .head:
            return (8..<24, 0..<16)
        case .body:
            return (16..<40, 16..<32)
        case .rightArm:
            return (40..<56, 16..<32)
        case .leftArm:
            return (32..<48, 48..<64)
        case .rightLeg:
            return (0..<16, 16..<32)
        case .leftLeg:
            return (16..<32, 48..<64)
        case .hat:
            return (32..<64, 0..<16)
        case .jacket:
            return (16..<40, 32..<48)
        }
    }
    
    var color: Color {
        switch self {
        case .head: return .blue
        case .body: return .green
        case .rightArm, .leftArm: return .orange
        case .rightLeg, .leftLeg: return .purple
        case .hat: return .pink
        case .jacket: return .cyan
        }
    }
    
    var displayName: String {
        return self.rawValue
    }
    
    var iconName: String {
        switch self {
        case .head:
            return "person.crop.circle"
        case .body:
            return "person.fill"
        case .leftArm, .rightArm:
            return "arm.wave"
        case .leftLeg, .rightLeg:
            return "figure.walk"
        case .hat:
            return "hat.fill"
        case .jacket:
            return "jacket.fill"
        }
    }
    
    // Additional properties for GuidedCreationFlow compatibility
    var icon: String {
        switch self {
        case .head: return "face.smiling"
        case .body: return "tshirt"
        case .leftArm, .rightArm: return "hand.raised"
        case .leftLeg, .rightLeg: return "figure.walk"
        case .hat: return "hat.fill"
        case .jacket: return "jacket.fill"
        }
    }
    
    var order: Int {
        switch self {
        case .head: return 0
        case .body: return 1
        case .leftArm: return 2
        case .rightArm: return 3
        case .leftLeg: return 4
        case .rightLeg: return 5
        case .hat: return 6
        case .jacket: return 7
        }
    }
    
    var suggestedColors: [Color] {
        switch self {
        case .head:
            return [
                Color(red: 0.96, green: 0.80, blue: 0.69), // Skin tone
                Color(red: 0.85, green: 0.65, blue: 0.50), // Darker skin
                Color(red: 1.0, green: 0.90, blue: 0.80),  // Light skin
                .brown, .black // Hair colors
            ]
        case .body:
            return [.blue, .red, .green, .purple, .orange, .pink]
        case .leftArm, .rightArm:
            return [
                Color(red: 0.96, green: 0.80, blue: 0.69),
                .blue, .red, .white, .black
            ]
        case .leftLeg, .rightLeg:
            return [.blue, .black, .brown, .gray, .purple]
        case .hat:
            return [.black, .brown, .red, .blue, .green]
        case .jacket:
            return [.blue, .black, .red, .green, .gray]
        }
    }
    
    // UV coordinates for each body part in the 64x64 texture
    var textureRegion: (x: Int, y: Int, width: Int, height: Int) {
        switch self {
        case .head:
            return (x: 8, y: 0, width: 8, height: 8) // Front face
        case .body:
            return (x: 20, y: 20, width: 8, height: 12)
        case .rightArm:
            return (x: 44, y: 20, width: 4, height: 12)
        case .leftArm:
            return (x: 36, y: 52, width: 4, height: 12)
        case .rightLeg:
            return (x: 4, y: 20, width: 4, height: 12)
        case .leftLeg:
            return (x: 20, y: 52, width: 4, height: 12)
        case .hat:
            return (x: 40, y: 0, width: 8, height: 8)
        case .jacket:
            return (x: 20, y: 32, width: 8, height: 12)
        }
    }
    
    var mirrorPart: BodyPart? {
        switch self {
        case .leftArm: return .rightArm
        case .rightArm: return .leftArm
        case .leftLeg: return .rightLeg
        case .rightLeg: return .leftLeg
        default: return nil
        }
    }
}