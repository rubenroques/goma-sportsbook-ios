import Foundation

public struct TimeOption: Equatable {
    public let title: String
    public let value: Float
    
    public init(title: String, value: Float) {
        self.title = title
        self.value = value
    }
}
