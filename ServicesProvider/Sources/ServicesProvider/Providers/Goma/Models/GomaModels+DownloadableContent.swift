//
//  DownloadableContent.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 14/03/2025.
//

import Foundation

extension GomaModels {
    
    struct DownloadableContent: Codable {
        let id: Int
        let type: String
        let target: String?
        let status: String?
        let downloadUrl: String
        
        enum CodingKeys: String, CodingKey {
            case id, type, target, status
            case downloadUrl = "download_url"
        }
    }
}
