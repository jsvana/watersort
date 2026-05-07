import SwiftUI

struct LevelListView: View {
    let game: GameState
    let onSelect: (Int) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(game.levels.enumerated()), id: \.element.id) { index, level in
                    cell(index: index, level: level)
                }
            }
            .padding(16)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: 0x101218), Color(hex: 0x1C1F2A)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func cell(index: Int, level: Level) -> some View {
        let solved = game.isSolved(levelIndex: index)
        let current = index == game.currentLevelIndex

        Button {
            onSelect(index)
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 4) {
                    Text("\(index + 1)")
                        .font(.title2.weight(.semibold))
                        .monospacedDigit()
                    Text("\(level.vials.compactMap { $0.first }.uniqued().count) colors")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(solved
                            ? Color(hex: 0x06D6A0).opacity(0.18)
                            : Color.white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(current ? Color.white.opacity(0.7) : Color.white.opacity(0.1),
                                lineWidth: current ? 2 : 1)
                )

                if solved {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(hex: 0x06D6A0))
                        .padding(6)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
