//
//  FullRegisterDocumentsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 24/09/2021.
//

import UIKit
import UniformTypeIdentifiers
import Combine
import ServicesProvider
import SharedModels

class FullRegisterDocumentsViewController: UIViewController {

    @IBOutlet private var topView: UIView!
    @IBOutlet private var navigationView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var progressView: UIView!
    @IBOutlet private var progressLabel: UILabel!
    @IBOutlet private var progressImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var idHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var addFileDocumentPickerView: DocumentPickerView!
    @IBOutlet private var submitButton: RoundButton!

    // Variables
    let supportedTypes = ["com.apple.iwork.pages.pages",
                          "com.apple.iwork.numbers.numbers",
                          "com.apple.iwork.keynote.key",
                          "public.image",
                          "com.apple.application",
                          "public.item",
                          "public.data",
                          "public.content",
                          "public.audiovisual-content",
                          "public.movie",
                          "public.audiovisual-content",
                          "public.video", "public.audio",
                          "public.text", "public.data",
                          "public.zip-archive",
                          "com.pkware.zip-archive",
                          "public.composite-content",
                          "public.text"]
    var cancellables = Set<AnyCancellable>()
    var registerForm: FullRegisterUserForm
    var profile: EveryMatrix.UserProfile?

    init(registerForm: FullRegisterUserForm) {
        self.registerForm = registerForm
        super.init(nibName: "FullRegisterDocumentsViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
        setupWithTheme()

        setupPublishers()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func commonInit() {
        //
        closeButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        closeButton.setTitle(localized("close"), for: .normal)

        progressLabel.text = localized("complete_signup")
        progressLabel.font = AppFont.with(type: .bold, size: 24)

        titleLabel.text = localized("documents_id")
        titleLabel.font = AppFont.with(type: .bold, size: 18)

        idHeaderTextFieldView.setPlaceholderText(localized("id_number"))

        submitButton.setTitle(localized("submit"), for: .normal)
        submitButton.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        submitButton.isEnabled = false

        // Service not implemented
        addFileDocumentPickerView.isHidden = true

        checkUserInputs()

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    func setupWithTheme() {
        topView.backgroundColor = UIColor.App.backgroundPrimary

        view.backgroundColor = UIColor.App.backgroundPrimary

        containerView.backgroundColor = UIColor.App.backgroundPrimary

        navigationView.backgroundColor = UIColor.App.backgroundPrimary

        closeButton.setTitleColor( UIColor.App.highlightPrimary, for: .normal)
        closeButton.setTitleColor( UIColor.App.highlightPrimary.withAlphaComponent(0.7), for: .highlighted)
        closeButton.setTitleColor( UIColor.App.highlightPrimary.withAlphaComponent(0.4), for: .disabled)

        progressView.backgroundColor = UIColor.App.backgroundPrimary

        progressLabel.textColor = UIColor.App.textPrimary

        titleLabel.textColor = UIColor.App.textPrimary

        idHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        idHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        idHeaderTextFieldView.setTextFieldColor(UIColor.App.textPrimary)
        idHeaderTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        idHeaderTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))

        submitButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        submitButton.setBackgroundColor(UIColor.App.buttonDisablePrimary, for: .disabled)
        submitButton.setTitleColor(UIColor.App.buttonTextDisablePrimary, for: .disabled)
        submitButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        submitButton.cornerRadius = CornerRadius.button

    }

    func setupPublishers() {
        self.idHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkUserInputs()
            })
            .store(in: &cancellables)

        self.addFileDocumentPickerView.didTapAddFile = {
            self.openFile()
        }
    }

    private func checkUserInputs() {
        let validCardId = idHeaderTextFieldView.text == "" ? false : true

        if validCardId {
            self.submitButton.isEnabled = true
        }
        else {
            self.submitButton.isEnabled = false
        }
    }

    private func openFile() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: supportedTypes, in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        documentPicker.shouldShowFileExtensions = true
        present(documentPicker, animated: true, completion: nil)
    }

    func showAlert(type: EditAlertView.AlertState, text: String = "") {

        let popup = EditAlertView()
        popup.alertState = type
        if text != "" {
            popup.setAlertText(text)
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            popup.alpha = 1
        }, completion: { _ in
        })
        popup.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(popup)
        NSLayoutConstraint.activate([
            popup.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            popup.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            popup.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        popup.onClose = {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                popup.alpha = 0
            }, completion: { _ in
                popup.removeFromSuperview()
            })
        }
        self.view.bringSubviewToFront(popup)
    }

    @IBAction private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func closeAction() {
       // self.dismiss(animated: true, completion: nil)
        
         self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func submitAction() {
        
//        guard let profile = profile else {
//            return
//        }
//
//        let gender = registerForm.title == "Mr." ? "M" : "F"
//        let form = EveryMatrix.ProfileForm(email: profile.email,
//                                           title: registerForm.title,
//                                           gender: gender,
//                                           firstname: registerForm.firstName,
//                                           surname: registerForm.lastName,
//                                           birthDate: profile.birthDate,
//                                           country: registerForm.country,
//                                           address1: registerForm.address1,
//                                           address2: registerForm.address2,
//                                           city: registerForm.city,
//                                           postalCode: registerForm.postalCode,
//                                           mobile: profile.mobile,
//                                           mobilePrefix: profile.mobilePrefix,
//                                           phone: profile.phone,
//                                           phonePrefix: profile.phonePrefix,
//                                           personalID: registerForm.personalID,
//                                           securityQuestion: registerForm.securityQuestion,
//                                           securityAnswer: registerForm.securityAnswer)
//
        var serviceProviderCountry: SharedModels.Country?
        if let countryValue = self.registerForm.country {
            serviceProviderCountry = ServiceProviderModelMapper.country(fromCountry: countryValue)
        }
        
        let mobileNumber: String = (registerForm.mobilePrefix ?? "") + (registerForm.mobileNumber ?? "")
        let form = ServicesProvider.UpdateUserProfileForm.init(username: registerForm.username,
                                                              email: registerForm.email,
                                                              firstName: registerForm.firstName,
                                                              lastName: registerForm.lastName,
                                                              birthDate: registerForm.birthDate,
                                                              gender: registerForm.gender,
                                                              address: registerForm.address,
                                                              province: registerForm.province,
                                                              city: registerForm.city,
                                                              postalCode: registerForm.postalCode,
                                                              country: serviceProviderCountry,
                                                              cardId: self.idHeaderTextFieldView.text,
                                                              mobileNumber: mobileNumber,
                                                              securityQuestion: registerForm.securityQuestion,
                                                              securityAnswer: registerForm.securityAnswer)
        
        self.fullRegisterProfile(form: form)

    }

    private func fullRegisterProfile(form: ServicesProvider.UpdateUserProfileForm) {
        
        Env.servicesProvider.signUpCompletion(form: form)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.showLoadingView()
                self?.view.isUserInteractionEnabled = false
            },
            receiveCompletion: { [weak self] _ in
                self?.hideLoadingView()
                self?.view.isUserInteractionEnabled = true
            })
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("signUpCompletion error")
                    self.showAlert(type: .error, text: "")
                case .finished:
                    ()
                }
            }, receiveValue: { _ in
                self.refreshUserProfile()
                self.navigationController?.popToRootViewController(animated: true)
            })
            .store(in: &cancellables)

        
        if let firstName = form.firstName, let lastName = form.lastName {
            Env.gomaNetworkClient.requestUpdateNameProfile(name: "\(firstName) \(lastName)")
                        .replaceError(with: MessageNetworkResponse.failed)
                        .sink { response in
                            print("Update name on GomaAPI \(response)")
                        }
                        .store(in: &cancellables)
        }
        
        
    }

    private func refreshUserProfile() {
        Env.userSessionStore.refreshUserProfile()
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        idHeaderTextFieldView.resignFirstResponder()

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

extension FullRegisterDocumentsViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let fileUrl = urls[0].lastPathComponent

        let uploadView = UploadView()
        uploadView.setTitle(fileUrl)
        uploadView.setProgressText("0%")
        uploadView.didTapClose = {
            uploadView.removeFromSuperview()
            self.addFileDocumentPickerView.fileSelected = false

            self.submitButton.isEnabled = false
            self.submitButton.backgroundColor = UIColor.App.buttonDisablePrimary
        }

        addFileDocumentPickerView.addSubview(uploadView)

        NSLayoutConstraint.activate([

            uploadView.topAnchor.constraint(equalTo: addFileDocumentPickerView.topAnchor, constant: 8),
            uploadView.trailingAnchor.constraint(equalTo: addFileDocumentPickerView.trailingAnchor, constant: -16),
            uploadView.leadingAnchor.constraint(equalTo: addFileDocumentPickerView.leadingAnchor, constant: 16),
            uploadView.bottomAnchor.constraint(equalTo: addFileDocumentPickerView.bottomAnchor, constant: -8)
        ])

        // Simulate upload
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let progress = 33.0/100
            let progressPercent = Int(progress*100)
            uploadView.setProgressText("\(progressPercent)%")
            uploadView.setProgressBar(Float(progress))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let progress = 66.0/100
            let progressPercent = Int(progress*100)
            uploadView.setProgressText("\(progressPercent)%")
            uploadView.setProgressBar(Float(progress))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let progress = 100.0/100
            let progressPercent = Int(progress*100)
            uploadView.setProgressText("\(progressPercent)%")
            uploadView.setProgressBar(Float(progress))
            self.addFileDocumentPickerView.fileSelected = true
            if self.addFileDocumentPickerView.fileSelected && self.idHeaderTextFieldView.text != "" {
                self.submitButton.isEnabled = true
                self.submitButton.backgroundColor = UIColor.App.buttonBackgroundPrimary
            }
        }

    }

     func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
