//
//  VersionUpdateViewController.swift
//  ShowcaseProd
//
//  Created by André Lascas on 16/08/2021.
//

import UIKit

class VersionUpdateViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var updateButton: UIButton!

    init() {
        super.init(nibName: "VersionUpdateViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupWithTheme()
        commonInit()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.Core.tint
        containerView.backgroundColor = UIColor.Core.tint
        titleLabel.textColor = UIColor.Core.headingMain
        textLabel.textColor = UIColor.Core.headingMain
    }

    func commonInit() {
        titleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 30)
        titleLabel.textColor = UIColor.white
        titleLabel.text = "iOS Update" // FIXME: As strings não podem esar hardcoded, devem estar no ficheiro Localizable.strings como no exemplo abaixo
        textLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 24)
        textLabel.textColor = UIColor.white
        textLabel.numberOfLines = 0
        textLabel.text = localized("string_update_available") // FIXME: Exemplo
        textLabel.sizeToFit()
        updateButton.layer.cornerRadius = 5
        updateButton.layer.borderWidth = 1
        updateButton.layer.borderColor = UIColor.black.cgColor
        updateButton.setTitleColor(UIColor.white, for: .normal)

        if Env.appUpdateType == "optional" {
            titleLabel.text = "iOS Update Available"
            textLabel.text = "There's a new version available (Version: \(String(describing: UserDefaults.standard.object(forKey: "ios_current_version")!))). Visit the App Store to update to the newest version."
            updateButton.setTitle("OK!", for: .normal)
        }
        else if Env.appUpdateType == "required" {
            titleLabel.text = "iOS Update Required"
            textLabel.text = "To proceed an app update is required. Required minimum version: \(String(describing: UserDefaults.standard.object(forKey: "ios_required_version")!))"
            updateButton.setTitle("Update", for: .normal)

        }
    }

    @IBAction private func updateAction(_ sender: UIButton) {
        if Env.appUpdateType == "optional" {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            UIApplication.shared.open(NSURL(string: "http://www.apple.com")! as URL, options: [:], completionHandler: nil)
        }
    }

}
