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
            } else if let score {
                Text(score.display)
                    .font(.title3.monospaced())
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)

                Text(statusLabel(for: score.status))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Button("Refresh") {
                    Task { await loadScore() }
                }

                Button("Change Team") {
                    TeamPreferences.shared.favoriteTeamAbbr = nil
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
            score = try await APIClient.shared.fetchScore(teamAbbr: teamAbbr)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func statusLabel(for status: String) -> String {
        switch status {
        case "pre":
            return "Scheduled"
        case "live":
            return "Live"
        case "final":
            return "Final"
        case "cancelled":
            return "Cancelled"
        case "none":
            return "No game"
        default:
            return status
        }
    }
}

#Preview {
    ScoreView(teamAbbr: "T", onChangeTeam: {})
}
