//
//  TimeSliderViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 27/05/2025.
//

import Foundation
import Combine

public protocol TimeSliderViewModelProtocol {
    var title: String { get }
    var timeOptions: [TimeOption] { get }
    var selectedTimeValue: CurrentValueSubject<Float, Never> { get }
    func didChangeValue(_ value: Float)
}
