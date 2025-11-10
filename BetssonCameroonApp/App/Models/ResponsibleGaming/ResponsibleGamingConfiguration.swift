//
//  ResponsibleGamingConfiguration.swift
//  BetssonCameroonApp
//
//  Created by Claude on 07/11/2025.
//

import Foundation

struct ResponsibleGamingConfiguration: Codable {
    let depositLimits: ResponsibleGamingOptionGroup
    let timeout: ResponsibleGamingOptionGroup
    let selfExclusion: ResponsibleGamingOptionGroup

    static let defaultConfiguration: ResponsibleGamingConfiguration = {
        ResponsibleGamingConfiguration(
            depositLimits: .init(periods: [
                .init(label: "daily", value: "daily", isDefault: true),
                .init(label: "weekly", value: "weekly"),
                .init(label: "monthly", value: "monthly")
            ]),
            timeout: .init(periods: [
                .init(label: "24_hours", value: "CoolOffFor24Hours", isDefault: true),
                .init(label: "7_days", value: "CoolOffFor7Days"),
                .init(label: "1_month", value: "CoolOffFor30Days"),
                .init(label: "3_months", value: "CoolOffFor3Months")
            ]),
            selfExclusion: .init(periods: [
                .init(label: "3_months", value: "SelfExclusionFor3Months"),
                .init(label: "6_months", value: "SelfExclusionFor6Months"),
                .init(label: "12_months", value: "SelfExclusionFor1Year"),
                .init(label: "18_months", value: "SelfExclusionCustom18Months", isCustomDate: true, apiValue: "SelfExclusionUntilSelectedDate", customDatePeriodType: "months", customDatePeriodValue: 18),
                .init(label: "24_months", value: "SelfExclusionCustom24Months", isCustomDate: true, apiValue: "SelfExclusionUntilSelectedDate", customDatePeriodType: "months", customDatePeriodValue: 24),
                .init(label: "indefinitely", value: "SelfExclusionPermanent")
            ])
        )
    }()

    static var defaultJSONData: Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return (try? encoder.encode(defaultConfiguration)) ?? Data()
    }
}

struct ResponsibleGamingOptionGroup: Codable {
    let periods: [ResponsibleGamingPeriod]
}

struct ResponsibleGamingPeriod: Codable {
    let label: String
    let value: String
    let isDefault: Bool?
    let isCustomDate: Bool?
    let apiValue: String?
    let customDatePeriodType: String?
    let customDatePeriodValue: Int?

    init(
        label: String,
        value: String,
        isDefault: Bool? = nil,
        isCustomDate: Bool? = nil,
        apiValue: String? = nil,
        customDatePeriodType: String? = nil,
        customDatePeriodValue: Int? = nil
    ) {
        self.label = label
        self.value = value
        self.isDefault = isDefault
        self.isCustomDate = isCustomDate
        self.apiValue = apiValue
        self.customDatePeriodType = customDatePeriodType
        self.customDatePeriodValue = customDatePeriodValue
    }
}
