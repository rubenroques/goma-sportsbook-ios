 //
//  HomeTemplate.swift
//
//
//  Created on: May 15, 2024
//

import Foundation

public struct HomeTemplate: Codable, Hashable {
    public let id: Int
    public let clientId: Int
    public let title: String
    public let platform: String
    public let sections: [TemplateSection]

    public init(id: Int, clientId: Int, title: String, platform: String, sections: [TemplateSection]) {
        self.id = id
        self.clientId = clientId
        self.title = title
        self.platform = platform
        self.sections = sections
    }
}

public struct TemplateSection: Codable, Hashable {
    public let type: String
    public let title: String
    public let source: String

    public init(type: String, title: String, source: String) {
        self.type = type
        self.title = title
        self.source = source
    }
}
