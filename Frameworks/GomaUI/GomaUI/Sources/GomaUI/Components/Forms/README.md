# Forms Components

This folder contains UI components for form inputs, text fields, search, and code entry.

## Components

### Text Input
| Component | Description |
|-----------|-------------|
| `BorderedTextFieldView` | Modern text input with floating labels and validation states |
| `PinDigitEntryView` | PIN code entry with individual digit boxes |
| `CustomSliderView` | Highly customizable slider with discrete steps |

### Code Entry
| Component | Description |
|-----------|-------------|
| `CodeInputView` | Code entry with text input, submit button, and validation |
| `CodeClipboardView` | Code display with clipboard copy functionality |
| `CopyableCodeView` | Copyable code display component |
| `ResendCodeView` | Resend code countdown and action |

### Search
| Component | Description |
|-----------|-------------|
| `SearchView` | Lightweight search input with icon and clear button |
| `RecentSearchView` | Recent search terms display |
| `SearchHeaderInfoView` | Search header with info display |

### Selection & Options
| Component | Description |
|-----------|-------------|
| `SelectOptionsView` | Options selection component |
| `TermsAcceptanceView` | Terms and conditions acceptance with checkbox |

## Usage

These components are used in:
- Registration flows
- Login screens
- Verification screens
- Search interfaces
- Settings forms

## Architecture

All components follow GomaUI's standard MVVM pattern with protocol-driven ViewModels, mock implementations, and Combine-based reactive bindings.
