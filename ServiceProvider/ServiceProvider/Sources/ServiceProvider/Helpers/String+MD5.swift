//
//  String+MD5.swift
//  
//
//  Created by Ruben Roques on 24/11/2022.
//

import Foundation
import CryptoKit

public extension String {
    public func MD5() -> String {
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
