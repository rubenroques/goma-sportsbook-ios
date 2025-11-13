import Foundation
import UIKit
import Combine
import SharedModels

public protocol SportGamesFilterViewModelProtocol {
    var title: String { get }
    var sportFilters: [SportFilter] { get }
    var selectedSport: CurrentValueSubject<FilterIdentifier, Never> { get set }
    var sportFilterState: CurrentValueSubject<SportGamesFilterStateType, Never> { get }
    func selectSport(_ sport: FilterIdentifier)
    func didTapCollapseButton()
}
