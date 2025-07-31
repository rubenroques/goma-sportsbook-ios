//
//  CustomNavigationViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 12/06/2025.
//

import Foundation
import UIKit
import Combine

// MARK: - Data Models
public struct CustomNavigationData {
    public let id: String
    public let logoImage: String?
    public let closeIcon: String?
    public let backgroundColor: UIColor?
    public let closeButtonBackgroundColor: UIColor?
    public let closeIconTintColor: UIColor?
    
    public init(
        id: String = UUID().uuidString,
        logoImage: String? = nil,
        closeIcon: String? = nil,
        backgroundColor: UIColor? = nil,
        closeButtonBackgroundColor: UIColor? = nil,
        closeIconTintColor: UIColor? = nil
    ) {
        self.id = id
        self.logoImage = logoImage
        self.closeIcon = closeIcon
        self.backgroundColor = backgroundColor
        self.closeButtonBackgroundColor = closeButtonBackgroundColor
        self.closeIconTintColor = closeIconTintColor
    }
}

// MARK: - View Model Protocol
public protocol CustomNavigationViewModelProtocol {
    var data: CustomNavigationData { get }
    var dataPublisher: AnyPublisher<CustomNavigationData, Never> { get }
    
    func configure(with data: CustomNavigationData)
}
