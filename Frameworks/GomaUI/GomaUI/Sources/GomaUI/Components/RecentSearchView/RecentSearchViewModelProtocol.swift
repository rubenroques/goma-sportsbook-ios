//
//  RecentSearchViewModelProtocol.swift
//  GomaUI
//
//  Created on 2024-12-19.
//

import Foundation

public protocol RecentSearchViewModelProtocol {
    var searchText: String { get }
    var onTap: (() -> Void)? { get set }
    var onDelete: (() -> Void)? { get set }
}
