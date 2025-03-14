//
//  DownloadableContentsProvider.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 14/03/2025.
//

import Foundation
import Combine

protocol DownloadableContentsProvider: Connector {
    
    /// Retrieves downloadable content for the iOS platform.
    /// - Returns: A publisher that emits a GomaModels.DownloadableContent or an error.
    func getDownloadableContentItems() -> AnyPublisher<DownloadableContentItems, ServiceProviderError>
    
}
