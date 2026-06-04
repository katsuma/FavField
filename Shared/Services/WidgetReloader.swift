import WidgetKit

enum WidgetReloader {
    static func reloadScoreWidget() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
