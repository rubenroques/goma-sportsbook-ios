//
//  File.swift
//
//
//  Created by Ruben Roques on 27/09/2023.
//

import Foundation

public struct ServicesProviderConfiguration {

    public enum Environment {
        case production
        case staging
        case development
    }

    private(set) var environment: Environment = .production
    private(set) var deviceUUID: String?

    public init(environment: Environment = .production, deviceUUID: String? = nil) {
        self.environment = environment
        self.deviceUUID = deviceUUID
    }

}
