# GomaGaming Sportsbook - iOS Client

GOMA Sportsbook multi-sport betting app.

## Requirements

* Xcode 12
* iOS 13
* [SwiftLint](https://github.com/realm/SwiftLint)
* [Fastlane](https://docs.fastlane.tools/)

## Instalation

Clone this repository:
```
git clone git@github.com:gomagaming/sportsbook-ios.git
```
This project uses SwiftLint to help enforce Swift style and conventions. Make sure it is installed:
```
brew install swiftlint
```
Open `Sportsbook.xcodeproj` file.

## Project Structure

* **Core**: App delegate, Shared classes, UI and resources used by the clients.
    * **App**: Global classes like boot, routing, enviroment.
    * **Services**: External services and utilities used by Core.
    * **Models**: Shared models.
    * **Screens**: Screen UI and logic.
    * **Views**: Shared views used across the app.
    * **Constants**: Constant variables.
    * **Tools**: Helper tools and extensions.
        * **Protocols**: Protocol definitions.
            * **ClientsProtocols**: Each Core client should have a class implementing this protocol.
        * **Extensions**: Apple frameworks extensions.
        * **Functional**: Functional-style helpers and extensions.
        * **Helpers**: 
    * **Resources**: Assets, localization files,
        * **Localization**:
        * **SharedAssets**: Shared assets between all the clients.
    * **Tests**: All the tests classes and helpers.
* **Clients**: Contains all the Sportsbook clients.
    * **Showcase**: The Demo client, clone this folder to create a new client.
        * **Prod**: Production build configs and static variables
        * **Dev**: Developement build configs and static variables

## ViewController Structure

ViewControllers interfaces should be created preferably in code and using *AutoLayout*. 
Using `//MARK:` from Xcode, ViewControllers should be organized with the following struture:
  
* **Types**: contains enumerations and internal structs.
* **Properties**: all properties (IBOutlet, let, var, etc.).
* **Lifetime and Cycle**: init and deinit methods, and all viewDid… methods.
* **Layout and Theme**: layoutSubviews… methods.
* **Setup**: view and data initialization.
* **Bindings**: connect to publishers.
* **Actions**: actions done by the user (IBAction, UIGestureRecognizer, didTapXYZ, etc.),
* **Notifications**: notifications methods.
* **Convenience**: interface update, all convenience methods.
* **Delegates**: all delegate methods.

## Tools

* [QuickType IO](https://app.quicktype.io/) Convert JSON to Swift `Codable` structs.
* [JSONEditorOnline](http://jsoneditoronline.org/) JSON formatter and tree viewer.
* [JSON Generator](https://json-generator.com/) Generate JSON to tests logic and strutures.
* [StackEdit](https://stackedit.io/) for Markdown preview.
