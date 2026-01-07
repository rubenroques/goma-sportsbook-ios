import Foundation
import Combine

public struct ShareChannelsGridData {
    public let channels: [ShareChannel]

    public init(channels: [ShareChannel]) {
        self.channels = channels
    }
}

public protocol ShareChannelsGridViewModelProtocol {
    var dataPublisher: AnyPublisher<ShareChannelsGridData, Never> { get }
    var onChannelSelected: ((ShareChannelType) -> Void)? { get set }
}
