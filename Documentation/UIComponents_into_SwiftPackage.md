# Organizing UI Components into a Swift Package with MVVM

## Introduction

As iOS projects grow, managing UI components can become complex and messy. Extracting reusable UI elements into a Swift package keeps your codebase organized, modular, and easier to maintain. This document will walk you through creating a Swift package for UI components using the MVVM pattern. By the end, you’ll have a clear, reusable package that is:

- **Reusable**: Works across different projects without modification.
- **Loosely Coupled**: Avoids tight dependencies on app-specific logic.
- **Testable**: Easy to verify with unit tests.

This guide assumes you’re familiar with Swift, UIKit, and the basics of MVVM. Let’s dive in!

---

## Structure of the Swift Package

A Swift package for UI components should include:

- **View**: The UI element (e.g., a custom button, a user profile card).
- **ViewModel**: The logic and data handling for the View.

### Why Include View and ViewModel Together?
- **Cohesion**: The View and ViewModel are a team. Packaging them together keeps their relationship intact.
- **Reusability**: Developers can drop the component into any project without reimplementing the logic.

### What to Exclude: The Model
- **Model**: Data structures (e.g., `User`, `Product`) should **not** live in the package.
  - **Reason**: Models are app-specific. Including them ties the package to one app’s domain, killing reusability.

Instead, we’ll use **protocols** to define what the ViewModel needs from a Model, letting the app supply its own data types.

---

## Handling the Model with Protocols

To keep the package independent of app-specific Models, we’ll use protocols. The ViewModel will rely on these protocols, not concrete types.

### Example: UserDisplayable Protocol

Imagine a UI component that shows user info. Define a `UserDisplayable` protocol in the package:

```swift
// In the Swift package
public protocol UserDisplayable {
    var displayName: String { get }
    var profileImageURL: URL? { get }
}
```

The ViewModel uses this protocol:

```swift
// In the Swift package
public class MyComponentViewModel {
    private let user: UserDisplayable

    public init(user: UserDisplayable) {
        self.user = user
    }

    public var displayName: String {
        return user.displayName
    }

    public var profileImageURL: URL? {
        return user.profileImageURL
    }
}
```

In the app, conform your `User` type to `UserDisplayable`:

```swift
// In the app
struct User: UserDisplayable {
    let name: String
    let profileImageURL: URL?

    var displayName: String { return name }
}

// Usage
let user = User(name: "Alice", profileImageURL: someURL)
let viewModel = MyComponentViewModel(user: user)
```

**Why This Works**: The package doesn’t care about your app’s `User` struct. It works with any type that meets `UserDisplayable`, keeping it flexible.

---

## Managing External Services

The ViewModel might need services (e.g., a network client to fetch images). To avoid hardcoding dependencies, use **dependency injection** with protocols.

### Example: ImageFetcher Protocol

If the ViewModel fetches images, define an `ImageFetcher` protocol:

```swift
// In the Swift package
public protocol ImageFetcher {
    func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void)
}
```

Inject it into the ViewModel:

```swift
// In the Swift package
public class MyComponentViewModel {
    private let imageFetcher: ImageFetcher

    public init(imageFetcher: ImageFetcher) {
        self.imageFetcher = imageFetcher
    }

    public func loadProfileImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        imageFetcher.fetchImage(from: url, completion: completion)
    }
}
```

In the app, provide an implementation:

```swift
// In the app
class NetworkImageFetcher: ImageFetcher {
    func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // Networking code, e.g., using URLSession
    }
}

// Usage
let imageFetcher = NetworkImageFetcher()
let viewModel = MyComponentViewModel(imageFetcher: imageFetcher)
```

**Why This Works**: The ViewModel isn’t tied to your networking code. You can swap implementations or use mocks for testing.

---

## Dealing with App-Specific Logic

For actions like navigation, use **callbacks** or **delegates**. This keeps the package free of app-specific details.

### Example: Navigation Callback

If tapping the component triggers navigation, add a callback:

```swift
// In the Swift package
public class MyComponentViewModel {
    public var onNavigateToDetails: (() -> Void)?

    public func buttonTapped() {
        onNavigateToDetails?()
    }
}
```

In the app, define the navigation:

```swift
// In the app
let viewModel = MyComponentViewModel()
viewModel.onNavigateToDetails = { [weak self] in
    self?.navigationController?.pushViewController(DetailsViewController(), animated: true)
}
```

**Why This Works**: The package doesn’t know about your app’s navigation stack. It just calls a function, staying independent.

---

## Putting It All Together

Here’s the full structure for a UI component package:

1. **View and ViewModel**: Bundle them in the package.
2. **Model**: Use protocols (e.g., `UserDisplayable`).
3. **Services**: Define protocols (e.g., `ImageFetcher`) and inject them.
4. **App Logic**: Use callbacks or delegates.

### Full Example

#### In the Swift Package

```swift
// Protocols
public protocol UserDisplayable {
    var displayName: String { get }
    var profileImageURL: URL? { get }
}

public protocol ImageFetcher {
    func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void)
}

// ViewModel
public class MyComponentViewModel {
    private let user: UserDisplayable
    private let imageFetcher: ImageFetcher
    public var onNavigateToDetails: (() -> Void)?

    public init(user: UserDisplayable, imageFetcher: ImageFetcher) {
        self.user = user
        self.imageFetcher = imageFetcher
    }

    public var displayName: String {
        return user.displayName
    }

    public func loadProfileImage(completion: @escaping (UIImage?) -> Void) {
        if let url = user.profileImageURL {
            imageFetcher.fetchImage(from: url, completion: completion)
        }
    }

    public func buttonTapped() {
        onNavigateToDetails?()
    }
}

// View
public class MyComponent: UIView {
    private let viewModel: MyComponentViewModel
    private let nameLabel = UILabel()
    private let profileImageView = UIImageView()
    private let button = UIButton()

    public init(viewModel: MyComponentViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Add subviews and constraints
        addSubview(nameLabel)
        addSubview(profileImageView)
        addSubview(button)
        // Set up layout (e.g., with NSLayoutConstraint)
    }

    private func setupBindings() {
        nameLabel.text = viewModel.displayName
        viewModel.loadProfileImage { [weak self] image in
            self?.profileImageView.image = image
        }
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    @objc private func buttonTapped() {
        viewModel.buttonTapped()
    }
}
```

#### In the App

```swift
// Model
struct User: UserDisplayable {
    let name: String
    let profileImageURL: URL?

    var displayName: String { return name }
}

// Service
class NetworkImageFetcher: ImageFetcher {
    func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // Fetch image with URLSession or similar
    }
}

// Usage in a ViewController
class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let user = User(name: "Alice", profileImageURL: someURL)
        let imageFetcher = NetworkImageFetcher()
        let viewModel = MyComponentViewModel(user: user, imageFetcher: imageFetcher)
        viewModel.onNavigateToDetails = { [weak self] in
            self?.navigationController?.pushViewController(DetailsViewController(), animated: true)
        }

        let component = MyComponent(viewModel: viewModel)
        view.addSubview(component)
        // Add constraints for component
    }
}
```

---

## Additional Tips

### Testing the Package
- **ViewModel Tests**: Mock `ImageFetcher` and `UserDisplayable` for unit tests.
  - Example: A `MockImageFetcher` that returns a test image.
- **View Tests**: Use snapshot testing (e.g., SnapshotTesting) to check the UI.

### Keeping It Focused
- **Single Responsibility**: Each component should do one job (e.g., display a user).
- **No App Logic**: Keep navigation, storage, etc., out of the package.

---

## Conclusion

This approach gives you a Swift package that’s:

- **Reusable**: Drop it into any project.
- **Loosely Coupled**: No ties to app-specific code.
- **Testable**: Easy to mock and verify.

Key takeaways:
- Use **protocols** for Models and services.
- **Inject dependencies** into the ViewModel.
- Handle app logic with **callbacks or delegates**.

With this structure, your UI components will be clean, maintainable, and ready for any project. Let’s start building!