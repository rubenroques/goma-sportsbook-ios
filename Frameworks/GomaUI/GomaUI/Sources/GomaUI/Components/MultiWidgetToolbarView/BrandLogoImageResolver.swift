//
//  BrandLogoImageResolver.swift
//  GomaUI
//

import UIKit

/// Protocol for resolving brand logo images
/// Apps implement this to provide their own brand assets based on client/environment
public protocol BrandLogoImageResolver {
    /// Returns the brand logo image for the top bar
    /// - Returns: The brand logo UIImage, or nil if not found
    func brandLogo() -> UIImage?
}

/// Default implementation that returns the Betsson logo from GomaUI bundle
public struct DefaultBrandLogoImageResolver: BrandLogoImageResolver {
    public init() {}

    public func brandLogo() -> UIImage? {
        UIImage(named: "default_brand_horizontal", in: Bundle.module, with: nil)
    }
}
