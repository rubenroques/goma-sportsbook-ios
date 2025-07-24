//
//  Notification+CustomNames.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 23/07/2025.
//


import Foundation

extension Notification.Name {
    static let didMoveToInvalidLocation = Notification.Name("didMoveToInvalidLocation")
    static let didMoveToValidLocation = Notification.Name("didMoveToValidLocation")
    static let didChangeAppTheme = Notification.Name("didChangeAppTheme")
    static let targetFeaturesChanged = Notification.Name("targetFeaturesDidChange")
}
