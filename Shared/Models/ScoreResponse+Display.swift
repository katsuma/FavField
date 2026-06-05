import Foundation

enum ScoreLeadingSide: Equatable {
    case away
    case home
    case tie
}

extension ScoreResponse {
    var statusLabel: String {
        GameStatus.label(for: status)
    }

    var statusLabelJP: String {
        GameStatus.labelJP(for: status)
    }

    var leadingSide: ScoreLeadingSide {
        let awayScore = away.score ?? 0
        let homeScore = home.score ?? 0

        if awayScore > homeScore {
            return .away
        }
        if homeScore > awayScore {
            return .home
        }
        return .tie
    }

    var inningLabel: String? {
        guard status == "live", let inning, let half else {
            return nil
        }
        return "\(inning)\(half)"
    }

    var subtitleLabelJP: String {
        switch status {
        case "live":
            return inningLabel ?? statusLabelJP
        case "final", "pre", "cancelled", "none":
            return statusLabelJP
        default:
            return statusLabelJP
        }
    }

    var inlineText: String {
        switch status {
        case "none":
            return "試合なし"
        case "cancelled":
            return "\(away.abbr)-\(home.abbr) 中止"
        case "pre":
            let time = startTime ?? "--:--"
            return "\(away.abbr)-\(home.abbr) \(time)"
        case "live", "final":
            let awayScore = away.score ?? 0
            let homeScore = home.score ?? 0
            var text = "\(away.abbr) \(awayScore)-\(homeScore) \(home.abbr)"
            if status == "live", let inningLabel {
                text += " \(inningLabel)"
            } else if status == "final" {
                text += " 終了"
            }
            return text
        default:
            return display
        }
    }
}

enum GameStatus {
    static func label(for status: String) -> String {
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

    static func labelJP(for status: String) -> String {
        switch status {
        case "pre":
            return "試合開始前"
        case "live":
            return "Live"
        case "final":
            return "試合終了"
        case "cancelled":
            return "試合中止"
        case "none":
            return "本日の試合はありません"
        default:
            return status
        }
    }
}

enum ScoreRefreshInterval {
    static func minutes(for status: String) -> Int {
        switch status {
        case "live":
            return 3
        case "pre":
            return 15
        case "final":
            return 30
        case "cancelled":
            return 60
        case "none":
            return 360
        default:
            return 30
        }
    }

    static func nextDate(from date: Date, status: String) -> Date {
        let minutes = minutes(for: status)
        return Calendar.current.date(byAdding: .minute, value: minutes, to: date) ?? date
    }
}

extension ScoreResponse {
    static let previewLive = ScoreResponse(
        status: "live",
        away: TeamScore(abbr: "E", name: "楽天", score: 1),
        home: TeamScore(abbr: "T", name: "阪神", score: 8),
        inning: 7,
        half: "裏",
        startTime: nil,
        display: "E 1-8 T 7裏",
        gameId: "preview-live",
        updatedAt: "2026-06-05T21:00:00Z"
    )

    static let previewFinal = ScoreResponse(
        status: "final",
        away: TeamScore(abbr: "E", name: "楽天", score: 1),
        home: TeamScore(abbr: "T", name: "阪神", score: 8),
        inning: nil,
        half: nil,
        startTime: nil,
        display: "E 1-8 T",
        gameId: "preview-final",
        updatedAt: "2026-06-05T21:00:00Z"
    )

    static let previewPre = ScoreResponse(
        status: "pre",
        away: TeamScore(abbr: "E", name: "楽天", score: nil),
        home: TeamScore(abbr: "T", name: "阪神", score: nil),
        inning: nil,
        half: nil,
        startTime: "14:00",
        display: "E - T 14:00",
        gameId: "preview-pre",
        updatedAt: "2026-06-05T21:00:00Z"
    )

    static let previewNone = ScoreResponse(
        status: "none",
        away: TeamScore(abbr: "E", name: "楽天", score: nil),
        home: TeamScore(abbr: "E", name: "楽天", score: nil),
        inning: nil,
        half: nil,
        startTime: nil,
        display: "E 試合なし",
        gameId: nil,
        updatedAt: "2026-06-05T21:00:00Z"
    )
}
