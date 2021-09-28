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
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var editButton: UIButton!
    @IBOutlet private var depositView: UIView!
    @IBOutlet private var depositLabel: UILabel!
    @IBOutlet private var depositHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var depositFrequencySelectTextFieldView: SelectTextFieldView!
    @IBOutlet private var depositLineView: UIView!
    @IBOutlet private var bettingView: UIView!
    @IBOutlet private var bettingLabel: UILabel!
    @IBOutlet private var bettingHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var bettingFrequencySelectTextFieldView: SelectTextFieldView!
    @IBOutlet private var bettingLineView: UIView!
    @IBOutlet private var lossView: UIView!
    @IBOutlet private var lossLabel: UILabel!
    @IBOutlet private var lossHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var lossFrequencySelectHeaderTextFieldView: SelectTextFieldView!
    @IBOutlet private var lossLineView: UIView!
    @IBOutlet private var exclusionView: UIView!
    @IBOutlet private var exclusionLabel: UILabel!
    @IBOutlet private var exclusionSelectTextFieldView: SelectTextFieldView!

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

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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

        depositView.backgroundColor = UIColor.App.backgroundDarkProfile

        depositLabel.textColor = UIColor.App.headingMain

        depositHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        depositHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        depositHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        depositHeaderTextFieldView.setSecureField(false)

        depositLineView.backgroundColor = UIColor.App.headerTextFieldGray.withAlphaComponent(0.2)

        bettingView.backgroundColor = UIColor.App.backgroundDarkProfile

        bettingLabel.textColor = UIColor.App.headingMain

        bettingHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        bettingHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        bettingHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        bettingHeaderTextFieldView.setSecureField(false)

        bettingLineView.backgroundColor = UIColor.App.headerTextFieldGray.withAlphaComponent(0.2)

        lossView.backgroundColor = UIColor.App.backgroundDarkProfile

        lossLabel.textColor = UIColor.App.headingMain

        lossHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        lossHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        lossHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        lossHeaderTextFieldView.setSecureField(false)

        lossLineView.backgroundColor = UIColor.App.headerTextFieldGray.withAlphaComponent(0.2)

        exclusionView.backgroundColor = UIColor.App.backgroundDarkProfile

        exclusionLabel.textColor = UIColor.App.headingMain

    }

    func commonInit() {

        headerLabel.font = AppFont.with(type: .semibold, size: 17)
        headerLabel.text = localized("string_limits_management")

        editButton.underlineButtonTitleLabel(title: localized("string_save"))

        depositLabel.text = localized("string_deposit_limit")
        depositLabel.font = AppFont.with(type: .semibold, size: 17)

        depositHeaderTextFieldView.setPlaceholderText(localized("string_deposit_limit"))
        depositHeaderTextFieldView.setImageTextField(UIImage(named: "question-circle")!)
        depositHeaderTextFieldView.setKeyboardType(.numberPad)
        depositHeaderTextFieldView.isCurrency = true
        depositHeaderTextFieldView.didTapIcon = {
            self.showFieldInfo(view: self.depositHeaderTextFieldView.superview!)
        }

        depositFrequencySelectTextFieldView.setSelectionPicker(["Daily", "Monthly", "Anual"])

        bettingLabel.text = localized("string_betting_limit")
        bettingLabel.font = AppFont.with(type: .semibold, size: 17)

        bettingHeaderTextFieldView.setPlaceholderText(localized("string_betting_limit"))
        bettingHeaderTextFieldView.setImageTextField(UIImage(named: "question-circle")!)
        bettingHeaderTextFieldView.setKeyboardType(.numberPad)
        bettingHeaderTextFieldView.isCurrency = true
        bettingHeaderTextFieldView.didTapIcon = {
            self.showFieldInfo(view: self.bettingHeaderTextFieldView.superview!)
        }

        bettingFrequencySelectTextFieldView.setSelectionPicker(["Daily", "Monthly", "Anual"])

        lossLabel.text = localized("string_loss_limit")
        lossLabel.font = AppFont.with(type: .semibold, size: 17)

        lossHeaderTextFieldView.setPlaceholderText(localized("string_loss_limit"))
        lossHeaderTextFieldView.setImageTextField(UIImage(named: "question-circle")!)
        lossHeaderTextFieldView.setKeyboardType(.numberPad)
        lossHeaderTextFieldView.isCurrency = true
        lossHeaderTextFieldView.didTapIcon = {
            self.showFieldInfo(view: self.lossHeaderTextFieldView.superview!)
        }

        lossFrequencySelectHeaderTextFieldView.setSelectionPicker(["Daily", "Monthly", "Anual"])

        exclusionLabel.text = localized("string_auto_exclusion")
        exclusionLabel.font = AppFont.with(type: .semibold, size: 17)

        exclusionSelectTextFieldView.isIconArray = true
        exclusionSelectTextFieldView.setSelectionPicker(["Active", "Limited", "Permanent"], iconArray: [UIImage(named: "icon_active")!, UIImage(named: "icon_limited")!, UIImage(named: "icon_excluded")!])

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    // TESTING
    func showFieldInfo(view: UIView) {
        let infoView = EditAlertView()
        infoView.alertState = .info
        view.addSubview(infoView)
        NSLayoutConstraint.activate([
            infoView.topAnchor.constraint(equalTo: view.topAnchor),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            infoView.alpha = 1
        } completion: { _ in
        }

        infoView.onClose = {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
                infoView.alpha = 0
            } completion: { _ in
                infoView.removeFromSuperview()
            }
        }
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.depositHeaderTextFieldView.resignFirstResponder()
        self.bettingHeaderTextFieldView.resignFirstResponder()
        self.lossHeaderTextFieldView.resignFirstResponder()
    }

    @IBAction private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func editAction() {
        // TEST
        if depositHeaderTextFieldView.text != "" {
            self.showAlert(type: .success)
        }
        else {
            self.showAlert(type: .error)
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {

        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification) {

        let contentInset: UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }

}
