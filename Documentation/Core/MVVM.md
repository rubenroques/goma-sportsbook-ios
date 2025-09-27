# MVVM Architecture Guide for iOS Development (UIKit)

## Core Principle
**"Views are dumb, ViewModels are smart, ViewControllers are coordinators"**

## The Golden Rules

### 1. Every Interactive View Gets a ViewModel
```swift
// ✅ DO: Even small views get ViewModels
ProfilePictureView → ProfilePictureViewModel
RatingStarsView → RatingViewModel
CustomSliderView → SliderViewModel

// ❌ DON'T: Share ViewModels between unrelated views
UserProfileView → SharedViewModel ← SettingsView // Wrong!
```

### 2. Communication Flow is Unidirectional
```
View → ViewModel → Parent ViewModel → Root ViewModel
     ←            ←                  ←
```

### 3. ViewModels Never Import UIKit
```swift
// ✅ DO
import Foundation
import Combine

// ❌ DON'T
import UIKit  // Never in ViewModels!
```

### 4. Understand Vertical vs Horizontal Relationships

#### Vertical Pattern (Within Same ViewController)
**✅ ViewModels CAN create child ViewModels for their own subviews**
```swift
// ✅ CORRECT: Parent ViewModel creates children for its view hierarchy
class MusicStudioViewModel {
    // These are subviews within the same screen
    let mixerViewModel = MixerViewModel()
    let trackListViewModel = TrackListViewModel()
    let controlsViewModel = ControlsViewModel()
    
    init() {
        // Set up communication between child ViewModels
        setupBindings()
    }
}
```

#### Horizontal Pattern (Between ViewControllers)
**❌ ViewModels CANNOT create ViewModels for other ViewControllers**
```swift
// ❌ WRONG: Creating ViewModel for another ViewController
class ShoppingCartViewModel {
    func createCheckoutViewModel() -> CheckoutViewModel {
        return CheckoutViewModel()  // This is for CheckoutViewController!
    }
}

// ✅ CORRECT: Let ViewController handle it
class ShoppingCartViewController {
    func presentCheckout() {
        let checkoutVM = CheckoutViewModel()  // VC creates it
        let checkoutVC = CheckoutViewController(viewModel: checkoutVM)
        present(checkoutVC, animated: true)
    }
}
```

## Component Responsibilities

### View (UIView, UITableViewCell, etc.)
- **ONLY** displays data and captures user input
- Updates UI based on ViewModel state
- Forwards user actions to ViewModel

```swift
// ✅ DO: View is passive
class PriceTagView: UIView {
    private var viewModel: PriceTagViewModel?
    
    @IBAction func discountButtonTapped() {
        viewModel?.applyDiscount()  // Just forward the action
    }
    
    func configure(with viewModel: PriceTagViewModel) {
        self.viewModel = viewModel
        priceLabel.text = viewModel.formattedPrice  // Just display
    }
}

// ❌ DON'T: Business logic in View
class PriceTagView: UIView {
    @IBAction func discountButtonTapped() {
        let newPrice = price * 0.8  // Don't calculate here!
        if newPrice < minimumPrice {  // Don't validate here!
            showError()
        }
    }
}
```

### ViewModel
- Contains ALL business logic
- Manages state
- Transforms data for display
- Never references Views or ViewControllers
- Can create child ViewModels for its own view hierarchy

```swift
// ✅ DO: ViewModel handles logic
class PriceTagViewModel: ObservableObject {
    @Published var price: Double = 100.0
    @Published var hasDiscount: Bool = false
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: price)) ?? ""
    }
    
    func applyDiscount() {
        guard !hasDiscount else { return }
        price = price * 0.8
        hasDiscount = true
        analytics.track("discount_applied")
    }
}

// ❌ DON'T: UI references in ViewModel
class PriceTagViewModel {
    weak var view: PriceTagView?  // Never!
    var label: UILabel?  // Never!
}
```

### ViewController
- Creates and owns ViewModels
- Handles navigation
- Binds Views to ViewModels
- Coordinates between child ViewControllers
- Creates ViewModels for other ViewControllers when navigating

```swift
// ✅ DO: ViewController as coordinator
class ProductViewController: UIViewController {
    private let viewModel = ProductViewModel()
    
    override func viewDidLoad() {
        setupBindings()
        setupChildViews()
    }
    
    private func setupChildViews() {
        // Configure views with child ViewModels from the main ViewModel
        priceTagView.configure(with: viewModel.priceTagViewModel)
        reviewsView.configure(with: viewModel.reviewsViewModel)
    }
    
    private func navigateToDetails() {
        // ViewController creates ViewModel for next screen
        let detailsVM = ProductDetailsViewModel(product: viewModel.selectedProduct)
        let detailsVC = ProductDetailsViewController(viewModel: detailsVM)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
```

## Vertical Pattern: Complex View Hierarchies

### Example: Dashboard with Multiple Sections
```swift
// Main ViewModel creates children for its subviews
class DashboardViewModel {
    // Child ViewModels for different sections of the same screen
    let headerViewModel: HeaderViewModel
    let statsViewModel: StatsViewModel
    let activityViewModel: ActivityViewModel
    let footerViewModel: FooterViewModel
    
    init(user: User) {
        // Create child ViewModels with necessary data
        self.headerViewModel = HeaderViewModel(userName: user.name)
        self.statsViewModel = StatsViewModel(userId: user.id)
        self.activityViewModel = ActivityViewModel()
        self.footerViewModel = FooterViewModel()
        
        // Set up inter-communication between children
        setupBindings()
    }
    
    private func setupBindings() {
        // When activity changes, update stats
        activityViewModel.onActivityUpdated = { [weak self] in
            self?.statsViewModel.refresh()
        }
    }
}

// ViewController wires everything up
class DashboardViewController: UIViewController {
    private let viewModel: DashboardViewModel
    
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var statsView: StatsView!
    @IBOutlet weak var activityView: ActivityView!
    @IBOutlet weak var footerView: FooterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure each view with its ViewModel
        headerView.configure(with: viewModel.headerViewModel)
        statsView.configure(with: viewModel.statsViewModel)
        activityView.configure(with: viewModel.activityViewModel)
        footerView.configure(with: viewModel.footerViewModel)
    }
}
```

### Deeply Nested Example: TableView with Complex Cells
```swift
// Cell has multiple interactive subviews
class OrderCellViewModel {
    let orderId: String
    
    // ViewModels for cell's subviews
    let statusBadgeViewModel: StatusBadgeViewModel
    let actionButtonsViewModel: ActionButtonsViewModel
    let priceBreakdownViewModel: PriceBreakdownViewModel
    
    // Callbacks to parent
    var onOrderSelected: (() -> Void)?
    var onActionTaken: ((OrderAction) -> Void)?
    
    init(order: Order) {
        self.orderId = order.id
        
        // Create child ViewModels
        self.statusBadgeViewModel = StatusBadgeViewModel(status: order.status)
        self.actionButtonsViewModel = ActionButtonsViewModel(availableActions: order.availableActions)
        self.priceBreakdownViewModel = PriceBreakdownViewModel(price: order.totalPrice, tax: order.tax)
        
        // Wire up child callbacks
        setupBindings()
    }
    
    private func setupBindings() {
        actionButtonsViewModel.onActionSelected = { [weak self] action in
            self?.onActionTaken?(action)
        }
    }
}
```

## Horizontal Pattern: Navigation Between ViewControllers

### Without Coordinators
```swift
class ProductListViewController: UIViewController {
    private let viewModel = ProductListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ViewModel tells VC when navigation is needed
        viewModel.onProductSelected = { [weak self] product in
            self?.showProductDetails(for: product)
        }
        
        viewModel.onFilterRequested = { [weak self] in
            self?.showFilterOptions()
        }
    }
    
    private func showProductDetails(for product: Product) {
        // ViewController creates ViewModel for next screen
        let detailsViewModel = ProductDetailsViewModel(product: product)
        
        // Set up callback for results
        detailsViewModel.onPurchaseComplete = { [weak self] order in
            self?.viewModel.handlePurchase(order)
        }
        
        let detailsVC = ProductDetailsViewController(viewModel: detailsViewModel)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    private func showFilterOptions() {
        // Create ViewModel for modal
        let filterViewModel = FilterViewModel(currentFilters: viewModel.activeFilters)
        
        // Set up callback
        filterViewModel.onFiltersApplied = { [weak self] filters in
            self?.viewModel.applyFilters(filters)
            self?.dismiss(animated: true)
        }
        
        let filterVC = FilterViewController(viewModel: filterViewModel)
        let navController = UINavigationController(rootViewController: filterVC)
        present(navController, animated: true)
    }
}
```

### With Coordinators
```swift
// Coordinator handles all navigation
class ProductFlowCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let listViewModel = ProductListViewModel()
        let listVC = ProductListViewController(viewModel: listViewModel)
        
        // Coordinator owns navigation callbacks
        listVC.onProductSelected = { [weak self] product in
            self?.showProductDetails(product)
        }
        
        listVC.onFilterRequested = { [weak self] in
            self?.showFilterOptions()
        }
        
        navigationController.pushViewController(listVC, animated: false)
    }
    
    private func showProductDetails(_ product: Product) {
        let detailsViewModel = ProductDetailsViewModel(product: product)
        let detailsVC = ProductDetailsViewController(viewModel: detailsViewModel)
        
        detailsVC.onPurchaseComplete = { [weak self] order in
            self?.handlePurchaseComplete(order)
        }
        
        navigationController.pushViewController(detailsVC, animated: true)
    }
    
    private func showFilterOptions() {
        let filterCoordinator = FilterCoordinator(
            presentingController: navigationController,
            onComplete: { [weak self] filters in
                self?.applyFilters(filters)
            }
        )
        
        childCoordinators.append(filterCoordinator)
        filterCoordinator.start()
    }
}

// ViewControllers become even simpler
class ProductListViewController: UIViewController {
    private let viewModel: ProductListViewModel
    
    // Navigation callbacks owned by Coordinator
    var onProductSelected: ((Product) -> Void)?
    var onFilterRequested: (() -> Void)?
    
    init(viewModel: ProductListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @objc private func productTapped(_ product: Product) {
        onProductSelected?(product)  // Just notify coordinator
    }
}
```

## Complex MVVM Hierarchies with Coordinators

### Multi-Level Coordinator Structure
```swift
// App Coordinator (Root)
class AppCoordinator: Coordinator {
    func start() {
        if userIsLoggedIn {
            showMainFlow()
        } else {
            showAuthFlow()
        }
    }
    
    private func showMainFlow() {
        let mainCoordinator = MainCoordinator(nav: navigationController)
        childCoordinators.append(mainCoordinator)
        mainCoordinator.start()
    }
}

// Main Coordinator (Tab-based)
class MainCoordinator: Coordinator {
    func start() {
        let tabBarController = UITabBarController()
        
        // Each tab has its own coordinator
        let homeCoordinator = HomeCoordinator()
        let searchCoordinator = SearchCoordinator()
        let profileCoordinator = ProfileCoordinator()
        
        childCoordinators = [homeCoordinator, searchCoordinator, profileCoordinator]
        
        // Start each coordinator
        childCoordinators.forEach { $0.start() }
    }
}

// Feature Coordinator
class HomeCoordinator: Coordinator {
    func start() {
        let homeViewModel = HomeViewModel()
        let homeVC = HomeViewController(viewModel: homeViewModel)
        
        homeVC.onShowProduct = { [weak self] product in
            self?.showProductFlow(for: product)
        }
        
        navigationController.setViewControllers([homeVC], animated: false)
    }
    
    private func showProductFlow(for product: Product) {
        let productCoordinator = ProductFlowCoordinator(
            navigationController: navigationController,
            product: product
        )
        childCoordinators.append(productCoordinator)
        productCoordinator.start()
    }
}
```

### ViewModel Communication in Coordinator Architecture
```swift
// ViewModels don't know about navigation
class HomeViewModel {
    @Published var featuredProducts: [Product] = []
    @Published var categories: [Category] = []
    
    // Just signals - no navigation logic
    let productSelectionRequested = PassthroughSubject<Product, Never>()
    let categorySelectionRequested = PassthroughSubject<Category, Never>()
    
    func selectProduct(_ product: Product) {
        // Business logic only
        trackProductView(product)
        productSelectionRequested.send(product)
    }
}

// ViewController binds ViewModel signals to Coordinator callbacks
class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // Coordinator callbacks
    var onShowProduct: ((Product) -> Void)?
    var onShowCategory: ((Category) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Bind ViewModel signals to Coordinator callbacks
        viewModel.productSelectionRequested
            .sink { [weak self] product in
                self?.onShowProduct?(product)
            }
            .store(in: &cancellables)
    }
}
```

## Communication Patterns Summary

### Vertical Communication (Same ViewController)
```swift
// Parent ViewModel owns children
ParentViewModel
    ├── ChildViewModel1
    ├── ChildViewModel2
    └── ChildViewModel3

// Children communicate up via callbacks
childViewModel.onAction = { [weak self] in
    self?.handleChildAction()
}
```

### Horizontal Communication (Between ViewControllers)

#### Without Coordinator
```swift
ViewControllerA → creates ViewModelB → creates ViewControllerB
                                    ↓
                            sets up callback
                                    ↓
                        ViewModelB completes action
                                    ↓
                        callback to ViewModelA
```

#### With Coordinator
```swift
ViewControllerA → notifies → Coordinator
                                ↓
                    creates ViewModelB & ViewControllerB
                                ↓
                    handles navigation & results
```

## Testing Guidelines

### ViewModel Testing
```swift
// ViewModels should be easily testable without UI
func testDiscountApplication() {
    let viewModel = PriceTagViewModel()
    viewModel.price = 100
    
    viewModel.applyDiscount()
    
    XCTAssertEqual(viewModel.price, 80)
    XCTAssertTrue(viewModel.hasDiscount)
}
```

### Testing with Coordinators
```swift
class MockCoordinator: ProductFlowCoordinator {
    var showDetailsCalled = false
    var shownProduct: Product?
    
    override func showProductDetails(_ product: Product) {
        showDetailsCalled = true
        shownProduct = product
    }
}
```

## Common Mistakes to Avoid

### 1. Wrong ViewModel Creation Location
```swift
// ❌ DON'T: ViewModel creating sibling ViewModels
class CartViewModel {
    func proceedToCheckout() -> CheckoutViewModel {
        return CheckoutViewModel()  // Wrong! This is for another VC
    }
}

// ✅ DO: ViewController or Coordinator creates them
class CartViewController {
    func proceedToCheckout() {
        let checkoutVM = CheckoutViewModel(cart: viewModel.cart)
        let checkoutVC = CheckoutViewController(viewModel: checkoutVM)
        present(checkoutVC, animated: true)
    }
}
```

### 2. ViewModels Knowing About Navigation
```swift
// ❌ DON'T
class LoginViewModel {
    func loginSuccess() {
        // ViewModels should not know about navigation
        let homeVC = HomeViewController()
        navigationController?.push(homeVC)
    }
}

// ✅ DO
class LoginViewModel {
    let loginSucceeded = PassthroughSubject<User, Never>()
    
    func login() {
        // Just publish the event
        loginSucceeded.send(user)
    }
}
```

### 3. Circular References
```swift
// ❌ DON'T: Strong references creating cycles
class ParentViewModel {
    var childViewModel: ChildViewModel?
    
    init() {
        childViewModel = ChildViewModel()
        childViewModel?.parent = self  // Potential cycle!
    }
}

// ✅ DO: Use weak references and callbacks
class ChildViewModel {
    weak var delegate: ParentViewModelDelegate?
    var onAction: (() -> Void)?
}
```

## Summary Checklist

- [ ] Every interactive view has its own ViewModel
- [ ] ViewModels contain ALL business logic
- [ ] Views only display and capture input
- [ ] ViewControllers coordinate and navigate (or delegate to Coordinators)
- [ ] Parent ViewModels can create child ViewModels for their view hierarchy
- [ ] ViewModels never create ViewModels for other ViewControllers
- [ ] Communication flows through callbacks/delegates/Combine
- [ ] No UIKit imports in ViewModels
- [ ] ViewModels are easily unit testable
- [ ] No circular references between ViewModels

## Final Rule
When in doubt about ViewModel creation:
- Same screen's subviews? → Parent ViewModel creates children ✅
- Different screens? → ViewController or Coordinator creates them ✅
- ViewModel creating for another ViewController? → Never ❌