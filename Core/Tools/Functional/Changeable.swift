import Foundation

protocol Changeable {
    func change<T>(path: WritableKeyPath<Self, T>, to value: T) -> Self
}

extension Changeable {
    func change<T>(path: WritableKeyPath<Self, T>, to value: T) -> Self {
        var clone = self
        clone[keyPath: path] = value
        return clone
    }
}
