import SwiftUI

struct SkinTemplate {
    let name: String
    let category: String
    let baseColors: [SkinRegion: Color]
    let overlayColors: [SkinRegion: Color]
    
    enum SkinRegion {
        case head, body, rightArm, leftArm, rightLeg, leftLeg
    }
}

class TemplateManager {
    static let shared = TemplateManager()
    
    let templates: [SkinTemplate] = [
        SkinTemplate(
            name: "Classic Player",
            category: "Classic",
            baseColors: [
                .head: Color(red: 0.96, green: 0.80, blue: 0.69),
                .body: Color(red: 0.0, green: 0.68, blue: 0.94),
                .rightArm: Color(red: 0.96, green: 0.80, blue: 0.69),
                .leftArm: Color(red: 0.96, green: 0.80, blue: 0.69),
                .rightLeg: Color(red: 0.27, green: 0.39, blue: 0.81),
                .leftLeg: Color(red: 0.27, green: 0.39, blue: 0.81)
            ],
            overlayColors: [:]
        ),
        
        SkinTemplate(
            name: "Slim Player",
            category: "Classic",
            baseColors: [
                .head: Color(red: 0.98, green: 0.86, blue: 0.74),
                .body: Color(red: 0.55, green: 0.86, blue: 0.48),
                .rightArm: Color(red: 0.98, green: 0.86, blue: 0.74),
                .leftArm: Color(red: 0.98, green: 0.86, blue: 0.74),
                .rightLeg: Color(red: 0.59, green: 0.46, blue: 0.36),
                .leftLeg: Color(red: 0.59, green: 0.46, blue: 0.36)
            ],
            overlayColors: [:]
        ),
        
        SkinTemplate(
            name: "Green Monster",
            category: "Mobs",
            baseColors: [
                .head: Color(red: 0.0, green: 0.80, blue: 0.0),
                .body: Color(red: 0.0, green: 0.80, blue: 0.0),
                .rightArm: Color(red: 0.0, green: 0.60, blue: 0.0),
                .leftArm: Color(red: 0.0, green: 0.60, blue: 0.0),
                .rightLeg: Color(red: 0.0, green: 0.60, blue: 0.0),
                .leftLeg: Color(red: 0.0, green: 0.60, blue: 0.0)
            ],
            overlayColors: [
                .head: Color.black.opacity(0.3)
            ]
        ),
        
        SkinTemplate(
            name: "Zombie",
            category: "Mobs",
            baseColors: [
                .head: Color(red: 0.32, green: 0.62, blue: 0.31),
                .body: Color(red: 0.32, green: 0.62, blue: 0.31),
                .rightArm: Color(red: 0.32, green: 0.62, blue: 0.31),
                .leftArm: Color(red: 0.32, green: 0.62, blue: 0.31),
                .rightLeg: Color(red: 0.27, green: 0.39, blue: 0.81),
                .leftLeg: Color(red: 0.27, green: 0.39, blue: 0.81)
            ],
            overlayColors: [:]
        ),
        
        SkinTemplate(
            name: "Skeleton",
            category: "Mobs",
            baseColors: [
                .head: Color(red: 0.95, green: 0.95, blue: 0.95),
                .body: Color(red: 0.95, green: 0.95, blue: 0.95),
                .rightArm: Color(red: 0.95, green: 0.95, blue: 0.95),
                .leftArm: Color(red: 0.95, green: 0.95, blue: 0.95),
                .rightLeg: Color(red: 0.95, green: 0.95, blue: 0.95),
                .leftLeg: Color(red: 0.95, green: 0.95, blue: 0.95)
            ],
            overlayColors: [
                .head: Color.black.opacity(0.2),
                .body: Color.black.opacity(0.2)
            ]
        ),
        
        SkinTemplate(
            name: "Shadow Being",
            category: "Mobs",
            baseColors: [
                .head: Color.black,
                .body: Color.black,
                .rightArm: Color.black,
                .leftArm: Color.black,
                .rightLeg: Color.black,
                .leftLeg: Color.black
            ],
            overlayColors: [
                .head: Color.purple.opacity(0.5)
            ]
        ),
        
        SkinTemplate(
            name: "Knight",
            category: "Fantasy",
            baseColors: [
                .head: Color(red: 0.96, green: 0.80, blue: 0.69),
                .body: Color(red: 0.75, green: 0.75, blue: 0.75),
                .rightArm: Color(red: 0.75, green: 0.75, blue: 0.75),
                .leftArm: Color(red: 0.75, green: 0.75, blue: 0.75),
                .rightLeg: Color(red: 0.75, green: 0.75, blue: 0.75),
                .leftLeg: Color(red: 0.75, green: 0.75, blue: 0.75)
            ],
            overlayColors: [
                .head: Color(red: 0.60, green: 0.60, blue: 0.60)
            ]
        ),
        
        SkinTemplate(
            name: "Ninja",
            category: "Fantasy",
            baseColors: [
                .head: Color.black,
                .body: Color.black,
                .rightArm: Color.black,
                .leftArm: Color.black,
                .rightLeg: Color.black,
                .leftLeg: Color.black
            ],
            overlayColors: [
                .head: Color.red.opacity(0.3)
            ]
        ),
        
        SkinTemplate(
            name: "Astronaut",
            category: "Modern",
            baseColors: [
                .head: Color.white,
                .body: Color.white,
                .rightArm: Color.white,
                .leftArm: Color.white,
                .rightLeg: Color.white,
                .leftLeg: Color.white
            ],
            overlayColors: [
                .head: Color(red: 0.8, green: 0.8, blue: 0.9).opacity(0.5),
                .body: Color.blue.opacity(0.2)
            ]
        ),
        
        SkinTemplate(
            name: "Robot",
            category: "Modern",
            baseColors: [
                .head: Color(red: 0.7, green: 0.7, blue: 0.7),
                .body: Color(red: 0.7, green: 0.7, blue: 0.7),
                .rightArm: Color(red: 0.7, green: 0.7, blue: 0.7),
                .leftArm: Color(red: 0.7, green: 0.7, blue: 0.7),
                .rightLeg: Color(red: 0.7, green: 0.7, blue: 0.7),
                .leftLeg: Color(red: 0.7, green: 0.7, blue: 0.7)
            ],
            overlayColors: [
                .head: Color.cyan.opacity(0.3),
                .body: Color.red.opacity(0.2)
            ]
        )
    ]
    
    func applyTemplate(_ template: SkinTemplate, to skin: inout CharacterSkin) {
        // Apply base colors to different regions
        applyRegionColors(template.baseColors, to: &skin, layer: .base)
        
        // Apply overlay colors
        if !template.overlayColors.isEmpty {
            applyRegionColors(template.overlayColors, to: &skin, layer: .overlay)
        }
    }
    
    private func applyRegionColors(_ colors: [SkinTemplate.SkinRegion: Color], to skin: inout CharacterSkin, layer: SkinLayer) {
        for (region, color) in colors {
            let coords = getRegionCoordinates(for: region)
            for (x, y) in coords {
                skin.setPixel(x: x, y: y, color: color, layer: layer)
            }
        }
    }
    
    private func getRegionCoordinates(for region: SkinTemplate.SkinRegion) -> [(Int, Int)] {
        var coords: [(Int, Int)] = []
        
        switch region {
        case .head:
            // Front face of head (8x8 at position 8,8)
            for y in 8..<16 {
                for x in 8..<16 {
                    coords.append((x, y))
                }
            }
            // Top of head (8x8 at position 8,0)
            for y in 0..<8 {
                for x in 8..<16 {
                    coords.append((x, y))
                }
            }
            
        case .body:
            // Front of body (8x12 at position 20,20)
            for y in 20..<32 {
                for x in 20..<28 {
                    coords.append((x, y))
                }
            }
            
        case .rightArm:
            // Right arm (4x12 at position 44,20)
            for y in 20..<32 {
                for x in 44..<48 {
                    coords.append((x, y))
                }
            }
            
        case .leftArm:
            // Left arm (4x12 at position 36,52)
            for y in 52..<64 {
                for x in 36..<40 {
                    coords.append((x, y))
                }
            }
            
        case .rightLeg:
            // Right leg (4x12 at position 4,20)
            for y in 20..<32 {
                for x in 4..<8 {
                    coords.append((x, y))
                }
            }
            
        case .leftLeg:
            // Left leg (4x12 at position 20,52)
            for y in 52..<64 {
                for x in 20..<24 {
                    coords.append((x, y))
                }
            }
        }
        
        return coords
    }
}