import Foundation

/// A single puzzle. `vials` is an array of vials, each vial is an array of
/// color indices stacked bottom-to-top. Empty array = empty vial.
struct Level: Codable, Identifiable, Hashable {
    let id: Int
    let vials: [[Int]]
}

struct LevelPack: Codable {
    let levels: [Level]
}
