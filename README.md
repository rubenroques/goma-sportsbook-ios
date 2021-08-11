# GomaGaming Sportsbook - iOS Client

StackEdit stores your files in your browser, which means all your files are automatically saved locally and are accessible.

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
This project uses SwiftLint to help enforce Swift style and conventions. 
Make sure it is installed:
```
brew install swiftlint
```

Open `Sportsbook.xcodeproj` file.


## Project Structure

* **Core**: Shared classes, UI and resources used by the clients.
    * **App**: Global classes like boot, routing, enviroment.
    * **Services**: External services and utilities used by the Core.
    * **Models**: Shared model
    * **Screens**: Screen UI and logic
    * **Views**: Shared views used across the app.
    * **Constants**: Constant variables
    * **Tools**: Helper tools and extensions
        * **Protocols**: Protocol definitions
            * **ClientsProtocols**: Each Core client should have a class implementing this protocol.
        * **Extensions**: Apple frameworks extensions
        * **Functional**:
        * **Helpers**:
    * **Resources**: Assets, localization files,  
        * **Localization**:
        * **SharedAssets**:
    * **Tests**: All the tests classes and helpers.
* **Clients**: Contains all the Sportsbook clients.
    * **Showcase**: The Demo client, clone this folder to create a new client.
        * **Prod**: Production build configs and static variables
        * **Dev**: Developement build configs and static variables

