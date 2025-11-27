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
    let imageURL: String?

    // MARK: - Callbacks

    var onGameSelected: ((String) -> Void)?

    // MARK: - Initialization

    init(
        gameId: String,
        gameURL: String,
        imageURL: String?
    ) {
        self.gameId = gameId
        self.gameURL = gameURL
        self.imageURL = imageURL
    }

    // MARK: - Convenience Initializer

    convenience init(data: CasinoGameImageData) {
        self.init(
            gameId: data.id,
            gameURL: data.gameURL,
            imageURL: data.imageURL
        )
    }

    // MARK: - Protocol Methods

    func gameSelected() {
        onGameSelected?(gameId)
    }
}
