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

Button heights are set to 30pt to match the design.

### Colors

All colors come from StyleProvider:
- Balance amounts: `highlightPrimary` (orange)
- Labels: `textPrimary`
- Separators: `separatorLine`
- Background: `backgroundTertiary` (white)

## Architecture Notes

- **Tier 2 Component**: Interactive with button actions
- **Reactive Design**: Publishers for all dynamic values
- **Reusable Components**: Leverages existing ButtonView
- **Clean Separation**: View model handles all business logic

## Testing

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