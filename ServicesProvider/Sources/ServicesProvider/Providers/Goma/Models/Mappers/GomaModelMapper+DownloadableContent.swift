//
//  GomaModelMapper+DownloadableContent.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 14/03/2025.
//


import Foundation

extension GomaModelMapper {
    
    static func downloadableContentItems(fromInternalDownloadableContentItems internalDownloadableContentItems: [GomaModels.DownloadableContent]) -> [DownloadableContent] {
        return internalDownloadableContentItems.map(Self.downloadableContent(fromInternalDownloadableContent:))
    }
 
    static func downloadableContent(fromInternalDownloadableContent internalDownloadableContent: GomaModels.DownloadableContent) -> DownloadableContent {
        
        return DownloadableContent(id: internalDownloadableContent.id,
                                   type: internalDownloadableContent.type,
                                   target: internalDownloadableContent.target,
                                   status: internalDownloadableContent.status,
                                   downloadUrl: internalDownloadableContent.downloadUrl)
    }
    
}
