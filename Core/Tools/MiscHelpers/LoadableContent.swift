//
//  LoadState.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/10/2021.
//

import Foundation

enum LoadableContent<T> {
    case idle
    case loading
    case loaded(T)
    case failed
}
