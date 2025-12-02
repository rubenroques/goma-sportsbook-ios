# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## GomaUI Framework Overview

GomaUI is a **reusable UI component library** for iOS sports betting applications, featuring 60+ MVVM-driven components with a comprehensive demo app for testing and showcasing.

### Architecture
- **Framework**: Swift Package at `GomaUI/` with protocol-driven components
- **Demo App**: `GomaUIDemo.xcodeproj` with interactive component gallery
- **Pattern**: MVVM + Combine + Protocol interfaces + Mock implementations
- **Styling**: Centralized StyleProvider for theming

## UIKit Code Organization Reference

**📋 For comprehensive UIKit coding standards, see [UIKIT_CODE_ORGANIZATION_GUIDE.md](UIKIT_CODE_ORGANIZATION_GUIDE.md)**

This guide covers essential UIKit development patterns that all GomaUI components must follow:
- **Lazy property initialization** with static factory methods
- **Programmatic AutoLayout** patterns and constraint management  
- **Code organization** structure (MARK comments, extensions, initialization flow)
- **View Controller** specific patterns and lifecycle management
- **Complete templates** for UIView and UIViewController implementation

The UIKIT guide provides the **foundational coding patterns**, while this CLAUDE.md focuses on **GomaUI-specific architecture** (MVVM, protocols, mocks, etc.)

## Critical Component Development Rules

### 1. Component File Organization

**FUNDAMENTAL RULE: One class/struct/enum/protocol per file - NO EXCEPTIONS**

Every type declaration (class, struct, enum, protocol, actor) MUST have its own dedicated file. This applies to:
- Public types
- Internal types  
- Private helper classes that were previously nested
- Enums used by the component
- Any supporting types

**✅ CORRECT: Each type in its own file**
```
ThemeSwitcherView/
├── ThemeMode.swift                        # Enum (separate file)
├── ThemeSwitcherView.swift               # Main view class only
├── ThemeSegmentView.swift                # Internal helper view (separate file)
├── ThemeSwitcherViewModelProtocol.swift  # Protocol
└── MockThemeSwitcherViewModel.swift      # Mock implementation
```

**❌ WRONG: Multiple types in one file**
```swift
// ThemeSwitcherView.swift - BAD
public enum ThemeMode { }        // ❌ Should be in ThemeMode.swift
public class ThemeSwitcherView { } // ✓ Belongs here
private class ThemeSegmentView { } // ❌ Should be in ThemeSegmentView.swift
```

### 2. File Separation Rules

**Critical guidelines for maintaining clean architecture:**

1. **Every type gets its own file** - No nested classes, no multiple types per file
2. **File name matches type name** - `ThemeMode.swift` contains `enum ThemeMode`
3. **Extract helper classes** - Even private/internal helpers get separate files
4. **Enums are types too** - Put them in their own files
5. **Extensions of external types** - Can stay in the main component file
6. **Private static factory methods** - Stay with their class

When refactoring existing components:
- Extract all secondary types to separate files
- Convert nested classes to standalone files
- Move enums to dedicated files
- Keep only the main class and its extensions in the primary file

### 3. No Direct Table/Collection Cells

**✅ CORRECT: Create wrapper cells for views**
```swift
// The reusable view
public class CasinoGameCardView: UIView {
    // Full implementation as a standalone view
}

// The wrapper cell
final class CasinoGameCardCollectionViewCell: UICollectionViewCell {
    private let gameCardView = CasinoGameCardView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(gameCardView)
        // Setup constraints to contentView
    }
    
    func configure(with viewModel: CasinoGameCardViewModelProtocol) {
        gameCardView.configure(with: viewModel)
    }
}
```

**❌ WRONG: Direct UITableViewCell/UICollectionViewCell components**

All components must be UIView subclasses for maximum reusability. Table/collection cells are created as thin wrappers.

### 4. ReusableView Protocol - Cell Reuse Support

**All GomaUI components must conform to `ReusableView`** and be able to render themselves without a ViewModel (blank/empty state). This ensures no stale data appears during cell recycling.

```swift
public protocol ReusableView {
    func prepareForReuse()
}
```

**Requirements:**

1. **ViewModel must be optional** - component handles `nil` gracefully with empty/blank state
2. **`prepareForReuse()`** clears cancellables, resets callbacks, nils ViewModel, clears visuals, calls child cleanup
3. **`configure(with:)`** sets ViewModel and renders synchronously

```swift
final class SomeView: UIView, ReusableView {
    private var viewModel: SomeViewModelProtocol?  // Optional!
    private var cancellables = Set<AnyCancellable>()

    func prepareForReuse() {
        cancellables.removeAll()
        viewModel = nil
        onCallback = {}
        childView.prepareForReuse()
        renderEmptyState()  // titleLabel.text = nil, imageView.image = nil, etc.
    }

    func configure(with viewModel: SomeViewModelProtocol) {
        self.viewModel = viewModel
        render(state: viewModel.currentDisplayState)  // Sync first
        setupBindings()
    }
}
```

### 5. Synchronous State Access (Reactive Components)

**Problem**: Combine publishers have a micro-delay. UITableView/UICollectionView calculate cell sizes *before* Combine emits, breaking layouts.

**Solution**: Reactive ViewModel protocols must expose both:
- `displayStatePublisher` - for reactive updates
- `currentDisplayState` - for **synchronous immediate access**

ViewModels must use `CurrentValueSubject` (not `PassthroughSubject`) to back the publisher.

```swift
// ViewModel Protocol
protocol XViewModelProtocol {
    var currentDisplayState: XDisplayState { get }
    var displayStatePublisher: AnyPublisher<XDisplayState, Never> { get }
}

// View bindings - use dropFirst() to avoid double-render
private func setupBindings() {
    viewModel?.displayStatePublisher
        .dropFirst()  // Skip initial - already rendered synchronously in configure()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] state in self?.render(state: state) }
        .store(in: &cancellables)
}
```

## Production-Ready Component Standards

**FUNDAMENTAL PRINCIPLE: Components must be 100% production-ready, not scaffolds awaiting "real" implementation.**

Every GomaUI component is a complete, self-sufficient unit that works perfectly with its mock implementation. The protocol-driven architecture means the view should never bypass its protocol interface with callbacks or placeholder code.

### Core Requirements

1. **Full Protocol Utilization**: Every user interaction (taps, swipes, text input) must call protocol methods directly. No callbacks like `var onTap: (() -> Void)?` in views.

2. **No Placeholder Code**: Zero tolerance for `print()` statements, empty methods, TODOs, or "will be implemented later" comments in view code.

3. **Complete Mock Behavior**: Mocks must simulate realistic production behavior including loading states, delays, errors, and state transitions. A mock that just prints or does nothing is unacceptable.

4. **Self-Sufficiency**: The component with its mock must demonstrate full functionality in the demo app. If it "needs production code to work properly," it's incomplete.

### Anti-Patterns to Avoid

- Views with callback properties bypassing the protocol
- Button handlers that just print instead of calling viewModel methods  
- Mocks with empty method implementations
- Comments like "TODO: Connect to real API"
- Any code expecting "production integration" to make it work

### Implementation Checklist

✓ All user interactions route through protocol methods
✓ Mock provides realistic simulated behavior
✓ Component works standalone in demo app
✓ No print statements or debug code in views
✓ No TODO/FIXME comments
✓ All loading/error states handled via protocol

### 4. Preview Requirements

**✅ PREFERRED: Use PreviewUIViewController for better rendering**
```swift
@available(iOS 17.0, *)
#Preview("Component States") {
    PreviewUIViewController {
        let vc = UIViewController()
        let component = YourComponentView(viewModel: MockViewModel.default)
        component.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(component)
        
        NSLayoutConstraint.activate([
            component.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            component.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            component.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor)
        ])
        
        return vc
    }
}
```

**⚠️ Use PreviewUIView only for simple components**

PreviewUIViewController provides better AutoLayout rendering in SwiftUI previews for UIKit components.

## Component Architecture Patterns

### Standard Component Structure

Components follow MVVM architecture with these REQUIRED elements:
- **View**: The UIView implementation (can be multiple files)
- **ViewModelProtocol**: Protocol defining the interface
- **Mock ViewModel**: Test implementation

Simple components might only need 3 files:
```
SimpleButtonView/
├── SimpleButtonView.swift
├── SimpleButtonViewModelProtocol.swift
└── MockSimpleButtonViewModel.swift
```

Complex components will have many more:
```
TallOddsMatchCardView/
├── TallOddsMatchCardView.swift           
├── TallOddsMatchCardHeaderView.swift     
├── TallOddsMatchCardOutcomesView.swift
├── TallOddsMatchCardParticipantView.swift
├── MatchOutcomeType.swift                # Enum in own file
├── MatchCardState.swift                  # Enum in own file
├── TallOddsMatchCardViewModelProtocol.swift
├── MockTallOddsMatchCardViewModel.swift
└── Documentation/
    └── README.md                         # Usage documentation
```

### Composite Components
Components that use other GomaUI components:

```swift
// CasinoCategorySectionView uses:
private let categoryBarView = CasinoCategoryBarView()  // Another GomaUI component
private let collectionView: UICollectionView           // With CasinoGameCardView items
```

Common composite patterns:
- **TallOddsMatchCardView**: Combines MatchHeader + MatchParticipants + MarketOutcomes
- **CasinoCategorySectionView**: Uses CasinoCategoryBarView + CasinoGameCardViews
- **RecentlyPlayedGamesView**: Header pill + horizontal game collection

## Build Commands

**Prerequisites**: Get device ID from existing simulators:
```bash
# Check existing simulators first
xcrun simctl list devices
# Look for iPhone simulators with iOS 18.2+ and copy the device ID

# Only create if no suitable simulator exists:
# xcrun simctl create "iPhone 16 Pro iOS 18.2" "iPhone 16 Pro" "com.apple.CoreSimulator.SimRuntime.iOS-18-2"
```

**Build Commands**:
```bash
# Build demo app (for testing components) - replace YOUR_DEVICE_ID with actual ID
cd /Users/rroques/Desktop/GOMA/iOS/sportsbook-ios
xcodebuild -workspace Sportsbook.xcworkspace -scheme GomaUIDemo -destination 'platform=iOS Simulator,id=YOUR_DEVICE_ID' build 2>&1 | xcbeautify --quieter

# Build framework only (no destination needed)
xcodebuild -workspace Sportsbook.xcworkspace -scheme GomaUI build 2>&1 | xcbeautify --quieter

# Available schemes
# - GomaUIDemo: Demo app with component gallery
# - GomaUI: Framework only
```

## Adding Components to Demo App

### 1. Create Component Files
Follow the multi-file pattern for complex components, single file for simple ones.

### 2. Add to ComponentsTableViewController
```swift
UIComponent(
    title: "Your Component Name",
    description: "Brief description of functionality",
    viewController: YourComponentViewController.self,
    previewFactory: {
        let viewModel = MockYourComponentViewModel.defaultMock
        return YourComponentView(viewModel: viewModel)
    }
)
```

### 3. Create Demo View Controller
```swift
class YourComponentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let component = YourComponentView(viewModel: MockViewModel.interactiveMock)
        // Setup and add to view hierarchy
    }
}
```

## Component Categories

### Core Betting Components
- **OutcomeItemView**: Individual betting outcome
- **MarketOutcomesLineView**: Horizontal outcome group
- **MarketOutcomesMultiLineView**: Multiple outcome lines
- **TallOddsMatchCardView**: Complete match betting card

### Casino Components
- **CasinoGameCardView**: Game thumbnail with info
- **CasinoCategoryBarView**: Section header
- **CasinoCategorySectionView**: Full section with games
- **RecentlyPlayedGamesView**: Horizontal recent games

### Navigation & Layout
- **AdaptiveTabBarView**: Dynamic multi-config tab bar
- **QuickLinksTabBar**: Horizontal quick access
- **MarketGroupSelectorTabView**: Market group tabs
- **CustomNavigationView**: Custom nav bar

### Form & Input
- **BorderedTextFieldView**: Modern text input
- **PinDigitEntryView**: PIN code entry
- **CustomSliderView**: Customizable slider
- **AmountPillsView**: Amount selection pills

## StyleProvider Usage

**MANDATORY: Never hardcode colors or fonts**
```swift
// ✅ CORRECT
backgroundColor = StyleProvider.Color.backgroundColor
label.font = StyleProvider.fontWith(type: .medium, size: 14)

// ❌ WRONG
backgroundColor = .white
label.font = UIFont.systemFont(ofSize: 14)
```

## Testing Workflow

1. **SwiftUI Previews**: Use PreviewUIViewController for development
2. **Demo App Gallery**: Run DemoGomaUI to see all components
3. **Interactive Testing**: Navigate to specific component demos
4. **Mock ViewModels**: Use different mock states for testing

## Key Implementation Rules

1. **File Organization**: One type per file - NO EXCEPTIONS
2. **No Direct Cells**: Always create UIView, wrap in cells when needed
3. **Preview with ViewController**: Use PreviewUIViewController for better layout
4. **Protocol-Driven**: Define ViewModelProtocol for every component
5. **Mock Implementations**: Provide comprehensive mocks with various states
6. **StyleProvider Only**: Never hardcode visual properties
7. **Combine Bindings**: Use publishers for state updates
8. **Documentation**: Include README for complex components
9. **Production-Ready**: Components work fully with mocks, no placeholder code
10. **Protocol-First**: All interactions through protocol, no bypass callbacks

## Common Patterns

### Wrapper Cell Pattern
```swift
// 1. Create the view
class MyCustomView: UIView { /* implementation */ }

// 2. Create wrapper cell when needed
class MyCustomTableViewCell: UITableViewCell {
    private let customView = MyCustomView()
    
    func configure(with viewModel: MyCustomViewModelProtocol) {
        customView.configure(with: viewModel)
    }
}
```

### Multi-File Component Pattern
```swift
// Main view delegates to sub-components
class ComplexComponentView: UIView {
    private lazy var headerSection = ComplexComponentHeaderView()
    private lazy var contentSection = ComplexComponentContentView()
    private lazy var footerSection = ComplexComponentFooterView()
}
```

### Preview Pattern
```swift
@available(iOS 17.0, *)
#Preview("Default State") {
    PreviewUIViewController {
        ComponentDemoViewController.makePreview(
            with: MockViewModel.defaultState
        )
    }
}
```

### High Customization Pattern

For components requiring extensive visual customization (colors, borders, backgrounds) across different states (selected/unselected, enabled/disabled), use the **dual-configuration pattern** demonstrated by **PillItemView** (`Components/PillItemView/`). This pattern separates style definitions into individual state configurations wrapped in a parent customization struct, enabling complete control over appearance while maintaining clean initialization:

```swift
// PillItemStyle.swift - Individual state configuration
public struct PillItemStyle: Equatable {
    public let textColor: UIColor
    public let backgroundColor: UIColor
    public let borderColor: UIColor
    public let borderWidth: CGFloat
}

// PillItemCustomization.swift - Container for state-specific styles
public struct PillItemCustomization: Equatable {
    public let selectedStyle: PillItemStyle
    public let unselectedStyle: PillItemStyle
}
```

This pattern allows consumers to configure everything at initialization while keeping the component's interface clean. Use this approach when components need more than 3-4 customizable visual properties per state.

This framework prioritizes reusability, proper organization, and comprehensive testing through its demo app architecture.