//
//  SearchViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 20/01/2022.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var searchView: UIView!
    @IBOutlet private weak var searchBarView: UISearchBar!
    @IBOutlet private weak var cancelButton: UIButton!

    // Variables
    var viewModel: SearchViewModel

    init() {
        self.viewModel = SearchViewModel()
        super.init(nibName: "SearchViewController", bundle: nil)
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

        self.view.backgroundColor = UIColor.App.mainBackground

        self.topView.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.mainBackground

        self.searchView.backgroundColor = .clear

        self.cancelButton.backgroundColor = .clear
        self.cancelButton.tintColor = UIColor.App.headingMain
    }

    func commonInit() {

        self.searchBarView.searchBarStyle = UISearchBar.Style.prominent
        self.searchBarView.sizeToFit()
        self.searchBarView.isTranslucent = false
        self.searchBarView.backgroundImage = UIImage()
        self.searchBarView.tintColor = .white
        self.searchBarView.barTintColor = .white
        self.searchBarView.backgroundImage = UIColor.App.mainBackground.image()

        if let textfield = searchBarView.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.App.secondaryBackground
            textfield.textColor = UIColor.App.headingMain
            textfield.tintColor = UIColor.App.headingMain
            textfield.font = AppFont.with(type: .semibold, size: 14)
            textfield.attributedPlaceholder = NSAttributedString(string: localized("search_for_teams_competitions"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor:
                                                                                UIColor.App.headerTextField, NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14)])

            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = UIColor.App.headerTextField
            }
        }

        self.searchBarView.delegate = self

        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        self.containerView.addGestureRecognizer(backgroundTapGesture)

        self.cancelButton.setTitle(localized("cancel"), for: .normal)
        self.cancelButton.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
    }

    @IBAction private func didTapCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func didTapBackground() {
        self.searchBarView.resignFirstResponder()
    }

}

extension SearchViewController: UISearchBarDelegate {

    func searchMatches() {

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchMatches()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchMatches()
        self.searchBarView.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarView.text = ""
        self.searchMatches()
    }
}
