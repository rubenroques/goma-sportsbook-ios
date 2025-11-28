import Foundation

/// Mock implementation of CasinoGameImageViewModelProtocol for testing and previews
public final class MockCasinoGameImageViewModel: CasinoGameImageViewModelProtocol {

    // MARK: - Protocol Properties

    public let gameId: String
    public let gameURL: String
    public let iconURL: String?

    // MARK: - Callbacks

    public var onGameSelected: ((String) -> Void)?

    // MARK: - Initialization

    public init(
        gameId: String,
        gameURL: String,
        iconURL: String?
    ) {
        self.gameId = gameId
        self.gameURL = gameURL
        self.iconURL = iconURL
    }

    // MARK: - Convenience Initializer

    public convenience init(data: CasinoGameImageData) {
        self.init(
            gameId: data.id,
            gameURL: data.gameURL,
            iconURL: data.iconURL
        )
    }

    // MARK: - Protocol Methods

    public func gameSelected() {
        onGameSelected?(gameId)
    }
}

// MARK: - Factory Methods

extension MockCasinoGameImageViewModel {

    /// PlinkGoal game mock with placeholder image
    public static var plinkGoal: MockCasinoGameImageViewModel {
        MockCasinoGameImageViewModel(
            gameId: "plinkgoal-001",
            gameURL: "https://casino.example.com/games/plinkgoal",
            iconURL: "https://picsum.photos/164/164?random=1"
        )
    }

    /// Aviator game mock with placeholder image
    public static var aviator: MockCasinoGameImageViewModel {
        MockCasinoGameImageViewModel(
            gameId: "aviator-001",
            gameURL: "https://casino.example.com/games/aviator",
            iconURL: "https://picsum.photos/164/164?random=2"
        )
    }

    /// Samba Soccer game mock with placeholder image
    public static var sambaSoccer: MockCasinoGameImageViewModel {
        MockCasinoGameImageViewModel(
            gameId: "samba-soccer-001",
            gameURL: "https://casino.example.com/games/samba-soccer",
            iconURL: "https://picsum.photos/164/164?random=3"
        )
    }

    /// Failed state mock (invalid URL)
    public static var failed: MockCasinoGameImageViewModel {
        MockCasinoGameImageViewModel(
            gameId: "failed-game",
            gameURL: "https://casino.example.com/games/failed",
            iconURL: "invalid-url-that-will-fail"
        )
    }

    /// No image mock
    public static var noImage: MockCasinoGameImageViewModel {
        MockCasinoGameImageViewModel(
            gameId: "no-image-game",
            gameURL: "https://casino.example.com/games/no-image",
            iconURL: nil
        )
    }
}
