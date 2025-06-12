//
//  GamesViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 23/05/2025.
//

import Foundation

import Foundation
import UIKit
import Combine

public protocol SportGamesFilterViewModelProtocol {
    var title: String { get }
    var sportFilters: [SportFilter] { get }
    var selectedId: CurrentValueSubject<Int, Never> { get set }
    var sportFilterState: CurrentValueSubject<SportGamesFilterStateType, Never> { get }
    func selectOption(withId id: Int)
    func didTapCollapseButton()
}
