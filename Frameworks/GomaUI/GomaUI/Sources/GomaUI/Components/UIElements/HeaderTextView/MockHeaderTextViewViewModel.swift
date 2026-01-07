//
//  MockHeaderTextViewModel.swift
//  GomaUI
//
//  Created on 2025-01-27.
//

import Foundation
import Combine
import UIKit

public class MockHeaderTextViewModel: HeaderTextViewModelProtocol {
    public var title: String
    
    public var refreshData: (() -> Void)?
    
    public init(
        title: String = ""
    ) {
        self.title = title
    }
    
    public func updateTitle(_ title: String) {
        self.title = title
        self.refreshData?()
    }
    
}
