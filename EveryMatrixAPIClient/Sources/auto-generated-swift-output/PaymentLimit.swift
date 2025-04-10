import Foundation

struct PaymentLimit: Codable {
    // Date formatter for ISO8601 dates
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    var id: Int64?
    var name: String?
    var activeStatus: String?
    var description: String?
    var vendorId: String?
    var transType: String?
    var limitRuleId: Int64?
    var ruleLevel: String?
    var ruleLevelName: String?
    var currency: String?
    var limitDays: Int32?
    var totalAmount: Double?
    var created: Date?
    var authorUserId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case activeStatus
        case description
        case vendorId
        case transType
        case limitRuleId
        case ruleLevel
        case ruleLevelName
        case currency
        case limitDays
        case totalAmount
        case created
        case authorUserId
    }

    // Custom decoding initialization for handling special formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int64.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.activeStatus = try container.decodeIfPresent(String.self, forKey: .activeStatus)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.vendorId = try container.decodeIfPresent(String.self, forKey: .vendorId)
        self.transType = try container.decodeIfPresent(String.self, forKey: .transType)
        self.limitRuleId = try container.decodeIfPresent(Int64.self, forKey: .limitRuleId)
        self.ruleLevel = try container.decodeIfPresent(String.self, forKey: .ruleLevel)
        self.ruleLevelName = try container.decodeIfPresent(String.self, forKey: .ruleLevelName)
        self.currency = try container.decodeIfPresent(String.self, forKey: .currency)
        self.limitDays = try container.decodeIfPresent(Int32.self, forKey: .limitDays)
        self.totalAmount = try container.decodeIfPresent(Double.self, forKey: .totalAmount)

        // Decode created as Date
        if let dateString = try container.decodeIfPresent(String.self, forKey: .created) {
            self.created = PaymentLimit.dateFormatter.date(from: dateString)
        } else {
            self.created = nil
        }
        self.authorUserId = try container.decodeIfPresent(String.self, forKey: .authorUserId)
    }

    // Custom encoding for handling special formats
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.activeStatus, forKey: .activeStatus)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encodeIfPresent(self.vendorId, forKey: .vendorId)
        try container.encodeIfPresent(self.transType, forKey: .transType)
        try container.encodeIfPresent(self.limitRuleId, forKey: .limitRuleId)
        try container.encodeIfPresent(self.ruleLevel, forKey: .ruleLevel)
        try container.encodeIfPresent(self.ruleLevelName, forKey: .ruleLevelName)
        try container.encodeIfPresent(self.currency, forKey: .currency)
        try container.encodeIfPresent(self.limitDays, forKey: .limitDays)
        try container.encodeIfPresent(self.totalAmount, forKey: .totalAmount)

        // Encode created as ISO8601 string
        if let date = self.created {
            try container.encode(PaymentLimit.dateFormatter.string(from: date), forKey: .created)
        } else {
            try container.encodeNil(forKey: .created)
        }
        try container.encodeIfPresent(self.authorUserId, forKey: .authorUserId)
    }
}
