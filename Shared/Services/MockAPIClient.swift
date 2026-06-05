import Foundation

#if DEBUG
enum MockTeams {
    static let all: [Team] = [
        Team(id: 1, abbr: "G", name: "巨人"),
        Team(id: 2, abbr: "S", name: "ヤクルト"),
        Team(id: 3, abbr: "DB", name: "DeNA"),
        Team(id: 4, abbr: "D", name: "中日"),
        Team(id: 5, abbr: "T", name: "阪神"),
        Team(id: 6, abbr: "C", name: "広島"),
        Team(id: 7, abbr: "L", name: "西武"),
        Team(id: 8, abbr: "F", name: "日本ハム"),
        Team(id: 9, abbr: "M", name: "ロッテ"),
        Team(id: 11, abbr: "B", name: "オリックス"),
        Team(id: 12, abbr: "H", name: "ソフトバンク"),
        Team(id: 376, abbr: "E", name: "楽天"),
    ]
}

final class MockAPIClient: ScoreProviding {
    private let responseDelayNanoseconds: UInt64 = 300_000_000

    func fetchTeams() async throws -> [Team] {
        try await Task.sleep(nanoseconds: responseDelayNanoseconds)
        return MockTeams.all
    }

    func fetchScore(teamAbbr: String) async throws -> ScoreResponse {
        try await Task.sleep(nanoseconds: responseDelayNanoseconds)
        return mockScore(for: AppConfig.mockState?.lowercased() ?? "live")
    }

    private func mockScore(for state: String) -> ScoreResponse {
        switch state {
        case "final":
            return .previewFinal
        case "pre":
            return .previewPre
        case "none":
            return .previewNone
        default:
            return .previewLive
        }
    }
}
#endif
