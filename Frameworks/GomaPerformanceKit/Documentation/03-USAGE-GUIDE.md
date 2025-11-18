# GomaPerformanceKit - Usage Guide

## Table of Contents
1. [Installation](#installation)
2. [Basic Setup](#basic-setup)
3. [Tracking Operations](#tracking-operations)
4. [Querying Logs](#querying-logs)
5. [Exporting Data](#exporting-data)
6. [Integration Examples](#integration-examples)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

## Installation

### Adding to Xcode Project

1. **Add Swift Package to Workspace**:
   - In Xcode, select your workspace
   - File → Add Packages → Add Local...
   - Navigate to `/Frameworks/GomaPerformanceKit`
   - Click "Add Package"

2. **Link to Target**:
   - Select your target (e.g., BetssonCameroonApp)
   - Build Phases → Link Binary With Libraries
   - Add `GomaPerformanceKit`

3. **Import in Swift Files**:
   ```swift
   import GomaPerformanceKit
   ```

## Basic Setup

### Application Startup Configuration

**AppDelegate.swift** or **SceneDelegate.swift**:

```swift
import GomaPerformanceKit
import Reachability

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // 1. Determine network type
        let reachability = try? Reachability()
        let networkType: String
        switch reachability?.connection {
        case .wifi:
            networkType = "WiFi"
        case .cellular:
            networkType = "Cellular"
        default:
            networkType = "Unknown"
        }

        // 2. Create device context
        let deviceContext = DeviceContext.current(networkType: networkType)

        // 3. Get user ID (optional, nil if logged out)
        let userID = UserSessionStore.shared.currentUser?.id.sha256Hash

        // 4. Configure tracker
        PerformanceTracker.shared.configure(
            deviceContext: deviceContext,
            userID: userID
        )

        // 5. Add destinations
        #if DEBUG
        // Console output in debug builds
        let consoleDestination = ConsoleDestination()
        consoleDestination.logLevel = .verbose
        PerformanceTracker.shared.addDestination(consoleDestination)
        #endif

        // File destination for all builds
        let fileDestination = FileDestination(
            batchSize: 10,
            flushInterval: 30.0
        )
        PerformanceTracker.shared.addDestination(fileDestination)

        // Analytics destination for production
        #if !DEBUG
        if let analyticsURL = URL(string: "https://analytics.betsson.com/performance") {
            let analyticsDestination = AnalyticsDestination(
                endpoint: analyticsURL,
                batchSize: 50,
                flushInterval: 60.0
            )
            PerformanceTracker.shared.addDestination(analyticsDestination)
        }
        #endif

        // 6. Enable tracking
        PerformanceTracker.shared.enable()

        return true
    }
}
```

### Update User ID on Login/Logout

```swift
// On successful login
func onUserLoggedIn(_ user: User) {
    PerformanceTracker.shared.updateUserID(user.id.sha256Hash)
}

// On logout
func onUserLoggedOut() {
    PerformanceTracker.shared.updateUserID(nil)
}
```

## Tracking Operations

### Basic Tracking Pattern

```swift
// Start tracking
PerformanceTracker.shared.start(
    feature: .deposit,
    layer: .app,
    metadata: [:] // Optional
)

// ... perform operation ...

// End tracking
PerformanceTracker.shared.end(
    feature: .deposit,
    layer: .app,
    metadata: [:] // Optional
)
```

### With Metadata

```swift
// Start with context
PerformanceTracker.shared.start(
    feature: .deposit,
    layer: .api,
    metadata: [
        "endpoint": "/payment/GetPaymentSession",
        "currency": "XAF"
    ]
)

// ... API call ...

// End with result info
PerformanceTracker.shared.end(
    feature: .deposit,
    layer: .api,
    metadata: [
        "status": "success",
        "responseSize": "1024",
        "statusCode": "200"
    ]
)
```

### Error Handling

```swift
PerformanceTracker.shared.start(feature: .withdraw, layer: .api)

do {
    let response = try await apiClient.withdraw(amount: 100)
    PerformanceTracker.shared.end(
        feature: .withdraw,
        layer: .api,
        metadata: ["status": "success"]
    )
} catch {
    PerformanceTracker.shared.end(
        feature: .withdraw,
        layer: .api,
        metadata: [
            "status": "error",
            "error": error.localizedDescription
        ]
    )
}
```

## Querying Logs

### Get All Logs

```swift
let allLogs = PerformanceTracker.shared.getAllLogs()
print("Total entries: \(allLogs.count)")
```

### Filter by Feature

```swift
let depositLogs = PerformanceTracker.shared.getLogs(feature: .deposit)
print("Deposit operations: \(depositLogs.count)")

depositLogs.forEach { entry in
    print("\(entry.layer): \(entry.durationFormatted)")
}
```

### Filter by Layer

```swift
let apiLogs = PerformanceTracker.shared.getLogs(layer: .api)
print("API calls: \(apiLogs.count)")

let avgDuration = apiLogs.map { $0.duration }.reduce(0, +) / Double(apiLogs.count)
print("Average API duration: \(avgDuration)s")
```

### Filter by Feature and Layer

```swift
let depositAPILogs = PerformanceTracker.shared.getLogs(
    feature: .deposit,
    layer: .api
)

print("Deposit API calls: \(depositAPILogs.count)")
```

## Exporting Data

### Export as JSON

```swift
if let jsonData = PerformanceTracker.shared.exportJSON() {
    // Save to file
    let fileURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("performance.json")

    try? jsonData.write(to: fileURL)

    // Share via activity controller
    let activityVC = UIActivityViewController(
        activityItems: [fileURL],
        applicationActivities: nil
    )
    present(activityVC, animated: true)
}
```

### Export as CSV

```swift
if let csvData = PerformanceTracker.shared.exportCSV() {
    let fileURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("performance.csv")

    try? csvData.write(to: fileURL)

    // Email to support
    if MFMailComposeViewController.canSendMail() {
        let mail = MFMailComposeViewController()
        mail.setToRecipients(["support@betsson.com"])
        mail.setSubject("Performance Logs")
        mail.addAttachmentData(csvData, mimeType: "text/csv", fileName: "performance.csv")
        present(mail, animated: true)
    }
}
```

### Manual Flush

```swift
// Force immediate write to disk/analytics
PerformanceTracker.shared.flush()
```

## Integration Examples

### Example 1: ServicesProvider API Calls

**EveryMatrixProvider.swift**:

```swift
import GomaPerformanceKit

func getBankingWebView(
    parameters: CashierParameters
) -> AnyPublisher<CashierWebViewResponse, Error> {

    let feature: PerformanceFeature = parameters.type == "Deposit" ? .deposit : .withdraw

    // Start tracking
    PerformanceTracker.shared.start(
        feature: feature,
        layer: .api,
        metadata: [
            "endpoint": "/payment/GetPaymentSession",
            "currency": parameters.currency
        ]
    )

    return apiClient
        .request(endpoint: "/payment/GetPaymentSession", parameters: parameters)
        .handleEvents(
            receiveOutput: { response in
                // Success
                PerformanceTracker.shared.end(
                    feature: feature,
                    layer: .api,
                    metadata: [
                        "status": "success",
                        "url": response.webViewURL
                    ]
                )
            },
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    // Error
                    PerformanceTracker.shared.end(
                        feature: feature,
                        layer: .api,
                        metadata: [
                            "status": "error",
                            "error": error.localizedDescription
                        ]
                    )
                }
            }
        )
        .eraseToAnyPublisher()
}
```

### Example 2: ViewController APP Layer

**DepositWebContainerViewController.swift**:

```swift
import GomaPerformanceKit

class DepositWebContainerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Track APP layer initialization
        PerformanceTracker.shared.start(feature: .deposit, layer: .app)

        setupUI()
        bindViewModel()
        setupTimingOverlay()

        PerformanceTracker.shared.end(feature: .deposit, layer: .app)

        // Start loading deposit
        viewModel.loadDeposit(currency: "XAF")
    }
}
```

### Example 3: WebView WEB Layer

**DepositWebContainerViewController.swift** (WKNavigationDelegate):

```swift
extension DepositWebContainerViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Track WEB layer start
        PerformanceTracker.shared.start(
            feature: .deposit,
            layer: .web,
            metadata: ["url": webView.url?.absoluteString ?? ""]
        )
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Track WEB layer end
        PerformanceTracker.shared.end(
            feature: .deposit,
            layer: .web,
            metadata: ["success": "true"]
        )
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // Track WEB layer error
        PerformanceTracker.shared.end(
            feature: .deposit,
            layer: .web,
            metadata: [
                "success": "false",
                "error": error.localizedDescription
            ]
        )
    }
}
```

### Example 4: Login Flow

**LoginViewController.swift**:

```swift
@objc private func loginButtonTapped() {
    PerformanceTracker.shared.start(feature: .login, layer: .app)

    let email = emailTextField.text ?? ""
    let password = passwordTextField.text ?? ""

    PerformanceTracker.shared.end(feature: .login, layer: .app)

    // API call (tracked in AuthProvider)
    authProvider.login(email: email, password: password)
}
```

**AuthProvider.swift**:

```swift
func login(email: String, password: String) -> AnyPublisher<User, Error> {
    PerformanceTracker.shared.start(
        feature: .login,
        layer: .api,
        metadata: ["method": "email"]
    )

    return apiClient.post("/auth/login", body: ["email": email, "password": password])
        .handleEvents(
            receiveOutput: { user in
                PerformanceTracker.shared.end(
                    feature: .login,
                    layer: .api,
                    metadata: ["status": "success"]
                )
            },
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    PerformanceTracker.shared.end(
                        feature: .login,
                        layer: .api,
                        metadata: [
                            "status": "error",
                            "error": error.localizedDescription
                        ]
                    )
                }
            }
        )
}
```

### Example 5: Sports Data Loading

**MatchListViewController.swift**:

```swift
func loadMatches() {
    PerformanceTracker.shared.start(
        feature: .sportsData,
        layer: .api,
        metadata: ["dataType": "matches"]
    )

    sportsProvider.getMatches()
        .sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    PerformanceTracker.shared.end(
                        feature: .sportsData,
                        layer: .api,
                        metadata: ["status": "success"]
                    )
                case .failure(let error):
                    PerformanceTracker.shared.end(
                        feature: .sportsData,
                        layer: .api,
                        metadata: [
                            "status": "error",
                            "error": error.localizedDescription
                        ]
                    )
                }
            },
            receiveValue: { matches in
                self?.updateUI(with: matches)
            }
        )
        .store(in: &cancellables)
}
```

## Best Practices

### 1. Always Pair start() with end()

✅ **Good**:
```swift
func performOperation() {
    PerformanceTracker.shared.start(feature: .deposit, layer: .api)
    defer {
        PerformanceTracker.shared.end(feature: .deposit, layer: .api)
    }
    // Operation code
}
```

❌ **Bad**:
```swift
func performOperation() {
    PerformanceTracker.shared.start(feature: .deposit, layer: .api)
    // Missing end() call!
}
```

### 2. Use Meaningful Metadata

✅ **Good**:
```swift
metadata: [
    "endpoint": "/payment/GetPaymentSession",
    "currency": "XAF",
    "bonusCode": "WELCOME100"
]
```

❌ **Bad**:
```swift
metadata: [
    "data": "some data"
]
```

### 3. Track at Appropriate Granularity

✅ **Good**: Track major operations
```swift
// Track complete deposit flow
PerformanceTracker.shared.start(feature: .deposit, layer: .app)
```

❌ **Bad**: Track too granularly
```swift
// Don't track every button tap
PerformanceTracker.shared.start(feature: .deposit, layer: .app)
```

### 4. Use defer for Error Handling

```swift
func riskyOperation() throws {
    PerformanceTracker.shared.start(feature: .withdraw, layer: .api)

    defer {
        // Always called, even on throw
        PerformanceTracker.shared.end(feature: .withdraw, layer: .api)
    }

    try performAPICall()
}
```

### 5. Sanitize Sensitive Data

❌ **Bad**: Log passwords, tokens
```swift
metadata: [
    "password": "user123",  // NEVER!
    "token": "Bearer abc123"  // NEVER!
]
```

✅ **Good**: Log safe identifiers
```swift
metadata: [
    "userID": user.id.sha256Hash,
    "hasToken": "true"
]
```

## Troubleshooting

### Issue: Missing Logs

**Symptoms**: `getAllLogs()` returns empty array

**Possible Causes**:
1. Tracker not enabled: `PerformanceTracker.shared.enable()`
2. No destinations added: `addDestination(...)`
3. Missing `end()` calls: Check for unmatched `start()`

**Solution**:
```swift
print("Enabled: \(PerformanceTracker.shared.isEnabled)")
print("Destinations: \(PerformanceTracker.shared.destinationCount)")
```

### Issue: Duplicate Entries

**Symptoms**: Multiple entries for same operation

**Possible Causes**:
- Multiple `end()` calls
- Concurrent operations of same feature+layer

**Solution**:
```swift
// Use defer to ensure single end() call
defer {
    PerformanceTracker.shared.end(...)
}
```

### Issue: High Memory Usage

**Symptoms**: App memory increases over time

**Possible Causes**:
- In-memory cache too large
- Not flushing to disk

**Solution**:
```swift
// Manually flush periodically
PerformanceTracker.shared.flush()

// Reduce cache size in FileDestination
let destination = FileDestination(batchSize: 5, flushInterval: 15)
```

### Issue: Session Timeout Warnings

**Symptoms**: Console warnings about expired sessions

```
[Performance] Warning: Session expired: deposit_api_1731927483.234
```

**Cause**: `start()` called but `end()` never called (or takes > 5 minutes)

**Solution**:
- Add `end()` call
- Use `defer` pattern
- Check for early returns that skip `end()`

### Issue: Analytics Not Sending

**Symptoms**: Logs not appearing in backend

**Possible Causes**:
1. Wrong endpoint URL
2. Network connectivity
3. Authentication required

**Debug**:
```swift
// Check destination configuration
if let analyticsDestination = PerformanceTracker.shared.destinations
    .first(where: { $0 is AnalyticsDestination }) as? AnalyticsDestination {
    print("Analytics endpoint: \(analyticsDestination.endpoint)")
    print("Buffer size: \(analyticsDestination.bufferSize)")
}

// Force manual flush
PerformanceTracker.shared.flush()
```

## Advanced Usage

### Custom Destination

```swift
class CustomDestination: PerformanceDestination {
    func log(entry: PerformanceEntry) {
        // Custom logging logic
        // e.g., send to Firebase, Crashlytics, etc.
    }

    func flush() {
        // Flush buffered entries
    }
}

// Add to tracker
PerformanceTracker.shared.addDestination(CustomDestination())
```

### Conditional Tracking

```swift
// Only track in specific conditions
if ProcessInfo.processInfo.arguments.contains("-trackPerformance") {
    PerformanceTracker.shared.enable()
} else {
    PerformanceTracker.shared.disable()
}
```

### Feature Flagging

```swift
// Remote config to enable/disable
RemoteConfig.fetch { config in
    if config.performanceTrackingEnabled {
        PerformanceTracker.shared.enable()
    } else {
        PerformanceTracker.shared.disable()
    }
}
```
