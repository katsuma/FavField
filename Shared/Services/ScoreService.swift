import Foundation

enum ScoreService {
    static var current: ScoreProviding {
        if AppConfig.useMock {
            #if DEBUG
            return MockAPIClient()
            #else
            return APIClient.shared
            #endif
        }
        return APIClient.shared
    }
}
