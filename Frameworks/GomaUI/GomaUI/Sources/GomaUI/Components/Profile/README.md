# Profile Components

This folder contains UI components for user profile, settings, and preferences.

## Components

| Component | Description |
|-----------|-------------|
| `ProfileMenuListView` | Interactive profile menu with navigation actions and selections |
| `ThemeSwitcherView` | Theme switcher with Light/System/Dark options |
| `LanguageSelectorView` | Language picker with radio buttons and flag icons |
| `UserLimitCardView` | User betting/deposit limits card display |
| `ShareChannelsGridView` | Grid of sharing channel options |

## Usage

These components are used in:
- Profile/Account screens
- Settings screens
- Preferences modals
- Sharing dialogs

## Architecture

All components follow GomaUI's standard MVVM pattern with protocol-driven ViewModels, mock implementations, and Combine-based reactive bindings.
