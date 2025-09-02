//
//  FloatingToolPalette.swift
//  SkinCrafter
//
//  Created by Claude on 8/31/25.
//

import SwiftUI

struct FloatingToolPalette: View {
    @Binding var selectedTool: DrawingTool
    @Binding var selectedColor: Color
    @Binding var brushSize: Float
    @State private var isExpanded = false
    @State private var showColorPicker = false
    
    let compactMode: Bool
    let onToolChange: (DrawingTool) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            if compactMode {
                compactPalette
            } else {
                expandedPalette
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .sheet(isPresented: $showColorPicker) {
            ColorPickerSheet(selectedColor: $selectedColor)
        }
    }
    
    private var compactPalette: some View {
        VStack(spacing: 8) {
            // Main tool button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: selectedTool.iconName)
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(selectedColor.opacity(0.2)))
            }
            
            if isExpanded {
                toolGrid
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(12)
    }
    
    private var expandedPalette: some View {
        HStack(spacing: 12) {
            toolGrid
            
            Divider()
                .frame(height: 60)
            
            colorAndBrushControls
        }
        .padding(16)
    }
    
    private var toolGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(40), spacing: 8), count: compactMode ? 3 : 6), spacing: 8) {
            ForEach(DrawingTool.allCases, id: \.self) { tool in
                Button(action: {
                    selectedTool = tool
                    onToolChange(tool)
                    if compactMode {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isExpanded = false
                        }
                    }
                }) {
                    Image(systemName: tool.iconName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selectedTool == tool ? .white : .primary)
                        .frame(width: 40, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTool == tool ? Color.accentColor : Color.gray.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var colorAndBrushControls: some View {
        VStack(spacing: 12) {
            // Color selector
            Button(action: {
                showColorPicker = true
            }) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedColor)
                    .frame(width: 40, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.primary.opacity(0.2), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            
            // Brush size slider
            VStack(spacing: 4) {
                Text("Size")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Slider(value: $brushSize, in: 1...20, step: 1)
                    .frame(width: 60)
                    .accentColor(.primary)
                
                Text("\(Int(brushSize))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}



// Preview
struct FloatingToolPalette_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Compact mode preview
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingToolPalette(
                        selectedTool: .constant(.brush),
                        selectedColor: .constant(.red),
                        brushSize: .constant(5),
                        compactMode: true,
                        onToolChange: { _ in }
                    )
                    .padding()
                }
            }
            .previewDisplayName("Compact Mode")
            
            // Expanded mode preview
            VStack {
                Spacer()
                FloatingToolPalette(
                    selectedTool: .constant(.brush),
                    selectedColor: .constant(.blue),
                    brushSize: .constant(8),
                    compactMode: false,
                    onToolChange: { _ in }
                )
                .padding()
            }
            .previewDisplayName("Expanded Mode")
        }
    }
}