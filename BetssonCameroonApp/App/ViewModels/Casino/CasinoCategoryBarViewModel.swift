//
//  CasinoCategoryBarViewModel.swift
//  BetssonCameroonApp
//

import Combine
import Foundation
import GomaUI

/// Production implementation of CasinoCategoryBarViewModelProtocol
final class CasinoCategoryBarViewModel: CasinoCategoryBarViewModelProtocol {

    // MARK: - Properties

    let categoryData: CasinoCategoryBarData

    // MARK: - Publishers

    @Published private var title: String
    @Published private var buttonText: String

    var titlePublisher: AnyPublisher<String, Never> {
        $title.eraseToAnyPublisher()
    }

    var buttonTextPublisher: AnyPublisher<String, Never> {
        $buttonText.eraseToAnyPublisher()
    }

    var categoryId: String {
        categoryData.id
    }

    // MARK: - Callbacks

    var onButtonTapped: (() -> Void)?

    // MARK: - Initialization

    init(categoryData: CasinoCategoryBarData) {
        self.categoryData = categoryData
        self.title = categoryData.title
        self.buttonText = categoryData.buttonText
    }

    // MARK: - Actions

    func buttonTapped() {
        onButtonTapped?()
    }

    // MARK: - State Update Methods

    func updateTitle(_ newTitle: String) {
        title = newTitle
    }

    func updateButtonText(_ newButtonText: String) {
        buttonText = newButtonText
    }
}
