# GomaUI Localization Guidelines

This document defines the responsibility boundaries for string localization between GomaUI components and consuming applications.

## Core Principle

**GomaUI components are localization-agnostic.** They define which keys they need for internal UI labels, but the consuming app provides all translations. This enables white-label flexibility where different apps can provide their own translations or terminology.

---

## The LocalizationProvider Bridge

GomaUI uses `LocalizationProvider` as a bridge to the consuming app's localization system:

```
┌─────────────────┐         ┌──────────────────────┐         ┌─────────────────────┐
│    GomaUI       │         │ LocalizationProvider │         │   Consuming App     │
│   Component     │────────▶│      (Bridge)        │────────▶│  Localizable.strings│
│                 │  key    │                      │  key    │                     │
│ "total_odds"    │         │   .string(key)       │         │ "total_odds" = "..." │
└─────────────────┘         └──────────────────────┘         └─────────────────────┘
```

### How It Works

1. **App configures the bridge at startup:**
```swift
// BetssonCameroonApp
LocalizationProvider.configure { key in
    return NSLocalizedString(key, bundle: .main, comment: "")
}
```

2. **GomaUI components request strings by key:**
```swift
// Inside GomaUI component
totalOddsLabel.text = LocalizationProvider.string("total_odds")
```

3. **App's Localizable.strings provides the translation:**
```
// BetssonCameroonApp/en.lproj/Localizable.strings
"total_odds" = "Total Odds";

// BetssonCameroonApp/fr.lproj/Localizable.strings
"total_odds" = "Cotes Totales";
```

### White-Label Flexibility

Different apps can provide different translations for the same keys:

| Key | BetssonCameroonApp | BetssonFranceApp | Future Casino App |
|-----|-------------------|------------------|-------------------|
| `bet_amount` | "Bet Amount" | "Mise" | "Stake" |
| `total_odds` | "Total Odds" | "Cote Totale" | "Combined Odds" |
| `place_bet` | "Place Bet" | "Placer le Pari" | "Confirm Wager" |

---

## String Categories

### Category 1: Dynamic Data

**Who defines keys:** N/A - no keys involved
**Who provides strings:** App (via ViewModel)

Content from APIs, user data, or business logic. These strings bypass LocalizationProvider entirely - the app provides fully-formed, localized strings directly to ViewModels.

**Examples:** Team names, market names, odds values, user balance, match dates

**Pattern:**
```swift
// App-side: Localize/format data, pass to ViewModel
let viewModel = MatchCardViewModel(
    homeTeam: match.homeTeam.localizedName,  // Already localized
    awayTeam: match.awayTeam.localizedName,
    startTime: dateFormatter.string(from: match.startTime)
)

// GomaUI component: Simply display
homeTeamLabel.text = viewModel.homeTeam  // No LocalizationProvider
```

---

### Category 2: Component UI Chrome

**Who defines keys:** GomaUI
**Who provides translations:** App (via Localizable.strings)

Fixed labels that are part of the component's visual structure. GomaUI defines which keys it uses; the consuming app provides translations.

**Examples:** "Total Odds:", "Bet Amount:", "Your Selection", "Expires:"

**Pattern:**
```swift
// GomaUI component defines the key it needs
totalOddsLabel.text = LocalizationProvider.string("total_odds")
betAmountLabel.text = LocalizationProvider.string("bet_amount")

// App's Localizable.strings provides translation
// "total_odds" = "Total Odds";
// "bet_amount" = "Bet Amount";
```

**Identifying UI Chrome:** Ask "Is this label part of the component's structure?"
- "Total Odds:" → Yes, structural label (GomaUI defines key)
- "1.85" → No, dynamic content (App provides directly)

---

### Category 3: Customizable Actions

**Who defines keys:** App (or GomaUI for defaults)
**Who provides translations:** App

Button text and action labels that vary by context. The app controls what text appears because the same component can be used differently across screens.

**Examples:** "Login", "Register", "Place Bet", "Clear Betslip"

**Pattern:**
```swift
// App-side: Provide localized button text
let buttonVM = ButtonViewModel(
    title: localized("place_bet"),  // App's key, app's translation
    style: .primary
)

// GomaUI component: Display what it receives
button.setTitle(viewModel.title, for: .normal)
```

**Why app owns this:** The same `ButtonView` might display "Login" on auth screen, "Place Bet" on betslip, or "Confirm" on a dialog. Context determines the text.

---

### Category 4: Generic Fallbacks

**Who defines keys:** GomaUI
**Who provides translations:** App

Default text when the app doesn't provide specific content. GomaUI defines fallback keys; the app provides translations. App can always override with specific content.

**Examples:** Empty states, loading indicators, generic errors

**Pattern:**
```swift
// GomaUI component: Use app-provided value or fall back to key
let message = viewModel.emptyStateMessage
    ?? LocalizationProvider.string("no_results")

// App's Localizable.strings provides fallback translation
// "no_results" = "No results found";

// App can override with specific message
let viewModel = EmptyStateViewModel(
    emptyStateMessage: localized("no_matches_for_sport")  // Specific override
)
```

---

## Decision Tree

```
Is this string...?
│
├─ Content from API/business logic?
│  (team names, odds, user data, dates)
│  └─> APP provides directly via ViewModel (no LocalizationProvider)
│
├─ Fixed label defining component structure?
│  ("Total:", "Expires:", "Your Selection")
│  └─> GOMAUI defines key, APP provides translation
│
├─ Button/action text that varies by context?
│  ("Login", "Place Bet", "Cancel")
│  └─> APP defines key and provides translation via ViewModel
│
└─ Default text when no specific content provided?
   (empty states, loading, generic errors)
   └─> GOMAUI defines key, APP provides translation
       (App can override with specific content)
```

---

## String Interpolation

### App Handles Complex Interpolation
When business logic is involved:

```swift
// App-side: Build the string, pass final result
let message = localized("add_more_legs")
    .replacingOccurrences(of: "{count}", with: "\(remaining)")
    .replacingOccurrences(of: "{minOdds}", with: formattedOdds)

viewModel.update(message: message)
```

### GomaUI Handles Simple Interpolation
When it's just inserting a value:

```swift
// GomaUI component: Simple count insertion
let text = LocalizationProvider.string("load_more_count")
    .replacingOccurrences(of: "{count}", with: "\(count)")
```

---

## App Responsibilities

### 1. Configure LocalizationProvider at Startup

```swift
// AppDelegate or AppStateManager
func setupGomaUI() {
    LocalizationProvider.configure { key in
        return NSLocalizedString(key, bundle: .main, comment: "")
    }
}
```

### 2. Provide Translations for GomaUI Keys

Apps must include translations for keys that GomaUI components use. If a key is missing, `LocalizationProvider` returns the key itself as fallback.

### 3. Provide Pre-Localized Dynamic Content

```swift
// App localizes content before passing to ViewModel
let matchCard = MatchCardViewModel(
    homeTeam: localizedTeamName(match.homeTeam),
    marketName: localizedMarketName(market),
    formattedOdds: oddsFormatter.format(odds)
)
```

---

## GomaUI Component Responsibilities

### 1. Define Keys for UI Chrome

```swift
// Component defines what keys it needs
private func setupLabels() {
    totalLabel.text = LocalizationProvider.string("total_odds")
    stakeLabel.text = LocalizationProvider.string("bet_amount")
}
```

### 2. Document Required Keys

Each component should document which keys it uses so apps know what translations to provide.

### 3. Provide Fallback Behavior

```swift
// Allow app override, fall back to generic key
let message = viewModel.customMessage
    ?? LocalizationProvider.string("default_empty_state")
```

### 4. Never Hardcode User-Facing Strings

```swift
// WRONG
label.text = "No results found"

// CORRECT
label.text = LocalizationProvider.string("no_results")
```

---

## Keys Used by GomaUI Components

GomaUI components use the following keys. Apps should provide translations for these:

### Navigation & Actions
| Key | Typical Translation | Used By |
|-----|---------------------|---------|
| `back` | "Back" | SimpleNavigationBarView |
| `cancel` | "Cancel" | Various dialogs |
| `close` | "Close" | Modal components |
| `see_more` | "See More" | SeeMoreButtonView |

### Betslip Components
| Key | Typical Translation | Used By |
|-----|---------------------|---------|
| `total_odds` | "Total Odds" | TicketBetInfoView |
| `bet_amount` | "Bet Amount" | TicketBetInfoView |
| `potential_winnings` | "Potential Winnings" | TicketBetInfoView |
| `your_selection` | "Your Selection" | BetslipTicketView |

### States & Fallbacks
| Key | Typical Translation | Used By |
|-----|---------------------|---------|
| `loading` | "Loading..." | Various components |
| `no_results` | "No results" | Empty state fallbacks |
| `no_market_groups_available` | "No markets available" | MarketGroupSelectorTabView |

### Bonus Components
| Key | Typical Translation | Used By |
|-----|---------------------|---------|
| `expires` | "Expires" | BonusInfoCardView |
| `bonus_amount` | "Bonus Amount" | BonusInfoCardView |
| `wagering_progress` | "Wagering Progress" | BonusInfoCardView |

---

## Common Mistakes

### Mistake 1: Hardcoding strings in GomaUI
```swift
// WRONG
emptyLabel.text = "No results found"

// CORRECT
emptyLabel.text = LocalizationProvider.string("no_results")
```

### Mistake 2: GomaUI localizing dynamic content
```swift
// WRONG - Component shouldn't touch content localization
teamLabel.text = LocalizationProvider.string(match.homeTeamId)

// CORRECT - App provides pre-localized content
teamLabel.text = viewModel.homeTeamName
```

### Mistake 3: App re-providing UI chrome strings
```swift
// WRONG - App shouldn't need to provide structural labels
let data = BetslipData(
    totalOddsLabel: localized("total_odds"),  // Unnecessary
    totalOddsValue: "3.45"
)

// CORRECT - GomaUI handles its own labels
let data = BetslipData(
    totalOddsValue: "3.45"
)
```

---

## Summary

| Category | GomaUI Role | App Role |
|----------|-------------|----------|
| Dynamic Data | Display only | Provide localized string via ViewModel |
| UI Chrome | Define keys, call LocalizationProvider | Provide translations in Localizable.strings |
| Actions | Display only | Define keys, provide translations, pass via ViewModel |
| Fallbacks | Define keys, call LocalizationProvider | Provide translations, optionally override |

**The key insight:** GomaUI is a library that multiple apps can consume. By using `LocalizationProvider` as a bridge, each app controls its own translations while GomaUI components remain reusable across all of them.
