import SwiftUI

struct ContentView: View {
    @State private var game = GameState()
    @State private var showWinSheet = false
    @State private var showLevelList = false

    var body: some View {
        VStack(spacing: 0) {
            toolbar
                .padding(.horizontal)
                .padding(.top, 8)

            Spacer(minLength: 0)

            vialGrid
                .padding(.horizontal)

            Spacer(minLength: 0)

            footer
                .padding(.bottom, 16)
        }
        .background(
            LinearGradient(
                colors: [Color(hex: 0x101218), Color(hex: 0x1C1F2A)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .preferredColorScheme(.dark)
        .onChange(of: game.didWin) { _, won in
            if won {
                // small delay so the player sees the final pour land before the alert
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    showWinSheet = true
                }
            }
        }
        .sheet(isPresented: $showLevelList) {
            LevelListView(game: game) { index in
                game.startLevel(index)
                showLevelList = false
            }
        }
        .alert("Solved!", isPresented: $showWinSheet) {
            if game.currentLevelIndex + 1 < game.levels.count {
                Button("Next level") { game.nextLevel() }
                Button("Replay", role: .cancel) { game.restartLevel() }
            } else {
                Button("Replay", role: .cancel) { game.restartLevel() }
            }
        } message: {
            Text("Nice one.")
        }
    }

    private var toolbar: some View {
        HStack {
            Button {
                game.restartLevel()
            } label: {
                Label("Restart", systemImage: "arrow.counterclockwise")
            }
            Button {
                showLevelList = true
            } label: {
                Label("Levels", systemImage: "square.grid.3x3.fill")
            }
            Spacer()
            Text("Level \(game.currentLevelIndex + 1) / \(game.levels.count)")
                .font(.headline)
                .monospacedDigit()
            Spacer()
            Button {
                game.undo()
            } label: {
                Label("Undo", systemImage: "arrow.uturn.backward")
            }
            .disabled(game.moveHistory.isEmpty)
        }
        .labelStyle(.iconOnly)
        .font(.title2)
        .buttonStyle(.bordered)
    }

    private var vialGrid: some View {
        // pick a column count that keeps things readable across iPhone widths
        let count = game.vials.count
        let columns = count <= 4 ? count : (count <= 6 ? 3 : (count <= 9 ? 4 : 5))
        let rows = Int((Double(count) / Double(columns)).rounded(.up))

        return VStack(spacing: 32) {
            ForEach(0 ..< rows, id: \.self) { row in
                HStack(spacing: 14) {
                    ForEach(0 ..< columns, id: \.self) { col in
                        let idx = row * columns + col
                        if idx < count {
                            VialView(
                                vial: game.vials[idx],
                                capacity: GameState.vialCapacity,
                                isSelected: game.selectedVial == idx,
                                hidden: game.currentLevel?.isHidden ?? false,
                                onTap: { game.tap(vial: idx) }
                            )
                        } else {
                            Color.clear.frame(width: 56, height: 200)
                        }
                    }
                }
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 24) {
            Button {
                if game.currentLevelIndex > 0 {
                    game.startLevel(game.currentLevelIndex - 1)
                }
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(game.currentLevelIndex == 0)

            Text("Tap a vial to pick it up, tap another to pour")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                if game.currentLevelIndex + 1 < game.levels.count {
                    game.startLevel(game.currentLevelIndex + 1)
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(game.currentLevelIndex + 1 >= game.levels.count)
        }
        .font(.title3)
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
