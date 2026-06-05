import SwiftUI

struct ScoreView: View {
    let teamAbbr: String
    let onChangeTeam: () -> Void

    @State private var score: ScoreResponse?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 12) {
            if isLoading {
                ProgressView()
            } else if let errorMessage {
                Text(errorMessage)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
            } else {
                ScoreDisplayView(
                    score: score,
                    teamAbbr: teamAbbr,
                    isError: false,
                    style: .app
                )
                .multilineTextAlignment(.center)
            }

            HStack {
                Button("Refresh") {
                    Task { await loadScore() }
                }

                Button("Change Team") {
                    TeamPreferences.shared.favoriteTeamAbbr = nil
                    WidgetReloader.reloadScoreWidget()
                    onChangeTeam()
                }
            }
            .font(.caption2)
        }
        .padding()
        .task {
            await loadScore()
        }
    }

    @MainActor
    private func loadScore() async {
        isLoading = score == nil
        errorMessage = nil

        do {
            score = try await ScoreService.current.fetchScore(teamAbbr: teamAbbr)
            WidgetReloader.reloadScoreWidget()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    ScoreView(teamAbbr: "T", onChangeTeam: {})
}
