//
//  MockHeaderTextViewViewModel.swift
//  GomaUI
//
//  Created by Assistant on 2025-01-27.
//

import Foundation
import Combine
import UIKit

public class MockHeaderTextViewViewModel: HeaderTextViewViewModelProtocol {
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
