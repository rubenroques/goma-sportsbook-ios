//
//  String+Extensions.swift
//  
//
//  Created by Ruben Roques on 04/12/2022.
//

import Foundation
import CryptoKit

public extension String {
    func MD5() -> String {
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
