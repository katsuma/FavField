import SwiftUI

struct ScoreDisplayView: View {
    enum Style {
        case widgetRectangular
        case app
    }

    let score: ScoreResponse?
    let teamAbbr: String?
    let isError: Bool
    let style: Style

    private var accentColor: Color { .orange }

    var body: some View {
        Group {
            if isError {
                fallbackBody(
                    title: "取得できません",
                    subtitle: "アプリで更新"
                )
            } else if teamAbbr == nil {
                fallbackBody(
                    title: "チーム未選択",
                    subtitle: "FavFieldを開く"
                )
            } else if let score {
                scoreBody(for: score)
            } else {
                fallbackBody(
                    title: "取得できません",
                    subtitle: "アプリで更新"
                )
            }
        }
    }

    @ViewBuilder
    private func scoreBody(for score: ScoreResponse) -> some View {
        switch score.status {
        case "none":
            Text(score.statusLabelJP)
                .font(secondaryFont)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: contentAlignment)
        case "pre":
            VStack(alignment: horizontalAlignment, spacing: spacing) {
                preGameLine(for: score)
                Text(score.subtitleLabelJP)
                    .font(secondaryFont)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: contentAlignment)
        case "live", "final", "cancelled":
            VStack(alignment: horizontalAlignment, spacing: spacing) {
                if score.status == "cancelled" {
                    cancelledLine(for: score)
                } else {
                    scoreLine(for: score)
                }
                Text(score.subtitleLabelJP)
                    .font(secondaryFont)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: contentAlignment)
        default:
            fallbackBody(
                title: score.display,
                subtitle: score.subtitleLabelJP
            )
        }
    }

    private func fallbackBody(title: String, subtitle: String) -> some View {
        VStack(alignment: horizontalAlignment, spacing: spacing) {
            Text(title)
                .font(scoreFont)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(subtitle)
                .font(secondaryFont)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: contentAlignment)
    }

    private func scoreLine(for score: ScoreResponse) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: groupSpacing) {
            teamScoreGroup(
                team: score.away.abbr,
                value: "\(score.away.score ?? 0)",
                valueColor: scoreColor(for: score, side: .away),
                teamFirst: true
            )
            Text("-")
                .font(scoreFont.monospacedDigit())
            teamScoreGroup(
                team: score.home.abbr,
                value: "\(score.home.score ?? 0)",
                valueColor: scoreColor(for: score, side: .home),
                teamFirst: false
            )
        }
        .minimumScaleFactor(0.7)
        .lineLimit(1)
    }

    private func teamScoreGroup(
        team: String,
        value: String,
        valueColor: Color,
        teamFirst: Bool
    ) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: teamScoreSpacing) {
            if teamFirst {
                Text(team)
                    .font(teamFont)
                Text(value)
                    .font(scoreFont.monospacedDigit())
                    .foregroundStyle(valueColor)
            } else {
                Text(value)
                    .font(scoreFont.monospacedDigit())
                    .foregroundStyle(valueColor)
                Text(team)
                    .font(teamFont)
            }
        }
    }

    private func preGameLine(for score: ScoreResponse) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: groupSpacing) {
            Text(score.away.abbr)
                .font(teamFont)
            Text(score.startTime ?? "--:--")
                .font(scoreFont.monospacedDigit())
            Text(score.home.abbr)
                .font(teamFont)
        }
        .minimumScaleFactor(0.7)
        .lineLimit(1)
    }

    private func cancelledLine(for score: ScoreResponse) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: groupSpacing) {
            Text(score.away.abbr)
                .font(teamFont)
            Text("-")
                .font(scoreFont.monospacedDigit())
            Text(score.home.abbr)
                .font(teamFont)
        }
        .minimumScaleFactor(0.7)
        .lineLimit(1)
    }

    private func scoreColor(for score: ScoreResponse, side: ScoreLeadingSide) -> Color {
        switch score.leadingSide {
        case .tie:
            return .primary
        case .away:
            return side == .away ? accentColor : .primary
        case .home:
            return side == .home ? accentColor : .primary
        }
    }

    private var scoreFont: Font {
        switch style {
        case .widgetRectangular:
            return .title2.weight(.light)
        case .app:
            return .title3
        }
    }

    private var teamFont: Font {
        switch style {
        case .widgetRectangular:
            return .title2.weight(.ultraLight)
        case .app:
            return .title3
        }
    }

    private var secondaryFont: Font {
        switch style {
        case .widgetRectangular:
            return .caption2
        case .app:
            return .caption
        }
    }

    private var spacing: CGFloat {
        switch style {
        case .widgetRectangular:
            return 0
        case .app:
            return 4
        }
    }

    /// Spacing between team abbr and its score (e.g. E–1, 8–T).
    private var teamScoreSpacing: CGFloat {
        switch style {
        case .widgetRectangular:
            return 8
        case .app:
            return 6
        }
    }

    /// Spacing between score groups and the dash (e.g. E1 – 8T).
    private var groupSpacing: CGFloat {
        switch style {
        case .widgetRectangular:
            return 6
        case .app:
            return 8
        }
    }

    private var horizontalAlignment: HorizontalAlignment {
        return .center
    }

    private var contentAlignment: Alignment {
        return .center
    }
}
