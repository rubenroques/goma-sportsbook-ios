//
//  VersionUpdateViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 16/08/2021.
//

import UIKit

class VersionUpdateViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var updateView: UIView!
    @IBOutlet private var brandImageView: UIImageView!
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var updateButton: UIButton!
    @IBOutlet private var dismissButton: UIButton!

    var dismissCallback: (() -> Void)?

    // Variables
    private var updateRequired: Bool

    init(updateRequired: Bool) {
        self.updateRequired = updateRequired

        super.init(nibName: "VersionUpdateViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.isModalInPresentation = self.updateRequired

        self.commonInit()
        self.setupWithTheme()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        containerView.backgroundColor = UIColor.App.backgroundPrimary
        updateView.backgroundColor = UIColor.App.backgroundPrimary
        titleLabel.textColor = UIColor.App.textPrimary
        textLabel.textColor = UIColor.App.textPrimary
        
        updateButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        updateButton.layer.borderColor = UIColor.App.highlightPrimary.cgColor
        updateButton.layer.backgroundColor = UIColor.App.highlightPrimary.cgColor

        dismissButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        dismissButton.layer.borderWidth = 0 
    }

    func commonInit() {
        brandImageView.image = UIImage(named: "logo_horizontal_center")
        brandImageView.contentMode = .scaleAspectFit
        
        logoImageView.backgroundColor = UIColor.App.backgroundPrimary
        logoImageView.image = UIImage(named: "update_available_icon")
        logoImageView.contentMode = .scaleAspectFill

        titleLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 22)
        titleLabel.textColor = UIColor.white
        titleLabel.text = localized("update_available_title")

        textLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 16)
        textLabel.textColor = UIColor.white
        textLabel.numberOfLines = 0
        textLabel.text = localized("update_available_text")
        textLabel.sizeToFit()

        updateButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 18)
        updateButton.layer.cornerRadius = 5
        updateButton.layer.borderWidth = 1
        updateButton.setTitle(localized("update_app"), for: .normal)

        dismissButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 18)
        dismissButton.setTitle(localized("dismiss_title"), for: .normal)

        if updateRequired {
            logoImageView.image = UIImage(named: "update_required_icon")
            titleLabel.text = localized("update_required_title")
            textLabel.text = localized("update_required_text")
            
            dismissButton.isHidden = true
        }
        else {
            logoImageView.image = UIImage(named: "update_available_icon")
            titleLabel.text = localized("update_available_title")
            textLabel.text = localized("update_available_text")
            
            dismissButton.isHidden = false
        }
    }

    @IBAction private func updateAction(_ sender: UIButton) {
        if let url = URL(string: TargetVariables.appStoreUrl ?? "") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @IBAction private func dismissAction() {
        if updateRequired {
            return
        }

        self.dismissCallback?()
        
        self.dismiss(animated: true, completion: nil)
    }

}
