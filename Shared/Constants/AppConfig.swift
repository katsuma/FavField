import Foundation

enum AppConfig {
    private static let productionBaseURL = URL(string: "https://fav-field.katsuma.workers.dev")!

    static var apiBaseURL: URL {
        if let env = ProcessInfo.processInfo.environment["FAVFIELD_API_BASE_URL"],
           !env.isEmpty,
           let url = URL(string: env) {
            return url
        }

        if let plist = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String,
           !plist.isEmpty,
           let url = URL(string: plist) {
            return url
        }

        return productionBaseURL
    }

    static var useMock: Bool {
        if let env = ProcessInfo.processInfo.environment["FAVFIELD_USE_MOCK"] {
            return parseBool(env)
        }

        if let plist = Bundle.main.object(forInfoDictionaryKey: "UseMockAPI") {
            return parseBool(plist)
        }

        return false
    }

    static var mockState: String? {
        ProcessInfo.processInfo.environment["FAVFIELD_MOCK_STATE"]
    }

    private static func parseBool(_ value: Any) -> Bool {
        if let bool = value as? Bool {
            return bool
        }

        if let string = value as? String {
            switch string.lowercased() {
            case "1", "true", "yes":
                return true
            default:
                return false
            }
        }

        return false
    }
}
