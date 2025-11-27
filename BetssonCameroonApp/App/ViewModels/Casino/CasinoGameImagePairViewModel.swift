//
//  CasinoGameImagePairViewModel.swift
//  BetssonCameroonApp
//

import Foundation
import GomaUI

/// Production implementation of CasinoGameImagePairViewModelProtocol
final class CasinoGameImagePairViewModel: CasinoGameImagePairViewModelProtocol {

    // MARK: - Protocol Properties

    let topGameViewModel: CasinoGameImageViewModelProtocol
    let bottomGameViewModel: CasinoGameImageViewModelProtocol?
    let pairId: String

    // MARK: - Callbacks

    var onGameSelected: ((String) -> Void)? {
        didSet {
            // Propagate callback to child ViewModels
            if let topVM = topGameViewModel as? CasinoGameImageViewModel {
                topVM.onGameSelected = onGameSelected
            }
            if let bottomVM = bottomGameViewModel as? CasinoGameImageViewModel {
                bottomVM.onGameSelected = onGameSelected
            }
        }
    }

    // MARK: - Initialization

    init(
        pairId: String,
        topGameViewModel: CasinoGameImageViewModelProtocol,
        bottomGameViewModel: CasinoGameImageViewModelProtocol?
    ) {
        self.pairId = pairId
        self.topGameViewModel = topGameViewModel
        self.bottomGameViewModel = bottomGameViewModel
    }

    /// Convenience initializer from game data
    convenience init(topGame: CasinoGameImageData, bottomGame: CasinoGameImageData?) {
        let topVM = CasinoGameImageViewModel(data: topGame)
        let bottomVM = bottomGame.map { CasinoGameImageViewModel(data: $0) }

        self.init(
            pairId: "pair-\(topGame.id)",
            topGameViewModel: topVM,
            bottomGameViewModel: bottomVM
        )
    }

    /// Create multiple pairs from an array of games
    static func pairs(from games: [CasinoGameImageData]) -> [CasinoGameImagePairViewModel] {
        var pairs: [CasinoGameImagePairViewModel] = []
        var index = 0

        while index < games.count {
            let topGame = games[index]
            let bottomGame = (index + 1 < games.count) ? games[index + 1] : nil

            let pair = CasinoGameImagePairViewModel(topGame: topGame, bottomGame: bottomGame)
            pairs.append(pair)

            index += 2
        }

        return pairs
    }
}
