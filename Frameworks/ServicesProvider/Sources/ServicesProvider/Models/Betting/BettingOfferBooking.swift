//
//  BettingOfferBooking.swift
//  ServicesProvider
//
//  Created by Assistant on 15/10/2025.
//

import Foundation

/// Represents a single betting offer selection for booking.
///
/// This is used when creating or retrieving betting offer bookings via the booking code system.
/// Each selection contains only the betting offer ID, which is the minimum required information
/// to reconstruct a betslip.
public struct BookingSelection: Codable, Equatable {

    /// The betting offer ID for this selection.
    ///
    /// This corresponds to the `bettingOfferId` field in the outcome selection.
    /// For EveryMatrix, this is the ID of the specific betting offer with current odds.
    ///
    /// **Example**: `"283682027195084800"`
    public let bettingOfferId: String

    /// Creates a new booking selection.
    ///
    /// - Parameter bettingOfferId: The betting offer ID to bookmark
    public init(bettingOfferId: String) {
        self.bettingOfferId = bettingOfferId
    }
}

/// Request payload for creating a betting offer booking.
///
/// This model is used to create a booking code that stores a collection of betting offer IDs.
/// The booking code can then be shared with other users or used to restore a betslip later.
///
/// ## Use Cases
/// - **Share Betslip**: Create a booking code and share it via QR code or link
/// - **Restore Betslip**: Store selections temporarily and restore them later
/// - **Cross-Device**: Transfer betslip selections between devices
///
/// ## Example
/// ```swift
/// let selections = [
///     BookingSelection(bettingOfferId: "283682027195084800"),
///     BookingSelection(bettingOfferId: "283682211352619520")
/// ]
/// let request = BookingRequest(selections: selections, originalSelectionsLength: 5)
/// ```
public struct BookingRequest: Codable, Equatable {

    /// Array of betting offer selections to bookmark.
    public let selections: [BookingSelection]

    /// Original number of selections before filtering.
    ///
    /// This tracks how many selections were originally intended to be saved,
    /// even if some were filtered out. Useful for tracking unavailable selections.
    ///
    /// **Example**: User had 5 selections, but only 4 were valid → originalSelectionsLength: 5
    public let originalSelectionsLength: Int

    /// Creates a new booking request.
    ///
    /// - Parameters:
    ///   - selections: Array of betting offer selections to store
    ///   - originalSelectionsLength: Original count of selections before filtering
    public init(selections: [BookingSelection], originalSelectionsLength: Int) {
        self.selections = selections
        self.originalSelectionsLength = originalSelectionsLength
    }
}

/// Response received after creating a betting offer booking.
///
/// Contains the generated booking code that can be used to retrieve the selections later.
///
/// ## Lifecycle
/// - Booking codes are typically short-lived (hours to days, depending on provider)
/// - Codes are case-sensitive alphanumeric strings
/// - Each code is unique and can only be used to retrieve the exact selections that were stored
///
/// ## Example Response
/// ```json
/// {
///   "code": "7YRLO2UQ",
///   "message": "{...original selections JSON...}"
/// }
/// ```
public struct BookingCodeResponse: Codable, Equatable {

    /// The generated booking code.
    ///
    /// This code can be shared with other users or stored for later retrieval.
    /// Codes are typically 8-character alphanumeric strings.
    ///
    /// **Example**: `"7YRLO2UQ"`
    public let code: String

    /// Optional message from the server.
    ///
    /// May contain the original request JSON or additional metadata.
    /// This field is informational and not required for retrieval.
    public let message: String?

    /// Creates a new booking code response.
    ///
    /// - Parameters:
    ///   - code: The generated booking code
    ///   - message: Optional server message
    public init(code: String, message: String? = nil) {
        self.code = code
        self.message = message
    }
}

/// Response received when retrieving betting offers using a booking code.
///
/// Contains the array of betting offer selections that were originally stored.
///
/// ## Retrieval Process
/// 1. Client provides booking code
/// 2. Server returns the original selections
/// 3. Client can reconstruct betslip using the betting offer IDs
///
/// ## Example Response
/// ```json
/// {
///   "selections": [
///     {"bettingOfferId": "283682027195084800"},
///     {"bettingOfferId": "283682211352619520"}
///   ],
///   "originalSelectionsLength": 5
/// }
/// ```
public struct BookingRetrievalResponse: Codable, Equatable {

    /// Array of betting offer selections retrieved from the booking code.
    public let selections: [BookingSelection]

    /// Original number of selections before filtering.
    ///
    /// This indicates how many selections were originally saved,
    /// even if some were filtered out or are no longer available.
    public let originalSelectionsLength: Int

    /// Creates a new booking retrieval response.
    ///
    /// - Parameters:
    ///   - selections: Array of retrieved betting offer selections
    ///   - originalSelectionsLength: Original count of selections when saved
    public init(selections: [BookingSelection], originalSelectionsLength: Int) {
        self.selections = selections
        self.originalSelectionsLength = originalSelectionsLength
    }
}
