import Foundation
import UIKit
import Combine

// MARK: - Data Models
public struct InfoRowData {
    public let id: String
    public let leftText: String
    public let rightText: String
    public let leftTextColor: UIColor?
    public let rightTextColor: UIColor?
    public let backgroundColor: UIColor?
    
    public init(
        id: String = UUID().uuidString,
        leftText: String,
        rightText: String,
        leftTextColor: UIColor? = nil,
        rightTextColor: UIColor? = nil,
        backgroundColor: UIColor? = nil
    ) {
        self.id = id
        self.leftText = leftText
        self.rightText = rightText
        self.leftTextColor = leftTextColor
        self.rightTextColor = rightTextColor
        self.backgroundColor = backgroundColor
    }
}

// MARK: - View Model Protocol
public protocol InfoRowViewModelProtocol {
    var data: InfoRowData { get }
    var dataPublisher: AnyPublisher<InfoRowData, Never> { get }
    
    func configure(with data: InfoRowData)
}
