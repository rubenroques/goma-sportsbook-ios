# **Banking Feature Technical Report**
## **Platform-Agnostic Analysis of Deposit & Withdraw Implementation**

Based on comprehensive analysis of the Android implementation in `feature/SPOR-5459-withdraw-integration`, here's the detailed technical specification for implementing the iOS Banking feature.

---

## **1. Architecture Overview**

### **Unified Banking Flow Design**
The Android team implemented a **unified banking architecture** that handles both Deposit and Withdraw operations through a single, reusable component system. This eliminates code duplication and provides consistent UX patterns.

**Key Architectural Principles:**
- **Single WebView Container**: One controller handles both transaction types
- **Dynamic Type Parameter**: `transactionType: String` ("Deposit" or "Withdraw") determines behavior
- **Shared State Management**: Common UI states and navigation logic
- **Centralized API Integration**: Unified backend communication layer

---

## **2. Core Components Architecture**

### **2.1 Banking State Machine**
```kotlin
sealed class BankingScreen {
    object BonusSelection : BankingScreen()
    object AmountInput : BankingScreen()
    object UssdPushIncoming : BankingScreen()
    object UssdConfirmation : BankingScreen() 
    object AlternativeSteps : BankingScreen()
    data class Success(val amount: Double) : BankingScreen()
}
```

**Flow Logic:**
- **Deposit**: BonusSelection → AmountInput → WebView
- **Withdraw**: AmountInput → WebView (skips bonus)
- **Common**: Error handling, loading states, success confirmation

### **2.2 Banking Parameters Model**
```kotlin
data class BankingParameters(
    val channel: String = "mobile",
    val type: String, // "Deposit" or "Withdraw"
    val successUrl: String = "http://localhost:5173/deposit/success",
    val cancelUrl: String = "http://localhost:5173/deposit/cancel", 
    val failUrl: String = "http://localhost:5173/deposit/fail",
    val language: String,
    val productType: String = "Sports",
    val currency: String,
    val isShortCashier: Boolean = false,
    val bonusCode: String = "Test",
    val showBonusSelectionInput: Boolean = true
)
```

### **2.3 WebView Response Model**
```kotlin
data class BankingWebViewResponse(
    val CashierInfo: CashierInfo
)

data class CashierInfo(
    val Url: String
)
```

---

## **3. WebView Integration & JavaScript Bridge**

### **3.1 JavaScript Interface Implementation**
```kotlin
private class WebAppInterface(
    private val activity: MainActivity?,
    private val onClose: () -> Unit,
    private val goToSports: () -> Unit, 
    private val goToCasino: () -> Unit
) {
    @JavascriptInterface
    fun postMessage(jsonData: String) {
        activity?.runOnUiThread {
            if (jsonData.contains("redirect")) {
                activity.getBalance() // Critical: Update balance
                
                when {
                    jsonData.contains("mm-hc-sports") -> {
                        onClose()
                        goToSports()
                    }
                    jsonData.contains("mm-hc-casino") -> {
                        onClose()
                        goToCasino()
                    }
                    jsonData.contains("mm-wm-hc-init-deposit") -> {
                        onClose()
                    }
                }
            }
        }
    }
}
```

### **3.2 JavaScript Event Listener Injection**
```kotlin
override fun onPageFinished(view: WebView?, url: String?) {
    val script = """
        window.addEventListener('message', function(event) {
            let messageData = event.data;
            if (typeof messageData === 'object') {
                messageData = JSON.stringify(messageData);
            }
            if (window.Android && typeof window.Android.postMessage === 'function') {
                window.Android.postMessage(messageData);
            }
        });
    """
    view?.evaluateJavascript(script, null)
}
```

**JavaScript Message Patterns:**
- `"redirect"` - Transaction completion indicator
- `"mm-hc-sports"` - Navigate to sports section
- `"mm-hc-casino"` - Navigate to casino section  
- `"mm-wm-hc-init-deposit"` - Simple close action

---

## **4. API Integration Layer**

### **4.1 Banking API Service**
```kotlin
interface PaymentApiServiceEM {
    @POST
    suspend fun getBanking(
        @Url url: String,
        @Header("X-SessionId") sessionId: String,
        @Body bankingParameters: BankingParameters
    ): Response<BankingWebViewResponse>
}
```

### **4.2 ViewModel Integration**
```kotlin
fun getBankingWebView(
    type: String, // "Deposit" or "Withdraw"
    currency: String,
    language: String, 
    sessionId: String,
    userId: String
) {
    val parameters = BankingParameters(
        channel = "mobile",
        type = type,
        language = language,
        currency = currency,
        // ... other parameters
    )
    // Make API call with unified parameters
}
```

---

## **5. UI/UX Implementation Details**

### **5.1 Dynamic Title Management**
```kotlin
val title = if (transactionType.equals("Withdraw", ignoreCase = true)) {
    stringResource(id = R.string.withdraw)
} else {
    stringResource(id = R.string.deposit)
}
```

### **5.2 WebView Optimization**
```kotlin
WebView(context).apply {
    settings.javaScriptEnabled = true
    settings.domStorageEnabled = true
    setBackgroundColor(0x00000000) // Transparent background
    settings.loadWithOverviewMode = true
    settings.useWideViewPort = true
    
    webViewClient = MyWebViewClient { isPageLoading = false }
    addJavascriptInterface(WebAppInterface(...), "Android")
}
```

### **5.3 Loading State Management**
- **Initial Load**: Show loading spinner until page loads
- **WebView Visibility**: Hidden (`alpha = 0f`) until `isPageLoading = false`
- **Balance Update**: Always triggered on transaction completion

---

## **6. Navigation & State Management**

### **6.1 Configuration System**
```kotlin
@Parcelize
data class Banking(
    val transactionType: String, // "Deposit" or "Withdraw"
    val isFirstDeposit: Boolean = false,
    val isCasinoDeposit: Boolean = false
) : DynamicHostConfig()
```

### **6.2 Back Navigation Logic**
```kotlin
when (currentScreen) {
    is BankingScreen.AmountInput -> {
        if (isFirstDeposit) currentScreen = BankingScreen.BonusSelection
        else dismiss()
    }
    is BankingScreen.UssdPushIncoming,
    is BankingScreen.UssdConfirmation,
    is BankingScreen.AlternativeSteps -> currentScreen = BankingScreen.AmountInput
    is BankingScreen.Success -> currentScreen = BankingScreen.AmountInput  
    is BankingScreen.BonusSelection -> dismiss()
}
```

### **6.3 Balance Update Strategy**
```kotlin
val handleClose = {
    activity.getBalance() // Critical: Always update balance before closing
    onClose()
}
```

---

## **7. Integration Points**

### **7.1 Entry Points**
- **Profile Screen**: Wallet widget with separate Deposit/Withdraw buttons
- **Top Bar**: Balance widget with withdraw option
- **Bottom Sheet**: Modal presentation for banking flow
- **Post-Login**: Automatic deposit flow redirect

### **7.2 Exit Behaviors**
- **Success**: Update balance → Navigate per JavaScript message
- **Cancel**: Update balance → Close modal
- **Error**: Show error → Allow retry or close

---

## **8. iOS Implementation Requirements**

### **8.1 Core iOS Components Needed**
1. **BankingViewController** - Unified WebView controller
2. **BankingScreen** - State machine enum
3. **BankingParameters** - API parameter model  
4. **BankingWebViewResponse** - Response model
5. **WebViewJavaScriptBridge** - JS communication layer
6. **BankingCoordinator** - Navigation management

### **8.2 ServicesProvider Integration**
- Add `getBankingWebView` method to payment provider
- Implement unified banking API endpoint
- Add banking response models to domain layer

### **8.3 GomaUI Components**
- Reuse existing WebView patterns from current implementation
- Apply StyleProvider theming to match brand requirements
- Implement loading states with GomaUI progress indicators

---

## **9. Technical Benefits**

### **9.1 Code Efficiency**
- **50% Less Code**: Single implementation vs separate Deposit/Withdraw
- **Unified Testing**: One test suite covers both flows
- **Consistent UX**: Identical patterns reduce user confusion

### **9.2 Maintenance Advantages**  
- **Single Source of Truth**: One controller for all banking operations
- **Easier Updates**: API changes affect one integration point
- **Scalable**: Easy to add new transaction types (Refund, Transfer, etc.)

### **9.3 Performance Optimizations**
- **Shared WebView**: No duplicate WebView instantiation
- **Optimized Loading**: Transparent background and proper visibility handling
- **Balance Sync**: Centralized balance update on all transaction completions

---

This unified banking architecture provides a robust, maintainable foundation for both Deposit and Withdraw functionality while leveraging the proven patterns from the Android implementation.

## **10. Implementation Roadmap**

### **Phase 1: Foundation**
1. Create banking models in ServicesProvider
2. Implement unified banking API integration
3. Set up core BankingViewController architecture

### **Phase 2: WebView Integration**
1. Implement JavaScript bridge communication
2. Add WebView optimization and loading states
3. Create transaction completion detection

### **Phase 3: UI Integration**
1. Integrate with BetssonCameroonApp navigation
2. Add banking entry points to profile and top bar
3. Implement proper state management and error handling

### **Phase 4: Testing & Polish**
1. Comprehensive testing of both deposit and withdraw flows
2. UI/UX refinements and accessibility improvements
3. Performance optimization and balance sync validation