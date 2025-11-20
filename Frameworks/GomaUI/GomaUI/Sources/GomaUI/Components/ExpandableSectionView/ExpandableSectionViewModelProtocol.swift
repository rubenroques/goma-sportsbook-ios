//
//  ExpandableSectionViewModelProtocol.swift
//  GomaUI
//
//  Protocol defining the interface for ExpandableSectionView
//

import Foundation
import Combine

/// Protocol defining the interface for an expandable section view model
public protocol ExpandableSectionViewModelProtocol {
    /// The title displayed in the section header
    var title: String { get }
    
    /// Publisher that emits the current expanded state
    var isExpandedPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Called when the user taps the expand/collapse button
    func toggleExpanded()
}




