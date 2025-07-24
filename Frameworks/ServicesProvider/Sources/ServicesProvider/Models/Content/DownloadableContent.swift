//
//  DownloadableContent.swift
//  ServicesProvider
//
//  Created by Ruben Roques on 14/03/2025.
//
import Foundation

public typealias DownloadableContentItems = [DownloadableContent]

public struct DownloadableContent: Codable {
    public let id: Int
    public let type: String
    public let target: String?
    public let status: String?
    public let downloadUrl: String
}
