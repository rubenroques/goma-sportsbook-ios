# Project Structure Improvement Proposal

## Current Structure Analysis

The current project structure has several organizational challenges:

1. Mixing of concerns across directories
2. Unclear separation between features and infrastructure
3. Inconsistent naming conventions
4. Duplication across client-specific implementations
5. Lack of clear modular boundaries
6. Overly nested directory structures

## Proposed Structure

```
sportsbook-ios/
├── App/                              # Main application code
│   ├── Bootstrap/                    # App initialization and configuration
│   ├── Navigation/                   # Router and navigation structure
│   └── AppDelegate.swift
│
├── Features/                         # Feature modules (organized by domain)
│   ├── Account/                      # User account management
│   ├── Authentication/               # Login, registration flows
│   ├── Betslip/                      # Bet management
│   ├── Cashback/                     # Cashback feature
│   ├── Events/                       # Sports events (Live, Pre-live, etc.)
│   ├── Home/                         # Main home screen
│   ├── Markets/                      # Betting markets
│   ├── MyBets/                       # User's betting history
│   ├── Promotions/                   # Promotional content
│   ├── Referrals/                    # Referral program
│   ├── Search/                       # Search functionality
│   ├── Settings/                     # User settings
│   └── SocialSharing/                # Social sharing features
│
├── Core/                             # Core infrastructure and utilities
│   ├── Analytics/                    # Analytics implementation
│   ├── Constants/                    # App-wide constants
│   ├── Extensions/                   # Swift extensions
│   ├── Localization/                 # Localization support
│   ├── Networking/                   # Network layer components
│   │   ├── APIClient/                # Base API client
│   │   ├── Providers/                # Service providers implementation
│   │   └── SocketClient/             # Socket communication
│   ├── Persistence/                  # Local storage
│   ├── Security/                     # Security related code
│   └── Utilities/                    # Helper utilities
│
├── Domain/                           # Domain models and business logic
│   ├── Models/                       # Core app models
│   ├── Repositories/                 # Data access layer
│   ├── Services/                     # Domain services
│   └── UseCases/                     # Business logic use cases
│
├── UI/                               # Reusable UI components
│   ├── Components/                   # Basic UI components
│   │   ├── Buttons/
│   │   ├── Cards/
│   │   ├── Forms/
│   │   └── etc...
│   ├── Styles/                       # Styling resources
│   │   ├── Colors/
│   │   ├── Fonts/
│   │   └── Themes/
│   ├── Resources/                    # Visual assets
│   │   ├── Animations/
│   │   ├── Icons/
│   │   └── Images/
│   └── DesignSystem/                 # UI design system components
│
├── Clients/                          # White-label client configurations
│   ├── Base/                         # Shared client functionality
│   ├── ATP/
│   ├── Betsson/
│   ├── DAZN/
│   └── etc...
│
├── Tests/                            # Test code
│   ├── Unit/                         # Unit tests organized by module
│   ├── Integration/                  # Integration tests
│   └── UITests/                      # UI tests
│
├── Tools/                            # Developer tools and scripts
│   ├── CodeGeneration/
│   ├── BuildScripts/
│   └── Utilities/
│
└── Documentation/                    # Project documentation
    ├── Architecture/
    ├── Guides/
    └── APIReferences/
```

## Key Improvements

### 1. Feature-Based Organization

- Group code by domain features rather than technical layers
- Makes feature boundaries clearer
- Easier for new developers to find relevant code
- Simplifies feature additions and removals

### 2. Clear Separation of Concerns

- Distinct Core, Domain, UI, and Features sections
- Better separation between business logic and presentation
- Reduces cognitive load when working on specific areas

### 3. Modular Structure

- Each module has a clear responsibility
- Reduces dependencies between modules
- Enables potential future migration to Swift packages
- Improves testability

### 4. Simplified Client Customization

- Client customizations isolated in dedicated directory
- Common components extracted to shared base client
- Reduced duplication across white-label implementations

### 5. Consistent Naming

- Consistent naming conventions throughout the codebase
- Improves searchability and discoverability
- Clear naming pattern for similar components across features

### 6. Centralized Resources

- Consolidates similar resources (styles, assets)
- Prevents duplication of common UI elements
- Easier to maintain consistent styling

### 7. Improved Test Organization

- Tests organized to mirror the main structure
- Makes it easier to find and maintain tests
- Clearer separation between test types

## Implementation Strategy

1. **Incremental migration** - Move code in phases rather than all at once
2. **Start with Core modules** - Begin with infrastructure pieces that other code depends on
3. **Feature by feature** - Migrate one feature at a time to minimize disruption
4. **Update build configuration** - Adjust project files to reflect new structure
5. **Documentation** - Document the new structure and migration process
6. **Automated tests** - Ensure tests pass after each migration step

## Benefits

- **Improved developer experience** - Easier to find, understand, and modify code
- **Faster onboarding** - New team members can understand the project structure more quickly
- **Better maintainability** - Clearer boundaries make the codebase more maintainable
- **Reduced technical debt** - Properly organized code prevents future organizational issues
- **Simplified future refactoring** - Modular structure makes it easier to refactor specific areas
- **Enhanced collaboration** - Team members can work on separate features with minimal conflicts

## Next Steps

1. Review this proposal with the team
2. Create a detailed migration plan with timeline
3. Set up CI checks to ensure the new structure is maintained
4. Document coding standards that align with the new structure
5. Begin implementation with highest-priority modules