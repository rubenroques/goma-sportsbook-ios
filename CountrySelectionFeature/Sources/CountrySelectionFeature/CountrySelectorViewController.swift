//
//  CountrySelectorViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 23/09/2021.
//

import UIKit
import CoreData
import SharedModels
import Extensions
import Theming

public final class CountrySelectorViewController: UIViewController {
    
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
    
    var originCountry: Country?
    var countries: [Country]
    
    private var originCountryString = ""
    
    private var filteredCountries: [Country] = []
    
    public var didSelectCountry: ((Country) -> Void) = { _ in }
    
    var showIndicatives: Bool = true
    let defaultHeight: CGFloat = 380
    
    public init(countries: [Country], originCountry: Country?, showIndicatives: Bool = true) {
        
        self.showIndicatives = showIndicatives
        self.countries = countries
        self.originCountry = originCountry
        
        super.init(nibName: "CountrySelectorViewController", bundle: Bundle.module)

        self.filteredCountries = self.countries
    }
    
    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.view.clipsToBounds = false

        self.dimmedBackgroundView.clipsToBounds = false

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
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.animatePresentContainer()
        self.animateShowDimmedView()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchBar.resignFirstResponder()
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.setupWithTheme()
    }
    
    func setupWithTheme() {
        self.tableView.backgroundColor = .clear
        self.tableView.backgroundView?.backgroundColor = .clear
        
        self.buttonsBarView.backgroundColor = .clear
        self.containerTitleLabel.textColor = AppColor.textPrimary
        self.containerTitleLabel.font = AppFont.with(type: .bold, size: 17)
        
        self.cancelButton.titleLabel?.font = AppFont.with(type: .semibold, size: 16)
        self.cancelButton.setTitle(Localization.localized("cancel"), for: .normal)
        self.cancelButton.setTitleColor(AppColor.highlightPrimary, for: .normal)
        
        self.searchBarBaseView.backgroundColor = .clear
        
        self.searchBar.searchBarStyle = UISearchBar.Style.prominent
        self.searchBar.sizeToFit()
        self.searchBar.isTranslucent = false
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.tintColor = .white
        self.searchBar.barTintColor = .white
        self.searchBar.backgroundImage = AppColor.backgroundPrimary.image()
        self.searchBar.placeholder = Localization.localized("search")
        
        self.searchBar.delegate = self
        
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = AppColor.backgroundSecondary
            textfield.textColor = .white
            textfield.tintColor = .white
            textfield.attributedPlaceholder = NSAttributedString(string: Localization.localized("search_field"),
                                                                 attributes: [NSAttributedString.Key.foregroundColor:
                                                                                AppColor.inputTextTitle])
            
            if let glassIconView = textfield.leftView as? UIImageView {
                glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
                glassIconView.tintColor = AppColor.inputTextTitle
            }
        }
        self.containerView.backgroundColor = AppColor.backgroundPrimary
    }
    
    public func animatePresentContainer() {
        // Update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerBottomContraint?.constant = 0
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    public func animateShowDimmedView() {
        dimmedBackgroundView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedBackgroundView.alpha = 0.4
        }
    }
    
    public func animateDismissView() {
        
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

extension CountrySelectorViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.originCountry != nil, section == 0 {
            return 1
        }
        return self.filteredCountries.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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

extension CountrySelectorViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 0, let originCountry = self.originCountry {
            self.didSelectCountry(originCountry)
        }
        else if let selectedCountry = self.filteredCountries[safe: indexPath.row] {
            self.didSelectCountry(selectedCountry)
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        view.backgroundColor = AppColor.backgroundPrimary
        
        let titleLabel = UILabel()
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = AppColor.inputTextTitle
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.with(type: .bold, size: 12)
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 25),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        if section == 0 {
            titleLabel.text = Localization.localized("suggested_country")
        }
        else {
            titleLabel.text = Localization.localized("available_countries")
        }
        
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
}

// Keyboard
extension CountrySelectorViewController {
    
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

extension CountrySelectorViewController: UISearchBarDelegate {
    
    func applyFilters() {
        
        if self.searchBar.text?.isEmpty ?? true {
            self.filteredCountries = self.countries
            self.tableView.reloadData()
            return
        }
        
        self.filteredCountries = self.filterResults(countries: self.countries, withText: self.searchBar.text ?? "")
        self.tableView.reloadData()
    }
    
    func filterResults(countries: [Country], withText text: String) -> [Country] {
        
        var filteredCountries: [Country] = []
        
        for country in countries {
            if fuzzySearch(originalString: country.name, stringToSearch: text) ||
                country.phonePrefix.contains(text) {
                filteredCountries.append(country)
            }
        }
        return filteredCountries
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.applyFilters()
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.applyFilters()
        self.searchBar.resignFirstResponder()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
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
