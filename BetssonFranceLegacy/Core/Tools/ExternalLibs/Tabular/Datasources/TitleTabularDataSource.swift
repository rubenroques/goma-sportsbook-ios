//
//  TitleTabularDataSource.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/11/2021.
//

import UIKit

class TitleTabularDataSource: TabularViewDataSource {

    private var viewControllers: [UIViewController]

    var initialPage: Int = 0

    // PageboyViewControllerDataSource
    init(with viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
    }

    func setViewControllers( _ viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
    }

    // ---
    func defaultPage() -> Int {
        return initialPage
    }

    func numberOfButtons() -> Int {
        return viewControllers.count
    }
    func titleForButton(atIndex index: Int) -> String {
        guard let viewController = viewControllers[safe: index] else {
            return ""
        }
        return "\(viewController.title ?? "")"
    }

    func contentViewControllers() -> [UIViewController] {
        return viewControllers
    }

}
