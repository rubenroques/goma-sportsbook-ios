//
//  ExtendedListFooterView.swift
//  GomaUI
//
//  Created on 02/11/2025.
//

import UIKit
import Kingfisher

// MARK: - Extended List Footer View

public class ExtendedListFooterView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let containerVerticalPadding: CGFloat = 48.0
        static let containerHorizontalPadding: CGFloat = 16.0
        static let sectionSpacing: CGFloat = 32.0
        static let subSectionSpacing: CGFloat = 16.0
        static let partnerLogoWidth: CGFloat = 168.0
        static let partnerLogoHeight: CGFloat = 80.0
        static let paymentLogoSize: CGFloat = 64.0
        static let socialIconSize: CGFloat = 64.0
        static let socialIconSpacing: CGFloat = 32.0
        static let paymentLogoSpacing: CGFloat = 24.0
        static let partnerLogoSpacing: CGFloat = 16.0
        static let egbaBadgeWidth: CGFloat = 128.0
        static let egbaBadgeHeight: CGFloat = 80.0
        static let ecograBadgeWidth: CGFloat = 168.0
        static let ecograBadgeHeight: CGFloat = 80.0
        static let certificationSpacing: CGFloat = 8.0
        static let licenseMaxWidth: CGFloat = 672.0
        static let linkSeparator: String = " | "
        static let minTouchTarget: CGFloat = 44.0
    }

    // MARK: - Private Properties

    private var viewModel: ExtendedListFooterViewModelProtocol
    private lazy var mainStackView: UIStackView = Self.createMainStackView()

    private var sponsorSectionContainer: UIView?
    private var sponsorLogosContainer: UIView?
    private var sponsorViewMap: [UIView: FooterSponsor] = [:]

    private var socialSectionContainer: UIView?
    private var socialLinksContainer: UIView?
    private var socialLinkViewMap: [UIView: FooterSocialLink] = [:]
    private var navigationLinksLabel: UILabel?

    // MARK: - Initialization

    public init(viewModel: ExtendedListFooterViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setupSubviews()
        self.setupWithTheme()
        self.bindViewModel()
    }

    private func bindViewModel() {
        viewModel.onSponsorsUpdated = { [weak self] sponsors in
            DispatchQueue.main.async {
                self?.updateSponsorSection(with: sponsors)
            }
        }

        viewModel.onSocialLinksUpdated = { [weak self] links in
            DispatchQueue.main.async {
                self?.updateSocialLinksSection(with: links)
            }
        }
        
        viewModel.onNavigationLinksUpdated = { [weak self] links in
            DispatchQueue.main.async {
                self?.updateNavigationLinksSection(with: links)
            }
        }
    }

    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false

        addSubview(mainStackView)

        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.containerVerticalPadding),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.containerHorizontalPadding),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.containerHorizontalPadding),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.containerVerticalPadding)
        ])

        // Build all sections
        setupPartnershipSection()
        setupNavigationLinksSection()
        setupPaymentProvidersSection()
        setupSocialMediaSection()
        setupResponsibleGamblingSection()
        setupCopyrightSection()
        setupLicenseSection()
    }

    private func setupWithTheme() {
        backgroundColor = StyleProvider.Color.allDark
    }

    // MARK: - Section 1: Partnership Sponsorships

    private func setupPartnershipSection() {
        let sectionContainer = UIView()
        sectionContainer.translatesAutoresizingMaskIntoConstraints = false
        sponsorSectionContainer = sectionContainer

        let headerLabel = Self.createSectionHeaderLabel(text: viewModel.partnershipHeaderText)
        sectionContainer.addSubview(headerLabel)

        let logosContainer = UIView()
        logosContainer.translatesAutoresizingMaskIntoConstraints = false
        sectionContainer.addSubview(logosContainer)
        sponsorLogosContainer = logosContainer

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: sectionContainer.topAnchor),
            headerLabel.centerXAnchor.constraint(equalTo: sectionContainer.centerXAnchor),

            logosContainer.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: Constants.subSectionSpacing),
            logosContainer.leadingAnchor.constraint(equalTo: sectionContainer.leadingAnchor),
            logosContainer.trailingAnchor.constraint(equalTo: sectionContainer.trailingAnchor),
            logosContainer.bottomAnchor.constraint(equalTo: sectionContainer.bottomAnchor)
        ])

        mainStackView.addArrangedSubview(sectionContainer)

        NSLayoutConstraint.activate([
            sectionContainer.widthAnchor.constraint(equalTo: mainStackView.widthAnchor)
        ])

        updateSponsorSection(with: viewModel.sponsors)
    }

    private func updateSponsorSection(with sponsors: [FooterSponsor]) {
        guard let sectionContainer = sponsorSectionContainer,
              let logosContainer = sponsorLogosContainer else { return }

        logosContainer.subviews.forEach { $0.removeFromSuperview() }
        sponsorViewMap.removeAll()

        if sponsors.isEmpty {
            let fallbackView = createDefaultSponsorsView()
            logosContainer.addSubview(fallbackView)

            NSLayoutConstraint.activate([
                fallbackView.topAnchor.constraint(equalTo: logosContainer.topAnchor),
                fallbackView.leadingAnchor.constraint(equalTo: logosContainer.leadingAnchor),
                fallbackView.trailingAnchor.constraint(equalTo: logosContainer.trailingAnchor),
                fallbackView.bottomAnchor.constraint(equalTo: logosContainer.bottomAnchor)
            ])

            sectionContainer.isHidden = viewModel.partnerClubs.isEmpty
            return
        }

        sectionContainer.isHidden = false

        let gridView = createSponsorLogosGrid(with: sponsors)
        logosContainer.addSubview(gridView)

        NSLayoutConstraint.activate([
            gridView.topAnchor.constraint(equalTo: logosContainer.topAnchor),
            gridView.leadingAnchor.constraint(equalTo: logosContainer.leadingAnchor),
            gridView.trailingAnchor.constraint(equalTo: logosContainer.trailingAnchor),
            gridView.bottomAnchor.constraint(equalTo: logosContainer.bottomAnchor)
        ])
    }

    private func createDefaultSponsorsView() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let verticalStack = UIStackView()
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.axis = .vertical
        verticalStack.spacing = Constants.partnerLogoSpacing
        verticalStack.alignment = .center

        container.addSubview(verticalStack)

        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: container.topAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        let logosPerRow = 2
        var currentRowStack: UIStackView?

        for (index, club) in viewModel.partnerClubs.enumerated() {
            if index % logosPerRow == 0 {
                let rowStack = UIStackView()
                rowStack.translatesAutoresizingMaskIntoConstraints = false
                rowStack.axis = .horizontal
                rowStack.spacing = Constants.partnerLogoSpacing
                rowStack.alignment = .center
                rowStack.distribution = .equalSpacing
                verticalStack.addArrangedSubview(rowStack)
                currentRowStack = rowStack
            }

            if let rowStack = currentRowStack {
                let sponsorView = createDefaultSponsorView(for: club)
                rowStack.addArrangedSubview(sponsorView)
            }
        }

        return container
    }

    private func createDefaultSponsorView(for club: PartnerClub) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: Constants.partnerLogoWidth),
            container.heightAnchor.constraint(equalToConstant: Constants.partnerLogoHeight)
        ])

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = viewModel.imageResolver.image(for: .partnerLogo(club: club))
        imageView.tintColor = StyleProvider.Color.allWhite

        container.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    private func createSponsorLogosGrid(with sponsors: [FooterSponsor]) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let verticalStack = UIStackView()
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.axis = .vertical
        verticalStack.spacing = Constants.partnerLogoSpacing
        verticalStack.alignment = .center

        container.addSubview(verticalStack)

        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: container.topAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        let logosPerRow = 2

        var currentRowStack: UIStackView?

        for (index, sponsor) in sponsors.enumerated() {
            if index % logosPerRow == 0 {
                let rowStack = UIStackView()
                rowStack.translatesAutoresizingMaskIntoConstraints = false
                rowStack.axis = .horizontal
                rowStack.spacing = Constants.partnerLogoSpacing
                rowStack.alignment = .center
                rowStack.distribution = .equalSpacing
                verticalStack.addArrangedSubview(rowStack)
                currentRowStack = rowStack
            }

            if let rowStack = currentRowStack {
                let sponsorView = createSponsorView(for: sponsor)
                rowStack.addArrangedSubview(sponsorView)
            }
        }

        return container
    }

    private func createSponsorView(for sponsor: FooterSponsor) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: Constants.partnerLogoWidth),
            container.heightAnchor.constraint(equalToConstant: Constants.partnerLogoHeight)
        ])

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        container.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        if let iconURL = sponsor.iconURL {
            loadImage(from: iconURL, into: imageView, context: "sponsor_\(sponsor.id)")
        } else {
            imageView.image = UIImage(systemName: "sponsor_\(sponsor.id)")
            imageView.tintColor = StyleProvider.Color.allWhite
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSponsorTap(_:)))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        sponsorViewMap[container] = sponsor

        return container
    }

    @objc private func handleSponsorTap(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view,
              let sponsor = sponsorViewMap[tappedView] else {
            return
        }

        viewModel.handleSponsorTap(sponsor)
    }

    private func loadImage(from url: URL, into imageView: UIImageView, context: String) {
        imageView.kf.cancelDownloadTask()

        imageView.kf.setImage(with: url, placeholder: nil, options: nil) { result in
            if case .failure(let error) = result {
                print("[ExtendedListFooterView] Failed to load \(context) image: \(error)")
                imageView.image = UIImage(named: context)
                imageView.tintColor = StyleProvider.Color.allWhite
            }
        }
    }

    // MARK: - Section 2: Navigation Links

    private func setupNavigationLinksSection() {
        let linksContainer = createNavigationLinksView()
        mainStackView.addArrangedSubview(linksContainer)
        updateNavigationLinksSection(with: viewModel.navigationLinks)
    }

    private func createNavigationLinksView() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = StyleProvider.Color.allWhite
        label.font = StyleProvider.fontWith(type: .regular, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true

        navigationLinksLabel = label

        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNavigationLinkTap(_:)))
        label.addGestureRecognizer(tapGesture)

        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }
    
    private func updateNavigationLinksSection(with links: [FooterLink]) {
        guard let label = navigationLinksLabel else { return }
        
        guard !links.isEmpty else {
            label.attributedText = nil
            label.isHidden = true
            return
        }
        
        label.isHidden = false
        label.attributedText = Self.buildNavigationLinksAttributedString(from: links)
    }

    @objc private func handleNavigationLinkTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
              let attributedText = label.attributedText else { return }

        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)

        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        let locationOfTouchInLabel = gesture.location(in: label)
        let indexOfCharacter = layoutManager.characterIndex(
            for: locationOfTouchInLabel,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        // Find which link was tapped
        var currentIndex = 0
        for (index, link) in viewModel.navigationLinks.enumerated() {
            let linkLength = link.title.count
            let linkRange = NSRange(location: currentIndex, length: linkLength)

            if NSLocationInRange(indexOfCharacter, linkRange) {
                viewModel.onLinkTap?(link.type)
                return
            }

            currentIndex += linkLength + Constants.linkSeparator.count
        }
    }

    // MARK: - Section 3: Payment Providers

    private func setupPaymentProvidersSection() {
        let container = createPaymentProvidersContainer()
        mainStackView.addArrangedSubview(container)
    }

    private func createPaymentProvidersContainer() -> UIView {
        let horizontalStack = UIStackView()
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = Constants.paymentLogoSpacing
        horizontalStack.alignment = .center
        horizontalStack.distribution = .equalSpacing

        for paymentOperator in viewModel.paymentOperators {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.image = viewModel.imageResolver.image(for: .paymentProvider(operator: paymentOperator))

            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: Constants.paymentLogoSize),
                imageView.heightAnchor.constraint(equalToConstant: Constants.paymentLogoSize)
            ])

            horizontalStack.addArrangedSubview(imageView)
        }

        return horizontalStack
    }

    // MARK: - Section 4: Social Media

    private func setupSocialMediaSection() {
        let sectionContainer = UIView()
        sectionContainer.translatesAutoresizingMaskIntoConstraints = false
        socialSectionContainer = sectionContainer

        let headerLabel = Self.createSectionHeaderLabel(text: viewModel.socialMediaHeaderText)
        sectionContainer.addSubview(headerLabel)

        let linksContainer = UIView()
        linksContainer.translatesAutoresizingMaskIntoConstraints = false
        sectionContainer.addSubview(linksContainer)
        socialLinksContainer = linksContainer

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: sectionContainer.topAnchor),
            headerLabel.centerXAnchor.constraint(equalTo: sectionContainer.centerXAnchor),

            linksContainer.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: Constants.subSectionSpacing),
            linksContainer.leadingAnchor.constraint(equalTo: sectionContainer.leadingAnchor),
            linksContainer.trailingAnchor.constraint(equalTo: sectionContainer.trailingAnchor),
            linksContainer.bottomAnchor.constraint(equalTo: sectionContainer.bottomAnchor)
        ])

        mainStackView.addArrangedSubview(sectionContainer)

        NSLayoutConstraint.activate([
            sectionContainer.widthAnchor.constraint(equalTo: mainStackView.widthAnchor)
        ])

        updateSocialLinksSection(with: viewModel.socialLinks)
    }

    private func updateSocialLinksSection(with socialLinks: [FooterSocialLink]) {
        guard let sectionContainer = socialSectionContainer,
              let linksContainer = socialLinksContainer else { return }

        linksContainer.subviews.forEach { $0.removeFromSuperview() }
        socialLinkViewMap.removeAll()

        if socialLinks.isEmpty {
            let fallbackView = createDefaultSocialMediaView()
            linksContainer.addSubview(fallbackView)

            NSLayoutConstraint.activate([
                fallbackView.topAnchor.constraint(equalTo: linksContainer.topAnchor),
                fallbackView.leadingAnchor.constraint(equalTo: linksContainer.leadingAnchor),
                fallbackView.trailingAnchor.constraint(equalTo: linksContainer.trailingAnchor),
                fallbackView.bottomAnchor.constraint(equalTo: linksContainer.bottomAnchor)
            ])

            sectionContainer.isHidden = viewModel.socialMediaPlatforms.isEmpty
            return
        }

        sectionContainer.isHidden = false

        let gridView = createSocialLinksGrid(with: socialLinks)
        linksContainer.addSubview(gridView)

        NSLayoutConstraint.activate([
            gridView.topAnchor.constraint(equalTo: linksContainer.topAnchor),
            gridView.leadingAnchor.constraint(equalTo: linksContainer.leadingAnchor),
            gridView.trailingAnchor.constraint(equalTo: linksContainer.trailingAnchor),
            gridView.bottomAnchor.constraint(equalTo: linksContainer.bottomAnchor)
        ])
    }

    private func createDefaultSocialMediaView() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = Constants.socialIconSpacing
        stackView.distribution = .equalSpacing
        stackView.alignment = .center

        for platform in viewModel.socialMediaPlatforms {
            let button = Self.createSocialMediaButton(for: platform)
            button.setImage(viewModel.imageResolver.image(for: .socialMedia(platform: platform)), for: .normal)
            button.addTarget(self, action: #selector(handleSocialMediaTap(_:)), for: .touchUpInside)
            button.tag = viewModel.socialMediaPlatforms.firstIndex(of: platform) ?? 0
            stackView.addArrangedSubview(button)
        }

        container.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])

        return container
    }

    private func createSocialLinksGrid(with socialLinks: [FooterSocialLink]) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let verticalStack = UIStackView()
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.axis = .vertical
        verticalStack.spacing = Constants.socialIconSpacing
        verticalStack.alignment = .center

        container.addSubview(verticalStack)

        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: container.topAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        let iconsPerRow = 4
        var currentRowStack: UIStackView?

        for (index, link) in socialLinks.enumerated() {
            if index % iconsPerRow == 0 {
                let rowStack = UIStackView()
                rowStack.translatesAutoresizingMaskIntoConstraints = false
                rowStack.axis = .horizontal
                rowStack.spacing = Constants.socialIconSpacing
                rowStack.alignment = .center
                rowStack.distribution = .equalSpacing
                verticalStack.addArrangedSubview(rowStack)
                currentRowStack = rowStack
            }

            if let rowStack = currentRowStack {
                let linkView = createSocialLinkView(for: link)
                rowStack.addArrangedSubview(linkView)
            }
        }

        return container
    }

    private func createSocialLinkView(for link: FooterSocialLink) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalToConstant: Constants.socialIconSize),
            container.heightAnchor.constraint(equalToConstant: Constants.socialIconSize)
        ])

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        container.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        if let iconURL = link.iconURL {
            loadImage(from: iconURL, into: imageView, context: "social_\(link.id)")
        } else {
            imageView.image = UIImage(systemName: "globe")
            imageView.tintColor = StyleProvider.Color.allWhite
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSocialLinkTap(_:)))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        socialLinkViewMap[container] = link

        return container
    }

    @objc private func handleSocialLinkTap(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view,
              let link = socialLinkViewMap[tappedView] else {
            return
        }

        viewModel.handleSocialLinkTap(link)
    }

    @objc private func handleSocialMediaTap(_ sender: UIButton) {
        let index = sender.tag
        guard index < viewModel.socialMediaPlatforms.count else { return }
        let platform = viewModel.socialMediaPlatforms[index]
        viewModel.onLinkTap?(.socialMedia(platform))
    }

    // MARK: - Section 5: Responsible Gambling

    private func setupResponsibleGamblingSection() {
        let sectionContainer = UIView()
        sectionContainer.translatesAutoresizingMaskIntoConstraints = false

        // Warning text
        let warningLabel = Self.createBodyTextLabel(text: viewModel.responsibleGamblingText.warning)
        sectionContainer.addSubview(warningLabel)

        // Advice text
        let adviceLabel = Self.createBodyTextLabel(text: viewModel.responsibleGamblingText.advice)
        sectionContainer.addSubview(adviceLabel)

        // Certification badges
        let badgesContainer = createCertificationBadgesContainer()
        sectionContainer.addSubview(badgesContainer)

        NSLayoutConstraint.activate([
            warningLabel.topAnchor.constraint(equalTo: sectionContainer.topAnchor),
            warningLabel.centerXAnchor.constraint(equalTo: sectionContainer.centerXAnchor),

            adviceLabel.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 4),
            adviceLabel.centerXAnchor.constraint(equalTo: sectionContainer.centerXAnchor),

            badgesContainer.topAnchor.constraint(equalTo: adviceLabel.bottomAnchor, constant: Constants.subSectionSpacing),
            badgesContainer.centerXAnchor.constraint(equalTo: sectionContainer.centerXAnchor),
            badgesContainer.bottomAnchor.constraint(equalTo: sectionContainer.bottomAnchor)
        ])

        mainStackView.addArrangedSubview(sectionContainer)

        NSLayoutConstraint.activate([
            sectionContainer.widthAnchor.constraint(equalTo: mainStackView.widthAnchor)
        ])
    }

    private func createCertificationBadgesContainer() -> UIView {
        let horizontalStack = UIStackView()
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = Constants.certificationSpacing
        horizontalStack.alignment = .center
        horizontalStack.distribution = .equalSpacing

        // EGBA badge
        let egbaImageView = UIImageView()
        egbaImageView.translatesAutoresizingMaskIntoConstraints = false
        egbaImageView.contentMode = .scaleAspectFit
        egbaImageView.image = viewModel.imageResolver.image(for: .certification(type: .egba))

        NSLayoutConstraint.activate([
            egbaImageView.widthAnchor.constraint(equalToConstant: Constants.egbaBadgeWidth),
            egbaImageView.heightAnchor.constraint(equalToConstant: Constants.egbaBadgeHeight)
        ])

        // eCOGRA badge
        let ecograImageView = UIImageView()
        ecograImageView.translatesAutoresizingMaskIntoConstraints = false
        ecograImageView.contentMode = .scaleAspectFit
        ecograImageView.image = viewModel.imageResolver.image(for: .certification(type: .ecogra))

        NSLayoutConstraint.activate([
            ecograImageView.widthAnchor.constraint(equalToConstant: Constants.ecograBadgeWidth),
            ecograImageView.heightAnchor.constraint(equalToConstant: Constants.ecograBadgeHeight)
        ])

        horizontalStack.addArrangedSubview(egbaImageView)
        horizontalStack.addArrangedSubview(ecograImageView)

        return horizontalStack
    }

    // MARK: - Section 6: Copyright

    private func setupCopyrightSection() {
        let label = Self.createSectionHeaderLabel(text: viewModel.copyrightText)
        mainStackView.addArrangedSubview(label)
    }

    // MARK: - Section 7: License

    private func setupLicenseSection() {
        let sectionContainer = UIView()
        sectionContainer.translatesAutoresizingMaskIntoConstraints = false

        // License header
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = viewModel.licenseHeaderText
        headerLabel.textColor = StyleProvider.Color.allWhite
        headerLabel.font = StyleProvider.fontWith(type: .semibold, size: 16)
        headerLabel.textAlignment = .center

        // License body
        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.text = viewModel.licenseBodyText
        bodyLabel.textColor = StyleProvider.Color.allWhite
        bodyLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0

        sectionContainer.addSubview(headerLabel)
        sectionContainer.addSubview(bodyLabel)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: sectionContainer.topAnchor),
            headerLabel.centerXAnchor.constraint(equalTo: sectionContainer.centerXAnchor),

            bodyLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: Constants.subSectionSpacing),
            bodyLabel.leadingAnchor.constraint(equalTo: sectionContainer.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: sectionContainer.trailingAnchor),
            bodyLabel.bottomAnchor.constraint(equalTo: sectionContainer.bottomAnchor),
            bodyLabel.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.licenseMaxWidth)
        ])

        mainStackView.addArrangedSubview(sectionContainer)

        NSLayoutConstraint.activate([
            sectionContainer.widthAnchor.constraint(equalTo: mainStackView.widthAnchor)
        ])
    }

}

// MARK: - Subviews Initialization

extension ExtendedListFooterView {

    private static func createMainStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Constants.sectionSpacing
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }
    
    private static func buildNavigationLinksAttributedString(from links: [FooterLink]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        
        for (index, link) in links.enumerated() {
            let linkText = NSAttributedString(
                string: link.title,
                attributes: [
                    .foregroundColor: StyleProvider.Color.allWhite,
                    .font: StyleProvider.fontWith(type: .regular, size: 16)
                ]
            )
            attributedString.append(linkText)
            
            if index < links.count - 1 {
                let separator = NSAttributedString(
                    string: Constants.linkSeparator,
                    attributes: [
                        .foregroundColor: StyleProvider.Color.allWhite,
                        .font: StyleProvider.fontWith(type: .regular, size: 16)
                    ]
                )
                attributedString.append(separator)
            }
        }
        
        return attributedString
    }

    private static func createSectionHeaderLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = StyleProvider.Color.allWhite
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textAlignment = .center
        return label
    }

    private static func createBodyTextLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.textColor = StyleProvider.Color.allWhite
        label.font = StyleProvider.fontWith(type: .regular, size: 16)
        label.textAlignment = .center
        return label
    }

    private static func createPartnerLogoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Constants.partnerLogoWidth),
            imageView.heightAnchor.constraint(equalToConstant: Constants.partnerLogoHeight)
        ])

        return imageView
    }

    private static func createSocialMediaButton(for platform: SocialPlatform) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = StyleProvider.Color.allWhite

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: Constants.socialIconSize),
            button.heightAnchor.constraint(equalToConstant: Constants.socialIconSize)
        ])

        return button
    }
}

// MARK: - SwiftUI Previews

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
#Preview("Full Cameroon Footer") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.backgroundTestColor

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(scrollView)

        // Create view model with tap handler
        let viewModel = MockExtendedListFooterViewModel.cameroonFooter
        viewModel.onLinkTap = { linkType in
            switch linkType {
            case .termsAndConditions:
                print("✅ Preview: Tapped Terms and Conditions")
            case .affiliates:
                print("✅ Preview: Tapped Affiliates")
            case .privacyPolicy:
                print("✅ Preview: Tapped Privacy Policy")
            case .cookiePolicy:
                print("✅ Preview: Tapped Cookie Policy")
            case .responsibleGambling:
                print("✅ Preview: Tapped Responsible Gambling")
            case .gameRules:
                print("✅ Preview: Tapped Game Rules")
            case .helpCenter:
                print("✅ Preview: Tapped Help Center")
            case .contactUs:
                print("✅ Preview: Tapped Contact Us")
            case .socialMedia(let platform):
                print("✅ Preview: Tapped Social Media - \(platform.displayName)")
            case .casinoRules:
                print("✅ Preview: Tapped Casino Rules")
            case .custom(let url, let label):
                print("✅ Preview: Tapped Custom Link - \(label) -> \(url)")
            }
        }

        let footerView = ExtendedListFooterView(viewModel: viewModel)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(footerView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),

            footerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            footerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            footerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Minimal Footer") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.backgroundTestColor

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(scrollView)

        let footerView = ExtendedListFooterView(viewModel: MockExtendedListFooterViewModel.minimalFooter)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(footerView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),

            footerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            footerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            footerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("No Links Footer") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.backgroundTestColor

        let footerView = ExtendedListFooterView(viewModel: MockExtendedListFooterViewModel.noLinksFooter)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(footerView)

        NSLayoutConstraint.activate([
            footerView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor),
            footerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            footerView.bottomAnchor.constraint(lessThanOrEqualTo: vc.view.bottomAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Three Partners (Dynamic Grid)") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.backgroundTestColor

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(scrollView)

        let footerView = ExtendedListFooterView(viewModel: MockExtendedListFooterViewModel.threePartnersFooter)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(footerView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),

            footerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            footerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            footerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Single Partner") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.backgroundTestColor

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(scrollView)

        let footerView = ExtendedListFooterView(viewModel: MockExtendedListFooterViewModel.singlePartnerFooter)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(footerView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),

            footerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            footerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            footerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        return vc
    }
}

@available(iOS 17.0, *)
#Preview("Five Partners (3 Rows)") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.backgroundTestColor

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(scrollView)

        let footerView = ExtendedListFooterView(viewModel: MockExtendedListFooterViewModel.fivePartnersFooter)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(footerView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),

            footerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            footerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            footerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        return vc
    }
}

#endif
