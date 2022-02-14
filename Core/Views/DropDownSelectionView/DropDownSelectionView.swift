//
//  DropDownSelectionView.swift
//  Sportsbook
//
//  Created by Teresa on 08/02/2022.
//

import UIKit
import CombineCocoa
import Combine

class DropDownSelectionView: UIView {
    
    // MARK: - Private Properties
    // Sub Views
    private lazy var containerView: UIView = Self.createView()
    
    private lazy var baseView: UIView = Self.createView()
    
    private lazy var placeholder: UILabel = Self.createPlaceholder()
    
    private lazy var textField: UITextField = Self.createTextField()
    
  
    
    
    // MARK: - Lifetime and Cycle

    @available(iOS, unavailable)
    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    func commonInit() {
      // cenas que os inits precisam chamar    super.viewDidLoad()
        
        self.setupSubviews()
 
    
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}


//
// MARK: - Subviews Initialization and Setup
//
extension DropDownSelectionView {

    private static func createView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createPlaceholder() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "TITLE"
        return label
    }
    
    private static func createTextField() -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = "text field"
        return textField
    }
    
    func setTextFieldColor(_ color: UIColor) {
        self.textField.textColor = color
    }
    
    func setPlaceholderText(_ placeholder: String) {
        self.textField.placeholder = ""
        self.placeholder.text = placeholder
    }
  
    func setPlaceholderLabelColor(_ color: UIColor) {
        self.placeholder.backgroundColor = color
    }
    
    func setPlaceholderTextColor(_ color: UIColor) {
        self.placeholder.textColor = color
    }
    
    func setViewColor(_ color: UIColor) {
        self.containerView.backgroundColor = .yellow
    }
    func setViewBorderColor(_ color: UIColor) {
        self.containerView.layer.borderColor = color.cgColor
    }

    
    private func setupSubviews() {

        // Add subviews to self.view or each other
        
        self.baseView.backgroundColor = UIColor.App.backgroundSecondary
        self.baseView.layer.cornerRadius = CornerRadius.headerInput

        self.baseView.layer.borderWidth = 1
        self.baseView.layer.borderColor = UIColor.systemPink.cgColor
        
       
        //self.containerView.addSubview(self.placeholder)
        self.baseView.addSubview(self.placeholder)
        
        self.containerView.addSubview(self.baseView)
        self.baseView.addSubview(self.textField)
        self.addSubview(self.containerView)
    

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.placeholder.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.placeholder.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.placeholder.topAnchor.constraint(equalTo: self.topAnchor),
            self.placeholder.heightAnchor.constraint(equalToConstant: 20),

            self.textField.leadingAnchor.constraint(equalTo: self.placeholder.leadingAnchor),
            self.textField.trailingAnchor.constraint(equalTo: self.placeholder.trailingAnchor),
            self.textField.topAnchor.constraint(equalTo: self.placeholder.bottomAnchor),
            self.textField.bottomAnchor.constraint(equalTo: self.bottomAnchor),
/*
            self.topSliderSeparatorView.leadingAnchor.constraint(equalTo: self.topSliderBaseView.leadingAnchor),
            self.topSliderSeparatorView.trailingAnchor.constraint(equalTo: self.topSliderBaseView.trailingAnchor),
            self.topSliderSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            self.topSliderSeparatorView.bottomAnchor.constraint(equalTo: self.topSliderBaseView.bottomAnchor),*/
        ])
/*
        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.topAnchor.constraint(equalTo: self.topSliderBaseView.bottomAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
        ])

        NSLayoutConstraint.activate([
            self.betslipCountLabel.trailingAnchor.constraint(equalTo: self.betslipButtonView.trailingAnchor, constant: 2),
            self.betslipCountLabel.topAnchor.constraint(equalTo: self.betslipButtonView.topAnchor, constant: -3),

            self.betslipButtonView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
            self.betslipButtonView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -12),
        ])
*/
    }
    
    
}
