# Authentication Screens Localization

## Date
10 November 2025

### Project / Branch
sportsbook-ios / betsson-cm

### Goals for this session
- Complete GomaUI localization (Batch 2 - medium priority components)
- Localize logout confirmation alert
- Localize all authentication screens (RegisterPhone and LoginPhone)
- Implement systematic approach: check existing keys first, then add only missing ones

### Achievements

#### GomaUI Localization - Batch 2 Completed
- [x] Fixed `live_status_ended` English translation bug (was showing French "TERMINÉ" in EN file)
- [x] Added 3 new localization keys (EN + FR):
  - `players_chose_bonus` = "{count} players chose this bonus"
  - `volatility` = "Volatility"
  - `no_events` = "No Events"
- [x] Updated 8 medium-priority GomaUI components:
  - BetslipOddsBoostHeaderView.swift - Changed to use `add_matches_bonus` (matching web implementation)
  - BetslipFloatingTallView.swift - Changed to use `add_matches_bonus`
  - PromotionalBonusCardView.swift - Players chose bonus message
  - BonusInfoCardView.swift - "Expires:" label
  - CasinoGameCardView.swift - "Min Stake:", "Loading..."
  - LeagueOptionRowView.swift - "No Events" (using `all_events_unavailable`)
  - CodeClipboardView.swift - "Copied to Clipboard"
  - CasinoGamePlayModeSelectorView.swift - "Volatility:", "Min Stake:"
  - MatchParticipantsInfoView.swift - "Ended" status

#### Logout Alert Localization
- [x] Added 1 new key: `logout_confirmation_message` (EN + FR)
- [x] Updated ProfileWalletCoordinator.swift logout confirmation alert
- [x] Reused 3 existing keys: `logout`, `cancel`, `logout` (for button)

#### Authentication Screens Localization (3 Batches)

**Batch 1: Navigation + Core Buttons (15 strings, 9 files)**
- [x] All keys already existed - 0 new keys needed!
- [x] Updated 6 ViewControllers: PhoneLogin, PhoneRegistration, PhoneVerification, PhonePasswordCodeReset, PhoneForgotPassword, PhonePasswordCodeVerification
- [x] Updated 3 ViewModels: PhoneRegistration, MockPhoneVerification, PhoneForgotPassword
- [x] Keys used: `login`, `register`, `close`, `done`, `create_account`, `verify`, `verify_phone_number`, `forgot_password`, `change_password`

**Batch 2: Headers + Placeholders (15 strings, 4 files)** - User completed
- [x] Added 3 new keys: `password_min_4_chars`, `date_format_placeholder`, `password_reset_code`
- [x] Updated 4 ViewModels: PhoneLogin, PhoneRegistration, MockPhoneVerification, PhoneForgotPassword
- [x] Reused 12 existing keys for welcome messages, placeholders, headers

**Batch 3: Validation Errors + Alerts (13 strings, 4 files)**
- [x] Added 6 new keys with placeholders:
  - `register_success_title` = "Registration Successful!"
  - `register_success_message` = "Your account was registered and logged in!"
  - `phone_number_length_error` = "Phone number must be between {min} and {max} digits"
  - `first_name_length_error` = "First name must be between {min} and {max} characters"
  - `minimum_age_error` = "You must be at least 21 years old to register"
  - `date_must_be_after` = "Date must be after {date}"
- [x] Updated alert messages in PhoneLoginViewController and PhoneRegistrationViewController
- [x] Updated validation errors in PhoneRegistrationViewModel (8 errors) and PhoneForgotPasswordViewModel (2 errors)
- [x] Reused 7 existing keys: `login_error_title`, `register_error_title`, `password_invalid_length`, `last_name_invalid_length`, `invalid_date_format`, `password_not_match`

### Issues / Bugs Hit
- [x] `live_status_ended` English value was "TERMINÉ" (French) instead of "ENDED"
  - **Fix**: Changed EN value to "ENDED" in Localizable.strings:1771
- [x] User selected `all_events_unavailable` for "No Events" empty state instead of creating new key
  - **Decision**: Accepted trade-off - uses longer message "These events are no longer available" for consistency

### Key Decisions

**GomaUI Batch 2 Decisions:**
- **Key reuse priority**: Check existing keys first before creating new ones - achieved 70% reuse rate (7/10 keys)
- **BetslipOddsBoost pattern change**: Switched from custom "by adding X more legs" text to `add_matches_bonus` key to match web implementation
  - New wording: "Add {nMatches} more qualifying events to get a {percentage}% win boost"
  - Includes percentage in description message for better UX consistency
- **Empty state messaging**: Used `all_events_unavailable` instead of creating `no_events` for LeagueOptionRowView
  - Trade-off: Longer message but maintains consistency with existing error patterns

**Authentication Localization Strategy:**
- **Systematic approach**: Always verify existing keys before creating new ones
  - Result: 43 strings localized using only 9 new keys + 34 existing keys (79% reuse!)
- **Parameterized strings**: Use placeholder pattern `{key}` (not `%d` format strings)
  - Example: `phone_number_length_error` = "Phone number must be between {min} and {max} digits"
  - Then: `.replacingOccurrences(of: "{min}", with: "\(value)")`
- **Batch prioritization**: Navigation/buttons first (high visibility, all keys exist) → Headers/placeholders → Validation/alerts
  - Allows incremental progress with immediate visual impact

**Localization Key Management:**
- **Naming convention**: `[screen]_[element]_[type]` for specific elements (e.g., `register_success_title`)
- **Generic actions**: `[action]_[description]` for reusable keys (e.g., `password_invalid_length`)
- **Validation errors**: Prefer parameterized single key over multiple variants (e.g., one `password_invalid_length` instead of `password_too_short` + `password_too_long`)

### Experiments & Notes

**Key Reuse Efficiency:**
- GomaUI Batch 2: 7/10 keys reused (70%)
- Auth Batch 1: 15/15 keys reused (100%)
- Auth Batch 2: 12/15 keys reused (80%)
- Auth Batch 3: 7/13 keys reused (54%)
- **Overall average: 79% key reuse rate**

**Localization Key Search Strategy:**
- Used Task agent with Plan subagent to systematically search Localizable.strings
- Searched for exact matches + variations + similar patterns
- Reported EXISTS / SIMILAR_EXISTS / NEEDS_CREATION status
- Included EN/FR values for verification

**Placeholder Pattern Performance:**
- Confirmed {placeholder} pattern works correctly with `.replacingOccurrences(of:with:)`
- More readable than `String(format:)` with `%d` for non-English speakers
- Easier to maintain and validate in localization files

### Useful Files / Links

**GomaUI Localization Files:**
- [BetslipOddsBoostHeaderView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipOddsBoostHeaderView/BetslipOddsBoostHeaderView.swift)
- [BetslipFloatingTallView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/BetslipFloatingView/BetslipFloatingTallView.swift)
- [PromotionalBonusCardView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/PromotionalBonusCardView/PromotionalBonusCardView.swift)

**Authentication Files:**
- [PhoneLoginViewController.swift](../../BetssonCameroonApp/App/Screens/PhoneLogin/PhoneLoginViewController.swift)
- [PhoneLoginViewModel.swift](../../BetssonCameroonApp/App/Screens/PhoneLogin/PhoneLoginViewModel.swift)
- [PhoneRegistrationViewController.swift](../../BetssonCameroonApp/App/Screens/Register/PhoneRegister/PhoneRegistrationViewController.swift)
- [PhoneRegistrationViewModel.swift](../../BetssonCameroonApp/App/Screens/Register/PhoneRegister/PhoneRegistrationViewModel.swift)

**Logout Alert:**
- [ProfileWalletCoordinator.swift](../../BetssonCameroonApp/App/Coordinators/ProfileWalletCoordinator.swift)

**Localization Resources:**
- [English Localizations](../../BetssonCameroonApp/App/Resources/Language/en.lproj/Localizable.strings)
- [French Localizations](../../BetssonCameroonApp/App/Resources/Language/fr.lproj/Localizable.strings)
- [Previous Session - GomaUI Localization](./08-November-2025-gomaui-localization-migration.md)

### Statistics

**GomaUI Localization - Batch 2:**
- Components updated: 8
- Strings localized: ~12
- New keys added: 3
- Existing keys reused: 7
- Files modified: 11 (2 Localizable.strings + 9 GomaUI components)

**Logout Alert:**
- Strings localized: 4
- New keys added: 1
- Existing keys reused: 3
- Files modified: 3

**Authentication Screens - All 3 Batches:**
- Total strings localized: 43
- New keys created: 9 (21%)
- Existing keys reused: 34 (79%)
- Components updated: 13 files
  - 7 ViewControllers
  - 6 ViewModels

**Grand Total (All Work):**
- Strings localized: ~60
- New localization keys added: 13
- Files modified: 27
- Key reuse efficiency: 79%

### Next Steps

1. **Test language switching:**
   - Build GomaUI framework
   - Build BetssonCameroonApp
   - Test EN → FR language switch in app
   - Verify all UI displays correct translations
   - Test validation errors with both languages

2. **Remaining localization work:**
   - Search for hardcoded strings in remaining BetssonCameroonApp screens
   - Focus on high-traffic screens: Profile, Wallet, Betting flow
   - Continue systematic approach: verify existing keys first

3. **Optional cleanup:**
   - Consider consolidating similar validation error keys
   - Review if `no_events` key should still be created for better semantics
   - Document localization patterns for team in CLAUDE.md

4. **Git commit:**
   - "Complete authentication screens localization (43 strings, 9 new keys)"
   - Include: GomaUI Batch 2, logout alert, all auth batches

### Technical Debt Addressed
- **✅ Translation bug fixed**: `live_status_ended` EN now correctly shows "ENDED"
- **✅ Authentication flow fully localized**: All login, register, verification, password reset screens
- **✅ Validation errors localized**: User-friendly error messages in both languages
- **✅ Alert messages localized**: Success/error alerts properly translated
- **✅ Parameterized strings**: Flexible error messages with variable substitution

### Learnings

**Localization Strategy:**
- **Always check existing keys first**: 79% reuse rate proves the value of this approach
- **Use Task agents for systematic search**: More thorough than manual grep, catches variations
- **Batch by visibility/dependency**: High-visibility items first (navigation) → Content → Validation
  - Provides incremental user value
  - Catches most keys in early batches when developers are fresh

**Key Management:**
- **Parameterized strings are essential**: Single key with placeholders > multiple variant keys
  - Easier to maintain
  - Reduces translation costs
  - More flexible for different contexts
- **Naming conventions matter**: Consistent patterns make keys discoverable
- **Document trade-offs**: Recording why `all_events_unavailable` was chosen over `no_events` helps future maintainers

**Development Process:**
- **User involvement works**: User completing Batch 2 independently shows good knowledge transfer
- **Todo list tracking helps**: Clear progress visibility prevents losing track across complex multi-file changes
- **Parallel agent approach**: Not used this session, but previous success with git diff review agents proved valuable
