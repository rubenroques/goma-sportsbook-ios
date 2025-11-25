import Foundation

/// Enum representing different types of casino lobbies supported by the ServiceProvider
public enum CasinoLobbyType {
    case casino
    case virtuals

    public var displayName: String {
        switch self {
        case .casino:
            return "casino"
        case .virtuals:
            return "virtuals"
        }
    }

}
