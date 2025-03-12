# Dynamic Theming with Native Dark/Light Mode Support

## Overview

This document outlines the implementation of a dynamic theming system that:

1. Fetches theme colors from a server
2. Supports native iOS light/dark mode
3. Allows app owners to update themes without app releases
4. Maintains backward compatibility with existing code

## Implementation Components

### 1. Theme Models

Create these model structures to represent themes fetched from the server:

```swift
struct Theme: Codable {
    let id: String
    let name: String
    let lightColors: ThemeColors
    let darkColors: ThemeColors

    static let defaultTheme = Theme(
        id: "default",
        name: "Default Theme",
        lightColors: ThemeColors(
            primary: "#FF5733",
            secondary: "#33FF57",
            background: "#FFFFFF",
            text: "#000000"
            // Add all your color properties here
        ),
        darkColors: ThemeColors(
            primary: "#FF8866",
            secondary: "#66FF88",
            background: "#121212",
            text: "#FFFFFF"
            // Add all your color properties here
        )
    )
}

struct ThemeColors: Codable {
    let primary: String
    let secondary: String
    let background: String
    let text: String
    // Add all your color properties here

    func color(from hex: String) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
```

### 2. Theme Service

Create a service to fetch, cache, and provide themes:

```swift
class ThemeService {
    static let shared = ThemeService()

    private let themeKey = "current_theme"
    private let serverURL = "https://your-api.com/themes"

    // Current theme publisher
    private var themeSubject = CurrentValueSubject<Theme, Never>(Theme.defaultTheme)
    var themePublisher: AnyPublisher<Theme, Never> {
        return themeSubject.eraseToAnyPublisher()
    }

    var currentTheme: Theme {
        return themeSubject.value
    }

    init() {
        // Load cached theme on init
        if let cachedTheme = loadCachedTheme() {
            themeSubject.send(cachedTheme)
        }
    }

    func fetchThemeFromServer() async {
        do {
            guard let url = URL(string: serverURL) else { return }

            let (data, _) = try await URLSession.shared.data(from: url)
            let theme = try JSONDecoder().decode(Theme.self, from: data)

            // Cache the theme
            cacheTheme(theme)

            // Update current theme
            DispatchQueue.main.async {
                self.themeSubject.send(theme)
                // Post notification for views that don't use Combine
                NotificationCenter.default.post(name: .themeDidChange, object: nil)

                // Force UI update across the app
                UIApplication.shared.windows.forEach { window in
                    window.subviews.forEach { $0.setNeedsDisplay() }
                }
            }
        } catch {
            print("Error fetching theme: \(error)")
        }
    }

    private func cacheTheme(_ theme: Theme) {
        if let encoded = try? JSONEncoder().encode(theme) {
            UserDefaults.standard.set(encoded, forKey: themeKey)
        }
    }

    private func loadCachedTheme() -> Theme? {
        guard let data = UserDefaults.standard.data(forKey: themeKey) else {
            return nil
        }

        return try? JSONDecoder().decode(Theme.self, from: data)
    }
}

// Notification for theme changes
extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}
```

### 3. Dynamic UIColor Extension

Replace your existing `UIColor.App` implementation with this dynamic version:

```swift
extension UIColor {
    struct App {
        static var primary: UIColor {
            return UIColor { (traitCollection) -> UIColor in
                let theme = ThemeService.shared.currentTheme
                let hexColor = traitCollection.userInterfaceStyle == .dark ?
                    theme.darkColors.primary :
                    theme.lightColors.primary
                return theme.lightColors.color(from: hexColor)
            }
        }

        static var secondary: UIColor {
            return UIColor { (traitCollection) -> UIColor in
                let theme = ThemeService.shared.currentTheme
                let hexColor = traitCollection.userInterfaceStyle == .dark ?
                    theme.darkColors.secondary :
                    theme.lightColors.secondary
                return theme.lightColors.color(from: hexColor)
            }
        }

        static var background: UIColor {
            return UIColor { (traitCollection) -> UIColor in
                let theme = ThemeService.shared.currentTheme
                let hexColor = traitCollection.userInterfaceStyle == .dark ?
                    theme.darkColors.background :
                    theme.lightColors.background
                return theme.lightColors.color(from: hexColor)
            }
        }

        static var text: UIColor {
            return UIColor { (traitCollection) -> UIColor in
                let theme = ThemeService.shared.currentTheme
                let hexColor = traitCollection.userInterfaceStyle == .dark ?
                    theme.darkColors.text :
                    theme.lightColors.text
                return theme.lightColors.color(from: hexColor)
            }
        }

        // Add all your other color properties here following the same pattern
    }
}
```

## Integration Guide

### Step 1: Initialize Theme Service

In your `AppDelegate` or `SceneDelegate`:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Fetch theme on app launch
    Task {
        await ThemeService.shared.fetchThemeFromServer()
    }

    return true
}
```

### Step 2: Use Colors in Your Views

No changes needed if you're already using `UIColor.App` colors:

```swift
// This will automatically work with both dynamic theming and dark/light mode
titleLabel.textColor = UIColor.App.text
actionButton.backgroundColor = UIColor.App.primary
```

### Step 3: Handle Theme Updates (Optional)

For views that need to know when the theme changes from the server:

```swift
class MyViewController: UIViewController {
    private var themeSubscription: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Subscribe to theme changes
        themeSubscription = ThemeService.shared.themePublisher
            .sink { [weak self] _ in
                // Refresh your view when theme changes
                self?.view.setNeedsLayout()
                self?.view.setNeedsDisplay()
            }
    }
}
```

For UIKit components that don't use Combine:

```swift
class CustomView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()

        // Register for theme change notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: .themeDidChange,
            object: nil
        )
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()

        // Register for theme change notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: .themeDidChange,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func themeDidChange() {
        setNeedsDisplay()
    }
}
```

## Server API Requirements

The server should provide a JSON response with this structure:

```json
{
  "id": "theme_1",
  "name": "Corporate Theme",
  "lightColors": {
    "primary": "#0066CC",
    "secondary": "#FF9900",
    "background": "#FFFFFF",
    "text": "#333333"
    // All other colors
  },
  "darkColors": {
    "primary": "#4488EE",
    "secondary": "#FFBB33",
    "background": "#121212",
    "text": "#EEEEEE"
    // All other colors
  }
}
```

## Benefits

1. **Seamless Dark Mode Support**: Colors automatically adapt to system dark/light mode
2. **Remote Configuration**: Theme colors can be updated without app releases
3. **No Code Changes Required**: Existing code using `UIColor.App` will work automatically
4. **Offline Support**: Themes are cached for offline use
5. **Real-time Updates**: UI refreshes immediately when theme changes

## Best Practices

1. **Define All Colors**: Make sure all colors used in the app are defined in the theme
2. **Use Semantic Color Names**: Name colors by their purpose (e.g., `primary`, `error`) not their appearance
3. **Test Both Modes**: Always test your app in both light and dark mode
4. **Provide Fallbacks**: Include default theme values in case the server is unreachable
5. **Consider Accessibility**: Ensure color contrast meets accessibility standards in both modes

## Troubleshooting

- **Colors Not Updating**: Make sure you're using `UIColor.App` colors, not hardcoded values
- **Theme Not Loading**: Check network connectivity and server response format
- **Dark Mode Not Working**: Verify your Info.plist has the proper dark mode support settings

## Future Enhancements

1. **Theme Versioning**: Add version control to themes to only update when necessary
2. **User Theme Selection**: Allow users to choose between multiple themes
3. **Transition Animations**: Add animations when switching between themes
4. **Component-Specific Theming**: Allow different components to use different themes
5. **A/B Testing**: Test different themes with different user segments

---

By implementing this system, we maintain a clean, consistent theming approach while gaining the flexibility of server-controlled themes and native iOS dark mode support.