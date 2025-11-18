//
//  DeviceContext.swift
//  GomaPerformanceKit
//
//  Static device and app context information
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Static device and application context
/// Captured once at app startup and attached to all performance entries
public struct DeviceContext: Codable, Equatable {
    /// Device model (e.g., "iPhone 14 Pro")
    public let deviceModel: String

    /// iOS version (e.g., "17.2.1")
    public let iosVersion: String

    /// App version (e.g., "1.5.0")
    public let appVersion: String

    /// Build number (e.g., "142")
    public let buildNumber: String

    /// Network connection type (e.g., "WiFi", "5G", "4G")
    public let networkType: String

    /// Timestamp when context was created
    public let capturedAt: Date

    public init(
        deviceModel: String,
        iosVersion: String,
        appVersion: String,
        buildNumber: String,
        networkType: String
    ) {
        self.deviceModel = deviceModel
        self.iosVersion = iosVersion
        self.appVersion = appVersion
        self.buildNumber = buildNumber
        self.networkType = networkType
        self.capturedAt = Date()
    }

    /// Create device context from current device and app info
    /// - Parameter networkType: Current network type (e.g., "WiFi", "5G")
    /// - Returns: DeviceContext with current device information
    public static func current(networkType: String) -> DeviceContext {
        #if canImport(UIKit)
        let device = UIDevice.current
        let deviceModel = device.modelName
        let iosVersion = device.systemVersion
        #else
        let deviceModel = "Unknown"
        let iosVersion = "Unknown"
        #endif

        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"

        return DeviceContext(
            deviceModel: deviceModel,
            iosVersion: iosVersion,
            appVersion: appVersion,
            buildNumber: buildNumber,
            networkType: networkType
        )
    }
}

#if canImport(UIKit)
// MARK: - UIDevice Extension for Model Name

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        // Map identifiers to readable names
        switch identifier {
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
        case "iPhone14,4": return "iPhone 13 mini"
        case "iPhone14,5": return "iPhone 13"
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"
        case "i386", "x86_64", "arm64": return "Simulator (\(identifier))"
        default: return identifier
        }
    }
}
#endif
