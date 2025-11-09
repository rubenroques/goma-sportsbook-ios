import Foundation


public final class MockSimpleSquaredFilterBarViewModel {

    // MARK: - Static Factory Methods

    public static var timeFilters: SimpleSquaredFilterBarData {
        SimpleSquaredFilterBarData(
            items: [
                ("all", "All"),
                ("1d", "1D"),
                ("1w", "1W"),
                ("1m", "1M"),
                ("3m", "3M")
            ],
            selectedId: "all"
        )
    }

    public static var statusFilters: SimpleSquaredFilterBarData {
        SimpleSquaredFilterBarData(
            items: [
                ("active", LocalizationProvider.string("active")),
                ("pending", LocalizationProvider.string("pending")),
                ("completed", LocalizationProvider.string("done")),
                ("cancelled", LocalizationProvider.string("void"))
            ],
            selectedId: "active"
        )
    }

    public static var priorityFilters: SimpleSquaredFilterBarData {
        SimpleSquaredFilterBarData(
            items: [
                ("low", "Low"),
                ("medium", "Medium"),
                ("high", "High"),
                ("urgent", "Urgent")
            ],
            selectedId: "medium"
        )
    }

    public static var categoryFilters: SimpleSquaredFilterBarData {
        SimpleSquaredFilterBarData(
            items: [
                ("all", "All"),
                ("payments", LocalizationProvider.string("payments")),
                ("games", "Games"),
                ("bonuses", LocalizationProvider.string("bonuses"))
            ],
            selectedId: "all"
        )
    }

    public static var gameTypeFilters: SimpleSquaredFilterBarData {
        SimpleSquaredFilterBarData(
            items: [
                ("live", LocalizationProvider.string("live")),
                ("upcoming", LocalizationProvider.string("upcoming")),
                ("finished", "Finished")
            ],
            selectedId: "live"
        )
    }

    public static var defaultMock: SimpleSquaredFilterBarData {
        timeFilters
    }
}
