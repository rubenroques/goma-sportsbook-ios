# Promotions Components

This folder contains all UI components related to promotions, bonuses, and CMS-driven promotional content.

## Component Categories

### Promotion Display Components
| Component | Description |
|-----------|-------------|
| `PromotionCardView` | Main promotion card with image, tag, title, description, and CTA |
| `PromotionItemView` | Pill-shaped category selector item |
| `PromotionSelectorBarView` | Horizontal scrollable category selector bar |
| `PromotionalHeaderView` | Icon + Title/Subtitle header for promotion sections |

### Bonus Components
| Component | Description |
|-----------|-------------|
| `PromotionalBonusCardView` | First deposit bonus card display |
| `PromotionalBonusCardsScrollView` | Scrollable container for bonus cards |
| `BonusCardView` | Bonus offer card with CTA and terms |
| `BonusInfoCardView` | Detailed bonus information with status |

### Banner Components
| Component | Description |
|-----------|-------------|
| `SingleButtonBannerView` | Full-width banner with message and action button |
| `TopBannerSliderView` | Horizontal slider for promotional banners |

### Content Blocks (subfolder)
The `ContentBlocks/` subfolder contains components for rendering CMS-driven rich content in promotion detail pages. See `ContentBlocks/README.md` for details.

## Component Hierarchy

```
PromotionSelectorBarView (composite)
└── PromotionItemView (leaf - items in selector)

PromotionalBonusCardsScrollView (composite)
└── PromotionalBonusCardView (leaf - bonus cards)

TopBannerSliderView (composite)
└── MatchBannerView, SingleButtonBannerView (leaf - banner items)
```

## Usage

These components are primarily used by:
- `PromotionsViewController` - Main promotions list screen
- `PromotionDetailViewController` - Promotion detail page (uses ContentBlocks)
- `FirstDepositPromotionsViewController` - Registration bonus flow

## Architecture

All components follow GomaUI's standard MVVM pattern:
- Protocol-driven ViewModels (`*ViewModelProtocol`)
- Mock implementations for testing and previews (`Mock*ViewModel`)
- Combine-based reactive bindings
- StyleProvider theming support
