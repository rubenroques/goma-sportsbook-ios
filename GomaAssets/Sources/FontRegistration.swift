//
//  FontRegistration.swift
//  GomaAssets
//
//  Created by Ruben Roques on 16/10/2024.
//

import UIKit
import CoreGraphics
import CoreText

public enum FontError: Swift.Error {
   case failedToRegisterFont
}


public protocol CustomFont: CaseIterable {
    var familyName: String { get }
    var weightName: String { get }
    var fullName: String { get }
    var containerFolderName: String? { get }
}

public enum Roboto: CustomFont {

    case black
    case bold
    case light
    case medium
    case regular
    case thin

    public var familyName: String {
        return "Roboto"
    }

    public var weightName: String {
        switch self {
        case .thin: return "Thin"
        case .light: return "Light"
        case .regular: return "Regular"
        case .medium: return "Medium"
        case .black: return "Black"
        case .bold: return "Bold"
        }
    }

    public var fullName: String {
        return "\(self.familyName)-\(self.weightName)"
    }

    public var containerFolderName: String? {
        return "Roboto"
    }

}

public func registerFont<T: CustomFont>(_ customFont: T.Type) throws {
    for fontWeight in customFont.allCases {
        try registerFontWeight(named: fontWeight.fullName,
                               folderName: fontWeight.containerFolderName)
    }
}

public func registerFontWeight(named name: String, folderName: String? = nil) throws {
    let fullName = [folderName, name].compactMap({ $0 }).joined(separator: "/")
    guard let asset = NSDataAsset(name: fullName, bundle: Bundle.module),
          let provider = CGDataProvider(data: asset.data as NSData),
          let font = CGFont(provider),
          CTFontManagerRegisterGraphicsFont(font, nil) else {
        throw FontError.failedToRegisterFont
    }
}
