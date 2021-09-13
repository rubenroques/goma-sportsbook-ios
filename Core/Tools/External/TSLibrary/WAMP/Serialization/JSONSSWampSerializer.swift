//
//  JSONSSWampSerializer.swift
//  Tipico
//
//  Created by Andrei Marinescu on 20/12/2019.
//  Copyright © 2019 Tipico. All rights reserved.
//

import Foundation

final class JSONSSWampSerializer: SSWampSerializer {
    
    public init() {}
    
     func pack(_ data: [Any]) -> Data? {
        do {
            return  try JSONSerialization.data(withJSONObject: data)
        }
        catch {
            return nil
        }
    }
    
     func unpack(_ data: Data) -> [Any]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data)
            return json as? [Any]
        } catch {
            return nil
        }
    }
}
