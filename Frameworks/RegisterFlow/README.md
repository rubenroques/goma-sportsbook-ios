# RegisterFlow

A Swift Package for a customizable, multi-step user registration flow.

## Overview

The `RegisterFlow` package provides a complete and customizable user registration experience. It's designed to be easily integrated into any application, and it supports different registration flows for different clients.

## Features

*   **Multi-Step Registration**: The registration process is broken down into a series of clear and easy-to-follow steps.
*   **Customizable UI**: The UI is highly customizable, with support for different themes, avatars, and animations.
*   **Client-Specific Flows**: The package supports different registration flows for different clients, allowing for a high degree of flexibility.
*   **Form Validation**: The package includes built-in form validation to ensure that users enter valid information.
*   **Dependency Injection**: The package uses dependency injection to make it easy to provide the necessary services and dependencies.

## Architecture

The `RegisterFlow` package is built on a modular architecture that separates the UI, logic, and resources into different components.

*   **`Sources/RegisterFlow`**: This directory contains the main source code for the package, including the different form steps, the registration view controller, and the shared components.
*   **`Resources`**: This directory contains all the resources used by the package, including the avatars, animations, and icons.

## Dependencies

The `RegisterFlow` package has the following dependencies:

*   **External**:
    *   `lottie-spm`: For animations.
    *   `Optimove-SDK-iOS`: For marketing automation.
    *   `PhoneNumberKit`: For phone number validation.
*   **Internal**:
    *   `Extensions`
    *   `HeaderTextField`
    *   `SharedModels`
    *   `Theming`
    *   `ServicesProvider`
    *   `CountrySelectionFeature`
    *   `AdresseFrancaise`

## Usage

To use the `RegisterFlow` package, you first need to create a `RegisterFlow` object and then present its view controller.

```swift
import RegisterFlow

// Create the RegisterFlow object
let registerFlow = RegisterFlow(
    servicesProvider: servicesProvider,
    countrySelectionFeature: countrySelectionFeature,
    adresseFrancaise: adresseFrancaise
)

// Get the register view controller
let registerViewController = registerFlow.makeSteppedRegistrationViewController(
    formType: .betsson,
    envelop: UserRegisterEnvelop()
)

// Present the view controller
present(registerViewController, animated: true)
```