//
//  HomeTemplateBuilder.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/05/2023.
//

import Foundation

enum HomeTemplateBuilderError: Error {
    case fileNotFound
    case invalidFormat
}

class HomeTemplateBuilder {

    init() {

    }

    func generateHomeFeedContents() -> [HomeFeedContent] {
        guard
            let parsedTemplate = try? self.parse(from: "home_template")
        else {
            return []
        }

        let externalFillers = 0
        for filler in parsedTemplate.homeFillers {

        }

        return []
    }

    private func parse(from file: String, bundle: Bundle = .main) throws -> HomeTemplate {
        guard let url = bundle.url(forResource: file, withExtension: "json") else {
            throw HomeTemplateBuilderError.fileNotFound
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(HomeTemplate.self, from: data)
        } catch {
            throw HomeTemplateBuilderError.invalidFormat
        }
    }
}

// ----
struct HomeTemplate: Codable {
    let positionedItems: [PositionedItem]
    let homeFillers: [HomeFiller]

    enum CodingKeys: String, CodingKey {
        case positionedItems = "positioned_items"
        case homeFillers = "home_fillers"
    }
}

struct PositionedItem: Codable {
    let index: Int
    let titleKey: String?
    let titleIconKey: String?
    let sectionType: String

    enum CodingKeys: String, CodingKey {
        case index
        case titleKey = "titleKey"
        case titleIconKey = "titleIconKey"
        case sectionType = "section_type"
    }
}

struct HomeFiller: Codable {
    let allowedFromIndex: Int
    let allowedToIndex: Int?
    let titleKey: String?
    let titleIconKey: String?
    let sectionType: String

    enum CodingKeys: String, CodingKey {
        case allowedFromIndex = "allowedFromIndex"
        case allowedToIndex = "allowedToIndex"
        case titleKey = "titleKey"
        case titleIconKey = "titleIconKey"
        case sectionType = "section_type"
    }
}

