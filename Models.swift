import Foundation

/// A single puzzle. `vials` is an array of vials, each vial is an array of
/// color indices stacked bottom-to-top. Empty array = empty vial.
///
/// `hidden` (optional, defaults to false) marks "blind" levels: the player
/// only sees the top color of each vial; lower bands stay obscured until
/// the band above them is poured off.
struct Level: Codable, Identifiable, Hashable {
    let id: Int
    let vials: [[Int]]
    let hidden: Bool?

    var isHidden: Bool { hidden ?? false }
}

struct LevelPack: Codable {
    let levels: [Level]
}
