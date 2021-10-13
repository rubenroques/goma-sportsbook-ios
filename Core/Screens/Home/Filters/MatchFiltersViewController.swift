//
//  MatchFiltersViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/10/2021.
//

import UIKit

class MatchFiltersViewController: UIViewController {

    @IBOutlet private var topView: UIView!
    @IBOutlet private var navigationView: UIView!
    @IBOutlet private var navigationLabel: UILabel!
    @IBOutlet private var cancelButton: UIButton!
    
    init() {
        super.init(nibName: "MatchFiltersViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.commonInit()
        self.setupWithTheme()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.commonInit()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func commonInit() {
        navigationLabel.text = localized("string_choose_sport")
        navigationLabel.font = AppFont.with(type: .bold, size: 16)

        cancelButton.setTitle(localized("string_cancel"), for: .normal)
        cancelButton.titleLabel?.font = AppFont.with(type: .semibold, size: 16)
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackground
        topView.backgroundColor = UIColor.App.mainBackground
        navigationView.backgroundColor = UIColor.App.mainBackground
        navigationLabel.textColor = UIColor.App.headingMain
        cancelButton.setTitleColor(UIColor.App.mainTint, for: .normal)
    }
    
}
