import Foundation
import UIKit
import Combine

// MARK: - Data Models
public struct CapsuleData: Equatable {
    public let id: String
    public let text: String?
    public let backgroundColor: UIColor?
    public let textColor: UIColor?
    public let font: UIFont?
    public let horizontalPadding: CGFloat
    public let verticalPadding: CGFloat
    public let minimumHeight: CGFloat?
    
    public init(
        id: String = UUID().uuidString,
        text: String? = nil,
        backgroundColor: UIColor? = nil,
        textColor: UIColor? = nil,
        font: UIFont? = nil,
        horizontalPadding: CGFloat = 12.0,
        verticalPadding: CGFloat = 4.0,
        minimumHeight: CGFloat? = nil
    ) {
        self.id = id
        self.text = text
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.font = font
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.minimumHeight = minimumHeight
    }
}

// MARK: - View Model Protocol
public protocol CapsuleViewModelProtocol {
    var dataPublisher: AnyPublisher<CapsuleData, Never> { get }
    var data: CapsuleData { get }
    
    func configure(with data: CapsuleData)
}