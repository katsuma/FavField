import WidgetKit
import SwiftUI

struct ScoreEntry: TimelineEntry {
    let date: Date
    let score: ScoreResponse?
    let teamAbbr: String?
    let isError: Bool
    let isLoading: Bool

    init(
        date: Date,
        score: ScoreResponse?,
        teamAbbr: String?,
        isError: Bool,
        isLoading: Bool = false
    ) {
        self.date = date
        self.score = score
        self.teamAbbr = teamAbbr
        self.isError = isError
        self.isLoading = isLoading
    }

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

    static func loading(teamAbbr: String?) -> ScoreEntry {
        ScoreEntry(
            date: .now,
            score: nil,
            teamAbbr: teamAbbr,
            isError: false,
            isLoading: true
        )
    }
}

struct ScoreProvider: TimelineProvider {
    private let widgetKind = "FavFieldScoreWidget"

    func placeholder(in context: Context) -> ScoreEntry {
        .loading(teamAbbr: TeamPreferences.shared.favoriteTeamAbbr)
    }

    func getSnapshot(in context: Context, completion: @escaping (ScoreEntry) -> Void) {
        if context.isPreview {
            completion(placeholder(in: context))
            return
        }

        Task {
            completion(await loadEntry())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ScoreEntry>) -> Void) {
        if WidgetLoadingState.consumeLoading() {
            let loadingEntry = ScoreEntry.loading(
                teamAbbr: TeamPreferences.shared.favoriteTeamAbbr
            )
            completion(
                Timeline(
                    entries: [loadingEntry],
                    policy: .after(Date().addingTimeInterval(1))
                )
            )
            Task {
                _ = await loadEntry()
                WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
            }
            return
        }

        Task {
            let entry = await loadEntry()
            let refresh = ScoreRefreshInterval.nextDate(
                from: entry.date,
                status: entry.status,
                startTime: entry.score?.startTime
            )
            completion(Timeline(entries: [entry], policy: .after(refresh)))
        }
    }

    private func loadEntry() async -> ScoreEntry {
        guard let teamAbbr = TeamPreferences.shared.favoriteTeamAbbr else {
            return .pickTeam
        }

        do {
            let score = try await ScoreService.current.fetchScore(teamAbbr: teamAbbr)
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
        if entry.isLoading {
            loadingBody
        } else {
            switch family {
            case .accessoryRectangular:
                rectangularBody
            default:
                inlineBody
            }
        }
    }

    private var loadingBody: some View {
        Group {
            switch family {
            case .accessoryRectangular:
                Color.clear
            default:
                Text(" ")
                    .font(.caption2)
            }
        }
    }

    private var inlineBody: some View {
        Text(entry.inlineText)
            .font(.caption2)
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
