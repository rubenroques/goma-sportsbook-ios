//
//  ProfileLimitsManagementViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 22/09/2021.
//

import UIKit

class ProfileLimitsManagementViewController: UIViewController {

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var backView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var editButton: UIButton!

    init() {
        super.init(nibName: "ProfileLimitsManagementViewController", bundle: nil)
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

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundDarkProfile

        containerView.backgroundColor = UIColor.App.backgroundDarkProfile

        headerView.backgroundColor = UIColor.App.backgroundDarkProfile

        backButton.backgroundColor = UIColor.App.backgroundDarkProfile
        backButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.tintColor = UIColor.App.headingMain

        headerLabel.textColor = UIColor.App.headingMain

        editButton.backgroundColor = UIColor.App.backgroundDarkProfile
    }

    func commonInit() {

    }

}
