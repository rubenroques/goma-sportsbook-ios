# ShareChannelsGridView

A grid layout of social sharing channel buttons organized in two rows.

## Overview

ShareChannelsGridView displays a grid of sharing channel buttons (WhatsApp, Facebook, Twitter, Telegram, etc.) organized in up to two rows of 5 buttons each. Each button shows a branded icon with the channel name and supports availability states. The component is used for share sheets and social sharing functionality throughout the app.

## Component Relationships

### Used By (Parents)
- Share sheets
- Referral screens
- Social sharing dialogs

### Uses (Children)
- `ShareChannelButtonView` (internal helper)

## Features

- Two-row grid layout (5 buttons per row max)
- Social channel icons with brand colors
- Channel availability states (enabled/disabled)
- Channel selection callback
- Dynamic channel configuration
- Empty row hiding
- Spacer views for consistent layout
- Reactive updates via Combine publishers

## Usage

```swift
let viewModel = MockShareChannelsGridViewModel.allChannelsMock
let shareGrid = ShareChannelsGridView(viewModel: viewModel)

// Handle channel selection
viewModel.onChannelSelected = { channelType in
    switch channelType {
    case .whatsApp: shareToWhatsApp()
    case .facebook: shareToFacebook()
    case .twitter: shareToTwitter()
    default: break
    }
}

// Social channels only
let socialVM = MockShareChannelsGridViewModel.socialOnlyMock
let socialGrid = ShareChannelsGridView(viewModel: socialVM)

// With disabled channels
let disabledVM = MockShareChannelsGridViewModel.withDisabledMock
```

## Data Model

```swift
enum ShareChannelType: String, CaseIterable, Identifiable {
    case twitter, whatsApp, facebook, telegram, messenger, viber, sms, email

    var title: String
    var iconName: String
    var backgroundColor: UIColor
    var urlScheme: String?
}

struct ShareChannel: Identifiable, Equatable {
    let id: String
    let type: ShareChannelType
    let title: String
    let iconName: String
    let isAvailable: Bool

    static func allChannels() -> [ShareChannel]
    static func socialChannels() -> [ShareChannel]
    static func messagingChannels() -> [ShareChannel]
}

struct ShareChannelsGridData {
    let channels: [ShareChannel]
}

protocol ShareChannelsGridViewModelProtocol {
    var dataPublisher: AnyPublisher<ShareChannelsGridData, Never> { get }
    var onChannelSelected: ((ShareChannelType) -> Void)? { get set }
}
```

## Styling

Layout constants:
- Container horizontal padding: 12pt
- Container vertical padding: 8pt
- Row spacing: 12pt
- Button spacing: 16pt
- Distribution: fillEqually

Row behavior:
- Top row: First 5 channels
- Bottom row: Remaining channels (up to 5)
- Empty rows hidden

Channel colors (per type):
- Twitter: #1DA1F2
- WhatsApp: #25D366
- Facebook: #1877F2
- Telegram: #22ADE1
- Messenger: #0084FF
- Viber: #734F96
- SMS: #52C41A
- Email: #58A6FF

Icons:
- Social: Bundle assets (twitter_icon, whatsapp_icon, etc.)
- SMS: SF Symbol "message.circle.fill"
- Email: SF Symbol "envelope.circle.fill"

## Mock ViewModels

Available presets:
- `.allChannelsMock` - All 8 channels
- `.socialOnlyMock` - Twitter, WhatsApp, Facebook, Telegram, Messenger
- `.messagingOnlyMock` - Viber, SMS, Email
- `.limitedMock` - WhatsApp, Facebook, SMS, Email only
- `.withDisabledMock` - Channels with some disabled
- `.emptyMock` - No channels
