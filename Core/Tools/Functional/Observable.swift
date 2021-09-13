import Foundation

protocol ObservableProtocol {
    associatedtype ValueType
    var value: ValueType { get set }
    func subscribe(on observer: AnyObject, initialTrigger: Bool, deliverQueue: DispatchQueue, block: @escaping (_ newValue: ValueType) -> Void)
    func unsubscribe(observer: AnyObject)
}

final class Observable<T>: ObservableProtocol {

    typealias ObserverBlock = (_ newValue: T) -> Void
    typealias ObserversEntry = (observer: AnyObject, deliverQueue: DispatchQueue, block: ObserverBlock)
    var observers: [ObserversEntry]

    init(_ value: T) {
        self.value = value
        self.observers = []
    }

    var value: T {
        didSet {
            self.observers.forEach { (entry: ObserversEntry) in
                let (_, deliverQueue, block) = entry
                deliverQueue.async { [weak self] in
                    guard let self = self else { return }
                    block(self.value)
                }
            }
        }
    }
    func subscribe(on observer: AnyObject, initialTrigger: Bool = true, deliverQueue: DispatchQueue = DispatchQueue.main, block: @escaping (T) -> Void) {
        let entry: ObserversEntry = (observer: observer, deliverQueue: deliverQueue, block: block)
        self.observers.append(entry)

        if initialTrigger {
            block(self.value)
        }
    }

    func unsubscribe(observer: AnyObject) {
        let filtered = observers.filter { entry in
            return entry.observer !== observer
        }
        self.observers = filtered
    }
}
