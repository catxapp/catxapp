import Foundation

@MainActor
@Observable
final class SettingsStore {
    var marginPercent: Double {
        didSet { UserDefaults.standard.set(marginPercent, forKey: Keys.marginPercent) }
    }

    private enum Keys {
        static let marginPercent = "settings.marginPercent"
    }

    init() {
        marginPercent = UserDefaults.standard.object(forKey: Keys.marginPercent) as? Double ?? 0
    }
}
