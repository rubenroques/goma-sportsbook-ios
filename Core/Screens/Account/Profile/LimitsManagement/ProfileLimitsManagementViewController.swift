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
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        containerView.backgroundColor = UIColor.App.backgroundPrimary

        headerView.backgroundColor = UIColor.App.backgroundPrimary

        backButton.backgroundColor = UIColor.App.backgroundPrimary
        backButton.setTitleColor(UIColor.App.textPrimary, for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.tintColor = UIColor.App.textPrimary

        headerLabel.textColor = UIColor.App.textPrimary

        editButton.backgroundColor = UIColor.App.backgroundPrimary

        depositView.backgroundColor = UIColor.App.backgroundPrimary

        depositLabel.textColor = UIColor.App.textPrimary

        depositHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        depositHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        depositHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        depositHeaderTextFieldView.setSecureField(false)

        depositLineView.backgroundColor = UIColor.App.inputTextTitle.withAlphaComponent(0.2)

        bettingView.backgroundColor = UIColor.App.backgroundPrimary

        bettingLabel.textColor = UIColor.App.textPrimary

        bettingHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        bettingHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        bettingHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        bettingHeaderTextFieldView.setSecureField(false)

        bettingLineView.backgroundColor = UIColor.App.inputTextTitle.withAlphaComponent(0.2)

        lossView.backgroundColor = UIColor.App.backgroundPrimary

        lossLabel.textColor = UIColor.App.textPrimary

        lossHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        lossHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        lossHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        lossHeaderTextFieldView.setSecureField(false)

        lossLineView.backgroundColor = UIColor.App.inputTextTitle.withAlphaComponent(0.2)

        exclusionView.backgroundColor = UIColor.App.backgroundPrimary

        exclusionLabel.textColor = UIColor.App.textPrimary

    }

    func commonInit() {

        headerLabel.font = AppFont.with(type: .semibold, size: 17)
        headerLabel.text = localized("limits_management")

        editButton.underlineButtonTitleLabel(title: localized("save"))

        depositLabel.text = localized("deposit_limit")
        depositLabel.font = AppFont.with(type: .semibold, size: 17)

        depositHeaderTextFieldView.setPlaceholderText(localized("deposit_limit"))
        depositHeaderTextFieldView.setImageTextField(UIImage(named: "question_circle_icon")!)
        depositHeaderTextFieldView.setKeyboardType(.numberPad)
        depositHeaderTextFieldView.isCurrency = true
        depositHeaderTextFieldView.didTapIcon = {
            self.showFieldInfo(view: self.depositHeaderTextFieldView.superview!)
        }

        depositFrequencySelectTextFieldView.setSelectionPicker([localized("daily"), localized("monthly"), localized("anual")])

        bettingLabel.text = localized("betting_limit")
        bettingLabel.font = AppFont.with(type: .semibold, size: 17)

        bettingHeaderTextFieldView.setPlaceholderText(localized("betting_limit"))
        bettingHeaderTextFieldView.setImageTextField(UIImage(named: "question_circle_icon")!)
        bettingHeaderTextFieldView.setKeyboardType(.numberPad)
        bettingHeaderTextFieldView.isCurrency = true
        bettingHeaderTextFieldView.didTapIcon = {
            self.showFieldInfo(view: self.bettingHeaderTextFieldView.superview!)
        }

        bettingFrequencySelectTextFieldView.setSelectionPicker([localized("daily"), localized("monthly"), localized("anual")])

        lossLabel.text = localized("loss_limit")
        lossLabel.font = AppFont.with(type: .semibold, size: 17)

        lossHeaderTextFieldView.setPlaceholderText(localized("loss_limit"))
        lossHeaderTextFieldView.setImageTextField(UIImage(named: "question_circle_icon")!)
        lossHeaderTextFieldView.setKeyboardType(.numberPad)
        lossHeaderTextFieldView.isCurrency = true
        lossHeaderTextFieldView.didTapIcon = {
            self.showFieldInfo(view: self.lossHeaderTextFieldView.superview!)
        }

        lossFrequencySelectHeaderTextFieldView.setSelectionPicker([localized("daily"), localized("monthly"), localized("anual")])

        exclusionLabel.text = localized("auto_exclusion")
        exclusionLabel.font = AppFont.with(type: .semibold, size: 17)

        exclusionSelectTextFieldView.isIconArray = true
        exclusionSelectTextFieldView.setSelectionPicker([localized("active"), localized("limited"), localized("permanent")],
                                                        iconArray: [UIImage(named: "icon_active")!,
                                                                    UIImage(named: "icon_limited")!,
                                                                    UIImage(named: "icon_excluded")!])

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

        guard
            let userInfo = notification.userInfo,
            var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }
        
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
