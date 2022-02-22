//
//  LinkPresentationItemSource.swift
//  Sportsbook
//
//  Created by André Lascas on 17/02/2022.
//

import Foundation
import LinkPresentation

class LinkPresentationItemSource: NSObject, UIActivityItemSource {
    var linkMetaData = LPLinkMetadata()

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {

        return linkMetaData
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return linkMetaData.originalURL
    }

    init(metaData: LPLinkMetadata) {
        self.linkMetaData = metaData
    }
}
