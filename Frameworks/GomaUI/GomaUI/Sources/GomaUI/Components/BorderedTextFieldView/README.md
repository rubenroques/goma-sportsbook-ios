# BorderedTextFieldView

A modern text field with floating label, animated border, and comprehensive validation support.

## Overview

BorderedTextFieldView provides a material-design inspired text input with floating placeholder labels, custom border with label cutout animation, password visibility toggle, prefix text support, and error state display. It supports various keyboard types, content types, and custom input views (e.g., date pickers).

## Component Relationships

### Used By (Parents)
- `BetInfoSubmissionView` - amount input field
- `CodeInputView` - code entry fields

### Uses (Children)
- None (leaf component)

## Features

- Floating label animation with scale transformation
- Custom border layer with label gap cutout
- Password visibility toggle with eye icon
- Prefix text support (e.g., currency symbols)
- Required field indicator with asterisk
- Four visual states: idle, focused, error, disabled
- Error message display below field
- Configurable keyboard type, return key, and content type
- Max length and character set validation
- Custom input view support (date pickers, pickers)
- Fixed 56pt field height

## Usage

```swift
let viewModel = MockBorderedTextFieldViewModel.emailField
let textFieldView = BorderedTextFieldView(viewModel: viewModel)

textFieldView.onTextChanged = { text in
    print("Text changed: \(text)")
}

textFieldView.onFocusChanged = { isFocused in
    print("Focus changed: \(isFocused)")
}
```

## Data Model

```swift
enum BorderedTextFieldVisualState: Equatable {
    case idle
    case focused
    case error(String)
    case disabled
}

struct BorderedTextFieldData: Equatable, Hashable {
    let id: String
    let text: String
    let placeholder: String
    let prefix: String?
    let isSecure: Bool
    let isRequired: Bool
    let usesCustomInput: Bool
    let visualState: BorderedTextFieldVisualState
    let keyboardType: UIKeyboardType
    let returnKeyType: UIReturnKeyType
    let textContentType: UITextContentType?
    let maxLength: Int?
    let allowedCharacters: CharacterSet?
}

protocol BorderedTextFieldViewModelProtocol {
    var textPublisher: AnyPublisher<String, Never> { get }
    var placeholderPublisher: AnyPublisher<String, Never> { get }
    var isSecurePublisher: AnyPublisher<Bool, Never> { get }
    var visualStatePublisher: AnyPublisher<BorderedTextFieldVisualState, Never> { get }
    var isPasswordVisiblePublisher: AnyPublisher<Bool, Never> { get }

    func updateText(_ text: String)
    func setVisualState(_ state: BorderedTextFieldVisualState)
    func togglePasswordVisibility()
    func setFocused(_ focused: Bool)
    func setError(_ errorMessage: String)
    func clearError()
    func setEnabled(_ enabled: Bool)
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.separatorLine` - idle border color
- `StyleProvider.Color.highlightPrimary` - focused border and required asterisk color
- `StyleProvider.Color.alertError` - error border and message color
- `StyleProvider.Color.textPrimary` - input text color
- `StyleProvider.Color.textDisablePrimary` - prefix label color
- `StyleProvider.Color.inputTextTitle` - floating label color
- `StyleProvider.Color.iconPrimary` - suffix button tint
- `StyleProvider.fontWith(type: .regular, size: 16)` - input and label font
- `StyleProvider.fontWith(type: .regular, size: 12)` - error label font

## Mock ViewModels

Available presets:
- `.phoneNumberField` - phone input with prefix
- `.passwordField` - secure entry with toggle
- `.emailField` - email keyboard type
- `.nameField` - standard text input
- `.errorField` - with error message displayed
- `.disabledField` - non-interactive state
- `.focusedField` - focused visual state
