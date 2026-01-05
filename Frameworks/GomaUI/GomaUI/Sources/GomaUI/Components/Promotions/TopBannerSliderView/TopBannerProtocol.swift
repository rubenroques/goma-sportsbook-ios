import Foundation
import UIKit

/// Protocol for banner components that can be displayed in a horizontal scroll view
public protocol TopBannerProtocol {
    /// The type identifier for this banner
    var type: String { get }
    
    /// Whether this banner should be visible
    var isVisible: Bool { get }
}

/// Protocol for UIView-based banner components that can be rendered in the TopBannerSliderView
public protocol TopBannerViewProtocol: UIView, TopBannerProtocol {
    /// Called when the banner becomes visible in the slider
    func bannerDidBecomeVisible()
    
    /// Called when the banner is no longer visible in the slider
    func bannerDidBecomeHidden()
} 