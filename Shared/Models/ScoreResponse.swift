import Foundation

struct ScoreResponse: Codable, Equatable {
    let status: String
    let away: TeamScore
    let home: TeamScore
    let inning: Int?
    let half: String?
    let startTime: String?
    let display: String
    let gameId: String?
    let updatedAt: String

    struct TeamScore: Codable, Equatable {
        let abbr: String
        let name: String
        let score: Int?
    }
}
