//
//  BrandedTicketShareView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 25/07/2025.
//

import UIKit
import Combine
import ServicesProvider

class BrandedTicketShareView: UIView {

    // MARK: Private Properties
    private lazy var backgroundImageView: UIImageView = Self.createBackgroundImageView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var brandingContainer: UIView = Self.createBrandingContainer()
    private lazy var ticketCardContainer: UIView = Self.createTicketCardContainer()
    
    // Branding elements
    private lazy var companyLogoImageView: UIImageView = Self.createCompanyLogoImageView()
    private lazy var referralTitleLabel: UILabel = Self.createReferralTitleLabel()
    
    private lazy var ticketCardView: SimpleMyTicketCardView = {
        let view = SimpleMyTicketCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Referral Code Properties
    private var referralCode: String?
    private var cancellables = Set<AnyCancellable>()
    private var onViewReady: (() -> Void)?
    private var isReferralCodeFetched = false
    private var isLayoutComplete = false
    
    // MARK: - Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
        self.setupWithTheme()
    }

    func commonInit() {
        self.setupSubviews()
        self.setupTicketCardView()
        self.fetchReferralCode()
    }

    func setupWithTheme() {
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)
        // Transparent backgrounds for seamless integration
        self.backgroundColor = UIColor.App.backgroundPrimary.resolvedColor(with: darkTraits)
        self.containerView.backgroundColor = .clear
        self.brandingContainer.backgroundColor = .clear
        self.ticketCardContainer.backgroundColor = .clear

        // Setup background image
        self.setupBackgroundImage()
    }
    
    private func setupBackgroundImage() {
        // Load the share ticket background image
        if let backgroundImage = UIImage(named: "share_ticket_background_v3") {
            self.backgroundImageView.image = backgroundImage
            self.backgroundImageView.contentMode = .scaleToFill
            self.adjustBackgroundImageConstraints(for: backgroundImage)
        }
    }
    
    private func adjustBackgroundImageConstraints(for image: UIImage) {
        // Calculate the height needed to fill width while maintaining aspect ratio
        let imageAspectRatio = image.size.height / image.size.width
        let containerWidth = UIScreen.main.bounds.width // Approximate, will be adjusted by layout
        let requiredHeight = containerWidth * imageAspectRatio
        
        // Remove existing height constraint if any
        self.backgroundImageView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }
        
        // Add new height constraint to ensure image fills width properly
        NSLayoutConstraint.activate([
            self.backgroundImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: requiredHeight)
        ])
    }

    // MARK: Functions
    func setOnViewReady(_ callback: @escaping () -> Void) {
        self.onViewReady = callback
        checkIfReady()
    }
    
    func configure(withBetHistoryEntry betHistoryEntry: BetHistoryEntry,
                   countryCodes: [String],
                   viewModel: MyTicketCellViewModel,
                   grantedWinBoost: GrantedWinBoostInfo? = nil) {
        // Configure the embedded ticket card view
        ticketCardView.configure(withBetHistoryEntry: betHistoryEntry,
                               countryCodes: countryCodes,
                               viewModel: viewModel,
                               grantedWinBoost: grantedWinBoost)
        
        DispatchQueue.main.async {
            self.isLayoutComplete = true
            self.checkIfReady()
        }
    }
    
    func generateShareImage() -> UIImage? {
        // Generate screenshot of the entire branded share view
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        return renderer.image { _ in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
    }
    
    private func setupTicketCardView() {
        // Add ticket card view to container
        self.ticketCardContainer.addSubview(self.ticketCardView)
        
        NSLayoutConstraint.activate([
            self.ticketCardView.leadingAnchor.constraint(equalTo: self.ticketCardContainer.leadingAnchor),
            self.ticketCardView.trailingAnchor.constraint(equalTo: self.ticketCardContainer.trailingAnchor),
            self.ticketCardView.topAnchor.constraint(equalTo: self.ticketCardContainer.topAnchor),
            self.ticketCardView.bottomAnchor.constraint(equalTo: self.ticketCardContainer.bottomAnchor)
        ])
    }
    
    private func fetchReferralCode() {
        Env.servicesProvider.getReferralLink()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("GET REFERRAL LINK ERROR: \(error)")
                    // Use fallback code on error
                    self?.referralCode = "XYZ"
                }
                self?.isReferralCodeFetched = true
                self?.setupBrandingElements()
                self?.checkIfReady()
            }, receiveValue: { [weak self] referralLink in
                let mappedReferralLink = ServiceProviderModelMapper.referralLink(fromServiceProviderReferralLink: referralLink)
                self?.referralCode = mappedReferralLink.code
            })
            .store(in: &cancellables)
    }
    
    private func checkIfReady() {
        if isReferralCodeFetched && isLayoutComplete {
            onViewReady?()
        }
    }
    
    private func setupBrandingElements() {
        let shareText = localized("share_bet_description") // Rejoins l'équipe Betsson avec mon code parrainage: {userCode} et empoche 10€ de Bonus!
        let userCode = self.referralCode ?? "XYZ" // Use fetched code or fallback
        
        // Configure referral messaging with attributed text
        self.referralTitleLabel.attributedText = createAttributedShareText(text: shareText, userCode: userCode)
        
        // Configure company logo
        self.companyLogoImageView.image = UIImage(named: "brand_icon_simple")

    }
    
    private func createAttributedShareText(text: String, userCode: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text.replacingOccurrences(of: "{userCode}", with: userCode))
        
        // Default white color for the entire text
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: attributedString.length))
        
        // Apply secondary color to user code
        if let userCodeRange = attributedString.string.range(of: userCode) {
            let nsRange = NSRange(userCodeRange, in: attributedString.string)
            attributedString.addAttribute(.foregroundColor, value: UIColor.App.textSecondary, range: nsRange)
        }
        
        // Apply highlight color to bonus amount (looking for pattern like "10€ de Bonus")
        let bonusPattern = "\\d+€ de Bonus"
        if let regex = try? NSRegularExpression(pattern: bonusPattern, options: []) {
            let matches = regex.matches(in: attributedString.string, options: [], range: NSRange(location: 0, length: attributedString.length))
            for match in matches {
                attributedString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: match.range)
            }
        }
        
        return attributedString
    }
    
}

//
// MARK: - Subviews Initialization and Setup
//
extension BrandedTicketShareView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTicketCardContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }
    
    private static func createBrandingContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    private static func createReferralTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("share_your_ticket")
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }
    
    private static func createCompanyLogoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createBackgroundImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }

    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Add background image first (behind everything)
        self.addSubview(self.backgroundImageView)
        
        // Add main container
        self.addSubview(self.containerView)
        
        // New layout order: branding at top, ticket in middle
        self.containerView.addSubview(self.brandingContainer)
        self.containerView.addSubview(self.ticketCardContainer)
        
        // Add branding elements to branding container
        self.brandingContainer.addSubview(self.companyLogoImageView)
        self.brandingContainer.addSubview(self.referralTitleLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            // Background Image View (pinned to top, fills width, extends beyond if needed)
            self.backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor),
            
            // Container View (with padding)
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.containerView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            self.containerView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            // Branding Container (at top)
            self.brandingContainer.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.brandingContainer.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.brandingContainer.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            
            // Company Logo (at top of branding section)
            self.companyLogoImageView.centerXAnchor.constraint(equalTo: self.brandingContainer.centerXAnchor),
            self.companyLogoImageView.topAnchor.constraint(equalTo: self.brandingContainer.topAnchor, constant: 16),
            self.companyLogoImageView.widthAnchor.constraint(equalToConstant: 120),
            self.companyLogoImageView.heightAnchor.constraint(equalToConstant: 40),

            // Referral Title
            self.referralTitleLabel.leadingAnchor.constraint(equalTo: self.brandingContainer.leadingAnchor, constant: 16),
            self.referralTitleLabel.trailingAnchor.constraint(equalTo: self.brandingContainer.trailingAnchor, constant: -16),
            self.referralTitleLabel.topAnchor.constraint(equalTo: self.companyLogoImageView.bottomAnchor, constant: 12),
            self.referralTitleLabel.bottomAnchor.constraint(equalTo: self.brandingContainer.bottomAnchor, constant: -12),

            // Ticket Card Container (in middle)
            self.ticketCardContainer.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 0),
            self.ticketCardContainer.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: 0),
            self.ticketCardContainer.topAnchor.constraint(equalTo: self.brandingContainer.bottomAnchor, constant: 6),
            self.ticketCardContainer.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -25),
        ])
    }
}
