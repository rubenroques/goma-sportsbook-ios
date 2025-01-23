//
//  ChipsTypeViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 22/01/2025.
//
import Combine

enum ChipType {
    case textual(title: String)
    case icon(title: String, iconName: String)
    case backgroungImage(title: String, iconName: String, imageName: String)

    var title: String {
        switch self {
        case .textual(title: let title):
            return title
        case .icon(let title, _):
            return title
        case .backgroungImage(title: let title, _, _):
            return title
        }
    }
}

class ChipsTypeViewModel {

    // MARK: - Properties
    @Published private(set) var tabs: [ChipType]
    @Published private(set) var selectedIndex: Int?

    private var pendingSelectionIndex: Int?

    // MARK: - Initialization
    init(tabs: [ChipType], defaultSelectedIndex: Int?) {
        self.tabs = tabs
        self.selectedIndex = defaultSelectedIndex
    }

    // MARK: - Public Methods
    func selectTab(at index: Int) {
        guard index != selectedIndex else { return }
        if index >= 0 && index < tabs.count {
            selectedIndex = index
            pendingSelectionIndex = nil
        } else {
            // Store the selection request for when tabs are updated
            pendingSelectionIndex = index
        }
    }

    func updateTabs(_ newTabs: [ChipType]) {
        self.tabs = newTabs

        // Try to apply pending selection if it exists and is now valid
        if let pending = pendingSelectionIndex, pending >= 0 && pending < newTabs.count {
            self.selectedIndex = pending
            self.pendingSelectionIndex = nil
        }
        // Reset selection if it's no longer valid
        else if let currentIndex = selectedIndex, currentIndex >= newTabs.count {
            self.selectedIndex = nil
            self.pendingSelectionIndex = nil
        }
    }

    func numberOfTabs() -> Int {
        return self.tabs.count
    }

    func tab(at index: Int) -> ChipType? {
        return self.tabs[safe: index]
    }
}
