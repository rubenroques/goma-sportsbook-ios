## Date
23 December 2025

### Project / Branch
sportsbook-ios / rr/new_match_card_ui

### Goals for this session
- Make Xcode builds fail if SwiftLint is not installed
- Consolidate SwiftLint configuration to a single root-level config
- Fix SwiftLint rule contradictions and enable complexity rules

### Achievements
- [x] Created global `.swiftlint.yml` at workspace root
- [x] Added SwiftLint build phase to BetssonCameroonApp (fails build if not installed)
- [x] Updated all SwiftLint build phases in BetssonFranceLegacy (10 targets) to fail if not installed
- [x] Deleted project-level configs (`BetssonCameroonApp/.swiftlint.yml`, `BetssonFranceLegacy/.swiftlint.yml`)
- [x] Fixed PATH issue for Homebrew - scripts now add `/opt/homebrew/bin` to PATH
- [x] Added `x`, `y` to identifier_name exclusions (standard coordinate names)
- [x] Excluded `ExternalLibs` folders from linting (third-party code)
- [x] Fixed force cast violation in `Date+Extension.swift`
- [x] Fixed line length violations in `UITapGestureRecognizer+Extensions.swift`

### Issues / Bugs Hit
- [x] SwiftLint not found during build - Xcode's shell environment doesn't include Homebrew paths by default
- [x] Complexity rules (`cyclomatic_complexity`, `function_body_length`) caused too many errors - disabled for now

### Key Decisions
- **Single global config** over project-specific configs with overrides (simpler maintenance)
- **Fail build** if SwiftLint not installed (was only warning before)
- **Disabled complexity rules** - too many violations in legacy code to fix immediately
- **Lenient thresholds** chosen: cyclomatic_complexity 15/25, function_body_length 60/150 (for future re-enablement)
- **Exclude ExternalLibs** - shouldn't lint third-party code

### Useful Files / Links
- [Root SwiftLint Config](../../.swiftlint.yml)
- [BetssonCameroonApp project.pbxproj](../../BetssonCameroonApp/BetssonCameroonApp.xcodeproj/project.pbxproj)
- [BetssonFranceLegacy project.pbxproj](../../BetssonFranceLegacy/BetssonFranceLegacy.xcodeproj/project.pbxproj)

### SwiftLint Configuration Summary

**Enabled Rules (opt-in):**
- `private_outlet`, `private_action` - IBOutlet/IBAction visibility
- `void_return`, `trailing_closure` - code style
- `empty_count`, `discouraged_direct_init` - best practices
- `duplicate_imports`, `redundant_optional_initialization` - cleanup
- `prohibited_super_call`, `overridden_super_call` - correctness

**Disabled Rules:**
- `cyclomatic_complexity`, `function_body_length` - too many legacy violations
- `type_body_length`, `file_length`, `nesting` - legacy code constraints
- `trailing_whitespace`, `trailing_comma`, `opening_brace` - formatting noise

**Excluded Paths:**
- `Carthage`, `Pods`, `.build`, `Frameworks`, `git-worktrees`
- `BetssonFranceLegacy/Core/Tools/ExternalLibs`
- `BetssonCameroonApp/App/Tools/ExternalLibs`

### Next Steps
1. Gradually refactor complex functions to re-enable `cyclomatic_complexity`
2. Consider SwiftLint SPM Plugin as alternative to system-installed SwiftLint
3. Add SwiftLint to CI pipeline to catch violations before merge
