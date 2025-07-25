// NOT GENERATED - This file is maintained manually
// ThemeService handles fetching, caching, and providing themes

import UIKit
import Combine

class ThemeService {
    static let shared = ThemeService()

    private let themeKey = "current_theme"
    private let serverURL = "https://your-api.com/themes" // Replace with your actual theme server URL

    // Current theme publisher
    private var themeSubject = CurrentValueSubject<Theme, Never>(Theme.defaultTheme)
    var themePublisher: AnyPublisher<Theme, Never> {
        return self.themeSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var currentTheme: Theme {
        return self.themeSubject.value
    }
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Load cached theme on init
        if let cachedTheme = loadCachedTheme() {
            self.themeSubject.send(cachedTheme)
        }
    }

    func fetchThemeFromServer() {
        
        //TODO: The CMS does not suppport yet the themes
        return
        
        //
        guard let url = URL(string: self.serverURL) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Theme.self, decoder: JSONDecoder())
            .replaceError(with: Theme.defaultTheme)
            .receive(on: RunLoop.main)
            .sink { [weak self] theme in
                guard let self = self else { return }
                
                // Cache the theme
                self.cacheTheme(theme)
                
                // Update current theme
                self.themeSubject.send(theme)
                
                // Post notification for views that don't use Combine
                NotificationCenter.default.post(name: .themeDidChange, object: nil)
                
                // Force UI update across the app
                UIApplication.shared.windows.forEach { window in
                    window.subviews.forEach { $0.setNeedsDisplay() }
                }
            }
            .store(in: &self.cancellables)
    }

    private func cacheTheme(_ theme: Theme) {
        if let encoded = try? JSONEncoder().encode(theme) {
            UserDefaults.standard.set(encoded, forKey: self.themeKey)
        }
    }

    private func loadCachedTheme() -> Theme? {
        guard let data = UserDefaults.standard.data(forKey: self.themeKey) else {
            return nil
        }

        return try? JSONDecoder().decode(Theme.self, from: data)
    }
} 
