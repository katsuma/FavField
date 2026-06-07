import Foundation

enum WidgetLoadingState {
    static func markLoading() {
        UserDefaults(suiteName: AppConstants.appGroupID)?
            .set(true, forKey: AppConstants.widgetLoadingKey)
    }

    static func consumeLoading() -> Bool {
        guard let defaults = UserDefaults(suiteName: AppConstants.appGroupID) else {
            return false
        }

        let loading = defaults.bool(forKey: AppConstants.widgetLoadingKey)
        if loading {
            defaults.set(false, forKey: AppConstants.widgetLoadingKey)
        }
        return loading
    }
}
