import WidgetKit
import SwiftUI

struct ScoreEntry: TimelineEntry {
    let date: Date
    let display: String
    let teamAbbr: String?
}

struct ScoreProvider: TimelineProvider {
    func placeholder(in context: Context) -> ScoreEntry {
        ScoreEntry(date: .now, display: "T 1-0 G 7裏", teamAbbr: "T")
    }

    func getSnapshot(in context: Context, completion: @escaping (ScoreEntry) -> Void) {
        Task {
            completion(await loadEntry(fallback: placeholder(in: context)))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ScoreEntry>) -> Void) {
        Task {
            let entry = await loadEntry(fallback: placeholder(in: context))
            let refresh = nextRefreshDate(for: entry)
            completion(Timeline(entries: [entry], policy: .after(refresh)))
        }
    }

    private func loadEntry(fallback: ScoreEntry) async -> ScoreEntry {
        guard let teamAbbr = TeamPreferences.shared.favoriteTeamAbbr else {
            return ScoreEntry(date: .now, display: "Pick a team", teamAbbr: nil)
        }

        do {
            let score = try await APIClient.shared.fetchScore(teamAbbr: teamAbbr)
            return ScoreEntry(date: .now, display: score.display, teamAbbr: teamAbbr)
        } catch {
            return ScoreEntry(date: .now, display: fallback.display, teamAbbr: teamAbbr)
        }
    }

    private func nextRefreshDate(for entry: ScoreEntry) -> Date {
        if entry.teamAbbr == nil {
            return Calendar.current.date(byAdding: .hour, value: 6, to: .now) ?? .now
        }

        if entry.display.contains(" - ") && entry.display.contains(":") {
            return Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now
        }

        if entry.display.contains("回") {
            return Calendar.current.date(byAdding: .minute, value: 3, to: .now) ?? .now
        }

        return Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
    }
}

struct ScoreWidgetView: View {
    var entry: ScoreEntry

    var body: some View {
        Text(entry.display)
            .font(.caption2.monospaced())
            .minimumScaleFactor(0.7)
            .lineLimit(1)
    }
}

struct FavFieldWidget: Widget {
    let kind = "FavFieldScoreWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ScoreProvider()) { entry in
            ScoreWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("FavField Score")
        .description("Latest NPB score for your favorite team.")
        .supportedFamilies([.accessoryInline, .accessoryRectangular])
    }
}

#Preview(as: .accessoryInline) {
    FavFieldWidget()
} timeline: {
    ScoreEntry(date: .now, display: "T 1-0 G 7裏", teamAbbr: "T")
}
