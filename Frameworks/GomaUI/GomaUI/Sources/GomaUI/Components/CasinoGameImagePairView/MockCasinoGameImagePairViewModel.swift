import Foundation

/// Mock implementation of CasinoGameImagePairViewModelProtocol for testing and previews
public final class MockCasinoGameImagePairViewModel: CasinoGameImagePairViewModelProtocol {

    // MARK: - Protocol Properties

    public let topGameViewModel: CasinoGameImageViewModelProtocol
    public let bottomGameViewModel: CasinoGameImageViewModelProtocol?
    public let pairId: String

    // MARK: - Callbacks

    public var onGameSelected: ((String) -> Void)? {
        didSet {
            // Propagate callback to child ViewModels
            if let topVM = topGameViewModel as? MockCasinoGameImageViewModel {
                topVM.onGameSelected = onGameSelected
            }
            if let bottomVM = bottomGameViewModel as? MockCasinoGameImageViewModel {
                bottomVM.onGameSelected = onGameSelected
            }
        }
    }

    // MARK: - Initialization

    public init(
        pairId: String,
        topGameViewModel: CasinoGameImageViewModelProtocol,
        bottomGameViewModel: CasinoGameImageViewModelProtocol?
    ) {
        self.pairId = pairId
        self.topGameViewModel = topGameViewModel
        self.bottomGameViewModel = bottomGameViewModel
    }

    /// Convenience initializer from game data
    public convenience init(topGame: CasinoGameImageData, bottomGame: CasinoGameImageData?) {
        let topVM = MockCasinoGameImageViewModel(data: topGame)
        let bottomVM = bottomGame.map { MockCasinoGameImageViewModel(data: $0) }

        self.init(
            pairId: "pair-\(topGame.id)",
            topGameViewModel: topVM,
            bottomGameViewModel: bottomVM
        )
    }
}

// MARK: - Factory Methods

extension MockCasinoGameImagePairViewModel {

    /// Full pair with both games
    public static var fullPair: MockCasinoGameImagePairViewModel {
        MockCasinoGameImagePairViewModel(
            pairId: "pair-full",
            topGameViewModel: MockCasinoGameImageViewModel.plinkGoal,
            bottomGameViewModel: MockCasinoGameImageViewModel.aviator
        )
    }

    /// Pair with only top game (odd number scenario)
    public static var topOnly: MockCasinoGameImagePairViewModel {
        MockCasinoGameImagePairViewModel(
            pairId: "pair-top-only",
            topGameViewModel: MockCasinoGameImageViewModel.sambaSoccer,
            bottomGameViewModel: nil
        )
    }

    /// Pair with no images (failure state)
    public static var noImages: MockCasinoGameImagePairViewModel {
        MockCasinoGameImagePairViewModel(
            pairId: "pair-no-images",
            topGameViewModel: MockCasinoGameImageViewModel.noImage,
            bottomGameViewModel: MockCasinoGameImageViewModel.noImage
        )
    }

    /// Create multiple pairs from an array of games
    public static func pairs(from games: [CasinoGameImageData]) -> [MockCasinoGameImagePairViewModel] {
        var pairs: [MockCasinoGameImagePairViewModel] = []
        var index = 0

        while index < games.count {
            let topGame = games[index]
            let bottomGame = (index + 1 < games.count) ? games[index + 1] : nil

            let pair = MockCasinoGameImagePairViewModel(topGame: topGame, bottomGame: bottomGame)
            pairs.append(pair)

            index += 2
        }

        return pairs
    }
}
