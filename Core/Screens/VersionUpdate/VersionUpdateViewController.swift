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
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var updateButton: UIButton!
    @IBOutlet private var dismissButton: UIButton!

    var dismissCallback: (() -> ())?
    // Variables
    var imageGradient: UIImage
    var required: Bool

    init(required: Bool) {
        self.required = required
        self.imageGradient = UIImage()

        super.init(nibName: "VersionUpdateViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageGradient = UIImage().getGradientColorImage(red: 37, green: 40, blue: 50, alpha: 1.0, bounds: self.view.bounds)

        commonInit()
        setupWithTheme()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor(patternImage: imageGradient)
        containerView.backgroundColor = UIColor(patternImage: imageGradient)
        updateView.backgroundColor = UIColor(patternImage: imageGradient)
        titleLabel.textColor = UIColor.App.headingMain
        textLabel.textColor = UIColor.App.headingMain
        updateButton.setTitleColor(UIColor.white, for: .normal)
        updateButton.layer.borderColor = UIColor.App.buttonMain.cgColor
        updateButton.layer.backgroundColor = UIColor.App.buttonMain.cgColor
        dismissButton.setTitleColor(UIColor.white, for: .normal)
        dismissButton.layer.borderColor = .none
        dismissButton.layer.backgroundColor = UIColor.white.withAlphaComponent(0).cgColor
    }

    func commonInit() {

        logoImageView.backgroundColor = UIColor(patternImage: imageGradient)
        logoImageView.image = UIImage(named: "update_available_icon")
        logoImageView.contentMode = .scaleAspectFill

        titleLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 22)
        titleLabel.textColor = UIColor.white
        titleLabel.text = localized("string_update_available_title")

        textLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 16)
        textLabel.textColor = UIColor.white
        textLabel.numberOfLines = 0
        textLabel.text = localized("string_update_available_text")
        textLabel.sizeToFit()

        updateButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 18)
        updateButton.layer.cornerRadius = 5
        updateButton.layer.borderWidth = 1
        updateButton.setTitle(localized("string_update_app"), for: .normal)

        dismissButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 18)
        dismissButton.setTitle(localized("string_dismiss_title"), for: .normal)

        if required {
            logoImageView.image = UIImage(named: "update_required_icon")
            titleLabel.text = localized("string_update_required_title")
            textLabel.text = localized("string_update_required_text")
            dismissButton.isHidden = true
        }
        else {
            logoImageView.image = UIImage(named: "update_available_icon")
            titleLabel.text = localized("string_update_available_title")
            textLabel.text = localized("string_update_available_text")
        }
    }

    @IBAction private func updateAction(_ sender: UIButton) {
        UIApplication.shared.open(NSURL(string: "https://gomadevelopment.pt/")! as URL, options: [:], completionHandler: nil)
    }

    @IBAction private func dismissAction() {
        if required {
            return
        }

        self.dismissCallback?()
        
        self.dismiss(animated: true, completion: nil)
    }

}
