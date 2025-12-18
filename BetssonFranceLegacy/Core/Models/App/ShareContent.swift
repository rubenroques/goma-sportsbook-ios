//
//  ShareContent.swift
//  Sportsbook
//
//  Created by Claude on 28/07/2025.
//

import UIKit
import LinkPresentation

struct ShareContent {
    let image: UIImage
    let shareText: String
    let url: URL?
    let metadata: LPLinkMetadata?
    
    init(image: UIImage, shareText: String, url: URL?, metadata: LPLinkMetadata?) {
        self.image = image
        self.shareText = shareText
        self.url = url
        self.metadata = metadata
    }
    
    var activityItems: [Any] {
        var items: [Any] = []
        
        if let metadata = metadata {
            let metadataItemSource = LinkPresentationItemSource(metaData: metadata)
            items.append(metadataItemSource)
        }
        
        items.append(image)
        
        // Add ShareableImageMetaSource for better sharing experience
        let shareableItem = ShareableImageMetaSource(
            thumbnail: UIImage(named: "share_thumb_icon") ?? image,
            title: localized("partage_pari"),
            subtitle: "betsson.fr"
        )
        items.append(shareableItem)
        
        items.append(shareText)
        
        return items
    }
}
