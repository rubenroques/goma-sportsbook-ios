//
//  CasinoGameImageGridSectionViewModel.swift
//  BetssonCameroonApp
//

import Foundation
import Combine
import GomaUI

/// Production implementation of CasinoGameImageGridSectionViewModelProtocol
final class CasinoGameImageGridSectionViewModel: CasinoGameImageGridSectionViewModelProtocol {

    // MARK: - Published Properties

    @Published private var _gamePairViewModels: [CasinoGameImagePairViewModelProtocol]

    // MARK: - Protocol Properties

    let categoryBarViewModel: CasinoCategoryBarViewModelProtocol
    let sectionId: String
    let categoryTitle: String

    var gamePairViewModels: [CasinoGameImagePairViewModelProtocol] {
        _gamePairViewModels
    }

    var gamePairViewModelsPublisher: AnyPublisher<[CasinoGameImagePairViewModelProtocol], Never> {
        $_gamePairViewModels.eraseToAnyPublisher()
    }

    // MARK: - Callbacks

    var onGameSelected: ((String) -> Void)?
    var onCategoryButtonTapped: (() -> Void)?

    // MARK: - Initialization

    init(
        sectionId: String,
        categoryTitle: String,
        categoryButtonText: String,
        gamePairViewModels: [CasinoGameImagePairViewModelProtocol]
    ) {
        self.sectionId = sectionId
        self.categoryTitle = categoryTitle
        self._gamePairViewModels = gamePairViewModels

        // Create category bar ViewModel
        let categoryData = CasinoCategoryBarData(
            id: sectionId,
            title: categoryTitle,
            buttonText: categoryButtonText
        )
        let categoryBarVM = CasinoCategoryBarViewModel(categoryData: categoryData)
        self.categoryBarViewModel = categoryBarVM

        // Wire up category bar button callback
        categoryBarVM.onButtonTapped = { [weak self] in
            self?.categoryButtonTapped()
        }

        // Set up callbacks on pair ViewModels
        setupPairCallbacks()
    }

    /// Convenience initializer from section data
    convenience init(data: CasinoGameImageGridSectionData) {
        let pairs = CasinoGameImagePairViewModel.pairs(from: data.games)

        self.init(
            sectionId: data.id,
            categoryTitle: data.categoryTitle,
            categoryButtonText: data.categoryButtonText,
            gamePairViewModels: pairs
        )
    }

    // MARK: - Protocol Methods

    func gameSelected(_ gameId: String) {
        onGameSelected?(gameId)
    }

    func categoryButtonTapped() {
        onCategoryButtonTapped?()
    }

    func refreshGames() {
        // Trigger a refresh notification
        _gamePairViewModels = _gamePairViewModels
    }

    // MARK: - Private Methods

    private func setupPairCallbacks() {
        for pair in _gamePairViewModels {
            if let prodPair = pair as? CasinoGameImagePairViewModel {
                prodPair.onGameSelected = { [weak self] gameId in
                    self?.gameSelected(gameId)
                }
            }
        }
    }
}
