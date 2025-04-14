//
//  SocialMyTicketTableViewCell.swift
//  MultiBet
//
//  Created by André Lascas on 22/01/2024.
//

import UIKit
import Combine

class SocialMyTicketTableViewCell: UITableViewCell {
    
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var topStatusView: UIView = Self.createTopStatusView()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var qrCodeButton: UIButton = Self.createQRCodeButton()
    private lazy var shareButton: UIButton = Self.createShareButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var dateLabel: UILabel = Self.createDateLabel()
    private lazy var betIdLabel: UILabel = Self.createBetIdLabel()
    private lazy var topInfoSeparatorLineView: UIView = Self.createTopInfoSeparatorLineView()
    private lazy var betActionsStackView: UIStackView = Self.createBetActionsStackView()
    private lazy var editBaseView: UIView = Self.createEditBaseView()
    private lazy var editButton: UIButton = Self.createEditButton()
    private lazy var updateOddsBaseView: UIView = Self.createUpdateOddsBaseView()
    private lazy var updateOddsButton: UIButton = Self.createUpdateOddsButton()
    private lazy var deleteBaseView: UIView = Self.createDeleteBaseView()
    private lazy var deleteButton: UIButton = Self.createDeleteButton()
    private lazy var betCardsStackView: UIStackView = Self.createBetCardsStackView()
    private lazy var bottomStatusView: UIView = Self.createBottomStatusView()
    private lazy var betInfoBaseView: UIView = Self.createBetInfoBaseView()
    private lazy var betInfoLabelsStackView: UIStackView = Self.createBetInfoLabelsStackView()
    private lazy var betInfoSeparatorLineView: UIView = Self.createBetInfoSeparatorLineView()
    private lazy var betInfoValuesStackView: UIStackView = Self.createBetInfoValuesStackView()
    private lazy var totalOddTitleLabel: UILabel = Self.createTotalOddTitleLabel()
    private lazy var totalOddValueLabel: UILabel = Self.createTotalOddValueLabel()
    private lazy var betAmountTitleLabel: UILabel = Self.createBetAmountTitleLabel()
    private lazy var betAmountValueLabel: UILabel = Self.createBetAmountValueLabel()
    private lazy var winningsTitleLabel: UILabel = Self.createWinningsTitleLabel()
    private lazy var winningsValueLabel: UILabel = Self.createWinningsValueLabel()
    private lazy var loadingView: UIView = Self.createLoadingView()
    private lazy var loadingActivityIndicator: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()
    
    private var betHistoryEntry: BetHistoryEntry?
    private var viewModel: MyTicketCellViewModel?
    
    private var isLoadingCellDataSubscription: AnyCancellable?

    var tappedShareAction: ((UIImage, BetHistoryEntry) -> Void) = { _, _ in }
    var tappedMatchDetail: ((String) -> Void)?
    var tappedQRCodeAction: ((BetHistoryEntry) -> Void)?
    var tappedUpdateOddsAction: ((String) -> Void)?
    var tappedDeleteBetAction: ((String) -> Void)?
    var tappedEditBetAction: ((BetHistoryEntry) -> Void)?
    var needsDataUpdate: (() -> Void)?

    // MARK: - Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()
        
        self.loadingView.isHidden = true

        self.qrCodeButton.addTarget(self, action: #selector(didTapQRCodeButton), for: .primaryActionTriggered)
        
        self.shareButton.addTarget(self, action: #selector(didTapShareButton), for: .primaryActionTriggered)
        
        self.editButton.addTarget(self, action: #selector(didTapEditButton), for: .primaryActionTriggered)
        
        self.updateOddsButton.addTarget(self, action: #selector(didTapUpdateOddsButton), for: .primaryActionTriggered)
        
        self.deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .primaryActionTriggered)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.betHistoryEntry = nil
        self.viewModel = nil
        self.loadingView.isHidden = true

        self.isLoadingCellDataSubscription?.cancel()
        self.isLoadingCellDataSubscription = nil
    }
    
    // MARK: - Layout and Theme
    override func layoutSubviews() {
        super.layoutSubviews()

        self.containerView.layer.cornerRadius = CornerRadius.button
        self.containerView.layer.masksToBounds = true

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }
    
    private func setupWithTheme() {
        self.contentView.backgroundColor = UIColor.App.backgroundTertiary

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.topStatusView.backgroundColor = .clear
        
        self.iconImageView.backgroundColor = .clear
        
        self.qrCodeButton.backgroundColor = .clear
        
        self.shareButton.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary
        
        self.dateLabel.textColor = UIColor.App.textSecondary
        
        self.betIdLabel.textColor = UIColor.App.textSecondary

        self.topInfoSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        
        self.betActionsStackView.backgroundColor = .clear
        
        self.editBaseView.backgroundColor = .clear
        self.editButton.backgroundColor = .clear
        self.editButton.setTitleColor(UIColor.App.highlightSecondary, for: .normal)
        
        self.updateOddsBaseView.backgroundColor = .clear
        self.updateOddsButton.backgroundColor = .clear
        self.updateOddsButton.setTitleColor(UIColor.App.highlightSecondary, for: .normal)

        self.deleteBaseView.backgroundColor = .clear
        self.deleteButton.backgroundColor = .clear
        self.deleteButton.setTitleColor(UIColor.App.alertError, for: .normal)

        self.betCardsStackView.backgroundColor = .clear
        
        self.betInfoBaseView.backgroundColor = .clear
        
        self.betInfoLabelsStackView.backgroundColor = .clear
        
        self.betInfoSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        
        self.betInfoValuesStackView.backgroundColor = .clear

        self.totalOddTitleLabel.textColor = UIColor.App.textPrimary
        
        self.totalOddValueLabel.textColor = UIColor.App.textPrimary
        
        self.betAmountTitleLabel.textColor = UIColor.App.textPrimary

        self.betAmountValueLabel.textColor = UIColor.App.textPrimary

        self.winningsTitleLabel.textColor = UIColor.App.textPrimary

        self.winningsValueLabel.textColor = UIColor.App.textPrimary
        
        self.bottomStatusView.backgroundColor = .clear
        
        self.loadingView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)

        // Specific theme coloring
        if let status = self.betHistoryEntry?.status?.uppercased() {
            switch status {
            case "WON":
                self.highlightCard(withColor: UIColor.App.myTicketsWon)
            case "LOST", "HALF_LOST":
                self.highlightCard(withColor: UIColor.App.myTicketsLost)
            default:
                self.resetHighlightedCard()
            }
        }
    }
    
    // MARK: Functions
    
    func configure(withBetHistoryEntry betHistoryEntry: BetHistoryEntry, countryCodes: [String], viewModel: MyTicketCellViewModel) {

        self.betHistoryEntry = betHistoryEntry
        self.viewModel = viewModel

        self.isLoadingCellDataSubscription = self.viewModel?.isLoadingCellData
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoadingCellData in
                if isLoadingCellData {
                    self?.loadingActivityIndicator.startAnimating()
                }
                else {
                    self?.loadingActivityIndicator.stopAnimating()
                }
                self?.loadingView.isHidden = !isLoadingCellData
            })

        self.betCardsStackView.removeAllArrangedSubviews()
        
        for (index, betHistoryEntrySelection) in (betHistoryEntry.selections ?? []).enumerated() {

            let myTicketBetLineView = MyTicketBetLineView(betHistoryEntrySelection: betHistoryEntrySelection,
                                                          countryCode: countryCodes[safe: index] ?? "",
                                                          viewModel: viewModel.selections[index])
            
//            myTicketBetLineView.configureCustomTheme(theme: .multibet)
            
            myTicketBetLineView.tappedMatchDetail = { [weak self] matchId in
                self?.tappedMatchDetail?(matchId)
            }
           
            self.betCardsStackView.addArrangedSubview(myTicketBetLineView)
        }

        //
        self.titleLabel.text = String([betHistoryEntry.type, betHistoryEntry.systemBetType, betHistoryEntry.localizedBetStatus]
            .compactMap({ $0 })
            .filter({ !$0.isEmpty })
            .map({ $0.capitalized })
            .joined(separator: " - "))

        if let date = betHistoryEntry.placedDate {
            self.dateLabel.text = SocialMyTicketTableViewCell.dateFormatter.string(from: date)
        }

        self.betIdLabel.text = "\(localized("bet_id")): \(betHistoryEntry.betId)"
        
        if let oddValue = betHistoryEntry.totalPriceValue, betHistoryEntry.type != "SYSTEM" {
            self.totalOddValueLabel.text = oddValue == 0.0 ? "-" : OddFormatter.formatOdd(withValue: oddValue)
        }

        if let betAmount = betHistoryEntry.totalBetAmount,
           let betAmountString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: betAmount)) {
            self.betAmountValueLabel.text = betAmountString
        }

        //
        self.winningsTitleLabel.text = localized("possible_winnings")
        if let maxWinnings = betHistoryEntry.maxWinning,
           let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
            self.winningsValueLabel.text = maxWinningsString
        }

        if let status = betHistoryEntry.status?.uppercased() {
            switch status {
            case "WON":
                self.highlightCard(withColor: UIColor.App.myTicketsWon)
                self.winningsTitleLabel.text = localized("return_text")  // Titulo
                if let maxWinnings = betHistoryEntry.overallBetReturns, // Valor  - > overallBetReturns
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.winningsValueLabel.text = maxWinningsString
                }
            case "LOST":
                self.highlightCard(withColor: UIColor.App.myTicketsLost)
                self.winningsTitleLabel.text = localized("possible_winnings") // Titulo
                if let maxWinnings = betHistoryEntry.maxWinning, // Valor  - > maxWinning
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.winningsValueLabel.text = maxWinningsString
                }
            case "DRAW":
                self.highlightCard(withColor: UIColor.App.myTicketsOther)
                self.winningsTitleLabel.text = localized("return_text")  // Titulo
                if let maxWinnings = betHistoryEntry.overallBetReturns, // Valor  - > overallBetReturns
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.winningsValueLabel.text = maxWinningsString
                }
            case "OPEN":
                self.resetHighlightedCard()
                self.winningsTitleLabel.text = localized("possible_winnings") // Titulo
                
                if let maxWinnings = betHistoryEntry.maxWinning, // Valor  - > maxWinning
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.winningsValueLabel.text = maxWinningsString
                }
            default:
                self.resetHighlightedCard()
            }
        }

    }
    private func highlightCard(withColor color: UIColor) {
        
        self.topStatusView.backgroundColor = color
        self.betInfoBaseView.backgroundColor = color
        self.bottomStatusView.backgroundColor = color

        self.betInfoSeparatorLineView.backgroundColor = UIColor.App.buttonTextSecondary
        
        self.totalOddTitleLabel.textColor = UIColor.App.buttonTextSecondary
        self.totalOddValueLabel.textColor = UIColor.App.buttonTextSecondary
        
        self.betAmountTitleLabel.textColor = UIColor.App.buttonTextSecondary
        self.betAmountValueLabel.textColor = UIColor.App.buttonTextSecondary

        self.winningsTitleLabel.textColor = UIColor.App.buttonTextSecondary
        self.winningsValueLabel.textColor = UIColor.App.buttonTextSecondary

    }
    
    private func resetHighlightedCard() {
        self.topStatusView.backgroundColor = .clear
        self.betInfoBaseView.backgroundColor = .clear
        self.bottomStatusView.backgroundColor = .clear

        self.betInfoSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        
        self.totalOddTitleLabel.textColor = UIColor.App.textPrimary
        self.totalOddValueLabel.textColor = UIColor.App.textPrimary
        
        self.betAmountTitleLabel.textColor = UIColor.App.textPrimary
        self.betAmountValueLabel.textColor = UIColor.App.textPrimary

        self.winningsTitleLabel.textColor = UIColor.App.textPrimary
        self.winningsValueLabel.textColor = UIColor.App.textPrimary
    }
    
    // MARK: Actions
    @objc private func didTapQRCodeButton() {
        print("QR CODE!")
        
        if let betInfo = self.betHistoryEntry {
            self.tappedQRCodeAction?(betInfo)
        }
        
    }
    
    @objc private func didTapShareButton() {
        let renderer = UIGraphicsImageRenderer(size: self.containerView.bounds.size)
        let image = renderer.image { _ in
            self.containerView.drawHierarchy(in: self.containerView.bounds, afterScreenUpdates: true)
        }
        if let betHistoryEntry = self.betHistoryEntry {
            self.tappedShareAction(image, betHistoryEntry)
        }
    }
    
    @objc private func didTapEditButton() {
        if let betHistoryEntry = self.betHistoryEntry {
            self.tappedEditBetAction?(betHistoryEntry)
        }
    }
    
    @objc private func didTapUpdateOddsButton() {
        if let betId = self.betHistoryEntry?.betId {
            self.tappedUpdateOddsAction?(betId)
            self.viewModel?.isLoadingCellData.send(true)
        }
    }
    
    @objc private func didTapDeleteButton() {
        if let betId = self.betHistoryEntry?.betId {
            self.tappedDeleteBetAction?(betId)
        }
        
    }
}

extension SocialMyTicketTableViewCell {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTopStatusView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "placard_logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createQRCodeButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "qr_code_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }
    
    private static func createShareButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "share_bet_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bet Title"
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        return label
    }
    
    private static func createDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "01/01/2000, 18:00"
        label.font = AppFont.with(type: .medium, size: 10)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }
    
    private static func createBetIdLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bet ID: 012345"
        label.font = AppFont.with(type: .medium, size: 10)
        label.textAlignment = .left
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }
    
    private static func createTopInfoSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createBetActionsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillProportionally
        return stackView
    }
    
    private static func createEditBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createEditButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("edit"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .medium, size: 13)
        button.setImage(UIImage(named: "edit_bet_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.setInsets(forContentPadding: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4), imageTitlePadding: 6)
        return button
    }
    
    private static func createUpdateOddsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createUpdateOddsButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("update_odds"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .medium, size: 13)
        button.setImage(UIImage(named: "update_bet_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.setInsets(forContentPadding: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4), imageTitlePadding: 6)
        return button
    }
    
    private static func createDeleteBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createDeleteButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("delete"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .medium, size: 13)
        button.setImage(UIImage(named: "delete_bet_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.setInsets(forContentPadding: UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4), imageTitlePadding: 6)
        return button
    }

    private static func createBetCardsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .equalSpacing
        return stackView
    }
    
    private static func createBottomStatusView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createBetInfoBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createBetInfoLabelsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fillEqually
        return stackView
    }
    
    private static func createBetInfoSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createBetInfoValuesStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fillEqually
        return stackView
    }
    
    private static func createTotalOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("total_odd")
        label.font = AppFont.with(type: .bold, size: 12)
        label.textAlignment = .center
        return label
    }
    
    private static func createTotalOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1.0"
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        return label
    }
    
    private static func createBetAmountTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("bet_amount")
        label.font = AppFont.with(type: .bold, size: 12)
        label.textAlignment = .center
        return label
    }
    
    private static func createBetAmountValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "€ 10,00"
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        return label
    }
    
    private static func createWinningsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("winnings")
        label.font = AppFont.with(type: .bold, size: 12)
        label.textAlignment = .center
        return label
    }
    
    private static func createWinningsValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "€ 10,00"
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        return label
    }
    
    private static func createLoadingView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createLoadingActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .medium)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        return activityIndicatorView
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.containerView)

        self.containerView.addSubview(self.topStatusView)
        self.containerView.addSubview(self.iconImageView)
        self.containerView.addSubview(self.qrCodeButton)
        self.containerView.addSubview(self.shareButton)
        
        self.containerView.addSubview(self.titleLabel)
        
        self.containerView.addSubview(self.dateLabel)
        
        self.containerView.addSubview(self.betIdLabel)
        
        self.containerView.addSubview(self.topInfoSeparatorLineView)
        
        self.containerView.addSubview(self.betActionsStackView)
        
        self.betActionsStackView.addArrangedSubview(self.editBaseView)
        self.editBaseView.addSubview(self.editButton)
        
        self.betActionsStackView.addArrangedSubview(self.updateOddsBaseView)
        self.updateOddsBaseView.addSubview(self.updateOddsButton)
        
        self.betActionsStackView.addArrangedSubview(self.deleteBaseView)
        self.deleteBaseView.addSubview(self.deleteButton)
        
        self.containerView.addSubview(self.betCardsStackView)
        
        self.containerView.addSubview(self.bottomStatusView)
        
        self.bottomStatusView.addSubview(self.betInfoBaseView)
        
        self.betInfoBaseView.addSubview(self.betInfoLabelsStackView)
        self.betInfoBaseView.addSubview(self.betInfoSeparatorLineView)
        self.betInfoBaseView.addSubview(self.betInfoValuesStackView)
        
        self.betInfoLabelsStackView.addArrangedSubview(self.totalOddTitleLabel)
        self.betInfoLabelsStackView.addArrangedSubview(self.betAmountTitleLabel)
        self.betInfoLabelsStackView.addArrangedSubview(self.winningsTitleLabel)
        
        self.betInfoValuesStackView.addArrangedSubview(self.totalOddValueLabel)
        self.betInfoValuesStackView.addArrangedSubview(self.betAmountValueLabel)
        self.betInfoValuesStackView.addArrangedSubview(self.winningsValueLabel)
        
        self.contentView.addSubview(self.loadingView)
        
        self.loadingView.addSubview(self.loadingActivityIndicator)
        
        self.initConstraints()

        self.containerView.layoutIfNeeded()
        self.containerView.layoutSubviews()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 12),
            self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -12),
            self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            self.containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5)
        ])
        
        // Content
        NSLayoutConstraint.activate([
            
            self.topStatusView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.topStatusView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.topStatusView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.topStatusView.heightAnchor.constraint(equalToConstant: 5),
        
            self.iconImageView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.iconImageView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 14),
            self.iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            self.qrCodeButton.widthAnchor.constraint(equalToConstant: 40),
            self.qrCodeButton.heightAnchor.constraint(equalToConstant: 40),
            self.qrCodeButton.centerYAnchor.constraint(equalTo: self.iconImageView.centerYAnchor),
            self.qrCodeButton.trailingAnchor.constraint(equalTo: self.shareButton.leadingAnchor, constant: 0),
            
            self.shareButton.widthAnchor.constraint(equalToConstant: 40),
            self.shareButton.heightAnchor.constraint(equalToConstant: 40),
            self.shareButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: 0),
            self.shareButton.centerYAnchor.constraint(equalTo: self.qrCodeButton.centerYAnchor),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.titleLabel.topAnchor.constraint(equalTo: self.iconImageView.bottomAnchor, constant: 10),
            
            self.dateLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.dateLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
            
            self.betIdLabel.leadingAnchor.constraint(equalTo: self.dateLabel.trailingAnchor, constant: 10),
            self.betIdLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.betIdLabel.centerYAnchor.constraint(equalTo: self.dateLabel.centerYAnchor),
            
            self.topInfoSeparatorLineView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.topInfoSeparatorLineView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.topInfoSeparatorLineView.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: 8),
            self.topInfoSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),
            
            self.betActionsStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.betActionsStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.betActionsStackView.topAnchor.constraint(equalTo: self.topInfoSeparatorLineView.bottomAnchor, constant: 8),
            self.betActionsStackView.heightAnchor.constraint(equalToConstant: 20),
            
            self.editButton.leadingAnchor.constraint(equalTo: self.editBaseView.leadingAnchor),
            self.editButton.centerYAnchor.constraint(equalTo: self.editBaseView.centerYAnchor),
            self.editButton.heightAnchor.constraint(equalToConstant: 20),
            
            self.updateOddsButton.centerXAnchor.constraint(equalTo: self.updateOddsBaseView.centerXAnchor),
            self.updateOddsButton.centerYAnchor.constraint(equalTo: self.updateOddsBaseView.centerYAnchor),
            self.updateOddsButton.heightAnchor.constraint(equalToConstant: 20),
            
            self.deleteButton.trailingAnchor.constraint(equalTo: self.deleteBaseView.trailingAnchor),
            self.deleteButton.centerYAnchor.constraint(equalTo: self.deleteBaseView.centerYAnchor),
            self.deleteButton.heightAnchor.constraint(equalToConstant: 20),
            
            self.betCardsStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 6),
            self.betCardsStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -6),
            self.betCardsStackView.topAnchor.constraint(equalTo: self.betActionsStackView.bottomAnchor, constant: 8),
            
            self.bottomStatusView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.bottomStatusView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.bottomStatusView.topAnchor.constraint(equalTo: self.betCardsStackView.bottomAnchor, constant: 14),
            self.bottomStatusView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            
            self.betInfoBaseView.leadingAnchor.constraint(equalTo: self.bottomStatusView.leadingAnchor, constant: 14),
            self.betInfoBaseView.trailingAnchor.constraint(equalTo: self.bottomStatusView.trailingAnchor, constant: -14),
            self.betInfoBaseView.topAnchor.constraint(equalTo: self.bottomStatusView.topAnchor, constant: 8),
            self.betInfoBaseView.bottomAnchor.constraint(equalTo: self.bottomStatusView.bottomAnchor, constant: -14),
            
            self.betInfoLabelsStackView.leadingAnchor.constraint(equalTo: self.betInfoBaseView.leadingAnchor),
            self.betInfoLabelsStackView.trailingAnchor.constraint(equalTo: self.betInfoBaseView.trailingAnchor),
            self.betInfoLabelsStackView.topAnchor.constraint(equalTo: self.betInfoBaseView.topAnchor),
            
            self.betInfoSeparatorLineView.leadingAnchor.constraint(equalTo: self.betInfoBaseView.leadingAnchor),
            self.betInfoSeparatorLineView.trailingAnchor.constraint(equalTo: self.betInfoBaseView.trailingAnchor),
            self.betInfoSeparatorLineView.topAnchor.constraint(equalTo: self.betInfoLabelsStackView.bottomAnchor, constant: 6),
            self.betInfoSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),

            self.betInfoValuesStackView.leadingAnchor.constraint(equalTo: self.betInfoBaseView.leadingAnchor),
            self.betInfoValuesStackView.trailingAnchor.constraint(equalTo: self.betInfoBaseView.trailingAnchor),
            self.betInfoValuesStackView.topAnchor.constraint(equalTo: self.betInfoSeparatorLineView.bottomAnchor, constant: 6),
            self.betInfoValuesStackView.bottomAnchor.constraint(equalTo: self.betInfoBaseView.bottomAnchor)
            
        ])
        
        // Loading View
        NSLayoutConstraint.activate([
        
            self.loadingView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.loadingView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.loadingView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.loadingView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            
            self.loadingActivityIndicator.centerXAnchor.constraint(equalTo: self.loadingView.centerXAnchor),
            self.loadingActivityIndicator.centerYAnchor.constraint(equalTo: self.loadingView.centerYAnchor)
        ])
    }
}

extension SocialMyTicketTableViewCell {
    static var dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        return dateFormatter
    }()
}
