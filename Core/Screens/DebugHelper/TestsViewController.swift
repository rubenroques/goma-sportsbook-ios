//
//  TestsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/07/2021.
//

import UIKit
import Combine
import SwiftUI

class TestsViewController: UIViewController {

    @IBOutlet private weak var openProfileButton: UIButton!

    var cancellables = Set<AnyCancellable>()

    init() {
        super.init(nibName: "TestsViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.buttonBackgroundPrimary
    }

    @IBAction private func didTapAPITest() {

    }

    @IBAction private func didTapUserSettings() {

    }

    @IBAction func testEveryMatrixAPI() {

    }

    @IBAction func testSubscription() {

    }

    @IBAction func testSubscriptionInitialDump() {

    }

    @IBAction private func didTapOpenProfileButton() {

    }

    @IBAction private func didTapLoginProfileButton() {

    }

}
