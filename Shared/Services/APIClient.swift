import Foundation

enum APIError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response."
        case .httpStatus(let code):
            return "Server returned HTTP \(code)."
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    private let baseURL: URL
    private let session: URLSession

    init(
        baseURL: URL = AppConstants.apiBaseURL,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    func fetchTeams() async throws -> [Team] {
        let url = baseURL.appending(path: "teams")
        let (data, response) = try await session.data(from: url)
        try validate(response: response)
        return try JSONDecoder().decode(TeamsResponse.self, from: data).teams
    }

    func fetchScore(teamAbbr: String) async throws -> ScoreResponse {
        var components = URLComponents(url: baseURL.appending(path: "score"), resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "team", value: teamAbbr)]
        guard let url = components?.url else {
            throw APIError.invalidResponse
        }

        let (data, response) = try await session.data(from: url)
        try validate(response: response)
        return try JSONDecoder().decode(ScoreResponse.self, from: data)
    }

    private func validate(response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200 ... 299).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }
    }
}
