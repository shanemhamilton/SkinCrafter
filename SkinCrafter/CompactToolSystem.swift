import SwiftUI

// MARK: - Compact Tool Carousel System
struct CompactToolCarousel: View {
    @Binding var selectedTool: AdvancedTool
    @Binding var showingToolSettings: Bool
    @State private var expandedCategory: ToolCategory? = nil
    @State private var showingQuickActions = false
    
    enum ToolCategory: String, CaseIterable {
        case drawing = "Drawing"
        case selection = "Select" 
        case adjustment = "Adjust"
        case special = "Special"
        
        var tools: [AdvancedTool] {
            switch self {
            case .drawing:
                return [.pencil, .brush, .airbrush, .eraser]
            case .selection:
                return [.eyedropper, .fillBucket, .gradientFill]
            case .adjustment:
                return [.smudge, .blur, .noise, .dither]
            case .special:
                return [.line, .rectangle, .ellipse, .mirror]
            }
        }
        
        var primaryTool: AdvancedTool {
            return tools.first!
        }
        
        var color: Color {
            switch self {
            case .drawing: return .blue
            case .selection: return .green
            case .adjustment: return .orange
            case .special: return .purple
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Quick Actions Row
            HStack(spacing: 12) {
                ForEach(ToolCategory.allCases, id: \.self) { category in
                    CompactToolButton(
                        tool: category.primaryTool,
                        isSelected: selectedTool == category.primaryTool,
                        categoryColor: category.color,
                        hasExpanded: expandedCategory == category
                    ) {
                        if expandedCategory == category {
                            expandedCategory = nil
                        } else {
                            selectedTool = category.primaryTool
                            expandedCategory = category
                            HapticManager.shared.impact(.light)
                        }
                    }
                }
                
                Spacer()
                
                // Settings button
                Button(action: { showingToolSettings.toggle() }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.05))
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // Expanded Tool Row
            if let expandedCategory = expandedCategory {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(expandedCategory.tools, id: \.self) { tool in
                            CompactToolButton(
                                tool: tool,
                                isSelected: selectedTool == tool,
                                categoryColor: expandedCategory.color,
                                hasExpanded: false
                            ) {
                                selectedTool = tool
                                self.expandedCategory = nil
                                HapticManager.shared.selectionChanged()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}

struct CompactToolButton: View {
    let tool: AdvancedTool
    let isSelected: Bool
    let categoryColor: Color
    let hasExpanded: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tool.iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                if !hasExpanded {
                    Text(tool.rawValue)
                        .font(.caption2)
                        .lineLimit(1)
                        .foregroundColor(isSelected ? .white : .secondary)
                }
            }
            .frame(width: 44, height: hasExpanded ? 44 : 60)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(categoryColor)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.clear)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(categoryColor.opacity(hasExpanded ? 0.5 : 0.2), lineWidth: 1)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// HapticManager is now in Services/HapticManager.swift