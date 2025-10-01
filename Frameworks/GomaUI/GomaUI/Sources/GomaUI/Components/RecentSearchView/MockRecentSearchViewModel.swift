//
//  MockRecentSearchViewModel.swift
//  GomaUI
//
//  Created by Assistant on 2024-12-19.
//

import Foundation

public class MockRecentSearchViewModel: RecentSearchViewModelProtocol {
    public var searchText: String
    public var onTap: (() -> Void)?
    public var onDelete: (() -> Void)?
    
    public init(
        searchText: String = "Liverpool",
        onTap: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.searchText = searchText
        self.onTap = onTap
        self.onDelete = onDelete
    }
}
