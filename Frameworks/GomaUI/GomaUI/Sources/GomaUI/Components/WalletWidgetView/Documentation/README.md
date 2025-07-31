# WalletWidgetView

A UI component that displays a wallet balance and a deposit button in a horizontally aligned view.

## Features

- Displays a wallet balance with a drop-down indicator
- Includes a "DEPOSIT" button for quick access to deposit funds
- Uses StyleProvider for consistent styling
- Follows MVVM architecture pattern

## Usage Example

```swift
// Create a view model (or use a mock for testing)
let walletData = WalletWidgetData(
    id: "user_wallet",
    balance: "2,550.75", 
    depositButtonTitle: "DEPOSIT"
)
let viewModel = MockWalletWidgetViewModel(walletData: walletData)

// Create the component
let walletWidget = WalletWidgetView(viewModel: viewModel)

// Add to your view hierarchy
parentView.addSubview(walletWidget)

// Set up constraints
NSLayoutConstraint.activate([
    walletWidget.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 16),
    walletWidget.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -16),
    walletWidget.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 8),
    walletWidget.heightAnchor.constraint(equalToConstant: 32)
])

// Handle deposit button taps
walletWidget.onDeposit = { widgetId in
    print("Deposit button tapped for: \(widgetId)")
    // Perform navigation or other actions
}
```

## Customization

The component uses the StyleProvider to access appropriate colors and fonts:

- `StyleProvider.Color.walletBackgroundColor` - Background color for the balance section
- `StyleProvider.Color.contrastTextColor` - Text color for the balance and deposit button
- `StyleProvider.Color.toolbarBackgroundColor` - Text color for the deposit button

## Integration with MultiWidgetToolbarView

The WalletWidgetView is designed to be used as a widget within the MultiWidgetToolbarView component:

```swift
private func createWalletWidget(_ widget: Widget) -> UIView {
    let walletData = WalletWidgetData(
        id: widget.id,
        balance: "2,000.00",
        depositButtonTitle: "DEPOSIT"
    )
    
    let viewModel = MockWalletWidgetViewModel(walletData: walletData)
    let walletView = WalletWidgetView(viewModel: viewModel)
    
    walletView.onDeposit = { [weak self] widgetID in
        self?.viewModel.selectWidget(id: widgetID)
        self?.onWidgetSelected(widgetID)
    }
    
    return walletView
}
``` 