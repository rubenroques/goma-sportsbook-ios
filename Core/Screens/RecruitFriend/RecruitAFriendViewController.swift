//
//  RecruitAFriendViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 12/07/2023.
//

import UIKit
import ServicesProvider
import Combine

class RecruitAFriendViewModel {
    
    var referralLink: ReferralLink?
    var referees: [Referee] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    var shouldSetupReferees: PassthroughSubject<Void, Never> = .init()
    
    init() {
        self.getReferralLink()
        self.getReferees()
    }
    
    private func getReferralLink() {
        
        Env.servicesProvider.getReferralLink()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("GET REFERRAL LINK ERROR: \(error)")
                }
            }, receiveValue: { [weak self] referralLink in
                
                let mappedReferralLink = ServiceProviderModelMapper.referralLink(fromServiceProviderReferralLink: referralLink)
                
                self?.referralLink = mappedReferralLink
            })
            .store(in: &cancellables)
    }
    
    private func getReferees() {
        
        Env.servicesProvider.getReferees()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("GET REFEREES ERROR: \(error)")
                }
                
                self?.shouldSetupReferees.send()

            }, receiveValue: { [weak self] referees in
                
                let mappedReferees = referees.map( {
                    ServiceProviderModelMapper.referee(fromServiceProviderReferee: $0)
                })
                
                self?.referees = mappedReferees
            })
            .store(in: &cancellables)
    }
}

class RecruitAFriendViewController: UIViewController {

    // MARK: Private properties
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var navigationTitleLabel: UILabel = Self.createNavigationTitleLabel()

    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var bannerImageView: UIImageView = Self.createBannerImageView()

    private lazy var recruitBonusInfoBaseView: UIView = Self.createRecruitBonusBaseView()
    private lazy var recruitBonusTitleLabel: UILabel = Self.createRecruitBonusTitleLabel()
    private lazy var recruitBonusDescriptionLabel: UILabel = Self.createRecruitBonusDescriptionLabel()

    private lazy var recruitReferralStackView: UIStackView = Self.createRecruitReferralStackView()

    private lazy var recruitReferralBaseView: UIView = Self.createRecruitReferralBaseView()
    private lazy var recruitReferralDescriptionLabel: UILabel = Self.createRecruitReferralDescriptionLabel()

    private lazy var recruitInvalidBaseView: UIView = Self.createRecruitInvalidBaseView()
    private lazy var recruitInvalidTitleLabel: UILabel = Self.createRecruitInvalidTitleLabel()
    private lazy var recruitInvalidDescriptionLabel: UILabel = Self.createRecruitInvalidDescriptionLabel()
    private lazy var recruitInvalidDocumentsButton: UIButton = Self.createRecruitInvalidDocumentsButton()
    private lazy var recruitInvalidDepositButton: UIButton = Self.createRecruitInvalidDepositButton()

    private lazy var recruitMethodsBaseView: UIView = Self.createRecruitMethodsBaseView()
    private lazy var recruitMethodsTitleLabel: UILabel = Self.createRecruitMethodsTitleLabel()
    private lazy var recruitMethodsDescriptionLabel: UILabel = Self.createRecruitMethodsDescriptionLabel()

    private lazy var shareBaseView: UIView = Self.createShareBaseView()
    private lazy var shareCounterView: UIView = Self.createShareCounterView()
    private lazy var shareCounterLabel: UILabel = Self.createShareCounterLabel()
    private lazy var shareTitleLabel: UILabel = Self.createShareTitleLabel()
    private lazy var shareDescriptionLabel: UILabel = Self.createShareDescriptionLabel()
    private lazy var shareButton: UIButton = Self.createShareButton()

    private lazy var qrCodeBaseView: UIView = Self.createQRCodeBaseView()
    private lazy var qrCodeCounterView: UIView = Self.createQRCodeCounterView()
    private lazy var qrCodeCounterLabel: UILabel = Self.createQRCodeCounterLabel()
    private lazy var qrCodeTitleLabel: UILabel = Self.createQRCodeTitleLabel()
    private lazy var qrCodeDescriptionLabel: UILabel = Self.createQRCodeDescriptionLabel()
    private lazy var qrCodeButton: UIButton = Self.createQRCodeButton()

    private lazy var referralsBaseView: UIView = Self.createReferralsBaseView()
    private lazy var referralsTitleLabel: UILabel = Self.createReferralsTitleLabel()
    private lazy var referralsDescriptionLabel: UILabel = Self.createReferralsDescriptionLabel()
    private lazy var referralsStackView: UIStackView = Self.createReferralsStackView()
    private lazy var referralsGodfatherBaseView: UIView = Self.createReferralsGodfatherBaseView()
    private lazy var referralsGodfatherTitleLabel: UILabel = Self.createReferralsGodfatherTitleLabel()
    private lazy var referralsGodfatherStackView: UIStackView = Self.createReferralsGodfatherStackView()
    private lazy var referralsGodfatherView: UserGodfatherView = Self.createReferralsGodfatherView()
    private lazy var referralsEmptyGodfatherView: EmptyReferralView = Self.createReferralsEmptyGodfatherView()

    private lazy var regulationsBaseView: UIView = Self.createRegulationsBaseView()
    private lazy var regulationsTitleLabel: UILabel = Self.createRegulationsTitleLabel()
    private lazy var regulationsDescriptionLabel: UILabel = Self.createRegulationsDescriptionLabel()

    // Constraints
    private lazy var bannerImageViewFixedHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewFixedHeightConstraint()
    private lazy var bannerImageViewDynamicHeightConstraint: NSLayoutConstraint = Self.createBannerImageViewDynamicHeightConstraint()
    private lazy var referralsStackViewBottomBaseConstraint: NSLayoutConstraint = Self.createReferralsStackViewBottomBaseConstraint()
    private lazy var referralsStackViewBottomGodfatherConstraint: NSLayoutConstraint = Self.createReferralsStackViewBottomGodfatherConstraint()
    private lazy var regulationReferralsTopConstraint: NSLayoutConstraint = Self.createRegulationReferralsTopConstraint()
    private lazy var regulationRecruitTopConstraint: NSLayoutConstraint = Self.createRegulationRecruitTopConstraint()
    
    private lazy var recruitMethodsBaseViewTopToStackConstraint: NSLayoutConstraint = Self.createRecruitMethodsBaseViewTopToStackConstraint()
    private lazy var recruitMethodsBaseViewTopToBonusInfoConstraint: NSLayoutConstraint = Self.createRecruitMethodsBaseViewTopToBonusInfoConstraint()


    private var aspectRatio: CGFloat = 1.0
    
    private var viewModel: RecruitAFriendViewModel

    // MARK: Public Properties
    var hasGodfather: Bool = false {
        didSet {
            self.referralsGodfatherView.isHidden = true
            self.referralsEmptyGodfatherView.isHidden = true

            self.referralsStackViewBottomBaseConstraint.isActive = !hasGodfather

            self.referralsStackViewBottomGodfatherConstraint.isActive = hasGodfather
        }
    }

    var isKYCVerified: Bool = false {
        didSet {

            if isKYCVerified {
                self.recruitInvalidDocumentsButton.setBackgroundColor(UIColor.App.alertSuccess, for: .normal)
                self.recruitInvalidDocumentsButton.setBackgroundColor(UIColor.App.alertSuccess.withAlphaComponent(0.7), for: .disabled)
            }
            else {
                self.recruitInvalidDocumentsButton.setBackgroundColor(UIColor.App.alertError, for: .normal)
                self.recruitInvalidDocumentsButton.setBackgroundColor(UIColor.App.alertError.withAlphaComponent(0.7), for: .disabled)

            }

            self.recruitInvalidDocumentsButton.isUserInteractionEnabled = !isKYCVerified
            self.recruitInvalidDocumentsButton.isEnabled = !isKYCVerified

//            self.regulationReferralsTopConstraint.isActive = isKYCVerified
//
//            self.regulationRecruitTopConstraint.isActive = !isKYCVerified
//
//            self.referralsBaseView.isHidden = !isKYCVerified

        }
    }

    var hasDeposit: Bool = false {
        didSet {
            if hasDeposit {
                self.recruitInvalidDepositButton.setBackgroundColor(UIColor.App.alertSuccess, for: .normal)
                self.recruitInvalidDepositButton.setBackgroundColor(UIColor.App.alertSuccess.withAlphaComponent(0.7), for: .disabled)
            }
            else {
                self.recruitInvalidDepositButton.setBackgroundColor(UIColor.App.alertError, for: .normal)
                self.recruitInvalidDepositButton.setBackgroundColor(UIColor.App.alertError.withAlphaComponent(0.7), for: .disabled)

            }

            self.recruitInvalidDepositButton.isUserInteractionEnabled = !hasDeposit
            self.recruitInvalidDepositButton.isEnabled = !hasDeposit
        }
    }
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: Lifetime and cycle
    init(viewModel: RecruitAFriendViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.shareButton.addTarget(self, action: #selector(didTapShareButton), for: .primaryActionTriggered)

        self.qrCodeButton.addTarget(self, action: #selector(didTapQRCode), for: .primaryActionTriggered)

        self.recruitInvalidDocumentsButton.addTarget(self, action: #selector(didTapDocuments), for: .primaryActionTriggered)

        self.recruitInvalidDepositButton.addTarget(self, action: #selector(didTapDeposit), for: .primaryActionTriggered)

        self.checkPlayerStatus()
        
        self.bind(toViewModel: self.viewModel)
    }
    
    private func checkPlayerStatus() {
        
        if let isUserKycVerified = Env.userSessionStore.userKnowYourCustomerStatus, isUserKycVerified == .pass {
            self.isKYCVerified = true
        }
        else {
            self.isKYCVerified = false
        }
        
        if let hasMadeDeposit = Env.userSessionStore.userProfilePublisher.value?.hasMadeDeposit {
            self.hasDeposit = hasMadeDeposit
        }
        else {
            self.hasDeposit = false
        }

        let isPlayerLocked = Env.userSessionStore.userProfilePublisher.value?.lockedStatus == .locked ? true : false
//        let isPlayerLocked = true

        if !isKYCVerified || !hasDeposit || isPlayerLocked {
            
            self.regulationReferralsTopConstraint.isActive = false
            
            self.regulationRecruitTopConstraint.isActive = true
            
            self.recruitReferralStackView.isHidden = false
            
            self.recruitMethodsBaseViewTopToStackConstraint.isActive = true
            
            self.recruitMethodsBaseViewTopToBonusInfoConstraint.isActive = false
            
            self.referralsBaseView.isHidden = true

            self.recruitReferralBaseView.isHidden = true

            self.recruitInvalidBaseView.isHidden = false

            self.shareButton.isEnabled = false

            self.qrCodeButton.isEnabled = false
        }
        else if isKYCVerified && hasDeposit && !isPlayerLocked {
            
            self.regulationReferralsTopConstraint.isActive = true
            
            self.regulationRecruitTopConstraint.isActive = false
            
            self.recruitReferralStackView.isHidden = true
            
            self.recruitMethodsBaseViewTopToStackConstraint.isActive = false
            
            self.recruitMethodsBaseViewTopToBonusInfoConstraint.isActive = true
            
            self.referralsBaseView.isHidden = false

            self.recruitReferralBaseView.isHidden = false

            self.recruitInvalidBaseView.isHidden = true

            self.shareButton.isEnabled = true

            self.qrCodeButton.isEnabled = true
        }

        self.hasGodfather = false

        //self.setupReferrals()
    }

    // MARK: Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.recruitBonusInfoBaseView.layer.cornerRadius = CornerRadius.card

        self.recruitReferralBaseView.layer.cornerRadius = CornerRadius.card

        self.recruitInvalidBaseView.layer.cornerRadius = CornerRadius.card

        self.recruitMethodsBaseView.layer.cornerRadius = CornerRadius.card

        self.shareCounterView.layer.cornerRadius = self.shareCounterView.frame.height / 2

        self.qrCodeCounterView.layer.cornerRadius = self.qrCodeCounterView.frame.height / 2

        self.referralsBaseView.layer.cornerRadius = CornerRadius.card

        self.regulationsBaseView.layer.cornerRadius = CornerRadius.card

        self.resizeBannerImageView()

        for arrangedSubview in self.referralsStackView.arrangedSubviews {

            arrangedSubview.setNeedsLayout()
            arrangedSubview.layoutIfNeeded()
        }
    }

    private func setupWithTheme() {

        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary

        self.backButton.backgroundColor = .clear

        self.navigationTitleLabel.textColor = UIColor.App.textPrimary

        self.scrollView.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.recruitBonusInfoBaseView.backgroundColor = UIColor.App.backgroundCards

        self.recruitBonusTitleLabel.textColor = UIColor.App.highlightPrimary

        self.recruitBonusDescriptionLabel.textColor = UIColor.App.textPrimary

        self.recruitReferralBaseView.backgroundColor = UIColor.App.backgroundCards
        self.recruitReferralBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor

        self.recruitInvalidBaseView.backgroundColor = UIColor.App.backgroundCards
        self.recruitInvalidBaseView.layer.borderColor = UIColor.App.highlightPrimary.cgColor

        self.recruitInvalidTitleLabel.textColor = UIColor.App.highlightPrimary

        self.recruitInvalidDescriptionLabel.textColor = UIColor.App.textPrimary

        self.recruitInvalidDocumentsButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.recruitInvalidDocumentsButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.recruitInvalidDocumentsButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .disabled)
        self.recruitInvalidDocumentsButton.setBackgroundColor(UIColor.App.alertError, for: .normal)
        self.recruitInvalidDocumentsButton.setBackgroundColor(UIColor.App.alertError, for: .highlighted)
        self.recruitInvalidDocumentsButton.setBackgroundColor(UIColor.App.alertError.withAlphaComponent(0.7), for: .disabled)

        self.recruitInvalidDepositButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.recruitInvalidDepositButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.recruitInvalidDepositButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .disabled)
        self.recruitInvalidDepositButton.setBackgroundColor(UIColor.App.alertError, for: .normal)
        self.recruitInvalidDepositButton.setBackgroundColor(UIColor.App.alertError, for: .highlighted)
        self.recruitInvalidDepositButton.setBackgroundColor(UIColor.App.alertError, for: .disabled)

        self.recruitMethodsBaseView.backgroundColor = UIColor.App.backgroundCards

        self.recruitMethodsTitleLabel.textColor = UIColor.App.highlightPrimary

        self.recruitMethodsDescriptionLabel.textColor = UIColor.App.textPrimary

        self.shareBaseView.backgroundColor = .clear

        self.shareCounterView.backgroundColor = UIColor.App.highlightPrimary

        self.shareCounterLabel.textColor = UIColor.App.buttonTextPrimary

        self.shareTitleLabel.textColor = UIColor.App.textPrimary

        self.shareDescriptionLabel.textColor = UIColor.App.textPrimary

        StyleHelper.styleButton(button: self.shareButton)
        self.shareButton.setBackgroundColor(UIColor.App.buttonDisablePrimary, for: .disabled)

        self.qrCodeBaseView.backgroundColor = .clear

        self.qrCodeCounterView.backgroundColor = UIColor.App.highlightPrimary

        self.qrCodeCounterLabel.textColor = UIColor.App.buttonTextPrimary

        self.qrCodeTitleLabel.textColor = UIColor.App.textPrimary

        self.qrCodeDescriptionLabel.textColor = UIColor.App.textPrimary

        StyleHelper.styleButton(button: self.qrCodeButton)
        self.qrCodeButton.setBackgroundColor(UIColor.App.buttonDisablePrimary, for: .disabled)

        self.referralsBaseView.backgroundColor = UIColor.App.backgroundCards

        self.referralsTitleLabel.textColor = UIColor.App.highlightPrimary

        self.referralsDescriptionLabel.textColor = UIColor.App.textPrimary

        self.referralsStackView.backgroundColor = .clear

        self.referralsGodfatherTitleLabel.textColor = UIColor.App.highlightPrimary

        self.regulationsBaseView.backgroundColor = UIColor.App.backgroundCards

        self.regulationsTitleLabel.textColor = UIColor.App.highlightPrimary

        self.regulationsDescriptionLabel.textColor = UIColor.App.textPrimary
    }
    
    // MARK: Binding
    private func bind(toViewModel viewModel: RecruitAFriendViewModel) {
        
        viewModel.shouldSetupReferees
            .sink(receiveValue: { [weak self] in
                self?.setupReferrals()
            })
            .store(in: &cancellables)
    }

    // MARK: Functions
    private func resizeBannerImageView() {

        if let bannerImage = self.bannerImageView.image {

            self.aspectRatio = bannerImage.size.width/bannerImage.size.height

            self.bannerImageViewFixedHeightConstraint.isActive = false

            self.bannerImageViewDynamicHeightConstraint =
            NSLayoutConstraint(item: self.bannerImageView,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: self.bannerImageView,
                               attribute: .width,
                               multiplier: 1/self.aspectRatio,
                               constant: 0)

            self.bannerImageViewDynamicHeightConstraint.isActive = true
        }
    }

    private func setupReferrals() {

        let referees = self.viewModel.referees
        
        if referees.isNotEmpty {
            
            for referee in referees {
                let referralView = UserReferralView()
                
                let isKycValidated = referee.kycStatus == .request ? false : true
                referralView.configure(title: "\(referee.username)",
                                       icon: "referral_avatar",
                                       isKycValidated: isKycValidated,
                                       hasDeposit: referee.depositPassed)
                
                self.referralsStackView.addArrangedSubview(referralView)
            }
        }
        else {
            let emptyReferralView = EmptyReferralView()
            emptyReferralView.configure(title: localized("referral_no_friends"))
            self.referralsStackView.addArrangedSubview(emptyReferralView)
        }
        
        self.referralsStackView.setNeedsLayout()
        self.referralsStackView.layoutIfNeeded()
    }

    // MARK: Actions
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapShareButton() {
        
        if let referralLink = viewModel.referralLink?.link {
            
            guard var url = URL(string: "\(referralLink)") else { return }
            
            let shareActivityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            if let popoverController = shareActivityViewController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            self.present(shareActivityViewController, animated: true, completion: nil)
        }
    }

    @objc private func didTapQRCode() {
        if let referralLink = viewModel.referralLink?.link {
            
            let referralQRCodeViewController = ReferralQRCodeViewController(referralLink: referralLink)
            
            referralQRCodeViewController.modalPresentationStyle = .overCurrentContext
            referralQRCodeViewController.modalTransitionStyle = .crossDissolve
            
            self.present(referralQRCodeViewController, animated: true)
        }
    }

    @objc private func didTapDocuments() {
        let documentsRootViewModel = DocumentsRootViewModel()

        let documentsRootViewController = DocumentsRootViewController(viewModel: documentsRootViewModel)

        let navigationViewController = Router.navigationController(with: documentsRootViewController)

        self.present(navigationViewController, animated: true)
    }

    @objc private func didTapDeposit() {
        let depositViewController = DepositViewController()

        let navigationViewController = Router.navigationController(with: depositViewController)

        depositViewController.shouldRefreshUserWallet = { [weak self] in
            Env.userSessionStore.refreshUserWallet()
        }

        self.present(navigationViewController, animated: true)
    }
}

extension RecruitAFriendViewController {

    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "arrow_back_icon")
        button.setImage(image, for: .normal)
        button.setTitle(nil, for: .normal)
        return button
    }

    private static func createNavigationTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 20)
        label.text = localized("referal_friend")
        label.textAlignment = .center
        return label
    }

    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView

    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBannerImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "betsson_banner")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    private static func createRecruitBonusBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRecruitBonusTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 18)
        label.text = localized("rf_first_title")
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createRecruitBonusDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.text = localized("rf_first_description")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.addLineHeight(to: label, lineHeight: 18)
        return label
    }

    private static func createRecruitReferralStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }

    private static func createRecruitReferralBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        return view
    }

    private static func createRecruitReferralDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.text = localized("rf_second_description")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.addLineHeight(to: label, lineHeight: 18)

        let sponsors = 1
        let days = 19

//        let sponsorsText = sponsors == 1 ?
//        localized("referrals_number_single").replacingFirstOccurrence(of: "{number}", with: "\(sponsors)") :
//        localized("referrals_number").replacingFirstOccurrence(of: "{number}", with: "\(sponsors)")
        let sponsorsText = "\(sponsors)"

        let daysText = days == 1 ?
        localized("days_number_single").replacingFirstOccurrence(of: "{number}", with: "\(days)") :
        localized("days_number").replacingFirstOccurrence(of: "{number}", with: "\(days)")

        let text = localized("rf_second_description").replacingFirstOccurrence(of: "{referrals}", with: sponsorsText).replacingFirstOccurrence(of: "{days}", with: daysText)

        let highlightAttributedString = NSMutableAttributedString(string: text)

        let range1 = (text as NSString).range(of: sponsorsText)
        let range2 = (text as NSString).range(of: daysText)

        highlightAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.App.highlightPrimary, range: range1)

        highlightAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.App.highlightPrimary, range: range2)

        label.attributedText = highlightAttributedString

        return label
    }

    private static func createRecruitInvalidBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        return view
    }

    private static func createRecruitInvalidTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 18)
        label.text = localized("rf_second_title_nv")
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createRecruitInvalidDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.text = localized("rf_second_description_nv")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.addLineHeight(to: label, lineHeight: 18)
        return label
    }

    private static func createRecruitInvalidDocumentsButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("rf_second_first_bottom_nv"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        button.layer.cornerRadius = CornerRadius.button
        button.layer.masksToBounds = true
        button.backgroundColor = .clear
        button.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 0, bottom: 10.0, right: 0)
        return button
    }

    private static func createRecruitInvalidDepositButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("rf_second_second_bottom_nv"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        button.layer.cornerRadius = CornerRadius.button
        button.layer.masksToBounds = true
        button.backgroundColor = .clear
        button.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 0, bottom: 10.0, right: 0)
        return button
    }

    private static func createRecruitMethodsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRecruitMethodsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 18)
        label.text = localized("rf_third_title")
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createRecruitMethodsDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.text = localized("rf_third_sub_title")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.addLineHeight(to: label, lineHeight: 18)
        return label
    }

    private static func createShareBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createShareCounterView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createShareCounterLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 12)
        label.text = "1"
        label.textAlignment = .center
        return label
    }

    private static func createShareTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.text = localized("rf_third_fs_title")
        label.textAlignment = .left
        return label
    }

    private static func createShareDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.text = localized("rf_third_fs_description")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.addLineHeight(to: label, lineHeight: 18)
        return label
    }

    private static func createShareButton() -> UIButton {
        let button = UIButton()
        button.setTitle(localized("rf_third_fs_bottom"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = CornerRadius.button
        button.contentEdgeInsets = UIEdgeInsets(top: 15.0, left: 30.0, bottom: 15.0, right: 30.0)
        return button
    }

    private static func createQRCodeBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createQRCodeCounterView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createQRCodeCounterLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 12)
        label.text = "2"
        label.textAlignment = .center
        return label
    }

    private static func createQRCodeTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.text = localized("rf_third_ss_title")
        label.textAlignment = .left
        return label
    }

    private static func createQRCodeDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.text = localized("rf_third_ss_description")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.addLineHeight(to: label, lineHeight: 18)
        return label
    }

    private static func createQRCodeButton() -> UIButton {
        let button = UIButton()
        button.setTitle(localized("rf_third_ss_bottom"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = CornerRadius.button
        button.contentEdgeInsets = UIEdgeInsets(top: 15.0, left: 30.0, bottom: 15.0, right: 30.0)
        return button
    }

    private static func createReferralsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createReferralsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.text = localized("rf_fourth_title")
        label.textAlignment = .left
        return label
    }

    private static func createReferralsDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.text = localized("rf_fourth_description")
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createReferralsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }

    private static func createReferralsGodfatherBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createReferralsGodfatherTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.text = localized("rf_fourth_second_title")
        label.textAlignment = .left
        return label
    }
    
    private static func createReferralsGodfatherStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }

    private static func createReferralsGodfatherView() -> UserGodfatherView {
        let view = UserGodfatherView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(title: "Godfather", icon: "godfather_avatar")
        return view
    }
    
    private static func createReferralsEmptyGodfatherView() -> EmptyReferralView {
        let view = EmptyReferralView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(title: localized("no_godfather"))
        return view
    }

    private static func createRegulationsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createRegulationsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 18)
        label.text = localized("rf_fifth_title")
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createRegulationsDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .regular, size: 14)
        label.text = localized("rf_fifth_description")
        label.textAlignment = .left
        label.numberOfLines = 0
        label.addLineHeight(to: label, lineHeight: 18)
        return label
    }

    // Constraints
    private static func createBannerImageViewFixedHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createBannerImageViewDynamicHeightConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createReferralsStackViewBottomBaseConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createReferralsStackViewBottomGodfatherConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createRegulationReferralsTopConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createRegulationRecruitTopConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private static func createRecruitMethodsBaseViewTopToStackConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private static func createRecruitMethodsBaseViewTopToBonusInfoConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {

        self.view.addSubview(self.navigationView)

        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.navigationTitleLabel)

        self.view.addSubview(self.scrollView)

        self.scrollView.addSubview(self.containerView)

        self.containerView.addSubview(self.bannerImageView)

        self.containerView.addSubview(self.recruitBonusInfoBaseView)

        self.recruitBonusInfoBaseView.addSubview(self.recruitBonusTitleLabel)
        self.recruitBonusInfoBaseView.addSubview(self.recruitBonusDescriptionLabel)

        self.containerView.addSubview(self.recruitReferralStackView)

        self.recruitReferralStackView.addArrangedSubview(self.recruitReferralBaseView)

        self.recruitReferralBaseView.addSubview(self.recruitReferralDescriptionLabel)

        self.recruitReferralStackView.addArrangedSubview(self.recruitInvalidBaseView)

        self.recruitInvalidBaseView.addSubview(self.recruitInvalidTitleLabel)
        self.recruitInvalidBaseView.addSubview(self.recruitInvalidDescriptionLabel)
        self.recruitInvalidBaseView.addSubview(self.recruitInvalidDocumentsButton)
        self.recruitInvalidBaseView.addSubview(self.recruitInvalidDepositButton)

        self.containerView.addSubview(self.recruitMethodsBaseView)

        self.recruitMethodsBaseView.addSubview(self.recruitMethodsTitleLabel)
        self.recruitMethodsBaseView.addSubview(self.recruitMethodsDescriptionLabel)

        self.recruitMethodsBaseView.addSubview(self.shareBaseView)

        self.shareBaseView.addSubview(self.shareCounterView)

        self.shareCounterView.addSubview(self.shareCounterLabel)

        self.shareBaseView.addSubview(self.shareTitleLabel)
        self.shareBaseView.addSubview(self.shareDescriptionLabel)
        self.shareBaseView.addSubview(self.shareButton)

        self.recruitMethodsBaseView.addSubview(self.qrCodeBaseView)

        self.qrCodeBaseView.addSubview(self.qrCodeCounterView)

        self.qrCodeCounterView.addSubview(self.qrCodeCounterLabel)

        self.qrCodeBaseView.addSubview(self.qrCodeTitleLabel)
        self.qrCodeBaseView.addSubview(self.qrCodeDescriptionLabel)
        self.qrCodeBaseView.addSubview(self.qrCodeButton)

        self.containerView.addSubview(self.referralsBaseView)

        self.referralsBaseView.addSubview(self.referralsTitleLabel)
        self.referralsBaseView.addSubview(self.referralsDescriptionLabel)
        self.referralsBaseView.addSubview(self.referralsStackView)
        self.referralsBaseView.addSubview(self.referralsGodfatherBaseView)

        self.referralsGodfatherBaseView.addSubview(self.referralsGodfatherTitleLabel)
        self.referralsGodfatherBaseView.addSubview(self.referralsGodfatherStackView)
        self.referralsGodfatherStackView.addArrangedSubview(self.referralsGodfatherView)
        self.referralsGodfatherStackView.addArrangedSubview(self.referralsEmptyGodfatherView)

        self.containerView.addSubview(self.regulationsBaseView)

        self.regulationsBaseView.addSubview(self.regulationsTitleLabel)
        self.regulationsBaseView.addSubview(self.regulationsDescriptionLabel)

        self.initConstraints()

        self.referralsGodfatherBaseView.setNeedsLayout()
        self.referralsGodfatherBaseView.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            self.backButton.heightAnchor.constraint(equalTo: self.backButton.widthAnchor),

            self.navigationTitleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 50),
            self.navigationTitleLabel.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -50),
            self.navigationTitleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
        ])

        NSLayoutConstraint.activate([

            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.containerView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            self.containerView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor),

            self.bannerImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.bannerImageView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.bannerImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor)
        ])

        // Recruit bonus Info
        NSLayoutConstraint.activate([
            self.recruitBonusInfoBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.recruitBonusInfoBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.recruitBonusInfoBaseView.topAnchor.constraint(equalTo: self.bannerImageView.bottomAnchor, constant: 15),

            self.recruitBonusTitleLabel.leadingAnchor.constraint(equalTo: self.recruitBonusInfoBaseView.leadingAnchor, constant: 16),
            self.recruitBonusTitleLabel.trailingAnchor.constraint(equalTo: self.recruitBonusInfoBaseView.trailingAnchor, constant: -16),
            self.recruitBonusTitleLabel.topAnchor.constraint(equalTo: self.recruitBonusInfoBaseView.topAnchor, constant: 16),

            self.recruitBonusDescriptionLabel.leadingAnchor.constraint(equalTo: self.recruitBonusTitleLabel.leadingAnchor),
            self.recruitBonusDescriptionLabel.trailingAnchor.constraint(equalTo: self.recruitBonusTitleLabel.trailingAnchor),
            self.recruitBonusDescriptionLabel.topAnchor.constraint(equalTo: self.recruitBonusTitleLabel.bottomAnchor, constant: 7),
            self.recruitBonusDescriptionLabel.bottomAnchor.constraint(equalTo: self.recruitBonusInfoBaseView.bottomAnchor, constant: -16)
        ])

        // Recruit referral Info
        NSLayoutConstraint.activate([

            self.recruitReferralStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.recruitReferralStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.recruitReferralStackView.topAnchor.constraint(equalTo: self.recruitBonusInfoBaseView.bottomAnchor, constant: 15),

//            self.recruitReferralBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
//            self.recruitReferralBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
//            self.recruitReferralBaseView.topAnchor.constraint(equalTo: self.recruitBonusInfoBaseView.bottomAnchor, constant: 15),

            self.recruitReferralDescriptionLabel.leadingAnchor.constraint(equalTo: self.recruitReferralBaseView.leadingAnchor, constant: 16),
            self.recruitReferralDescriptionLabel.trailingAnchor.constraint(equalTo: self.recruitReferralBaseView.trailingAnchor, constant: -16),
            self.recruitReferralDescriptionLabel.topAnchor.constraint(equalTo: self.recruitReferralBaseView.topAnchor, constant: 16),
            self.recruitReferralDescriptionLabel.bottomAnchor.constraint(equalTo: self.recruitReferralBaseView.bottomAnchor, constant: -16),

            self.recruitInvalidTitleLabel.leadingAnchor.constraint(equalTo: self.recruitInvalidBaseView.leadingAnchor, constant: 16),
            self.recruitInvalidTitleLabel.trailingAnchor.constraint(equalTo: self.recruitInvalidBaseView.trailingAnchor, constant: -16),
            self.recruitInvalidTitleLabel.topAnchor.constraint(equalTo: self.recruitInvalidBaseView.topAnchor, constant: 16),

            self.recruitInvalidDescriptionLabel.leadingAnchor.constraint(equalTo: self.recruitInvalidTitleLabel.leadingAnchor),
            self.recruitInvalidDescriptionLabel.trailingAnchor.constraint(equalTo: self.recruitInvalidTitleLabel.trailingAnchor),
            self.recruitInvalidDescriptionLabel.topAnchor.constraint(equalTo: self.recruitInvalidTitleLabel.bottomAnchor, constant: 7),

            self.recruitInvalidDocumentsButton.leadingAnchor.constraint(equalTo: self.recruitInvalidTitleLabel.leadingAnchor),
            self.recruitInvalidDocumentsButton.trailingAnchor.constraint(equalTo: self.recruitInvalidBaseView.centerXAnchor, constant: -8),
            self.recruitInvalidDocumentsButton.topAnchor.constraint(equalTo: self.recruitInvalidDescriptionLabel.bottomAnchor, constant: 16),
            self.recruitInvalidDocumentsButton.bottomAnchor.constraint(equalTo: self.recruitInvalidBaseView.bottomAnchor, constant: -16),

            self.recruitInvalidDepositButton.leadingAnchor.constraint(equalTo: self.recruitInvalidBaseView.centerXAnchor, constant: 8),
            self.recruitInvalidDepositButton.trailingAnchor.constraint(equalTo: self.recruitInvalidTitleLabel.trailingAnchor),
            self.recruitInvalidDepositButton.centerYAnchor.constraint(equalTo: self.recruitInvalidDocumentsButton.centerYAnchor)
        ])

        // Recruit methods Info
        NSLayoutConstraint.activate([
            self.recruitMethodsBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.recruitMethodsBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
//            self.recruitMethodsBaseView.topAnchor.constraint(equalTo: self.recruitReferralStackView.bottomAnchor, constant: 15),

            self.recruitMethodsTitleLabel.leadingAnchor.constraint(equalTo: self.recruitMethodsBaseView.leadingAnchor, constant: 16),
            self.recruitMethodsTitleLabel.trailingAnchor.constraint(equalTo: self.recruitMethodsBaseView.trailingAnchor, constant: -16),
            self.recruitMethodsTitleLabel.topAnchor.constraint(equalTo: self.recruitMethodsBaseView.topAnchor, constant: 16),

            self.recruitMethodsDescriptionLabel.leadingAnchor.constraint(equalTo: self.recruitMethodsTitleLabel.leadingAnchor),
            self.recruitMethodsDescriptionLabel.trailingAnchor.constraint(equalTo: self.recruitMethodsTitleLabel.trailingAnchor),
            self.recruitMethodsDescriptionLabel.topAnchor.constraint(equalTo: self.recruitMethodsTitleLabel.bottomAnchor, constant: 7)

        ])

        // Recruit share Info
        NSLayoutConstraint.activate([
            self.shareBaseView.leadingAnchor.constraint(equalTo: self.recruitMethodsBaseView.leadingAnchor, constant: 8),
            self.shareBaseView.trailingAnchor.constraint(equalTo: self.recruitMethodsBaseView.trailingAnchor, constant: -8),
            self.shareBaseView.topAnchor.constraint(equalTo: self.recruitMethodsDescriptionLabel.bottomAnchor, constant: 7),

            self.shareCounterView.leadingAnchor.constraint(equalTo: self.shareBaseView.leadingAnchor, constant: 8),
            self.shareCounterView.topAnchor.constraint(equalTo: self.shareBaseView.topAnchor, constant: 8),
            self.shareCounterView.widthAnchor.constraint(equalToConstant: 15),
            self.shareCounterView.heightAnchor.constraint(equalTo: self.shareCounterView.widthAnchor),

            self.shareCounterLabel.centerXAnchor.constraint(equalTo: self.shareCounterView.centerXAnchor),
            self.shareCounterLabel.centerYAnchor.constraint(equalTo: self.shareCounterView.centerYAnchor),

            self.shareTitleLabel.leadingAnchor.constraint(equalTo: self.shareCounterView.trailingAnchor, constant: 10),
            self.shareTitleLabel.trailingAnchor.constraint(equalTo: self.shareBaseView.trailingAnchor, constant: -8),
            self.shareTitleLabel.topAnchor.constraint(equalTo: self.shareBaseView.topAnchor, constant: 8),

            self.shareDescriptionLabel.leadingAnchor.constraint(equalTo: self.shareTitleLabel.leadingAnchor),
            self.shareDescriptionLabel.trailingAnchor.constraint(equalTo: self.shareTitleLabel.trailingAnchor),
            self.shareDescriptionLabel.topAnchor.constraint(equalTo: self.shareTitleLabel.bottomAnchor, constant: 7),

            self.shareButton.leadingAnchor.constraint(equalTo: self.shareTitleLabel.leadingAnchor),
            self.shareButton.topAnchor.constraint(equalTo: self.shareDescriptionLabel.bottomAnchor, constant: 7),
            self.shareButton.bottomAnchor.constraint(equalTo: self.shareBaseView.bottomAnchor, constant: -8)

        ])

        // Recruit qr code Info
        NSLayoutConstraint.activate([
            self.qrCodeBaseView.leadingAnchor.constraint(equalTo: self.recruitMethodsBaseView.leadingAnchor, constant: 8),
            self.qrCodeBaseView.trailingAnchor.constraint(equalTo: self.recruitMethodsBaseView.trailingAnchor, constant: -8),
            self.qrCodeBaseView.topAnchor.constraint(equalTo: self.shareBaseView.bottomAnchor, constant: 7),
            self.qrCodeBaseView.bottomAnchor.constraint(equalTo: self.recruitMethodsBaseView.bottomAnchor, constant: -8),

            self.qrCodeCounterView.leadingAnchor.constraint(equalTo: self.qrCodeBaseView.leadingAnchor, constant: 8),
            self.qrCodeCounterView.topAnchor.constraint(equalTo: self.qrCodeBaseView.topAnchor, constant: 8),
            self.qrCodeCounterView.widthAnchor.constraint(equalToConstant: 15),
            self.qrCodeCounterView.heightAnchor.constraint(equalTo: self.qrCodeCounterView.widthAnchor),

            self.qrCodeCounterLabel.centerXAnchor.constraint(equalTo: self.qrCodeCounterView.centerXAnchor),
            self.qrCodeCounterLabel.centerYAnchor.constraint(equalTo: self.qrCodeCounterView.centerYAnchor),

            self.qrCodeTitleLabel.leadingAnchor.constraint(equalTo: self.qrCodeCounterView.trailingAnchor, constant: 10),
            self.qrCodeTitleLabel.trailingAnchor.constraint(equalTo: self.qrCodeBaseView.trailingAnchor, constant: -8),
            self.qrCodeTitleLabel.topAnchor.constraint(equalTo: self.qrCodeBaseView.topAnchor, constant: 8),

            self.qrCodeDescriptionLabel.leadingAnchor.constraint(equalTo: self.qrCodeTitleLabel.leadingAnchor),
            self.qrCodeDescriptionLabel.trailingAnchor.constraint(equalTo: self.qrCodeTitleLabel.trailingAnchor),
            self.qrCodeDescriptionLabel.topAnchor.constraint(equalTo: self.qrCodeTitleLabel.bottomAnchor, constant: 7),

            self.qrCodeButton.leadingAnchor.constraint(equalTo: self.qrCodeTitleLabel.leadingAnchor),
            self.qrCodeButton.topAnchor.constraint(equalTo: self.qrCodeDescriptionLabel.bottomAnchor, constant: 7),
            self.qrCodeButton.bottomAnchor.constraint(equalTo: self.qrCodeBaseView.bottomAnchor, constant: -8)

        ])

        // Referrals godfather Info
        NSLayoutConstraint.activate([
            self.referralsBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.referralsBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.referralsBaseView.topAnchor.constraint(equalTo: self.recruitMethodsBaseView.bottomAnchor, constant: 15),

            self.referralsTitleLabel.leadingAnchor.constraint(equalTo: self.referralsBaseView.leadingAnchor, constant: 16),
            self.referralsTitleLabel.trailingAnchor.constraint(equalTo: self.referralsBaseView.trailingAnchor, constant: -16),
            self.referralsTitleLabel.topAnchor.constraint(equalTo: self.referralsBaseView.topAnchor, constant: 16),

            self.referralsDescriptionLabel.leadingAnchor.constraint(equalTo: self.referralsTitleLabel.leadingAnchor),
            self.referralsDescriptionLabel.trailingAnchor.constraint(equalTo: self.referralsTitleLabel.trailingAnchor),
            self.referralsDescriptionLabel.topAnchor.constraint(equalTo: self.referralsTitleLabel.bottomAnchor, constant: 7),

            self.referralsStackView.leadingAnchor.constraint(equalTo: self.referralsBaseView.leadingAnchor, constant: 16),
            self.referralsStackView.trailingAnchor.constraint(equalTo: self.referralsBaseView.trailingAnchor, constant: -16),
            self.referralsStackView.topAnchor.constraint(equalTo: self.referralsDescriptionLabel.bottomAnchor, constant: 15),

            self.referralsGodfatherBaseView.leadingAnchor.constraint(equalTo: self.referralsBaseView.leadingAnchor, constant: 16),
            self.referralsGodfatherBaseView.trailingAnchor.constraint(equalTo: self.referralsBaseView.trailingAnchor, constant: -16),
            self.referralsGodfatherBaseView.topAnchor.constraint(equalTo: self.referralsStackView.bottomAnchor, constant: 15),
            self.referralsGodfatherBaseView.bottomAnchor.constraint(equalTo: self.referralsBaseView.bottomAnchor, constant: -16),

            self.referralsGodfatherTitleLabel.leadingAnchor.constraint(equalTo: self.referralsGodfatherBaseView.leadingAnchor),
            self.referralsGodfatherTitleLabel.trailingAnchor.constraint(equalTo: self.referralsGodfatherBaseView.trailingAnchor),
            self.referralsGodfatherTitleLabel.topAnchor.constraint(equalTo: self.referralsGodfatherBaseView.topAnchor),
            
            self.referralsGodfatherStackView.leadingAnchor.constraint(equalTo: self.referralsGodfatherBaseView.leadingAnchor),
            self.referralsGodfatherStackView.trailingAnchor.constraint(equalTo: self.referralsGodfatherBaseView.trailingAnchor),
            self.referralsGodfatherStackView.topAnchor.constraint(equalTo: self.referralsGodfatherTitleLabel.bottomAnchor, constant: 15),
            self.referralsGodfatherStackView.bottomAnchor.constraint(equalTo: self.referralsGodfatherBaseView.bottomAnchor)
            
//            self.referralsGodfatherView.leadingAnchor.constraint(equalTo: self.referralsGodfatherBaseView.leadingAnchor),
//            self.referralsGodfatherView.trailingAnchor.constraint(equalTo: self.referralsGodfatherBaseView.trailingAnchor),
//            self.referralsGodfatherView.topAnchor.constraint(equalTo: self.referralsGodfatherTitleLabel.bottomAnchor, constant: 15),
//            self.referralsGodfatherView.bottomAnchor.constraint(equalTo: self.referralsGodfatherBaseView.bottomAnchor)

        ])

        // Regulations Info
        NSLayoutConstraint.activate([
            self.regulationsBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.regulationsBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            //self.regulationsBaseView.topAnchor.constraint(equalTo: self.referralsBaseView.bottomAnchor, constant: 15),
            self.regulationsBaseView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -20),

            self.regulationsTitleLabel.leadingAnchor.constraint(equalTo: self.regulationsBaseView.leadingAnchor, constant: 16),
            self.regulationsTitleLabel.trailingAnchor.constraint(equalTo: self.regulationsBaseView.trailingAnchor, constant: -16),
            self.regulationsTitleLabel.topAnchor.constraint(equalTo: self.regulationsBaseView.topAnchor, constant: 16),

            self.regulationsDescriptionLabel.leadingAnchor.constraint(equalTo: self.regulationsTitleLabel.leadingAnchor),
            self.regulationsDescriptionLabel.trailingAnchor.constraint(equalTo: self.regulationsTitleLabel.trailingAnchor),
            self.regulationsDescriptionLabel.topAnchor.constraint(equalTo: self.regulationsTitleLabel.bottomAnchor, constant: 7),
            self.regulationsDescriptionLabel.bottomAnchor.constraint(equalTo: self.regulationsBaseView.bottomAnchor, constant: -16)
        ])

        self.bannerImageViewFixedHeightConstraint =
        NSLayoutConstraint(item: self.bannerImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: 165)
        self.bannerImageViewFixedHeightConstraint.isActive = true

        self.bannerImageViewDynamicHeightConstraint =
        NSLayoutConstraint(item: self.bannerImageView,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: self.bannerImageView,
                           attribute: .width,
                           multiplier: 1/self.aspectRatio,
                           constant: 0)
        self.bannerImageViewDynamicHeightConstraint.isActive = false

        self.referralsStackViewBottomBaseConstraint =
        NSLayoutConstraint(item: self.referralsStackView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.referralsBaseView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: -16)
        self.referralsStackViewBottomBaseConstraint.isActive = true

        self.referralsStackViewBottomGodfatherConstraint =
        NSLayoutConstraint(item: self.referralsStackView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.referralsGodfatherBaseView,
                           attribute: .top,
                           multiplier: 1,
                           constant: -15)
        self.referralsStackViewBottomGodfatherConstraint.isActive = false

        self.regulationReferralsTopConstraint =
        NSLayoutConstraint(item: self.regulationsBaseView,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: self.referralsBaseView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 15)
        self.regulationReferralsTopConstraint.isActive = true

        self.regulationRecruitTopConstraint =
        NSLayoutConstraint(item: self.regulationsBaseView,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: self.recruitMethodsBaseView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 15)
        self.regulationRecruitTopConstraint.isActive = false
        
        self.recruitMethodsBaseViewTopToStackConstraint = NSLayoutConstraint(item: self.recruitMethodsBaseView,
                                                                             attribute: .top,
                                                                             relatedBy: .equal,
                                                                             toItem: self.recruitReferralStackView,
                                                                             attribute: .bottom,
                                                                             multiplier: 1,
                                                                             constant: 15)
        self.recruitMethodsBaseViewTopToStackConstraint.isActive = true
        
        self.recruitMethodsBaseViewTopToBonusInfoConstraint = NSLayoutConstraint(item: self.recruitMethodsBaseView,
                                                                             attribute: .top,
                                                                             relatedBy: .equal,
                                                                             toItem: self.recruitBonusInfoBaseView,
                                                                             attribute: .bottom,
                                                                             multiplier: 1,
                                                                             constant: 15)
        self.recruitMethodsBaseViewTopToBonusInfoConstraint.isActive = false
        
    }
}
