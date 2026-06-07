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
    private static let firstPitchHour = 13

    private static var tokyoCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return calendar
    }

    static func nextDate(from now: Date, status: String, startTime: String?) -> Date {
        switch status {
        case "live":
            return now.addingMinutes(3)
        case "pre":
            return preNextDate(from: now, startTime: startTime)
        case "final", "none", "cancelled":
            return nextLikelyFirstPitch(after: now)
        default:
            return now.addingMinutes(30)
        }
    }

    private static func preNextDate(from now: Date, startTime: String?) -> Date {
        guard let startTime, let start = startDate(from: startTime, now: now) else {
            return now.addingMinutes(Int.random(in: 30...60))
        }
        let mins = Int(start.timeIntervalSince(now) / 60)
        switch mins {
        case ..<0:
            return now.addingMinutes(Int.random(in: 5...10))
        case 0...30:
            return now.addingMinutes(Int.random(in: 10...15))
        default:
            let candidate = now.addingMinutes(Int.random(in: 30...60))
            let arriveTarget = start.addingMinutes(-15)
            return min(candidate, arriveTarget)
        }
    }

    private static func nextLikelyFirstPitch(after now: Date) -> Date {
        let calendar = tokyoCalendar
        let todayFirstPitch = calendar.date(
            bySettingHour: firstPitchHour, minute: 0, second: 0, of: now
        ) ?? now
        if now < todayFirstPitch {
            return todayFirstPitch
        }
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        return calendar.date(
            bySettingHour: firstPitchHour, minute: 0, second: 0, of: tomorrow
        ) ?? now.addingMinutes(360)
    }

    private static func startDate(from startTime: String, now: Date) -> Date? {
        let parts = startTime.split(separator: ":")
        guard parts.count == 2, let hour = Int(parts[0]), let minute = Int(parts[1]) else {
            return nil
        }
        return tokyoCalendar.date(bySettingHour: hour, minute: minute, second: 0, of: now)
    }
}

private extension Date {
    func addingMinutes(_ minutes: Int) -> Date {
        addingTimeInterval(TimeInterval(minutes * 60))
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
