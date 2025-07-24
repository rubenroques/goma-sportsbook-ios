import Foundation

/// Enum representing the available tab identifiers in the application
///
/// These are used to identify specific tabs in the UI and ensure type-safety when
/// referencing tabs throughout the application.
///
/// - Note: When decoding from JSON, the values must match the raw string values of the enum cases.
public enum TabIdentifier: String, Codable {
    /// Main sports tab
    case sports
    /// Live sports events tab
    case live
    /// User's active bets tab
    case mybets
    /// Sports search functionality tab
    case searchSports
    /// Main casino tab
    case casino
    /// Virtual games tab
    case virtuals
    /// Aviator game tab
    case aviator
    /// Casino search functionality tab
    case searchCasino

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let value = TabIdentifier(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid tab identifier: \(rawValue)"
            )
        }
        self = value
    }
}