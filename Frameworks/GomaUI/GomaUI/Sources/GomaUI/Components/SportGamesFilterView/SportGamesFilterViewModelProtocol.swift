import Foundation

import Foundation
import UIKit
import Combine

public protocol SportGamesFilterViewModelProtocol {
    var title: String { get }
    var sportFilters: [SportFilter] { get }
    var selectedId: CurrentValueSubject<String, Never> { get set }
    var sportFilterState: CurrentValueSubject<SportGamesFilterStateType, Never> { get }
    func selectOption(withId id: String)
    func didTapCollapseButton()
}
