import SwiftUI

struct TeamPickerView: View {
    @State private var teams: [Team] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    let onSelect: (String) -> Void

    var body: some View {
        Group {
            if isLoading {
                ProgressView("読み込み中...")
            } else if let errorMessage {
                VStack(spacing: 8) {
                    Text(errorMessage)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                    Button("再読み込み") {
                        Task { await loadTeams() }
                    }
                }
            } else {
                List(teams) { team in
                    Button {
                        TeamPreferences.shared.favoriteTeamAbbr = team.abbr
                        WidgetReloader.reloadScoreWidget()
                        onSelect(team.abbr)
                    } label: {
                        HStack {
                            Text(team.abbr)
                                .font(.headline.monospaced())
                                .frame(width: 28, alignment: .leading)
                            Text(team.name)
                            Spacer()
                        }
                    }
                }
            }
        }
        .task {
            await loadTeams()
        }
    }

    @MainActor
    private func loadTeams() async {
        isLoading = true
        errorMessage = nil

        do {
            teams = try await ScoreService.current.fetchTeams()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    TeamPickerView { _ in }
}
