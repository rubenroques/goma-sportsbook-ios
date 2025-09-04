# UITableView Cell Component Pattern for GomaUI

## The Fundamental Principle
**Any view that could potentially be used in a UITableView cell MUST have immediate, synchronous data access.**

## The Problem
UITableView automatic dimension calculation requires synchronous data during cell configuration. Components using Combine publishers with `DispatchQueue.main` create race conditions where:
1. Table view asks for cell height → Cell is empty
2. Publisher fires later → Content loads → Too late for sizing
3. Result: Truncated or incorrectly sized cells

## Configure Method Pattern

### View Implementation
```swift
public class ComponentView: UIView {
    private var viewModel: ComponentViewModel
    private var cancellables = Set<AnyCancellable>()
    
    public init(viewModel: TableViewCompatibleViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        setupView()
        setupConstraints()
        
        // ✅ CRITICAL: Configure immediately with current data
        configure(with: viewModel.currentData)
        
        // Optional: Subscribe to updates separately
        setupUpdateSubscription()
    }
    
    // Public configuration method for cell reuse
    public func configure(with data: ComponentData) {
        // Direct, synchronous UI updates
        updateUI(with: data)
    }
    
    private func setupUpdateSubscription() {
        // Updates are separate from initial configuration
        viewModel.updatesPublisher?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.updateUI(with: data)
            }
            .store(in: &cancellables)
    }
}
```

## Critical Rules

### 1. No Async During Configuration
- ❌ NEVER: Wait for publishers during init or configure
- ❌ NEVER: Use `.receive(on: DispatchQueue.main)` in initial setup
- ✅ ALWAYS: Have data immediately available


### 2. Default State Handling
- Components must handle empty/nil data gracefully
- Define sensible defaults for initial display
- Never assume data will arrive "soon"

### 3. Separate Initial Data from Updates
- Initial configuration: Synchronous, immediate
- Updates: Asynchronous, optional, for real-time changes only
- Don't mix these concerns

## Real-World Example: The TicketBetInfoView Problem

### The Problem Code
```swift
// ❌ BAD: Async data loading in nested components
class TicketBetInfoView {
    func updateTickets(with tickets: [TicketSelectionData]) {
        for ticketData in tickets {
            let viewModel = MockTicketSelectionViewModel.preLiveMock
            viewModel.updateTicketData(ticketData) // Async publisher update!
            let ticketView = TicketSelectionView(viewModel: viewModel)
            // ticketView is empty here - waiting for publisher
        }
    }
}

// TicketSelectionView waited for publisher:
private func bindViewModel() {
    viewModel.ticketDataPublisher // ❌ Async delay!
        .receive(on: DispatchQueue.main)
        .sink { [weak self] ticketData in
            self?.updateUI(with: ticketData) // Too late for sizing!
        }
}
```

### The Solution
```swift
// ✅ GOOD: Immediate data access
protocol TicketSelectionViewModelProtocol {
    var currentTicketData: TicketSelectionData { get }
    var ticketDataPublisher: AnyPublisher<TicketSelectionData, Never> { get }
}

class TicketSelectionView {
    init(viewModel: TicketSelectionViewModelProtocol) {
        // ... setup ...
        updateUI(with: viewModel.currentTicketData) // ✅ Immediate!
        bindToUpdates() // Optional updates
    }
}
```

## Migration Checklist

For existing components:
1. Add `currentData` property to ViewModel protocol
2. Implement immediate data access in ViewModel
3. Update view to use `currentData` during init
4. Move publisher subscription to separate method
5. Remove any `dropFirst()` hacks
6. Test with UITableView automatic dimensions

## Future-Proofing

Even if a component isn't currently used in a table view:
- Design with potential table view usage in mind
- Always provide synchronous configuration option
- Keep async updates optional and separate
- Document whether component is "table-view ready"

## Testing Requirements

1. Component renders correctly on first display
2. No height calculation issues in table view
3. No visual glitches during rapid scrolling
4. Nested components render properly
5. Dynamic updates still work (when applicable)

---

**Remember: In UITableView context, if the data isn't available immediately, it's too late.**
