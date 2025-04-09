import Foundation

struct BonusWallet: Codable {
    // Date formatter for ISO8601 dates
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    var walletId: Int64?
    var bonusId: String?
    var status: String?
    var name: String?
    var bonusCode: String?
    var type: String?
    var triggerType: String?
    var fulfilledWR: Double?
    var grantedAmount: Double?
    var currentAmount: Double?
    var lockedAmount: Double?
    var totalWR: Double?
    var refundableAmount: Double?
    var currency: String?
    var originalWageringRequirement: Double?
    var remainingWageringRequirement: Double?
    var originalWageringRequirementCurrency: String?
    var expiryTime: String?
    var freeRoundNumber: Int32?
    var granted: Date?
    var wageringProgress: WageringProgress?
    var vendor: [String: ResVendorInfo]?
    var levels: [ResLevels]?
    var walletExtension: ResWalletExtension?

    enum CodingKeys: String, CodingKey {
        case walletId
        case bonusId
        case status
        case name
        case bonusCode
        case type
        case triggerType
        case fulfilledWR
        case grantedAmount
        case currentAmount
        case lockedAmount
        case totalWR
        case refundableAmount
        case currency
        case originalWageringRequirement
        case remainingWageringRequirement
        case originalWageringRequirementCurrency
        case expiryTime
        case freeRoundNumber
        case granted
        case wageringProgress
        case vendor
        case levels
        case walletExtension
    }

    // Custom decoding initialization for handling special formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.walletId = try container.decodeIfPresent(Int64.self, forKey: .walletId)
        self.bonusId = try container.decodeIfPresent(String.self, forKey: .bonusId)
        self.status = try container.decodeIfPresent(String.self, forKey: .status)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.bonusCode = try container.decodeIfPresent(String.self, forKey: .bonusCode)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.triggerType = try container.decodeIfPresent(String.self, forKey: .triggerType)
        self.fulfilledWR = try container.decodeIfPresent(Double.self, forKey: .fulfilledWR)
        self.grantedAmount = try container.decodeIfPresent(Double.self, forKey: .grantedAmount)
        self.currentAmount = try container.decodeIfPresent(Double.self, forKey: .currentAmount)
        self.lockedAmount = try container.decodeIfPresent(Double.self, forKey: .lockedAmount)
        self.totalWR = try container.decodeIfPresent(Double.self, forKey: .totalWR)
        self.refundableAmount = try container.decodeIfPresent(Double.self, forKey: .refundableAmount)
        self.currency = try container.decodeIfPresent(String.self, forKey: .currency)
        self.originalWageringRequirement = try container.decodeIfPresent(Double.self, forKey: .originalWageringRequirement)
        self.remainingWageringRequirement = try container.decodeIfPresent(Double.self, forKey: .remainingWageringRequirement)
        self.originalWageringRequirementCurrency = try container.decodeIfPresent(String.self, forKey: .originalWageringRequirementCurrency)
        self.expiryTime = try container.decodeIfPresent(String.self, forKey: .expiryTime)
        self.freeRoundNumber = try container.decodeIfPresent(Int32.self, forKey: .freeRoundNumber)

        // Decode granted as Date
        if let dateString = try container.decodeIfPresent(String.self, forKey: .granted) {
            self.granted = BonusWallet.dateFormatter.date(from: dateString)
        } else {
            self.granted = nil
        }
        self.wageringProgress = try container.decodeIfPresent(WageringProgress.self, forKey: .wageringProgress)
        self.vendor = try container.decodeIfPresent([String: ResVendorInfo].self, forKey: .vendor)
        self.levels = try container.decodeIfPresent([ResLevels].self, forKey: .levels)
        self.walletExtension = try container.decodeIfPresent(ResWalletExtension.self, forKey: .walletExtension)
    }

    // Custom encoding for handling special formats
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.walletId, forKey: .walletId)
        try container.encodeIfPresent(self.bonusId, forKey: .bonusId)
        try container.encodeIfPresent(self.status, forKey: .status)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.bonusCode, forKey: .bonusCode)
        try container.encodeIfPresent(self.type, forKey: .type)
        try container.encodeIfPresent(self.triggerType, forKey: .triggerType)
        try container.encodeIfPresent(self.fulfilledWR, forKey: .fulfilledWR)
        try container.encodeIfPresent(self.grantedAmount, forKey: .grantedAmount)
        try container.encodeIfPresent(self.currentAmount, forKey: .currentAmount)
        try container.encodeIfPresent(self.lockedAmount, forKey: .lockedAmount)
        try container.encodeIfPresent(self.totalWR, forKey: .totalWR)
        try container.encodeIfPresent(self.refundableAmount, forKey: .refundableAmount)
        try container.encodeIfPresent(self.currency, forKey: .currency)
        try container.encodeIfPresent(self.originalWageringRequirement, forKey: .originalWageringRequirement)
        try container.encodeIfPresent(self.remainingWageringRequirement, forKey: .remainingWageringRequirement)
        try container.encodeIfPresent(self.originalWageringRequirementCurrency, forKey: .originalWageringRequirementCurrency)
        try container.encodeIfPresent(self.expiryTime, forKey: .expiryTime)
        try container.encodeIfPresent(self.freeRoundNumber, forKey: .freeRoundNumber)

        // Encode granted as ISO8601 string
        if let date = self.granted {
            try container.encode(BonusWallet.dateFormatter.string(from: date), forKey: .granted)
        } else {
            try container.encodeNil(forKey: .granted)
        }
        try container.encodeIfPresent(self.wageringProgress, forKey: .wageringProgress)
        try container.encodeIfPresent(self.vendor, forKey: .vendor)
        try container.encodeIfPresent(self.levels, forKey: .levels)
        try container.encodeIfPresent(self.walletExtension, forKey: .walletExtension)
    }
}
