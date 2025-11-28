//
//  CasinoGameImageViewModel.swift
//  BetssonCameroonApp
//

import Foundation
import GomaUI

/// Production implementation of CasinoGameImageViewModelProtocol
final class CasinoGameImageViewModel: CasinoGameImageViewModelProtocol {
    // MARK: - Protocol Properties

    let gameId: String
    let gameURL: String
    let iconURL: String?

    // MARK: - Callbacks

    var onGameSelected: ((String) -> Void)?

    // MARK: - Initialization

    init(
        gameId: String,
        gameURL: String,
        iconURL: String?
    ) {
        self.gameId = gameId
        self.gameURL = gameURL
        self.iconURL = iconURL
    }

    // MARK: - Convenience Initializer

    convenience init(data: CasinoGameImageData) {
        self.init(
            gameId: data.id,
            gameURL: data.gameURL,
            iconURL: data.iconURL
        )
    }

    // MARK: - Protocol Methods

    func gameSelected() {
        onGameSelected?(gameId)
    }
}
