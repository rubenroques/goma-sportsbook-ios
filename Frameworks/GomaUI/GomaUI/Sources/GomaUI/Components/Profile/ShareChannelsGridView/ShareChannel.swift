import Foundation

public struct ShareChannel: Identifiable, Equatable {
    public let id: String
    public let type: ShareChannelType
    public let title: String
    public let iconName: String
    public let isAvailable: Bool

    public init(
        id: String,
        type: ShareChannelType,
        title: String,
        iconName: String,
        isAvailable: Bool = true
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.iconName = iconName
        self.isAvailable = isAvailable
    }

    public init(type: ShareChannelType, isAvailable: Bool = true) {
        self.id = type.id
        self.type = type
        self.title = type.title
        self.iconName = type.iconName
        self.isAvailable = isAvailable
    }

    public static func allChannels() -> [ShareChannel] {
        return ShareChannelType.allCases.map { ShareChannel(type: $0) }
    }

    public static func socialChannels() -> [ShareChannel] {
        return [
            ShareChannel(type: .twitter),
            ShareChannel(type: .whatsApp),
            ShareChannel(type: .facebook),
            ShareChannel(type: .telegram),
            ShareChannel(type: .messenger)
        ]
    }

    public static func messagingChannels() -> [ShareChannel] {
        return [
            ShareChannel(type: .viber),
            ShareChannel(type: .sms),
            ShareChannel(type: .email)
        ]
    }
}
