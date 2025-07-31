# BorderedTextFieldView

BorderedTextFieldView is a sophisticated text input component featuring floating labels, customizable styling, and comprehensive input support. It provides a modern, accessible interface for user text input with real-time validation and state management.

## Features

- **Floating Label Animation** - Label smoothly transitions between placeholder and floated positions
- **Multiple Input Types** - Support for text, password, email, phone number, and more
- **Real-time Text Publisher** - Constant stream of text changes via Combine publishers
- **Password Visibility Toggle** - Built-in eye icon for secure text fields
- **Required Field Indication** - Visual asterisk for mandatory fields
- **Error State Handling** - Red styling and error message display
- **Focus State Management** - Border and label color changes on focus
- **Accessibility Support** - Full VoiceOver and accessibility identifier support

## Use Cases

- Login and registration forms
- Profile editing interfaces
- Search input fields
- Settings and configuration screens
- Contact information forms

## Usage Example

### Basic Text Field

```swift
// Create a view model
let viewModel = MockBorderedTextFieldViewModel(
    textFieldData: BorderedTextFieldData(
        id: "email",
        placeholder: "Enter email address",
        label: "Email Address",
        isRequired: true,
        keyboardType: .emailAddress,
        textContentType: .emailAddress
    )
)

// Create the component
let textFieldView = BorderedTextFieldView(viewModel: viewModel)
textFieldView.translatesAutoresizingMaskIntoConstraints = false

// Add to your view hierarchy
parentView.addSubview(textFieldView)

// Set up constraints
NSLayoutConstraint.activate([
    textFieldView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 20),
    textFieldView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -20),
    textFieldView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 20)
])

// Handle text changes
textFieldView.onTextChanged = { text in
    print("Text changed: \(text)")
    // Perform validation or other actions
}

// Handle focus changes
textFieldView.onFocusChanged = { isFocused in
    print("Focus changed: \(isFocused)")
}
```

### Password Field with Toggle

```swift
let passwordViewModel = MockBorderedTextFieldViewModel(
    textFieldData: BorderedTextFieldData(
        id: "password",
        placeholder: "Enter password",
        label: "Password",
        isRequired: true,
        isSecure: true,
        textContentType: .password
    )
)

let passwordField = BorderedTextFieldView(viewModel: passwordViewModel)

// Listen to text changes for real-time validation
passwordField.onTextChanged = { password in
    // Perform password strength validation
    validatePasswordStrength(password)
}
```

### Form with Multiple Fields

```swift
class RegistrationViewController: UIViewController {
    private var textFieldViewModels: [BorderedTextFieldViewModelProtocol] = []
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
        setupTextFieldObservation()
    }
    
    private func setupForm() {
        // Create view models
        let nameViewModel = MockBorderedTextFieldViewModel.nameField
        let emailViewModel = MockBorderedTextFieldViewModel.emailField
        let phoneViewModel = MockBorderedTextFieldViewModel.phoneNumberField
        let passwordViewModel = MockBorderedTextFieldViewModel.passwordField
        
        textFieldViewModels = [nameViewModel, emailViewModel, phoneViewModel, passwordViewModel]
        
        // Create and layout text fields
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for viewModel in textFieldViewModels {
            let textField = BorderedTextFieldView(viewModel: viewModel)
            stackView.addArrangedSubview(textField)
        }
        
        view.addSubview(stackView)
        // Add constraints...
    }
    
    private func setupTextFieldObservation() {
        // Observe all text fields for real-time form validation
        let textPublishers = textFieldViewModels.map { $0.textPublisher }
        
        Publishers.CombineLatest4(
            textPublishers[0],
            textPublishers[1],
            textPublishers[2],
            textPublishers[3]
        )
        .sink { [weak self] name, email, phone, password in
            self?.validateForm(name: name, email: email, phone: phone, password: password)
        }
        .store(in: &cancellables)
    }
    
    private func validateForm(name: String, email: String, phone: String, password: String) {
        // Real-time form validation logic
        let isValid = !name.isEmpty && isValidEmail(email) && isValidPhone(phone) && isValidPassword(password)
        updateSubmitButton(enabled: isValid)
    }
}
```

## Configuration Options

### BorderedTextFieldData Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | Unique identifier for the text field |
| `text` | String | Current text content |
| `placeholder` | String | Placeholder text (usually hidden due to floating label) |
| `label` | String | Floating label text |
| `isRequired` | Bool | Whether to show required asterisk indicator |
| `isSecure` | Bool | Whether this is a password field with toggle |
| `isEnabled` | Bool | Whether the field accepts input |
| `errorMessage` | String? | Error message to display below field |
| `keyboardType` | UIKeyboardType | Keyboard type for input optimization |
| `textContentType` | UITextContentType? | Content type for AutoFill support |

### Publisher Architecture

The component uses individual publishers for granular state management:

- `textPublisher` - Real-time text content updates
- `labelPublisher` - Floating label text changes
- `isRequiredPublisher` - Required state changes
- `isSecurePublisher` - Secure field state
- `isFocusedPublisher` - Focus state changes
- `isPasswordVisiblePublisher` - Password visibility state
- `errorMessagePublisher` - Error state changes

### Real-time Text Observation

```swift
// Subscribe to text changes
textFieldView.viewModel.textPublisher
    .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
    .sink { text in
        // Perform debounced validation
        performAsyncValidation(text)
    }
    .store(in: &cancellables)
```

## States and Animations

### Visual States

1. **Empty & Unfocused** - Label in center, gray border
2. **Empty & Focused** - Label floated up, accent border, cursor visible
3. **Filled & Unfocused** - Label floated up, gray border
4. **Filled & Focused** - Label floated up, accent border
5. **Error State** - Red border, red label, error message visible
6. **Disabled State** - Reduced opacity, no interaction

### Label Animation

The floating label smoothly animates between two positions:
- **Placeholder Position** - Centered vertically in the field
- **Floated Position** - Small and positioned above the field

Animation triggers:
- Text field gains/loses focus
- Text content changes (empty ↔ filled)

## Styling

The BorderedTextFieldView uses StyleProvider for consistent theming:

```swift
// Customize colors
StyleProvider.Color.customize(
    primaryColor: UIColor(named: "BrandPrimary"),
    secondaryColor: UIColor(named: "BorderGray"),
    backgroundColor: .systemBackground,
    textColor: .label
)

// Customize fonts
StyleProvider.setFontProvider { type, size in
    // Return custom fonts based on type and size
}
```

## Accessibility

The component provides comprehensive accessibility support:

- Text field is properly labeled with floating label text
- Required state is announced
- Error messages are read automatically
- Password toggle button has descriptive accessibility label
- Focus management follows accessibility guidelines

## Implementation Notes

- The floating label uses transform animations for smooth scaling
- Password visibility toggle automatically manages secure text entry
- Text field constraints dynamically adjust based on suffix button visibility
- Error state takes precedence over focus state for styling
- Component height adjusts to accommodate error messages
- Real-time text publisher enables immediate validation feedback

## Error Handling

```swift
// Set an error
viewModel.setError("Please enter a valid email address")

// Clear error
viewModel.clearError()

// The component automatically:
// - Shows red border and label
// - Displays error message below field
// - Announces error to screen readers
```

This component provides a complete, production-ready text input solution with modern UX patterns and comprehensive state management. 