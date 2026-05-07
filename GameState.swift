import Observation
import SwiftUI

@Observable
final class GameState {
    static let vialCapacity = 4
    private static let progressKey = "currentLevelIndex"
    private static let solvedKey = "solvedLevelIds"

    private(set) var levels: [Level] = []
    private(set) var currentLevelIndex: Int = 0
    var vials: [[Int]] = []
    var selectedVial: Int?
    private(set) var moveHistory: [[[Int]]] = []
    var didWin: Bool = false
    private(set) var solvedLevelIds: Set<Int> = []

    init() {
        loadLevels()
        loadSolved()
        currentLevelIndex = min(
            UserDefaults.standard.integer(forKey: Self.progressKey),
            max(levels.count - 1, 0)
        )
        startLevel(currentLevelIndex)
    }

    var currentLevel: Level? {
        guard currentLevelIndex >= 0, currentLevelIndex < levels.count else { return nil }
        return levels[currentLevelIndex]
    }

    func isSolved(levelIndex: Int) -> Bool {
        guard levelIndex >= 0, levelIndex < levels.count else { return false }
        return solvedLevelIds.contains(levels[levelIndex].id)
    }

    private func loadSolved() {
        let raw = UserDefaults.standard.array(forKey: Self.solvedKey) as? [Int] ?? []
        solvedLevelIds = Set(raw)
    }

    private func saveSolved() {
        UserDefaults.standard.set(Array(solvedLevelIds), forKey: Self.solvedKey)
    }

    // MARK: - Level loading

    private func loadLevels() {
        guard
            let url = Bundle.main.url(forResource: "Levels", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let pack = try? JSONDecoder().decode(LevelPack.self, from: data)
        else {
            // Fallback so the app still launches if the bundle is misconfigured.
            levels = [Level(id: 1, vials: [[0, 0, 1, 1], [1, 1, 0, 0], [], []], hidden: false)]
            return
        }
        levels = pack.levels
    }

    func startLevel(_ index: Int) {
        guard index >= 0, index < levels.count else { return }
        currentLevelIndex = index
        vials = levels[index].vials
        selectedVial = nil
        moveHistory = []
        didWin = false
    }

    func restartLevel() {
        startLevel(currentLevelIndex)
    }

    func nextLevel() {
        if currentLevelIndex + 1 < levels.count {
            startLevel(currentLevelIndex + 1)
            saveProgress()
        } else {
            // wrap or stay — just stay on last level
            didWin = false
        }
    }

    private func saveProgress() {
        UserDefaults.standard.set(currentLevelIndex, forKey: Self.progressKey)
    }

    // MARK: - Player input

    func tap(vial index: Int) {
        if let selected = selectedVial {
            if selected == index {
                selectedVial = nil // deselect
            } else {
                attemptPour(from: selected, to: index)
                selectedVial = nil
            }
        } else if !vials[index].isEmpty {
            selectedVial = index
        }
    }

    func undo() {
        guard let last = moveHistory.popLast() else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            vials = last
            selectedVial = nil
            didWin = false
        }
    }

    // MARK: - Game logic

    private func attemptPour(from src: Int, to dst: Int) {
        guard !vials[src].isEmpty,
              vials[dst].count < Self.vialCapacity else { return }

        let topColor = vials[src].last!
        if let dstTop = vials[dst].last, dstTop != topColor { return }

        var contiguous = 0
        for c in vials[src].reversed() {
            if c == topColor { contiguous += 1 } else { break }
        }
        let space = Self.vialCapacity - vials[dst].count
        let toPour = min(contiguous, space)
        guard toPour > 0 else { return }

        moveHistory.append(vials)

        withAnimation(.easeInOut(duration: 0.35)) {
            for _ in 0 ..< toPour {
                vials[src].removeLast()
                vials[dst].append(topColor)
            }
        }

        if isSolved {
            didWin = true
            solvedLevelIds.insert(levels[currentLevelIndex].id)
            saveSolved()
            saveProgress()
        }
    }

    var isSolved: Bool {
        vials.allSatisfy { v in
            v.isEmpty || (v.count == Self.vialCapacity && Set(v).count == 1)
        }
    }
}
