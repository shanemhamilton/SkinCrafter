//
//  BodyPartPageControl.swift
//  SkinCrafter
//
//  Created by Claude on 8/31/25.
//

import SwiftUI

struct BodyPartPageControl: View {
    @Binding var selectedBodyPart: BodyPart
    let availableBodyParts: [BodyPart]
    let onBodyPartChange: (BodyPart) -> Void
    
    @State private var dragOffset: CGFloat = 0
    @GestureState private var gestureOffset: CGFloat = 0
    
    private let itemWidth: CGFloat = 80
    private let spacing: CGFloat = 16
    
    var body: some View {
        VStack(spacing: 16) {
            // Body part carousel
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        ForEach(availableBodyParts, id: \.self) { bodyPart in
                            BodyPartCard(
                                bodyPart: bodyPart,
                                isSelected: selectedBodyPart == bodyPart,
                                action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedBodyPart = bodyPart
                                        onBodyPartChange(bodyPart)
                                    }
                                }
                            )
                            .id(bodyPart)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .onChange(of: selectedBodyPart) { newValue in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
            
            // Page indicator dots
            HStack(spacing: 8) {
                ForEach(availableBodyParts.indices, id: \.self) { index in
                    Circle()
                        .fill(selectedBodyPart == availableBodyParts[index] ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedBodyPart)
                }
            }
            
            // Navigation arrows (for iPad)
            if UIDevice.current.userInterfaceIdiom == .pad {
                HStack(spacing: 40) {
                    Button(action: selectPreviousBodyPart) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)
                    }
                    .disabled(selectedBodyPart == availableBodyParts.first)
                    
                    Spacer()
                    
                    Button(action: selectNextBodyPart) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title)
                            .foregroundColor(.accentColor)
                    }
                    .disabled(selectedBodyPart == availableBodyParts.last)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
    }
    
    private func selectPreviousBodyPart() {
        guard let currentIndex = availableBodyParts.firstIndex(of: selectedBodyPart),
              currentIndex > 0 else { return }
        
        let previousBodyPart = availableBodyParts[currentIndex - 1]
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedBodyPart = previousBodyPart
            onBodyPartChange(previousBodyPart)
        }
    }
    
    private func selectNextBodyPart() {
        guard let currentIndex = availableBodyParts.firstIndex(of: selectedBodyPart),
              currentIndex < availableBodyParts.count - 1 else { return }
        
        let nextBodyPart = availableBodyParts[currentIndex + 1]
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedBodyPart = nextBodyPart
            onBodyPartChange(nextBodyPart)
        }
    }
}

struct BodyPartCard: View {
    let bodyPart: BodyPart
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Icon
                Image(systemName: bodyPart.iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isSelected ? Color.accentColor : Color.gray.opacity(0.1))
                    )
                
                // Label
                Text(bodyPart.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .accentColor : .primary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 70)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}


// Navigation helper for gesture-based body part switching
extension BodyPartPageControl {
    func handleSwipeGesture(_ translation: CGSize) {
        guard abs(translation.width) > abs(translation.height) else { return }
        
        if translation.width > 50 {
            // Swipe right - previous body part
            selectPreviousBodyPart()
        } else if translation.width < -50 {
            // Swipe left - next body part
            selectNextBodyPart()
        }
    }
}

// Preview
struct BodyPartPageControl_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            // iPhone preview
            VStack {
                Spacer()
                BodyPartPageControl(
                    selectedBodyPart: .constant(.head),
                    availableBodyParts: BodyPart.allCases,
                    onBodyPartChange: { _ in }
                )
                .background(.ultraThinMaterial)
                Spacer()
            }
            .previewDisplayName("iPhone")
            .previewDevice("iPhone 15")
            
            // iPad preview
            VStack {
                Spacer()
                BodyPartPageControl(
                    selectedBodyPart: .constant(.body),
                    availableBodyParts: BodyPart.allCases,
                    onBodyPartChange: { _ in }
                )
                .background(.ultraThinMaterial)
                Spacer()
            }
            .previewDisplayName("iPad")
            .previewDevice("iPad Pro (12.9-inch)")
        }
    }
}