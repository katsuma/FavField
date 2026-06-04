import WidgetKit
import SwiftUI

struct ScoreEntry: TimelineEntry {
    let date: Date
    let display: String
    let status: String
    let teamAbbr: String?
    let isError: Bool

    static let pickTeam = ScoreEntry(
        date: .now,
        display: "Pick a team",
        status: "none",
        teamAbbr: nil,
        isError: false
    )
}

struct ScoreProvider: TimelineProvider {
    func placeholder(in context: Context) -> ScoreEntry {
        ScoreEntry(
            date: .now,
            display: "T 1-0 G 7裏",
            status: "live",
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
                display: score.display,
                status: score.status,
                teamAbbr: teamAbbr,
                isError: false
            )
        } catch {
            return ScoreEntry(
                date: .now,
                display: "Unavailable",
                status: "none",
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
        Text(entry.display)
            .font(.caption2.monospaced())
            .minimumScaleFactor(0.7)
            .lineLimit(1)
    }

    private var rectangularBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(entry.display)
                .font(.caption.monospaced())
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var subtitle: String {
        if entry.isError {
            return "Tap app to refresh"
        }
        if entry.teamAbbr == nil {
            return "Open FavField"
        }
        return GameStatus.label(for: entry.status)
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
    ScoreEntry(date: .now, display: "T 1-0 G 7裏", status: "live", teamAbbr: "T", isError: false)
}

#Preview(as: .accessoryRectangular) {
    FavFieldWidget()
} timeline: {
    ScoreEntry(date: .now, display: "L - T 18:00", status: "pre", teamAbbr: "T", isError: false)
}
