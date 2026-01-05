# CodeInputView

A code entry form with text field, submit button, and error display.

## Overview

CodeInputView provides a complete booking code input interface with a bordered text field, submit button, and optional error message display. It supports loading and error states, automatically managing the visual appearance of child components based on the current state. Common uses include booking code entry, promo code redemption, and verification code input.

## Component Relationships

### Used By (Parents)
- None (standalone form component)

### Uses (Children)
- `BorderedTextFieldView` - code input field
- `ButtonView` - submit button

## Features

- Bordered text field with placeholder
- Configurable submit button title
- Error state with warning banner (orange background, icon, message)
- Loading state with centered activity indicator
- Default, loading, and error states
- Text change callback for validation
- Button tap callback for submission
- Secondary background color
- Reactive updates via Combine publisher

## Usage

```swift
let viewModel = MockCodeInputViewModel.defaultMock()
let codeInputView = CodeInputView(viewModel: viewModel)

viewModel.onSubmitRequested = { code in
    // Validate and process the code
    if code.isEmpty {
        viewModel.setError("Please enter a code")
    } else {
        viewModel.setLoading(true)
        // API call...
    }
}
```

## Data Model

```swift
enum CodeInputState: Equatable {
    case `default`
    case loading
    case error(message: String)
}

struct CodeInputData: Equatable {
    let state: CodeInputState
    let code: String
    let placeholder: String
    let buttonTitle: String
    let isButtonEnabled: Bool
}

protocol CodeInputViewModelProtocol {
    var dataPublisher: AnyPublisher<CodeInputData, Never> { get }
    var currentData: CodeInputData { get }
    var codeTextFieldViewModel: BorderedTextFieldViewModelProtocol { get }
    var submitButtonViewModel: ButtonViewModelProtocol { get }

    func updateCode(_ code: String)
    func setLoading(_ isLoading: Bool)
    func setError(_ message: String)
    func clearError()
    func onButtonTapped()

    var onSubmitRequested: ((String) -> Void)? { get set }
}
```

## Styling

StyleProvider properties used:
- `StyleProvider.Color.backgroundSecondary` - container background
- `StyleProvider.Color.alertWarning` - error banner background
- `StyleProvider.Color.allWhite` - error icon and text color
- `StyleProvider.fontWith(type: .bold, size: 14)` - error message font

Layout constants:
- Text field height: 52pt
- Button height: 50pt
- Content padding: 16pt
- Vertical spacing: 12pt
- Error banner corner radius: 8pt
- Error icon size: 24pt

## Mock ViewModels

Available presets:
- `.defaultMock()` - empty default state
- `.loadingMock()` - loading with code "BA2672"
- `.errorMock()` - error state with message
- `.withCodeMock()` - pre-filled with code "BA2672"
