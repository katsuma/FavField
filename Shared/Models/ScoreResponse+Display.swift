import Foundation

extension ScoreResponse {
    var statusLabel: String {
        GameStatus.label(for: status)
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
