import Foundation

extension UserDefaults {
    private enum Keys {
        static let isDeveloperModeEnabled = "isDeveloperModeEnabled"
    }
    
    var isDeveloperModeEnabled: Bool {
        get {
            return bool(forKey: Keys.isDeveloperModeEnabled)
        }
        set {
            set(newValue, forKey: Keys.isDeveloperModeEnabled)
        }
    }
}
