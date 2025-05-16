import Foundation

/// Enum representing the available navigation bar identifiers in the application
///
/// These are used to identify specific navigation bars for switching between different
/// sections of the application.
///
/// - Note: When decoding from JSON, the values must match the raw string values of the enum cases.
public enum NavbarIdentifier: String, Codable {
    /// Sports navigation bar
    case sports
    /// Casino navigation bar
    case casino

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let value = NavbarIdentifier(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid navbar identifier: \(rawValue)"
            )
        }
        self = value
    }
} 