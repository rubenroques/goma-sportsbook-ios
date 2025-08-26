# LanguageSelectorView

A single-selection language picker component with radio buttons, flag icons, and reactive updates.

## Overview

LanguageSelectorView is a complete language selection solution that provides a clean, iOS-native interface for users to choose their preferred language. The component features radio button selection logic, flag icon support, and follows iOS accessibility guidelines.

## Features

- **Single Selection**: Only one language can be selected at a time
- **Radio Button Interface**: Clean radio buttons with orange highlight for selected state
- **Flag Support**: Emoji flags or custom assets for visual language identification
- **Reactive Updates**: Real-time selection updates using Combine publishers
- **Accessibility**: Full VoiceOver support with proper labels and hints
- **Customizable**: Supports custom language lists and initial selections
- **MVVM Architecture**: Protocol-driven with comprehensive mock implementations

## Components Structure

The LanguageSelectorView consists of two main components:

- **LanguageSelectorView**: Main container managing the list of language options
- **LanguageItemView**: Individual language row with flag, name, and radio button (internal)

## Usage

### Basic Usage

```swift
import GomaUI

// Create with default languages
let viewModel = MockLanguageSelectorViewModel.defaultMock
let languageSelector = LanguageSelectorView(viewModel: viewModel)

// Add to view hierarchy
view.addSubview(languageSelector)
```

### Custom Language List

```swift
// Define custom languages
let customLanguages = [
    LanguageModel(id: "en", name: "English", flagIcon: "🇺🇸", isSelected: true),
    LanguageModel(id: "fr", name: "Français", flagIcon: "🇫🇷", isSelected: false)
]

// Create with custom callback
let viewModel = MockLanguageSelectorViewModel.customCallbackMock(
    languages: customLanguages,
    initialSelection: customLanguages[0]
) { selectedLanguage in
    print("Language selected: \(selectedLanguage.displayName)")
    // Handle language change in your app
}

let languageSelector = LanguageSelectorView(viewModel: viewModel)
```

### Production Implementation

```swift
class AppLanguageSelectorViewModel: LanguageSelectorViewModelProtocol {
    @Published private var languages: [LanguageModel] = []
    @Published private var selectedLanguage: LanguageModel?
    private let languageChangedSubject = PassthroughSubject<LanguageModel, Never>()
    
    var languagesPublisher: AnyPublisher<[LanguageModel], Never> {
        $languages.eraseToAnyPublisher()
    }
    
    var selectedLanguagePublisher: AnyPublisher<LanguageModel?, Never> {
        $selectedLanguage.eraseToAnyPublisher()
    }
    
    var languageChangedPublisher: AnyPublisher<LanguageModel, Never> {
        languageChangedSubject.eraseToAnyPublisher()
    }
    
    func selectLanguage(_ language: LanguageModel) {
        // Update app language settings
        UserDefaults.standard.set(language.languageCode, forKey: "app_language")
        
        // Update internal state
        updateLanguageSelection(language)
        
        // Notify about change
        languageChangedSubject.send(language)
        
        // Trigger app language change
        applyLanguageChange(language)
    }
    
    func loadLanguages() {
        // Load supported languages from app configuration
        languages = AppConfiguration.supportedLanguages
    }
    
    // ... other protocol methods
}
```

## Data Models

### LanguageModel

The core data model representing a selectable language option:

```swift
struct LanguageModel: Identifiable, Equatable, Codable {
    let id: String              // Language identifier (e.g., "en", "fr")
    let name: String            // Native language name (e.g., "English", "Français")
    let flagIcon: String        // Flag emoji or asset name
    let isSelected: Bool        // Current selection state
    let languageCode: String?   // Full language code (e.g., "en-US")
    let englishName: String?    // English name for fallback
}
```

### Predefined Languages

Common languages are available as static properties:

```swift
// Available predefined languages
LanguageModel.english       // 🇺🇸 English
LanguageModel.french        // 🇫🇷 Français  
LanguageModel.spanish       // 🇪🇸 Español
LanguageModel.german        // 🇩🇪 Deutsch
LanguageModel.italian       // 🇮🇹 Italiano
LanguageModel.portuguese    // 🇵🇹 Português

// Use predefined collection
LanguageModel.commonLanguages // Array of all above languages
```

## Visual Specifications

### Container
- **Background**: `StyleProvider.Color.backgroundPrimary` (#e7e7e7)
- **Corner Radius**: 16px for container
- **Padding**: 8px around content

### Language Items
- **Background**: `StyleProvider.Color.backgroundTertiary` (#ffffff)
- **Height**: 56px per item
- **Padding**: 16px horizontal
- **Separator**: 1px line using `StyleProvider.Color.separatorLine` (#d8d8d8)
- **Corner Radius**: 8px for top/bottom items

### Radio Buttons
- **Size**: 20x20px
- **Border Width**: 2px
- **Selected State**:
  - Background: `StyleProvider.Color.highlightPrimary` (#ff6600)
  - Inner Dot: 12px white circle
- **Unselected State**:
  - Border: `StyleProvider.Color.iconSecondary` (#21222e)
  - Background: Transparent

### Typography
- **Language Name**: Open Sans Regular 14px
- **Color**: `StyleProvider.Color.textPrimary` (#252634)

### Flags
- **Size**: 24x24px container
- **Support**: Emoji flags or custom image assets
- **Fallback**: First 2 letters of language name

## Interaction Behavior

### Selection Logic
1. User taps any part of a language row
2. Previous selection is automatically deselected
3. New language becomes selected with visual feedback
4. `languageChangedPublisher` emits the new selection
5. Callback function is triggered (if provided)

### Visual Feedback
- **Tap Animation**: Subtle scale down/up animation (98% scale)
- **Radio Button**: Immediate visual state change
- **Selection Indicator**: Orange fill with white inner dot

### Accessibility
- **VoiceOver Labels**: "{Language} language option, {selected/not selected}"
- **Hints**: "Tap to select this language"
- **Traits**: Button trait for each selectable item
- **Dynamic Updates**: Selection state announced when changed

## Mock ViewModels

### Available Mocks

```swift
// Default configuration with 4 common languages, English selected
MockLanguageSelectorViewModel.defaultMock

// Two languages only (matches Figma design)
MockLanguageSelectorViewModel.twoLanguagesMock  

// Many languages for testing scrolling
MockLanguageSelectorViewModel.manyLanguagesMock

// French initially selected
MockLanguageSelectorViewModel.frenchSelectedMock

// Interactive demo with comprehensive feedback
MockLanguageSelectorViewModel.interactiveMock

// Custom configuration
MockLanguageSelectorViewModel.customCallbackMock(
    languages: customLanguages,
    initialSelection: selectedLanguage,
    onLanguageSelected: { language in
        // Handle selection
    }
)
```

### Testing Configurations

```swift
// Empty state testing
MockLanguageSelectorViewModel.emptyMock

// Single language testing  
MockLanguageSelectorViewModel.singleLanguageMock
```

## Integration Examples

### SwiftUI Integration

```swift
struct LanguageSettingsView: View {
    @StateObject private var viewModel = AppLanguageSelectorViewModel()
    
    var body: some View {
        VStack {
            Text("Choose Language")
                .font(.title2)
                .padding()
            
            PreviewUIView {
                LanguageSelectorView(viewModel: viewModel)
            }
            .padding()
        }
    }
}
```

### UIViewController Integration

```swift
class LanguageSettingsViewController: UIViewController {
    private let languageSelector: LanguageSelectorView
    private let viewModel: AppLanguageSelectorViewModel
    
    init() {
        self.viewModel = AppLanguageSelectorViewModel()
        self.languageSelector = LanguageSelectorView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLanguageSelector()
        bindToLanguageChanges()
    }
    
    private func bindToLanguageChanges() {
        viewModel.languageChangedPublisher
            .sink { [weak self] newLanguage in
                self?.handleLanguageChange(newLanguage)
            }
            .store(in: &cancellables)
    }
}
```

## Styling Customization

All visual properties use StyleProvider for consistent theming:

```swift
// Container colors
StyleProvider.Color.backgroundPrimary    // Container background
StyleProvider.Color.backgroundTertiary   // Item background  

// Text and borders
StyleProvider.Color.textPrimary         // Language names
StyleProvider.Color.separatorLine       // Item separators
StyleProvider.Color.iconSecondary       // Radio button borders

// Highlights
StyleProvider.Color.highlightPrimary    // Selected radio button
```

## Best Practices

### Implementation Guidelines

1. **Always use ViewModels**: Never create views directly, use protocol-based approach
2. **Handle selection callbacks**: Implement proper language change handling in your app
3. **Provide feedback**: Use the `languageChangedPublisher` to notify users of changes
4. **Test all states**: Use different mock configurations to test various scenarios
5. **Consider accessibility**: Test with VoiceOver enabled
6. **Flag consistency**: Use consistent flag representation (all emoji or all assets)

### Performance Considerations

1. **Lazy loading**: Languages are loaded on-demand when `loadLanguages()` is called
2. **Efficient updates**: Only changed items are updated during selection changes
3. **Memory management**: Combine subscriptions are properly managed with cancellables
4. **Reusable cells**: Internal item views are reused efficiently

### Common Integration Patterns

```swift
// Pattern 1: Settings Screen
class LanguageSettingsViewController {
    // Show as full-screen selection
    private func presentLanguageSelector() {
        let selector = LanguageSelectorView(viewModel: viewModel)
        // Add to view hierarchy
    }
}

// Pattern 2: Modal Selection
func showLanguageSelectionModal() {
    let modal = UIViewController()
    let selector = LanguageSelectorView(viewModel: viewModel)
    modal.view.addSubview(selector)
    present(modal, animated: true)
}

// Pattern 3: Profile Menu Integration
// Use with ProfileMenuListView for navigation to language selection
```

## Requirements

- **iOS**: 13.0+
- **Frameworks**: UIKit, Combine
- **Dependencies**: GomaUI StyleProvider
- **Accessibility**: iOS VoiceOver support

## File Structure

```
LanguageSelectorView/
├── LanguageSelectorView.swift              # Main container component
├── LanguageItemView.swift                  # Individual language row  
├── LanguageModel.swift                     # Data model and predefined languages
├── LanguageSelectorViewModelProtocol.swift # Protocol definition
├── MockLanguageSelectorViewModel.swift     # Mock implementation
└── README.md                              # This documentation
```

## Demo Integration

The component is fully integrated into GomaUIDemo with:
- **Interactive Demo**: Switch between different language configurations
- **Real-time Selection**: See immediate feedback on language selection
- **Action Logging**: Track all language selection events
- **Multiple Scenarios**: Test two languages, default set, and many languages

Access through: *GomaUIDemo → Language Selector*

---

*This component provides a complete solution for language selection in iOS apps, following iOS design guidelines and accessibility standards while maintaining consistency with the GomaUI component library.*