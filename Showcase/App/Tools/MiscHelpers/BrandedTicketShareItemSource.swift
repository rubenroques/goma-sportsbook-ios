//
//  BrandedTicketShareItemSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 26/07/2025.
//

import Foundation
import LinkPresentation
import UIKit

//class BrandedTicketShareItemSource: NSObject, UIActivityItemSource {
//    
//    private let image: UIImage
//    private let shareText: String
//    private let linkMetadata: LPLinkMetadata
//    
//    init(image: UIImage, shareText: String) {
//        self.image = image
//        self.shareText = shareText
//        
//        // Create rich link metadata
//        self.linkMetadata = LPLinkMetadata()
//        self.linkMetadata.title = shareText
//        self.linkMetadata.imageProvider = NSItemProvider(object: image)
//        
//        if let iconImage = UIImage(named: "share_thumb_icon") {
//            self.linkMetadata.iconProvider = NSItemProvider(object: iconImage)
//        }
//        
//        super.init()
//    }
//    
//    // MARK: - UIActivityItemSource
//    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
//        return shareText
//    }
//    
//    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
//        return nil
//    }
//    
//    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
//        return shareText
//    }
//    
//    // MARK: - LinkPresentation Support
//    
//    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
//        return linkMetadata
//    }
//}
//
//

/*
///// Wraps any UIImage so you can give the share‑sheet a custom
///// thumbnail, title and (optional) subtitle.
final class ShareableImageMetaSource: NSObject, UIActivityItemSource {

    // MARK: - Init
    private let payload: UIImage          // what you really share
    private let thumb:   UIImage          // what you *show* in header
    private let title:   String
    private let subtitle: String?         // optional second line

    init(payload: UIImage,
         thumbnail: UIImage,
         title: String,
         subtitle: String? = nil)
    {
        self.payload   = payload
        self.thumb     = thumbnail
        self.title     = title
        self.subtitle  = subtitle
        super.init()
    }

    // MARK: - UIActivityItemSource
    func activityViewControllerPlaceholderItem(_ : UIActivityViewController) -> Any {
        return payload                // anything lightweight is fine
    }

    func activityViewController(_ : UIActivityViewController,
                                itemForActivityType _: UIActivity.ActivityType?) -> Any? {
        return payload                // the real data being shared
    }

    /// iOS 13+: drives the header
    func activityViewControllerLinkMetadata(_ : UIActivityViewController) -> LPLinkMetadata? {
        let meta = LPLinkMetadata()
        meta.title = title
        meta.imageProvider = NSItemProvider(object: thumb)
        meta.iconProvider = NSItemProvider(object: thumb)   // small variant

        // “Subtitle hack”—anything you put in originalURL’s *path*
        // shows up as grey text under the title.
        meta.originalURL = URL(string: "betsson.fr")
        
        return meta
    }

    /// iOS 11/12 fallback (ignored on modern OSes)
    func activityViewController(_ : UIActivityViewController,
                                thumbnailImageForActivityType _: UIActivity.ActivityType?,
                                suggestedSize size: CGSize) -> UIImage? {
        thumb
    }
}

*/


import LinkPresentation
import UniformTypeIdentifiers

final class ShareableImageMetaSource: NSObject, UIActivityItemSource {

    // MARK: private: stored stuff
    private let thumb:   UIImage     // header thumbnail
    private let title:   String
    private let subtitle: String?

    // MARK: init
    init(
         thumbnail: UIImage,
         title: String,
         subtitle: String? = nil)
    {
        self.thumb    = thumbnail
        self.title    = title
        self.subtitle = subtitle
        super.init()
    }

    // MARK: - UIActivityItemSource
    /// Placeholder & real item *must* have the same type.
    func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        return "" // fileURL
    }

    func activityViewController(_ : UIActivityViewController,
                                itemForActivityType _: UIActivity.ActivityType?) -> Any? {
        return nil // fileURL // every target gets the file
    }

    /// Header preview (iOS 13+)
    func activityViewControllerLinkMetadata(_ : UIActivityViewController) -> LPLinkMetadata? {
        let meta = LPLinkMetadata()
        meta.title         = title
        meta.imageProvider = NSItemProvider(object: thumb)
        if let subtitle { meta.originalURL = URL(string: subtitle) } // subtitle trick
        return meta
    }

    /// Thumbnail for iOS 11/12 fallback
    func activityViewController(_ : UIActivityViewController,
                                thumbnailImageForActivityType _: UIActivity.ActivityType?,
                                suggestedSize _: CGSize) -> UIImage? {
        return thumb //
    }
}

