//
//  MarketGroupCardsScrollDelegate.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 22/07/2025.
//


import UIKit

// MARK: - MarketGroupCardsScrollDelegate
protocol MarketGroupCardsScrollDelegate: AnyObject {
    func marketGroupCardsDidScroll(_ scrollView: UIScrollView, scrollDirection: ScrollDirection, in viewController: MarketGroupCardsViewController)
    func marketGroupCardsDidEndScrolling(_ scrollView: UIScrollView, in viewController: MarketGroupCardsViewController)
}

// MARK: - ScrollDirection
enum ScrollDirection {
    case up
    case down
    case none
}