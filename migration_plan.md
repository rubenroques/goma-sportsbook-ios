Now I have the full picture. Let me map this out:

  BetssonCameroonApp Anatomy

  400 Swift files total

  STAYS IN THIN CLIENT (client-specific):          MOVES TO GomaPlatform:
  ─────────────────────────────────────            ──────────────────────
  ├── Boot/                                        ├── Screens/ (~30 screens)
  │   ├── Environment.swift                        │   ├── Banking/
  │   ├── DependenciesBootstrapper.swift           │   ├── Betslip/
  │   ├── Bootstrap.swift                          │   ├── Bonus/
  │   ├── Router.swift                             │   ├── Casino/
  │   └── AppStateManager.swift                    │   ├── CasinoSearch/
  │                                                │   ├── FirstDepositPromotions/
  ├── Coordinators/ (23 coordinators)              │   ├── InPlayEvents/
  │   ├── AppCoordinator.swift                     │   ├── LanguageSelector/
  │   ├── MainTabBarCoordinator.swift              │   ├── MainTabBar/
  │   ├── BetslipCoordinator.swift                 │   ├── Maintenance/
  │   ├── CasinoCoordinator.swift                  │   ├── MatchDetailsTextual/
  │   ├── BankingCoordinator.swift                 │   ├── MyBets/
  │   └── ... (18 more)                            │   ├── NextUpEvents/
  │                                                │   ├── Notifications/
  ├── Resources/                                   │   ├── PhoneLogin/
  │   ├── Assets/Media.xcassets                    │   ├── ProfileWallet/
  │   ├── Theme/                                   │   ├── Promotions/
  │   ├── Fonts/                                   │   ├── RecoverPassword/
  │   └── Language/ (en, fr)                       │   ├── Register/
  │                                                │   ├── ResponsibleGaming/
  └── Config files                                 │   ├── Splash/
      ├── Info.plist                               │   ├── SportsSearch/
      ├── GoogleService-Info.plist                 │   ├── TransactionHistory/
      ├── Debug.xcconfig                           │   └── VersionUpdate/
      └── *.entitlements                           │
                                                   ├── ViewModels/ (component VMs)
                                                   │   ├── TallOddsMatchCard/
                                                   │   ├── Banners/
                                                   │   ├── Casino/
                                                   │   └── ...
                                                   │
                                                   └── Tools/ → Extensions package
                                                       ├── Extensions/
                                                       ├── Functional/
                                                       ├── PreviewsHelper/
                                                       └── MiscHelpers/

  Christmas Sprint Plan (Solo)

  Given ~2 weeks of code freeze, here's a realistic breakdown:

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ DAY 1-2: INFRASTRUCTURE SETUP                                           │
  ├─────────────────────────────────────────────────────────────────────────┤
  │                                                                         │
  │ □ Create folder structure:                                              │
  │   └── Frameworks/GomaPlatform/                                          │
  │       ├── Package.swift                                                 │
  │       ├── Sources/GomaPlatform/                                         │
  │       └── Tests/GomaPlatformTests/                                      │
  │                                                                         │
  │ □ Create Apps/ folder structure:                                        │
  │   └── Apps/                                                             │
  │       └── BetssonCameroon/ (will be thin app later)                     │
  │                                                                         │
  │ □ Rename BetssonFranceApp → Legacy/BetssonFranceLegacy                  │
  │   (git mv, update workspace references)                                 │
  │                                                                         │
  │ □ Update Sportsbook.xcworkspace to include GomaPlatform                 │
  │                                                                         │
  │ □ Verify builds still work                                              │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘
                                      ↓
  ┌─────────────────────────────────────────────────────────────────────────┐
  │ DAY 3-4: FIRST EXTRACTION (Proof of Concept)                            │
  ├─────────────────────────────────────────────────────────────────────────┤
  │                                                                         │
  │ Pick a "leaf" screen with minimal dependencies:                         │
  │                                                                         │
  │ Candidates (ordered by isolation):                                      │
  │   1. LanguageSelector/ ← simplest, self-contained                       │
  │   2. Maintenance/                                                       │
  │   3. VersionUpdate/                                                     │
  │   4. Notifications/                                                     │
  │                                                                         │
  │ □ Move LanguageSelector VC + VM to GomaPlatform                         │
  │ □ Define FlowDelegate protocol for coordinator communication            │
  │ □ BetssonCameroonApp imports GomaPlatform, still builds                 │
  │ □ LanguageSelectorCoordinator uses imported screen                      │
  │ □ Test runtime - app still works                                        │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘
                                      ↓
  ┌─────────────────────────────────────────────────────────────────────────┐
  │ DAY 5-6: TOOLS EXTRACTION                                               │
  ├─────────────────────────────────────────────────────────────────────────┤
  │                                                                         │
  │ Move shared utilities to GomaPlatform (or Extensions package):          │
  │                                                                         │
  │ □ Tools/Extensions/* → GomaPlatform/Sources/Extensions/                 │
  │ □ Tools/Functional/* → GomaPlatform/Sources/Utilities/                  │
  │ □ Tools/PreviewsHelper/* → GomaPlatform/Sources/PreviewSupport/         │
  │ □ Tools/MiscHelpers/* → GomaPlatform/Sources/Utilities/                 │
  │                                                                         │
  │ These are used by screens, so extract first.                            │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘
                                      ↓
  ┌─────────────────────────────────────────────────────────────────────────┐
  │ DAY 7-10: SCREEN EXTRACTIONS (Core Screens)                             │
  ├─────────────────────────────────────────────────────────────────────────┤
  │                                                                         │
  │ Work through screens in dependency order:                               │
  │                                                                         │
  │ Batch 1 (simpler, less dependencies):                                   │
  │ □ Splash/                                                               │
  │ □ ProfileWallet/                                                        │
  │ □ TransactionHistory/                                                   │
  │ □ Bonus/                                                                │
  │ □ Promotions/                                                           │
  │                                                                         │
  │ Batch 2 (medium complexity):                                            │
  │ □ PhoneLogin/                                                           │
  │ □ Register/                                                             │
  │ □ RecoverPassword/                                                      │
  │ □ ResponsibleGaming/                                                    │
  │                                                                         │
  │ Batch 3 (core betting features):                                        │
  │ □ InPlayEvents/                                                         │
  │ □ NextUpEvents/                                                         │
  │ □ MatchDetailsTextual/                                                  │
  │ □ SportsSearch/                                                         │
  │                                                                         │
  │ Batch 4 (complex):                                                      │
  │ □ Betslip/                                                              │
  │ □ MyBets/                                                               │
  │ □ Banking/                                                              │
  │                                                                         │
  │ Batch 5 (casino):                                                       │
  │ □ Casino/                                                               │
  │ □ CasinoSearch/                                                         │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘
                                      ↓
  ┌─────────────────────────────────────────────────────────────────────────┐
  │ DAY 11-12: VIEWMODELS + MAIN TAB BAR                                    │
  ├─────────────────────────────────────────────────────────────────────────┤
  │                                                                         │
  │ □ ViewModels/ (component VMs that wire to GomaUI)                       │
  │   ├── TallOddsMatchCard/                                                │
  │   ├── Banners/                                                          │
  │   ├── Casino/                                                           │
  │   └── ... all component VMs                                             │
  │                                                                         │
  │ □ MainTabBar/ (the root navigation)                                     │
  │ □ FirstDepositPromotions/                                               │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘
                                      ↓
  ┌─────────────────────────────────────────────────────────────────────────┐
  │ DAY 13-14: THIN APP RESTRUCTURE + CLONE                                 │
  ├─────────────────────────────────────────────────────────────────────────┤
  │                                                                         │
  │ □ BetssonCameroonApp is now thin:                                       │
  │   └── Only Boot/, Coordinators/, Resources/, Config                     │
  │                                                                         │
  │ □ Move to Apps/BetssonCameroon/                                         │
  │                                                                         │
  │ □ Create Apps/BetssonFrance/ (clone structure)                          │
  │   ├── Copy Boot/, Coordinators/                                         │
  │   ├── New Resources/ (France theme, assets)                             │
  │   ├── Adjust coordinators for France flows                              │
  │   └── France-specific configs                                           │
  │                                                                         │
  │ □ (Stretch goal) Create Apps/BetAtHome/                                 │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘

  GomaPlatform Package.swift (Starting Point)

  // swift-tools-version: 5.9
  import PackageDescription

  let package = Package(
      name: "GomaPlatform",
      platforms: [.iOS(.v15)],
      products: [
          .library(name: "GomaPlatform", targets: ["GomaPlatform"]),
      ],
      dependencies: [
          .package(path: "../GomaUI"),
          .package(path: "../ServicesProvider"),
          .package(path: "../Extensions"),
      ],
      targets: [
          .target(
              name: "GomaPlatform",
              dependencies: [
                  "GomaUI",
                  "ServicesProvider",
                  "Extensions",
              ],
              path: "Sources/GomaPlatform"
          ),
          .testTarget(
              name: "GomaPlatformTests",
              dependencies: ["GomaPlatform"]
          ),
      ]
  )

  FlowDelegate Pattern (The Glue)

  Every screen exports a delegate protocol. Coordinators implement it:

  // In GomaPlatform/Sources/Screens/PhoneLogin/
  public protocol PhoneLoginFlowDelegate: AnyObject {
      func phoneLoginDidComplete(user: User)
      func phoneLoginDidTapRegister()
      func phoneLoginDidTapForgotPassword()
  }

  public final class PhoneLoginViewController: UIViewController {
      public weak var flowDelegate: PhoneLoginFlowDelegate?

      // ... implementation
  }

  // In BetssonCameroon/Coordinators/
  final class PhoneLoginCoordinator: Coordinator, PhoneLoginFlowDelegate {
      func phoneLoginDidComplete(user: User) {
          // Navigate to home
      }

      func phoneLoginDidTapRegister() {
          // Show register coordinator
      }

      func phoneLoginDidTapForgotPassword() {
          // Show password recovery
      }
  }

  Realistic Expectations

  Given solo effort during holidays:

  | Goal                                        | Likelihood | Notes                              |
  |---------------------------------------------|------------|------------------------------------|
  | Infrastructure setup (Day 1-2)              | ✅ High     | Mechanical, low risk               |
  | First extraction proof of concept (Day 3-4) | ✅ High     | Validates the pattern              |
  | Tools extraction (Day 5-6)                  | ✅ High     | Straightforward moves              |
  | All screen extractions (Day 7-12)           | ⚠️ Medium  | May run long, dependency surprises |
  | Thin app restructure (Day 13)               | ⚠️ Medium  | Depends on extraction progress     |
  | BetssonFrance clone (Day 14)                | ⚠️ Stretch | Nice to have, can be post-freeze   |

  Checkpoint strategy: After Day 6, you'll have a working pattern and can continue incrementally even after code freeze ends.

  ---
  Want me to:
  1. Start drafting the Package.swift and folder structure now?
  2. Audit a specific screen (like LanguageSelector) to see what the first extraction would look like?
  3. Map the coordinator-to-screen dependencies to identify the safest extraction order?
