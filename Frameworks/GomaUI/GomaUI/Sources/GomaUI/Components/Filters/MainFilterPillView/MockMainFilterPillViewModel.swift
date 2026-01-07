import Foundation
import Combine

final public class MockMainFilterPillViewModel: MainFilterPillViewModelProtocol {

    // MARK: - Properties
    public let mainFilterSubject: CurrentValueSubject<MainFilterItem, Never>
    public var mainFilterState: CurrentValueSubject<MainFilterStateType, Never>

    // MARK: - Initialization
    public init(mainFilter: MainFilterItem, initialState: MainFilterStateType = .notSelected) {
        self.mainFilterSubject = CurrentValueSubject(mainFilter)
        self.mainFilterState = CurrentValueSubject(initialState)
    }

    // MARK: - Public Methods
    public func setFilterState(_ state: MainFilterStateType) {
        mainFilterState.send(state)
    }

    // MARK: - Protocol
    public func didTapMainFilterItem() -> QuickLinkType {
        let quickLinkType = self.mainFilterSubject.value.type

        return quickLinkType
    }
}
