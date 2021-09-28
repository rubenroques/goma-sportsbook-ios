//
//  SportsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/09/2021.
//

import UIKit

class SportsViewController: UIViewController {

    @IBOutlet private weak var filtersBarBaseView: UIView!
    @IBOutlet private weak var filtersSeparatorLineView: UIView!
    @IBOutlet private weak var tableView: UITableView!

    init() {
        super.init(nibName: "SportsViewController", bundle: nil)
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

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackgroundColor

        self.filtersBarBaseView.backgroundColor = UIColor.App.mainBackgroundColor
        self.filtersSeparatorLineView.backgroundColor = UIColor.App.separatorLineColor
        self.filtersSeparatorLineView.alpha = 0.25
        
        self.tableView.backgroundColor = UIColor.App.mainBackgroundColor
        self.tableView.backgroundView?.backgroundColor = UIColor.App.mainBackgroundColor
    }

    func commonInit() {

    }

}
