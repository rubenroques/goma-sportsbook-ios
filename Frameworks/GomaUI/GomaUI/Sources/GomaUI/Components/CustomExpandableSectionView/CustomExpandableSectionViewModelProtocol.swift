//
//  CustomExpandableSectionViewModelProtocol.swift
//  GomaUI
//
//  Created by GPT-5.1 Codex on 17/11/2025.
//

import Combine
import Foundation

public protocol CustomExpandableSectionViewModelProtocol: AnyObject {
    var title: String { get }
    var leadingIconName: String? { get }
    var collapsedIconName: String? { get }
    var expandedIconName: String? { get }
    var isExpandedPublisher: AnyPublisher<Bool, Never> { get }
    func toggleExpanded()
}

