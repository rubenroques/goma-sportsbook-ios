//
//  PhonePrefixSelectorViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 23/09/2021.
//

import UIKit
import CoreData

class PhonePrefixSelectorViewController: UIViewController {

    @IBOutlet private weak var dimmedBackgroundView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet private weak var containerBottomContraint: NSLayoutConstraint!

    @IBOutlet private weak var buttonsBarView: UIView!
    @IBOutlet private weak var containerTitleLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!

    @IBOutlet private weak var searchBarBaseView: UIView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!

    var originCountry: EveryMatrix.Country?
    var countriesListings: EveryMatrix.CountryListing

    private var originCountryString = ""
    private var countriesStringArray: [String] = []

    private var filteredCountries: [EveryMatrix.Country] = []

    var didSelectCountry: ((EveryMatrix.Country) -> Void)?

    var showIndicatives: Bool = true
    let defaultHeight: CGFloat = 380

    init(countriesArray: EveryMatrix.CountryListing, showIndicatives: Bool = true) {
        self.countriesListings = countriesArray
        self.showIndicatives = showIndicatives

        super.init(nibName: "PhonePrefixSelectorViewController", bundle: nil)

        let processedCountries = self.convertCountries(listing: self.countriesListings)
        self.countriesStringArray = processedCountries.lists
        self.originCountry = processedCountries.originaCountry

        if  let originCountry = originCountry {
            if let isoCode = originCountry.isoCode,
               let flag = CountryFlagHelper.flag(forCode: isoCode) {
                self.originCountryString = "\(originCountry.name) \(flag) \(originCountry.phonePrefix)"
            }
            else {
                self.originCountryString = "\(originCountry.name) - \(originCountry.phonePrefix)"
            }
        }

        self.filteredCountries = self.countriesListings.countries
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dimmedBackgroundView.backgroundColor = .black
        self.dimmedBackgroundView.alpha = 0.0

        self.containerView.layer.cornerRadius = 20
        self.containerView.clipsToBounds = true
        self.containerBottomContraint.constant = -(defaultHeight + 40)

        self.tableView.register(CountrySelectorTableViewCell.nib, forCellReuseIdentifier: CountrySelectorTableViewCell.identifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        self.setupWithTheme()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.animatePresentContainer()
        self.animateShowDimmedView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchBar.resignFirstResponder()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func setupWithTheme() {
        self.tableView.backgroundColor = .clear
        self.tableView.backgroundView?.backgroundColor = .clear

        self.buttonsBarView.backgroundColor = .clear
        self.containerTitleLabel.textColor = UIColor.App.headingMain
        self.containerTitleLabel.font = AppFont.with(type: .bold, size: 17)

        self.cancelButton.titleLabel?.font = AppFont.with(type: .semibold, size: 16)
        self.cancelButton.setTitle(localized("string_cancel"), for: .normal)
        self.cancelButton.setTitleColor(UIColor.App.buttonMain, for: .normal)

        self.searchBarBaseView.backgroundColor = .clear

        self.searchBar.searchBarStyle = UISearchBar.Style.prominent
        self.searchBar.sizeToFit()
        self.searchBar.isTranslucent = false
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.tintColor = .blue
        self.searchBar.barTintColor = .red
        self.searchBar.backgroundImage = UIColor.App.mainBackgroundColor.image()
        self.searchBar.placeholder = localized("string_search")

        self.searchBar.delegate = self

        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = UIColor.App.secundaryBackgroundColor
            textfield.textColor = .white
            textfield.tintColor = .white
            textfield.attributedPlaceholder = NSAttributedString(string: localized("string_search_field"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor:
                                                                                UIColor.App.fadeOutHeadingColor])

            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = UIColor.App.fadeOutHeadingColor
            }
        }
        self.containerView.backgroundColor = UIColor.App.mainBackgroundColor
    }

    func animatePresentContainer() {
        // Update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerBottomContraint?.constant = 0
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }

    func animateShowDimmedView() {
        dimmedBackgroundView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedBackgroundView.alpha = 0.4
        }
    }

    func animateDismissView() {

        // hide main container view by updating bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.searchBar.resignFirstResponder()
            self.containerBottomContraint.constant = -(self.defaultHeight + 40)
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }

        // hide blur view
        UIView.animate(withDuration: 0.4) {
            self.dimmedBackgroundView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }

    @IBAction private func didTapCancelButton() {
        self.animateDismissView()
    }

}

extension PhonePrefixSelectorViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.originCountry.hasValue, section == 0 {
            return 1
        }
        return self.filteredCountries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: CountrySelectorTableViewCell.identifier, for: indexPath) as? CountrySelectorTableViewCell
        else {
            fatalError("")
        }

        if indexPath.section == 0, let originCountryValue = originCountry {
            cell.setupWithCountry(country: originCountryValue, showPrefix: self.showIndicatives)
        }
        else if let country = self.filteredCountries[safe: indexPath.row] {
            cell.setupWithCountry(country: country, showPrefix: self.showIndicatives)
        }
        return cell
    }

}

extension PhonePrefixSelectorViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        if indexPath.section == 0, let originCountry = self.originCountry {
            self.didSelectCountry?(originCountry)
        }
        else if let selectedCountry = self.filteredCountries[safe: indexPath.row] {
            self.didSelectCountry?(selectedCountry)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        view.backgroundColor = UIColor.App.mainBackgroundColor

        let titleLabel = UILabel()
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = UIColor.App.subtitleGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.with(type: .bold, size: 12)
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 25),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        if section == 0 {
            titleLabel.text = localized("Suggested Country")
        }
        else {
            titleLabel.text = localized("Available Countries")
        }

        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

}

extension PhonePrefixSelectorViewController {

    private func convertCountries(listing: EveryMatrix.CountryListing) -> (originaCountry: EveryMatrix.Country?, lists: [String]) {

        var originaCountry: EveryMatrix.Country?
        var countryPhoneList: [String] = []

        for country in listing.countries {
            if let isoCode = country.isoCode, country.phonePrefix.isNotEmpty {
                if let flag = CountryFlagHelper.flag(forCode: isoCode) {
                    if isoCode == listing.currentIpCountry {
                        originaCountry = country
                    }
                    else {
                        countryPhoneList.append("\(country.name) \(flag) \(country.phonePrefix)")
                    }
                }
                else {
                    countryPhoneList.append("\(country.name) \(country.isoCode ?? "") \(country.phonePrefix)")
                }
            }
        }
        return (originaCountry, countryPhoneList)
    }
}

// Keyboard
extension PhonePrefixSelectorViewController {

    @objc func keyboardWillShow(notification: NSNotification) {

        guard let userInfo = notification.userInfo else { return }

        // swiftlint:disable:next force_cast
        var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        let keyboardHeight = (keyboardFrame.size.height + 26)

        self.containerViewHeight.constant = 380 + keyboardHeight
        self.tableView.contentInset.bottom = keyboardHeight
        self.tableView.verticalScrollIndicatorInsets.bottom = keyboardHeight

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }

    }

    @objc func keyboardWillHide(notification: NSNotification) {

        self.animateWithKeyboard(notification: notification) { _ in
            self.containerViewHeight.constant = 380

            self.tableView.contentInset.bottom = 0
            self.tableView.verticalScrollIndicatorInsets.bottom = 0

            self.view.layoutIfNeeded()
        }
    }

}

extension PhonePrefixSelectorViewController: UISearchBarDelegate {

    func applyFilters() {

        if self.searchBar.text?.isEmpty ?? true {
            self.filteredCountries = self.countriesListings.countries
            self.tableView.reloadData()
            return
        }

        self.filteredCountries = self.filterResults(countries: self.countriesListings.countries, withText: self.searchBar.text ?? "")
        self.tableView.reloadData()
    }

    func filterResults(countries: [EveryMatrix.Country], withText text: String) -> [EveryMatrix.Country] {

        var filteredCountries: [EveryMatrix.Country] = []

        for country in countries {
            if fuzzySearch(originalString: country.name, stringToSearch: text) ||
                country.phonePrefix.contains(text) {
                filteredCountries.append(country)
            }
        }
        return filteredCountries
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.applyFilters()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.applyFilters()
        self.searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        self.applyFilters()
    }

    func fuzzySearch(originalString: String, stringToSearch: String, caseSensitive: Bool = false) -> Bool {

        var originalStringValue = originalString
        var stringToSearchValue = stringToSearch

        if originalStringValue.isEmpty || stringToSearchValue.isEmpty {
            return false
        }

        if originalStringValue.count < stringToSearchValue.count {
            return false
        }

        if !caseSensitive {
            originalStringValue = originalStringValue.lowercased()
            stringToSearchValue = stringToSearchValue.lowercased()
        }

        var searchIndex: Int = 0

        for charOut in originalStringValue {
            for (indexIn, charIn) in stringToSearchValue.enumerated() where indexIn == searchIndex {
                if charOut == charIn {
                    searchIndex += 1
                    if searchIndex == stringToSearch.count {
                        return true
                    }
                    else {
                        break
                    }
                }
                else {
                    break
                }
            }
        }
        return false
    }
}

extension UIViewController {
    func animateWithKeyboard(notification: NSNotification, animations: ((_ keyboardFrame: CGRect) -> Void)?) {
        // Extract the duration of the keyboard animation
        let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
        guard let duration = notification.userInfo![durationKey] as? Double else { return }

        // Extract the final frame of the keyboard
        let frameKey = UIResponder.keyboardFrameEndUserInfoKey
        guard let keyboardFrameValue = notification.userInfo![frameKey] as? NSValue else { return }

        // Extract the curve of the iOS keyboard animation
        let curveKey = UIResponder.keyboardAnimationCurveUserInfoKey
        guard let curveValue = notification.userInfo![curveKey] as? Int else { return }
        let curve = UIView.AnimationCurve(rawValue: curveValue)!

        // Create a property animator to manage the animation
        let animator = UIViewPropertyAnimator(duration: duration, curve: curve) {
            // Perform the necessary animation layout updates
            animations?(keyboardFrameValue.cgRectValue)
            // Required to trigger NSLayoutConstraint changes
            // to animate
            self.view?.layoutIfNeeded()
        }
        // Start the animation
        animator.startAnimation()
    }
}
