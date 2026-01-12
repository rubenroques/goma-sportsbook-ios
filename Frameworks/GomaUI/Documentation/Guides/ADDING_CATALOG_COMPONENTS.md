# Adding Components to the Gallery

This guide explains how to add your new GomaUI components to the `ComponentsTableViewController` gallery for easy discovery and testing.

## Overview

The `ComponentsTableViewController` serves as a **component gallery** that showcases all available GomaUI components with live previews. When you create a new component, you should add it to this gallery so other developers can discover and test it.

## Prerequisites

Before adding to the gallery, ensure your component follows the GomaUI architecture:

- ✅ **4-File Structure**: Protocol, Mock, View, Documentation
- ✅ **MVVM Pattern**: Protocol-based ViewModel with Combine publishers
- ✅ **Mock Data**: Factory methods for easy testing
- ✅ **TestCase Demo**: Individual demo view controller

## Step-by-Step Guide

### 1. Create Your Component Demo Controller

First, create a dedicated demo controller in the `TestCase` directory:

```swift
// TestCase/YourComponentViewController.swift
import UIKit
import Combine
import GomaUI

class YourComponentViewController: UIViewController {
    // Demo implementation showing all component states
    // Interactive controls and examples
    // Real-time state changes
}
```

### 2. Add to ComponentsTableViewController

Open `TestCase/ComponentsTableViewController.swift` and add your component to the `components` array:

```swift
private let components: [UIComponent] = [
    // ... existing components ...

    UIComponent(
        title: "Your Component Name",
        description: "Brief description of what your component does and its main features",
        viewController: YourComponentViewController.self,
        previewFactory: {
            let viewModel = MockYourComponentViewModel.defaultExample
            return YourComponentView(viewModel: viewModel)
        }
    )
]
```

### 3. Preview Factory Guidelines

The `previewFactory` creates a live instance of your component for the gallery preview:

#### ✅ **Good Preview Examples**

```swift
// Simple component with default state
previewFactory: {
    let viewModel = MockBorderedTextFieldViewModel.emailField
    return BorderedTextFieldView(viewModel: viewModel)
}

// Multiple components in a container
previewFactory: {
    let containerView = UIView()
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 8

    let component1 = YourComponentView(viewModel: MockViewModel.example1)
    let component2 = YourComponentView(viewModel: MockViewModel.example2)

    stackView.addArrangedSubview(component1)
    stackView.addArrangedSubview(component2)

    containerView.addSubview(stackView)
    // Add constraints...

    return containerView
}

// Component with specific state for preview
previewFactory: {
    let viewModel = MockTabSelectorViewModel.standardSportsMarkets
    return TabSelectorView(viewModel: viewModel)
}
```

#### ❌ **Avoid These Patterns**

```swift
// Don't create complex or resource-heavy previews
previewFactory: {
    // Avoid network calls, timers, or heavy computations
    // Don't create overly complex layouts
    // Keep it simple and representative
}
```

## Preview Best Practices

### **Size Considerations**
- Preview height is **80pt** - design accordingly
- Horizontal space is available but keep it reasonable
- Components should look good at preview size

### **State Selection**
- Choose the most **representative state** for previews
- Prefer **visually interesting** over empty states
- Use **selected/active states** when they show the component better
- Avoid error states unless that's the primary feature

### **Performance**
- Use **lightweight mock data**
- Avoid **animations** in preview factories
- Keep **memory usage** minimal
- **Simple configurations** only

## Component Types & Examples

### **Single Component Preview**
```swift
previewFactory: {
    let viewModel = MockWalletWidgetViewModel.defaultMock
    return WalletWidgetView(viewModel: viewModel)
}
```

### **Multiple Component States**
```swift
previewFactory: {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 8

    let selectedPill = PillItemView(viewModel: MockPillItemViewModel.selectedExample)
    let normalPill = PillItemView(viewModel: MockPillItemViewModel.normalExample)

    stackView.addArrangedSubview(selectedPill)
    stackView.addArrangedSubview(normalPill)

    return stackView
}
```

### **Container Component**
```swift
previewFactory: {
    let viewModel = MockMarketGroupSelectorTabViewModel.standardSportsMarkets
    return MarketGroupSelectorTabView(viewModel: viewModel)
}
```

## Testing Your Addition

After adding your component:

1. **Build and run** the TestCase app
2. **Check the gallery** - your component should appear in the list
3. **Verify the preview** - ensure it displays correctly
4. **Test navigation** - tap should open your demo controller
5. **Test on different devices** - preview should work on various screen sizes

## Troubleshooting

### **Preview Not Showing**
- Check that your `MockViewModel` factory method exists
- Verify the component initializes without errors
- Ensure no required dependencies are missing

### **Preview Too Large/Small**
- Remember the preview container is 80pt tall
- Adjust your component's intrinsic content size
- Consider using a container view for better control

### **Navigation Not Working**
- Verify your `YourComponentViewController` class name matches
- Check that the view controller is accessible from the TestCase target
- Ensure proper import statements

## Example: Complete Addition

Here's a complete example of adding a new component:

```swift
UIComponent(
    title: "Rating Stars",
    description: "Interactive star rating component with half-star support and custom styling",
    viewController: RatingStarsViewController.self,
    previewFactory: {
        let viewModel = MockRatingStarsViewModel.fourAndHalfStars
        return RatingStarsView(viewModel: viewModel)
    }
)
```

## Don't Forget: Catalog Metadata

After adding your component to the gallery, you must also update the catalog metadata for web documentation:

1. Open `Documentation/Catalog/catalog-metadata.json`
2. Add an entry for your component with appropriate fields
3. Validate JSON: `node -e "require('./Frameworks/GomaUI/Documentation/Catalog/catalog-metadata.json'); console.log('Valid')"`

See [CONTRIBUTING.md](../../CONTRIBUTING.md#metadata-registration) for metadata field guidelines.

## Questions?

If you encounter issues or have questions:

1. **Check existing components** in the gallery for patterns
2. **Review the GomaUI documentation** for component creation guidelines
3. **Look at similar components** for implementation examples
4. **Test in the demo app** to verify functionality

---

**Remember**: The gallery is the first impression developers get of your component. Make it count!


