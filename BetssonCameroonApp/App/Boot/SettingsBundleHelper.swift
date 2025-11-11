
import Foundation

/// Helper class for managing Settings.bundle integration with UserDefaults
final class SettingsBundleHelper {

    /// Registers defaults from Settings.bundle into UserDefaults
    ///
    /// This ensures iOS recognizes that the app has settings, making the app's
    /// settings page appear when using UIApplication.openSettingsURLString.
    /// Must be called on every app launch (values are not persisted by register).
    static func registerDefaultsFromSettingsBundle() {
        guard let settingsBundle = Bundle.main.path(forResource: "Settings", ofType: "bundle"),
              let settings = NSDictionary(contentsOfFile: "\(settingsBundle)/Root.plist"),
              let preferences = settings["PreferenceSpecifiers"] as? [[String: Any]] else {
            print("SettingsBundleHelper: Could not load Settings.bundle")
            return
        }

        var defaultsToRegister = [String: Any]()

        for preference in preferences {
            guard let key = preference["Key"] as? String else {
                // Skip items without keys (groups, child panes, etc.)
                continue
            }

            // Handle different preference types
            // All types (PSTextFieldSpecifier, PSToggleSwitchSpecifier, PSSliderSpecifier,
            // PSMultiValueSpecifier, PSTitleValueSpecifier) use "DefaultValue" key
            if let defaultValue = preference["DefaultValue"] {
                defaultsToRegister[key] = defaultValue
            }
        }

        UserDefaults.standard.register(defaults: defaultsToRegister)
        print("SettingsBundleHelper: Registered \(defaultsToRegister.count) default(s)")
    }

    /// Updates dynamic values in Settings.bundle (like version and build number)
    ///
    /// This updates read-only display fields that should reflect current app state.
    /// For example, the version preference shows the actual app version from Info.plist.
    static func updateSettingsBundleValues() {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            print("SettingsBundleHelper: Could not read version/build from Info.plist")
            return
        }

        let versionString = "\(version)(\(build))"
        UserDefaults.standard.set(versionString, forKey: "version_preference")
        UserDefaults.standard.synchronize()
        print("SettingsBundleHelper: Updated version to \(versionString)")
    }
}
