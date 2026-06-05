import WidgetKit
import SwiftUI

struct ScoreEntry: TimelineEntry {
    let date: Date
    let score: ScoreResponse?
    let teamAbbr: String?
    let isError: Bool

    var status: String {
        score?.status ?? "none"
    }

    var inlineText: String {
        if isError {
            return "取得不可"
        }
        if teamAbbr == nil {
            return "チーム未選択"
        }
        return score?.inlineText ?? "取得不可"
    }

    static let pickTeam = ScoreEntry(
        date: .now,
        score: nil,
        teamAbbr: nil,
        isError: false
    )
}

struct ScoreProvider: TimelineProvider {
    func placeholder(in context: Context) -> ScoreEntry {
        ScoreEntry(
            date: .now,
            score: .previewLive,
            teamAbbr: "T",
            isError: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ScoreEntry) -> Void) {
        Task {
            completion(await loadEntry(fallback: placeholder(in: context)))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ScoreEntry>) -> Void) {
        Task {
            let entry = await loadEntry(fallback: placeholder(in: context))
            let refresh = ScoreRefreshInterval.nextDate(from: entry.date, status: entry.status)
            completion(Timeline(entries: [entry], policy: .after(refresh)))
        }
    }

    private func loadEntry(fallback: ScoreEntry) async -> ScoreEntry {
        guard let teamAbbr = TeamPreferences.shared.favoriteTeamAbbr else {
            return .pickTeam
        }

        do {
            let score = try await APIClient.shared.fetchScore(teamAbbr: teamAbbr)
            return ScoreEntry(
                date: .now,
                score: score,
                teamAbbr: teamAbbr,
                isError: false
            )
        } catch {
            return ScoreEntry(
                date: .now,
                score: nil,
                teamAbbr: teamAbbr,
                isError: true
            )
        }
    }
}

struct ScoreWidgetView: View {
    @Environment(\.widgetFamily) private var family

    var entry: ScoreEntry

    var body: some View {
        switch family {
        case .accessoryRectangular:
            rectangularBody
        default:
            inlineBody
        }
    }

    private var inlineBody: some View {
        Text(entry.inlineText)
            .font(.caption2.monospaced())
            .minimumScaleFactor(0.7)
            .lineLimit(1)
    }

    private var rectangularBody: some View {
        ScoreDisplayView(
            score: entry.score,
            teamAbbr: entry.teamAbbr,
            isError: entry.isError,
            style: .widgetRectangular
        )
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

#if DEBUG
#Preview(as: .accessoryInline) {
    FavFieldWidget()
} timeline: {
    ScoreEntry(date: .now, score: .previewLive, teamAbbr: "T", isError: false)
    ScoreEntry(date: .now, score: .previewPre, teamAbbr: "T", isError: false)
    ScoreEntry(date: .now, score: .previewNone, teamAbbr: "E", isError: false)
}

#Preview(as: .accessoryRectangular) {
    FavFieldWidget()
} timeline: {
    ScoreEntry(date: .now, score: .previewLive, teamAbbr: "T", isError: false)
    ScoreEntry(date: .now, score: .previewFinal, teamAbbr: "T", isError: false)
    ScoreEntry(date: .now, score: .previewPre, teamAbbr: "T", isError: false)
    ScoreEntry(date: .now, score: .previewNone, teamAbbr: "E", isError: false)
}
#endif
