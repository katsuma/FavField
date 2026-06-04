import Foundation

final class TeamPreferences {
    static let shared = TeamPreferences()

    private let defaults: UserDefaults?

    init(defaults: UserDefaults? = UserDefaults(suiteName: AppConstants.appGroupID)) {
        self.defaults = defaults
    }

    var favoriteTeamAbbr: String? {
        get { defaults?.string(forKey: AppConstants.favoriteTeamKey) }
        set {
            if let newValue {
                defaults?.set(newValue, forKey: AppConstants.favoriteTeamKey)
            } else {
                defaults?.removeObject(forKey: AppConstants.favoriteTeamKey)
            }
        }
    }
}
