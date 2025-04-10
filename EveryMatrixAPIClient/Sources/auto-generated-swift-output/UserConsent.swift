import Foundation

struct UserConsent: Codable {
    // Date formatter for ISO8601 dates
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    var domainId: Int32?
    var userId: Int64?
    var consentTypeId: Int32?
    var tagCode: String?
    var friendlyName: String?
    var status: String?
    var expirationDate: Date?

    enum CodingKeys: String, CodingKey {
        case domainId = "domainID"
        case userId = "userID"
        case consentTypeId
        case tagCode
        case friendlyName
        case status
        case expirationDate
    }

    // Custom decoding initialization for handling special formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.domainId = try container.decodeIfPresent(Int32.self, forKey: .domainId)
        self.userId = try container.decodeIfPresent(Int64.self, forKey: .userId)
        self.consentTypeId = try container.decodeIfPresent(Int32.self, forKey: .consentTypeId)
        self.tagCode = try container.decodeIfPresent(String.self, forKey: .tagCode)
        self.friendlyName = try container.decodeIfPresent(String.self, forKey: .friendlyName)
        self.status = try container.decodeIfPresent(String.self, forKey: .status)

        // Decode expirationDate as Date
        if let dateString = try container.decodeIfPresent(String.self, forKey: .expirationDate) {
            self.expirationDate = UserConsent.dateFormatter.date(from: dateString)
        } else {
            self.expirationDate = nil
        }
    }

    // Custom encoding for handling special formats
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.domainId, forKey: .domainId)
        try container.encodeIfPresent(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.consentTypeId, forKey: .consentTypeId)
        try container.encodeIfPresent(self.tagCode, forKey: .tagCode)
        try container.encodeIfPresent(self.friendlyName, forKey: .friendlyName)
        try container.encodeIfPresent(self.status, forKey: .status)

        // Encode expirationDate as ISO8601 string
        if let date = self.expirationDate {
            try container.encode(UserConsent.dateFormatter.string(from: date), forKey: .expirationDate)
        } else {
            try container.encodeNil(forKey: .expirationDate)
        }
    }
}
