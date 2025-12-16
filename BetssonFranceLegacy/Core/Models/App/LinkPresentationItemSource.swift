//
//  LinkPresentationItemSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/07/2025.
//

import UIKit
import LinkPresentation

class LinkPresentationItemSource: NSObject, UIActivityItemSource {
    private let metadata: LPLinkMetadata
    
    init(metaData: LPLinkMetadata) {
        self.metadata = metaData
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return metadata.url ?? ""
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return metadata.url
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        return metadata
    }
}
