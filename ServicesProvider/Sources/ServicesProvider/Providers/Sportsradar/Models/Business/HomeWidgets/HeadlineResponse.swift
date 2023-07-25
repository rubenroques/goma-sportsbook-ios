//
//  File.swift
//  
//
//  Created by Ruben Roques on 08/06/2023.
//

import Foundation

extension SportRadarModels {

    struct HeadlineResponse: Codable {
        var headlineItems: [HeadlineItem]?

        enum CodingKeys: String, CodingKey {
            case headlineItems = "headlineItems"
        }

        init(headlineItems: [HeadlineItem]?) {
            self.headlineItems = headlineItems
        }
    }

    struct HeadlineItem: Codable {
        var idfwheadline: String?
        var marketGroupId: String?
        var marketId: String?
        var name: String?
        var title: String?
        var tsactivefrom: String?
        var tsactiveto: String?
        var idfwheadlinetype: String?
        var headlinemediatype: String?
        var categoryName: String?
        var numofselections: String?
        var imageURL: String?
        var linkURL: String?
        var oldMarketId: String?

        enum CodingKeys: String, CodingKey {
            case idfwheadline = "idfwheadline"
            case marketGroupId = "idfwmarketgroup"
            case marketId = "idfomarket"
            case name = "name"
            case title = "title"
            case tsactivefrom = "tsactivefrom"
            case tsactiveto = "tsactiveto"
            case idfwheadlinetype = "idfwheadlinetype"
            case headlinemediatype = "headlinemediatype"
            case categoryName = "categoryName"
            case numofselections = "numofselections"
            case imageURL = "imageurl"
            case linkURL = "linkurl"
            case oldMarketId = "bodytext"
        }

        init(idfwheadline: String?, marketGroupId: String?,
             marketId: String?, name: String?, title: String?,
             tsactivefrom: String?, tsactiveto: String?, idfwheadlinetype: String?,
             headlinemediatype: String?, categoryName: String?, numofselections: String?,
             imageURL: String?, linkURL: String?, oldMarketId: String?
        ) {
            self.idfwheadline = idfwheadline
            self.marketGroupId = marketGroupId
            self.marketId = marketId
            self.name = name
            self.title = title
            self.tsactivefrom = tsactivefrom
            self.tsactiveto = tsactiveto
            self.idfwheadlinetype = idfwheadlinetype
            self.headlinemediatype = headlinemediatype
            self.categoryName = categoryName
            self.numofselections = numofselections
            self.imageURL = imageURL
            self.linkURL = linkURL
            self.oldMarketId = oldMarketId
        }
    }

}
