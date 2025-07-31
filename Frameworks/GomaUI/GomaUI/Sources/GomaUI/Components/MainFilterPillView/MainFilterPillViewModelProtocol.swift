//
//  MainFilterViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 22/05/2025.
//

import Foundation
import UIKit
import Combine

public protocol MainFilterPillViewModelProtocol {
    
    func didTapMainFilterItem()-> QuickLinkType
    
    var mainFilterState: CurrentValueSubject<MainFilterStateType, Never> { get set }
    var mainFilterSubject: CurrentValueSubject<MainFilterItem, Never> { get }
}
