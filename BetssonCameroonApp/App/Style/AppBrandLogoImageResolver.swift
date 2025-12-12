//
//  AppBrandLogoImageResolver.swift
//  BetssonCameroonApp
//

import UIKit
import GomaUI

/// App-specific brand logo resolver that returns the appropriate logo based on build environment
struct AppBrandLogoImageResolver: BrandLogoImageResolver {

    func brandLogo() -> UIImage? {
        UIImage(named: TargetVariables.brandLogoAssetName)
    }
    
}
