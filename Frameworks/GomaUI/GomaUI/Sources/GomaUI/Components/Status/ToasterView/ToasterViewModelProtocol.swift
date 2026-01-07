import Foundation
import Combine
import CombineSchedulers
import UIKit

public struct ToasterData: Equatable {
    public let title: String
    public let icon: String?
    public let backgroundColor: UIColor
    public let titleColor: UIColor
    public let iconColor: UIColor
    public let cornerRadius: CGFloat

    public init(
        title: String,
        icon: String? = nil,
        backgroundColor: UIColor = StyleProvider.Color.backgroundTertiary,
        titleColor: UIColor = StyleProvider.Color.textPrimary,
        iconColor: UIColor = StyleProvider.Color.highlightPrimary,
        cornerRadius: CGFloat = 12
    ) {
        self.title = title
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.iconColor = iconColor
        self.cornerRadius = cornerRadius
    }
}

public protocol ToasterViewModelProtocol {
    var dataPublisher: AnyPublisher<ToasterData, Never> { get }
    var currentData: ToasterData { get }

    /// Scheduler for receiving updates. Use `DispatchQueue.main.eraseToAnyScheduler()` in production,
    /// `DispatchQueue.immediate.eraseToAnyScheduler()` in tests for synchronous execution.
    var scheduler: AnySchedulerOf<DispatchQueue> { get }
}


