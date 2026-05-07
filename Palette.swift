import SwiftUI

/// A liquid color paired with a unique SF Symbol so it's distinguishable
/// even for colorblind players (and for kids still learning their colors).
struct LiquidColor {
    let color: Color
    let symbol: String
}

extension Color {
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

/// Up to 12 colors. Each pairs a saturated hex color with a distinctive symbol.
let palette: [LiquidColor] = [
    .init(color: Color(hex: 0xE63946), symbol: "circle.fill"), // red
    .init(color: Color(hex: 0x1D7AE3), symbol: "square.fill"), // blue
    .init(color: Color(hex: 0x2A9D8F), symbol: "triangle.fill"), // teal
    .init(color: Color(hex: 0xF4A300), symbol: "diamond.fill"), // amber
    .init(color: Color(hex: 0x8338EC), symbol: "hexagon.fill"), // purple
    .init(color: Color(hex: 0xFF6B35), symbol: "star.fill"), // orange
    .init(color: Color(hex: 0xE56399), symbol: "heart.fill"), // pink
    .init(color: Color(hex: 0x06D6A0), symbol: "moon.fill"), // mint
    .init(color: Color(hex: 0x6F4E37), symbol: "leaf.fill"), // brown
    .init(color: Color(hex: 0x4D5DFA), symbol: "bolt.fill"), // indigo
    .init(color: Color(hex: 0xFFD60A), symbol: "sun.max.fill"), // yellow
    .init(color: Color(hex: 0x999999), symbol: "cloud.fill"), // gray
]
