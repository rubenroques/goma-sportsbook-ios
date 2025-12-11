## Date
11 December 2025

### Project / Branch
bet-at-home / rr/bet-at-home

### Goals for this session
- Fix profile screen menu icons showing wrong color (orange instead of bet-at-home green)

### Achievements
- [x] Identified root cause: PNG icons have pre-baked orange color and don't respect tintColor
- [x] Applied `.withRenderingMode(.alwaysTemplate)` to bundle images in ActionRowView
- [x] Single-line fix in GomaUI that handles all profile menu icons

### Issues / Bugs Hit
- None

### Key Decisions
- Chose programmatic `.alwaysTemplate` approach over modifying 10+ asset catalog JSON files
- Fix applied at GomaUI component level for automatic handling of future icons

### Experiments & Notes
- Asset catalog `Contents.json` can also use `"template-rendering-intent": "template"` but requires per-asset configuration
- System images (SF Symbols) already render as templates by default, only bundle images needed the fix

### Useful Files / Links
- [ActionRowView.swift](../../Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/ActionRowView/ActionRowView.swift) - Line 82

### Next Steps
1. Test profile screen in bet-at-home build to verify icons now show lime green (#73bd1c)
2. Check if other screens using ActionRowView also benefit from this fix
