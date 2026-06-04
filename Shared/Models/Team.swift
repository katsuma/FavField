import Foundation

struct Team: Identifiable, Codable, Hashable {
    let id: Int
    let abbr: String
    let name: String
}

struct TeamsResponse: Codable {
    let teams: [Team]
}
