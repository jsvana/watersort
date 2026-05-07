import SwiftUI

struct VialView: View {
    let vial: [Int] // bottom-to-top color indices
    let capacity: Int
    let isSelected: Bool
    let hidden: Bool
    let onTap: () -> Void

    var body: some View {
        GeometryReader { geo in
            let bandHeight = geo.size.height / CGFloat(capacity)
            let topIndex = vial.count - 1
            ZStack(alignment: .bottom) {
                // Glass outline
                vialShape
                    .stroke(Color.primary.opacity(0.35), lineWidth: 2.5)
                    .background(
                        vialShape.fill(Color.primary.opacity(0.04))
                    )

                // Liquid bands, drawn from the bottom up
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    ForEach(Array(vial.enumerated()).reversed(), id: \.offset) { offset, colorIndex in
                        let revealed = !hidden || offset == topIndex
                        band(colorIndex: colorIndex, height: bandHeight, revealed: revealed)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                }
                .clipShape(vialShape)
            }
        }
        .frame(width: 56, height: 200)
        .offset(y: isSelected ? -28 : 0)
        .scaleEffect(isSelected ? 1.04 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }

    private var vialShape: some Shape {
        UnevenRoundedRectangle(
            topLeadingRadius: 10,
            bottomLeadingRadius: 24,
            bottomTrailingRadius: 24,
            topTrailingRadius: 10
        )
    }

    @ViewBuilder
    private func band(colorIndex: Int, height: CGFloat, revealed: Bool) -> some View {
        if revealed {
            let liquid = palette[colorIndex % palette.count]
            ZStack {
                liquid.color
                Image(systemName: liquid.symbol)
                    .font(.system(size: height * 0.5, weight: .bold))
                    .foregroundStyle(.white.opacity(0.45))
            }
            .frame(height: height)
        } else {
            ZStack {
                Color(hex: 0x2A2E3A)
                Image(systemName: "questionmark")
                    .font(.system(size: height * 0.45, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.3))
            }
            .frame(height: height)
        }
    }
}
