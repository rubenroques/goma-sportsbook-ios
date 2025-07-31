# WalletStatusView

A comprehensive wallet status display component that shows various balance types with deposit and withdraw actions. Designed to work as an overlay dialog in any view controller.

## Features

- **Real-time balance updates** via Combine publishers
- **Multiple balance types**: Total, Current, Bonus, Cashback, Withdrawable
- **Integrated action buttons** using existing ButtonView component
- **Clean visual hierarchy** with separator lines
- **Reactive architecture** for server-side updates
- **Dialog-ready design** with rounded corners and padding

## Usage Example

### Basic Implementation

```swift
// Create view model (or use mock for testing)
let viewModel = MockWalletStatusViewModel.defaultMock

// Create the wallet status view
let walletStatusView = WalletStatusView(viewModel: viewModel)

// Add to your view hierarchy
parentView.addSubview(walletStatusView)

// Set up constraints (typically centered with fixed width)
NSLayoutConstraint.activate([
    walletStatusView.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
    walletStatusView.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
    walletStatusView.widthAnchor.constraint(equalToConstant: 350),
    walletStatusView.heightAnchor.constraint(equalToConstant: 340)
])

// Handle button actions
viewModel.depositButtonViewModel.onButtonTapped = {
    // Navigate to deposit screen
}

viewModel.withdrawButtonViewModel.onButtonTapped = {
    // Navigate to withdrawal screen
}
```

### Dialog/Overlay Usage

```swift
// Create overlay container
let overlayView = UIView()
overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
overlayView.translatesAutoresizingMaskIntoConstraints = false

// Add to window or root view
view.addSubview(overlayView)
NSLayoutConstraint.activate([
    overlayView.topAnchor.constraint(equalTo: view.topAnchor),
    overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
])

// Add wallet status view to overlay
let walletView = WalletStatusView(viewModel: viewModel)
walletView.translatesAutoresizingMaskIntoConstraints = false
overlayView.addSubview(walletView)

NSLayoutConstraint.activate([
    walletView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
    walletView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
    walletView.widthAnchor.constraint(equalToConstant: 350)
])

// Add tap to dismiss
let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissOverlay))
overlayView.addGestureRecognizer(tapGesture)
```

### Simulating Balance Updates

The mock view model provides methods to simulate server updates:

```swift
// Update specific balances
viewModel.simulateBalanceUpdate(
    total: "2,500.00",
    current: "1,200.00"
)

// Simulate deposit completion
viewModel.simulateDepositComplete(amount: 500.0)

// Simulate withdrawal
viewModel.simulateWithdrawalComplete(amount: 100.0)
```

## Production Implementation

In production, your view model would connect to real services:

```swift
class WalletViewModel: WalletStatusViewModelProtocol {
    private let walletService: WalletServiceProtocol
    private let totalBalanceSubject = CurrentValueSubject<String, Never>("0.00")
    // ... other subjects
    
    init(walletService: WalletServiceProtocol) {
        self.walletService = walletService
        
        // Subscribe to wallet updates
        walletService.walletUpdates
            .map { wallet in
                NumberFormatter.currency.string(from: wallet.totalBalance) ?? "0.00"
            }
            .sink { [weak self] formattedBalance in
                self?.totalBalanceSubject.send(formattedBalance)
            }
            .store(in: &cancellables)
    }
    
    // Implement protocol requirements...
}
```

## Customization

### Button Styling

The component uses ButtonView with predefined styles:
- **Deposit**: Solid background (green) - `.solidBackground`
- **Withdraw**: Bordered (orange) - `.bordered`

Button heights are set to 34pt with 12pt font size to match the design.

### Colors

All colors come from StyleProvider:
- Balance amounts: `highlightPrimary` (orange)
- Labels: `textPrimary`
- Separators: `separatorLine`
- Background: `backgroundTertiary` (white)

## Architecture Notes

- **Tier 2 Component**: Interactive with button actions
- **Reactive Design**: Publishers for all dynamic values
- **Reusable Components**: Leverages existing ButtonView and custom WalletBalanceLineView
- **Clean Separation**: View model handles all business logic
- **Modular Design**: Balance lines are handled by dedicated WalletBalanceLineView components

### Component Structure

The WalletStatusView is composed of several reusable sub-components:

#### WalletBalanceLineView
A dedicated component for displaying individual balance lines that provides:
- **Flexible initialization**: With or without icons
- **Clean API**: Direct property access (`titleText`, `valueText`, `icon`)
- **Type safety**: No casting of arranged subviews
- **Reusability**: Can be used in other wallet-related components

```swift
// Create with icon
let totalLine = WalletBalanceLineView(
    title: "Total Balance",
    value: "2,000.00",
    icon: UIImage(named: "banknote_cash_icon", in: Bundle.module, compatibleWith: nil)
)

// Create without icon
let currentLine = WalletBalanceLineView(title: "Current Balance", value: "1,000.00")

// Update dynamically
currentLine.updateValue("1,500.00")
currentLine.titleText = "Updated Balance"
```

#### Benefits of Modular Design
- **Maintainability**: Each balance line is a self-contained component
- **Type Safety**: No risky casting of UI elements
- **Testability**: Individual components can be tested in isolation
- **Consistency**: Uniform styling and behavior across all balance lines

## Testing

### WalletStatusView Testing

Use the provided mock factories for different scenarios:

```swift
// Default state matching Figma
MockWalletStatusViewModel.defaultMock

// Empty wallet
MockWalletStatusViewModel.emptyBalanceMock

// High balances
MockWalletStatusViewModel.highBalanceMock

// Bonus only (no withdrawable)
MockWalletStatusViewModel.bonusOnlyMock
```

### WalletBalanceLineView Testing

The WalletBalanceLineView component includes comprehensive SwiftUI previews for testing:

- **All Balance Line States**: Shows all variations used in the wallet (with/without icons)
- **Balance Line Without Icon**: Simple balance line preview
- **All Balance Line Types**: Collection view showing different balance types
- **Different Value Lengths**: Tests layout with various text lengths

These previews can be accessed in Xcode's preview pane and help validate:
- Layout behavior with long text
- Icon alignment and spacing
- Color theming consistency
- Different value formats

## File Structure

```
WalletStatusView/
├── WalletStatusView.swift              # Main component
├── WalletStatusViewModelProtocol.swift # Protocol definition
├── WalletBalanceLineView.swift         # Reusable balance line component
├── MockWalletStatusViewModel.swift     # Mock implementations
└── Documentation/
    └── README.md                       # This documentation
```