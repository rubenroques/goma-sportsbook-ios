//
//  MatchFiltersViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/10/2021.
//

import UIKit

class MatchFiltersViewController: UIViewController {

    init() {
        super.init(nibName: "MatchFiltersViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func setupSubviews() {
        self.setupWithTheme()
    }

    func setupWithTheme() {
        
    }
    
}
