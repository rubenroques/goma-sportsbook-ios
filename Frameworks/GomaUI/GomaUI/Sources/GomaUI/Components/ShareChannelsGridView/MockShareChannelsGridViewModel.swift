import Foundation
import Combine

public final class MockShareChannelsGridViewModel: ShareChannelsGridViewModelProtocol {

    private let dataSubject: CurrentValueSubject<ShareChannelsGridData, Never>

    public var dataPublisher: AnyPublisher<ShareChannelsGridData, Never> {
        dataSubject.eraseToAnyPublisher()
    }

    public var onChannelSelected: ((ShareChannelType) -> Void)?

    public init(channels: [ShareChannel]) {
        self.dataSubject = CurrentValueSubject(ShareChannelsGridData(channels: channels))
    }

    // MARK: - Mock Variants

    public static var allChannelsMock: MockShareChannelsGridViewModel {
        return MockShareChannelsGridViewModel(channels: ShareChannel.allChannels())
    }

    public static var socialOnlyMock: MockShareChannelsGridViewModel {
        return MockShareChannelsGridViewModel(channels: ShareChannel.socialChannels())
    }

    public static var messagingOnlyMock: MockShareChannelsGridViewModel {
        return MockShareChannelsGridViewModel(channels: ShareChannel.messagingChannels())
    }

    public static var limitedMock: MockShareChannelsGridViewModel {
        let channels = [
            ShareChannel(type: .whatsApp),
            ShareChannel(type: .facebook),
            ShareChannel(type: .sms),
            ShareChannel(type: .email)
        ]
        return MockShareChannelsGridViewModel(channels: channels)
    }

    public static var withDisabledMock: MockShareChannelsGridViewModel {
        let channels = [
            ShareChannel(type: .twitter),
            ShareChannel(type: .whatsApp),
            ShareChannel(type: .facebook, isAvailable: false),
            ShareChannel(type: .telegram),
            ShareChannel(type: .messenger, isAvailable: false),
            ShareChannel(type: .viber),
            ShareChannel(type: .sms),
            ShareChannel(type: .email)
        ]
        return MockShareChannelsGridViewModel(channels: channels)
    }

    public static var emptyMock: MockShareChannelsGridViewModel {
        return MockShareChannelsGridViewModel(channels: [])
    }
}
