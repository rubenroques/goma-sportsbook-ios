//
//  AvatarAssets.swift
//  RegisterFlow
//
//  Created by André Lascas on 21/02/2025.
//

import Foundation
import UIKit

public enum AvatarBrand {
    case betsson
    case goma
    
    var assetName: String {
        switch self {
        case .betsson:
            return "Betsson"
        case .goma:
            return "GOMA"
        }
    }
}

public enum AvatarAssets {
    public static var currentBrand: AvatarBrand = .betsson
    
    private static var registerFlowBundle: Bundle? {
        let mainBundle = Bundle.main
        if let bundlePath = mainBundle.path(forResource: "RegisterFlow_RegisterFlow", ofType: "bundle"),
           let bundle = Bundle(path: bundlePath) {
            return bundle
        }
        return nil
    }
    
    public static func image(named name: String, brand: AvatarBrand = currentBrand) -> UIImage? {
            guard let bundle = registerFlowBundle else {
                print("Could not find RegisterFlow bundle")
                return nil
            }
            
        let brandFolder = brand.assetName
        if let image = UIImage(named: "\(brandFolder)/\(name)", in: bundle, compatibleWith: nil) {
            return image
        }
        
        print("Could not find image \(name) in \(brand.assetName)")
        return nil
    }
    
}
