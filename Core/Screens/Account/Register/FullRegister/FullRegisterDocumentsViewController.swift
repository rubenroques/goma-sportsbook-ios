//
//  FullRegisterDocumentsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 24/09/2021.
//

import UIKit

class FullRegisterDocumentsViewController: UIViewController {

    init() {
        super.init(nibName: "FullRegisterDocumentsViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
        setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func commonInit() {

    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundDarkProfile
    }

}
