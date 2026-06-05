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
                .font(primaryFont)
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
        HStack(alignment: .firstTextBaseline, spacing: teamSpacing) {
            Text(score.away.abbr)
                .font(teamFont)
            Text("\(score.away.score ?? 0)")
                .font(primaryFont.monospacedDigit())
                .foregroundStyle(scoreColor(for: score, side: .away))
            Text("-")
                .font(primaryFont.monospacedDigit())
            Text("\(score.home.score ?? 0)")
                .font(primaryFont.monospacedDigit())
                .foregroundStyle(scoreColor(for: score, side: .home))
            Text(score.home.abbr)
                .font(teamFont)
        }
        .minimumScaleFactor(0.7)
        .lineLimit(1)
    }

    private func preGameLine(for score: ScoreResponse) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: teamSpacing) {
            Text(score.away.abbr)
                .font(primaryFont.monospacedDigit())
            Text(score.startTime ?? "--:--")
                .font(primaryFont.monospacedDigit())
            Text(score.home.abbr)
                .font(primaryFont.monospacedDigit())
        }
        .minimumScaleFactor(0.7)
        .lineLimit(1)
    }

    private func cancelledLine(for score: ScoreResponse) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: teamSpacing) {
            Text(score.away.abbr)
                .font(primaryFont.monospacedDigit())
            Text("-")
                .font(primaryFont.monospacedDigit())
            Text(score.home.abbr)
                .font(primaryFont.monospacedDigit())
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

    private var primaryFont: Font {
        switch style {
        case .widgetRectangular:
            return .title3.bold()
        case .app:
            return .title2.bold()
        }
    }

    private var teamFont: Font {
        switch style {
        case .widgetRectangular:
            return .caption2
        case .app:
            return .caption
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

    private var teamSpacing: CGFloat {
        switch style {
        case .widgetRectangular:
            return 2
        case .app:
            return 4
        }
    }

    private var horizontalAlignment: HorizontalAlignment {
        switch style {
        case .widgetRectangular:
            return .leading
        case .app:
            return .center
        }
    }

    private var contentAlignment: Alignment {
        switch style {
        case .widgetRectangular:
            return .leading
        case .app:
            return .center
        }
    }
}
