//
//  SharedTicketCardView.swift
//  Sportsbook
//
//  Created by André Lascas on 11/07/2022.
//

import UIKit
import ServicesProvider

class SharedTicketCardView: UIView {

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var shareButton: CustomShareButton = Self.createShareButton()
    private lazy var betCardsBaseView: UIView = Self.createBetCardsBaseView()
    private lazy var betCardsStackView: UIStackView = Self.createBetCardsStackView()
    private lazy var bottomBaseView: UIView = Self.createBottomBaseView()
    private lazy var bottomSeparatorLineView: UIView = Self.createBottomSeparatorLineView()
    private lazy var bottomTitlesStackView: UIStackView = Self.createBottomTitlesStackView()
    private lazy var bottomSubtitlesStackView: UIStackView = Self.createBottomSubtitlesStackView()
    private lazy var totalOddTitleLabel: UILabel = Self.createTotalOddTitleLabel()
    private lazy var totalOddSubtitleLabel: UILabel = Self.createTotalOddSubtitleLabel()
    private lazy var betAmountTitleLabel: UILabel = Self.createBetAmountTitleLabel()
    private lazy var betAmountSubtitleLabel: UILabel = Self.createBetAmountSubtitleLabel()
    private lazy var winningsTitleLabel: UILabel = Self.createWinningsTitleLabel()
    private lazy var winningsSubtitleLabel: UILabel = Self.createWinningsSubtitleLabel()
    private lazy var cashbackInfoBaseView: UIView = Self.createCashbackInfoBaseView()
    private lazy var cashbackInfoView: CashbackInfoView = Self.createCashbackInfoView()
    private lazy var cashbackValueLabel: UILabel = Self.createCashbackValueLabel()
    private lazy var learnMoreBaseView: CashbackLearnMoreView = Self.createLearnMoreBaseView()
    private lazy var cashbackIconImageView: UIImageView = Self.createCashbackIconImageView()
    private lazy var cashbackUsedBaseView: UIView = Self.createCashbackUsedBaseView()
    private lazy var cashbackUsedTitleLabel: UILabel = Self.createCashbackUsedTitleLabel()
    private lazy var bottomContainerStackView: UIStackView = Self.createBottomContainerStackView()
    private lazy var winBoostInfoView: WinBoostInfoView = Self.createWinBoostInfoView()
    
    // Container
    private lazy var subtitleLabelTopToTitleConstraint: NSLayoutConstraint = Self.createSubtitleLabelTopToTitleConstraint()
    private lazy var subtitleLabelTopToUsedCashbackConstraint: NSLayoutConstraint = Self.createSubtitleLabelTopToUsedCashbackConstraint()

    private var betHistoryEntry: BetHistoryEntry?

    var didTappedSharebet: ((UIImage?) -> Void)?
    var didTapLearnMore: (() -> Void)?

    var hasCashback: Bool = false {
        didSet {
            self.cashbackInfoBaseView.isHidden = !hasCashback
            self.cashbackValueLabel.isHidden = !hasCashback
            self.cashbackIconImageView.isHidden = !hasCashback
        }
    }

    var usedCashback: Bool = false {
        didSet {
            self.cashbackUsedBaseView.isHidden = !usedCashback
            self.subtitleLabelTopToTitleConstraint.isActive = !usedCashback
            self.subtitleLabelTopToUsedCashbackConstraint.isActive = usedCashback
        }
    }

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

//        if Env.appSession.businessModulesManager.isSocialFeaturesEnabled {
//            self.shareButton.isHidden = false
//        }
//        else {
//            self.shareButton.isHidden = true
//        }
        self.shareButton.isHidden = false
        
        self.shareButton.onTap = { [weak self] in
            self?.didTapShareButton()
        }

        self.cashbackInfoView.didTapInfoAction = { [weak self] in

            UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction], animations: {
                self?.learnMoreBaseView.alpha = 1
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction], animations: {
                    self?.learnMoreBaseView.alpha = 0
                })
            }
            
        }

        self.learnMoreBaseView.didTapLearnMoreAction = { [weak self] in

            self?.didTapLearnMore?()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.baseView.layer.cornerRadius = CornerRadius.button
        self.baseView.clipsToBounds = true
        self.baseView.layer.masksToBounds = true

        self.cashbackUsedBaseView.layer.cornerRadius = CornerRadius.status

    }

    func setupWithTheme() {

        self.backgroundColor = .clear

        self.shareButton.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.subtitleLabel.textColor = UIColor.App.textPrimary

        self.baseView.backgroundColor = UIColor.App.backgroundSecondary
        self.betCardsBaseView.backgroundColor = .clear
        self.betCardsStackView.backgroundColor = .clear

        self.bottomSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        self.bottomBaseView.backgroundColor = .clear
        self.bottomTitlesStackView.backgroundColor = .clear
        self.bottomSubtitlesStackView.backgroundColor = .clear

        self.totalOddTitleLabel.textColor = UIColor.App.textSecondary

        self.totalOddSubtitleLabel.textColor = UIColor.App.textPrimary

        self.betAmountTitleLabel.textColor = UIColor.App.textSecondary

        self.betAmountSubtitleLabel.textColor = UIColor.App.textPrimary

        self.winningsTitleLabel.textColor = UIColor.App.textSecondary

        self.winningsSubtitleLabel.textColor = UIColor.App.textPrimary

        self.cashbackInfoBaseView.backgroundColor = .clear

        self.cashbackValueLabel.textColor = UIColor.App.textPrimary

        self.cashbackIconImageView.backgroundColor = .clear

        self.learnMoreBaseView.alpha = 0

        self.cashbackUsedBaseView.backgroundColor = UIColor.App.highlightSecondary

        self.cashbackUsedTitleLabel.textColor = UIColor.App.buttonTextPrimary
    }

    func configure(withBetHistoryEntry betHistoryEntry: BetHistoryEntry,
                   countryCodes: [String],
                   viewModel: MyTicketCellViewModel,
                   cashbackValue: Double? = nil,
                   usedCashback: Bool,
                   betWheelInfo: BetWheelInfo?,
                   wheelAwardedTier: WheelAwardedTier?) {

        self.betHistoryEntry = betHistoryEntry

        self.betCardsStackView.removeAllArrangedSubviews()

        for (index, betHistoryEntrySelection) in (betHistoryEntry.selections ?? []).enumerated() {

            let sharedTicketBetLineView = SharedTicketBetLineView(betHistoryEntrySelection: betHistoryEntrySelection,
                                                                  countryCode: countryCodes[safe: index] ?? "")

            sharedTicketBetLineView.layoutIfNeeded()
            sharedTicketBetLineView.layoutSubviews()

            self.betCardsStackView.addArrangedSubview(sharedTicketBetLineView)
        }

        self.titleLabel.text = viewModel.title

        if let date = betHistoryEntry.placedDate {
            self.subtitleLabel.text = MyTicketBetLineView.dateFormatter.string(from: date)
        }

        if let oddValue = betHistoryEntry.totalPriceValue, betHistoryEntry.type?.uppercased() != "SYSTEM" {
//            self.totalOddSubtitleLabel.text = OddConverter.stringForValue(oddValue, format: UserDefaults.standard.userOddsFormat)
            if oddValue.isNaN {
                self.totalOddSubtitleLabel.text = "-"
            }
            else {
                self.totalOddSubtitleLabel.text = OddFormatter.formatOdd(withValue: oddValue)
            }
        }

        if let betAmount = betHistoryEntry.totalBetAmount,
           let betAmountString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: betAmount)) {
            self.betAmountSubtitleLabel.text = betAmountString
        }

        self.winningsTitleLabel.text = localized("possible_winnings")
        if let maxWinnings = betHistoryEntry.maxWinning,
           let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
            self.winningsSubtitleLabel.text = maxWinningsString
        }

        if let cashbackValue {
            let formattedValue = CurrencyFormater.defaultFormat.string(from: NSNumber(value: cashbackValue)) ?? localized("no_value")
            self.cashbackValueLabel.text = formattedValue
            
            self.hasCashback = true
        }
        else {
            self.hasCashback = false
        }

        self.usedCashback = usedCashback
        
        if let betWheelInfo,
           let wheelAwardedTier,
           let maxWinnings = betHistoryEntry.maxWinning {
            
            let winValue = (maxWinnings * wheelAwardedTier.boostMultiplier) > 500 ? 500 : maxWinnings * wheelAwardedTier.boostMultiplier

            let winValueString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: winValue))
            
            let prize = "+" + String(format: "%.0f%%", wheelAwardedTier.boostMultiplier * 100)
            
            self.winBoostInfoView.configure(title: localized("coup_de_boost"), subtitle: prize, value: winValueString ?? "")
            
            self.winBoostInfoView.isHidden = false
            
            self.baseView.setNeedsLayout()
            self.baseView.layoutIfNeeded()
        }
        
    }

    @objc func didTapShareButton() {
        print("Tapped share")
        let renderer = UIGraphicsImageRenderer(size: self.baseView.bounds.size)
        let image = renderer.image { _ in
            self.baseView.drawHierarchy(in: self.baseView.bounds, afterScreenUpdates: true)
        }

        didTappedSharebet?(image)
    }

}

extension SharedTicketCardView {
    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createHeaderBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 14)
        label.text = localized("title")
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 9)
        label.text = localized("subtitle")
        return label
    }

    private static func createShareButton() -> CustomShareButton {
        let button = CustomShareButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private static func createBetCardsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBetCardsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }

    private static func createBottomBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomTitlesStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        return stackView
    }

    private static func createBottomSubtitlesStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .fillEqually
        return stackView
    }

    private static func createTotalOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold , size: 10)
        label.text = localized("total_odd")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private static func createTotalOddSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold , size: 12)
        label.text = "-.--"
        label.textAlignment = .center
        return label
    }

    private static func createBetAmountTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold , size: 10)
        label.text = localized("bet_amount")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private static func createBetAmountSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold , size: 12)
        label.text = "-.--"
        label.textAlignment = .center
        return label
    }

    private static func createWinningsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold , size: 10)
        label.text = localized("winnings")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private static func createWinningsSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold , size: 14)
        label.text = "-.--"
        label.textAlignment = .center
        return label
    }

    private static func createCashbackInfoBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackInfoView() -> CashbackInfoView {
        let view = CashbackInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.text = "-.--"
        label.textAlignment = .center
        return label
    }

    private static func createLearnMoreBaseView() -> CashbackLearnMoreView {
        let view = CashbackLearnMoreView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "cashback_big_blue_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createCashbackUsedBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackUsedTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 9)
        label.text = localized("betsson_credits_used").uppercased()
        label.textAlignment = .left
        return label
    }
    
    private static func createBottomContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        return stackView
    }
    
    private static func createWinBoostInfoView() -> WinBoostInfoView {
        let view = WinBoostInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }
    
    private static func createSubtitleLabelTopToTitleConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private static func createSubtitleLabelTopToUsedCashbackConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {
        self.addSubview(self.baseView)

        self.baseView.addSubview(self.titleLabel)

        self.baseView.addSubview(self.subtitleLabel)

        self.baseView.addSubview(self.shareButton)

        self.baseView.addSubview(self.betCardsBaseView)

        self.betCardsBaseView.addSubview(self.betCardsStackView)

//        self.baseView.addSubview(self.bottomBaseView)
        self.baseView.addSubview(self.bottomContainerStackView)

        self.bottomContainerStackView.addArrangedSubview(self.bottomBaseView)
        
        self.bottomBaseView.addSubview(self.bottomTitlesStackView)

        self.bottomBaseView.addSubview(self.bottomSeparatorLineView)

        self.bottomBaseView.addSubview(self.bottomSubtitlesStackView)

        self.bottomTitlesStackView.addArrangedSubview(self.totalOddTitleLabel)
        self.bottomTitlesStackView.addArrangedSubview(self.betAmountTitleLabel)
        self.bottomTitlesStackView.addArrangedSubview(self.cashbackInfoBaseView)
        self.bottomTitlesStackView.addArrangedSubview(self.winningsTitleLabel)

        self.cashbackInfoBaseView.addSubview(self.cashbackInfoView)

        self.bottomSubtitlesStackView.addArrangedSubview(self.totalOddSubtitleLabel)
        self.bottomSubtitlesStackView.addArrangedSubview(self.betAmountSubtitleLabel)
        self.bottomSubtitlesStackView.addArrangedSubview(self.cashbackValueLabel)
        self.bottomSubtitlesStackView.addArrangedSubview(self.winningsSubtitleLabel)

        self.baseView.addSubview(self.learnMoreBaseView)

        self.baseView.addSubview(self.cashbackIconImageView)

        self.baseView.addSubview(self.cashbackUsedBaseView)

        self.cashbackUsedBaseView.addSubview(self.cashbackUsedTitleLabel)
        
        self.bottomContainerStackView.addArrangedSubview(self.winBoostInfoView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.baseView.topAnchor.constraint(equalTo: self.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 16),
            self.titleLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 14),
            
            self.cashbackUsedBaseView.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.cashbackUsedBaseView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 3),

            self.cashbackUsedTitleLabel.leadingAnchor.constraint(equalTo: self.cashbackUsedBaseView.leadingAnchor, constant: 8),
            self.cashbackUsedTitleLabel.trailingAnchor.constraint(equalTo: self.cashbackUsedBaseView.trailingAnchor, constant: -8),
            self.cashbackUsedTitleLabel.topAnchor.constraint(equalTo: cashbackUsedBaseView.topAnchor, constant: 3),
            self.cashbackUsedTitleLabel.bottomAnchor.constraint(equalTo: self.cashbackUsedBaseView.bottomAnchor, constant: -3),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 16),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -16),

            self.shareButton.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -12),
            self.shareButton.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 12),
            self.shareButton.heightAnchor.constraint(equalToConstant: 32),

            self.betCardsBaseView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 16),
            self.betCardsBaseView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -16),
            self.betCardsBaseView.topAnchor.constraint(equalTo: self.subtitleLabel.bottomAnchor, constant: 9),
            self.betCardsBaseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 90),

            self.betCardsStackView.leadingAnchor.constraint(equalTo: self.betCardsBaseView.leadingAnchor),
            self.betCardsStackView.trailingAnchor.constraint(equalTo: self.betCardsBaseView.trailingAnchor),
            self.betCardsStackView.topAnchor.constraint(equalTo: self.betCardsBaseView.topAnchor),
            self.betCardsStackView.bottomAnchor.constraint(equalTo: self.betCardsBaseView.bottomAnchor),
            
            self.bottomContainerStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.bottomContainerStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.bottomContainerStackView.topAnchor.constraint(equalTo: self.betCardsBaseView.bottomAnchor, constant: 12),
            self.bottomContainerStackView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -8),

            self.bottomBaseView.leadingAnchor.constraint(equalTo: self.bottomContainerStackView.leadingAnchor),
            self.bottomBaseView.trailingAnchor.constraint(equalTo: self.bottomContainerStackView.trailingAnchor),
//            self.bottomBaseView.topAnchor.constraint(equalTo: self.betCardsBaseView.bottomAnchor, constant: 12),
//            self.bottomBaseView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -14),
//            self.bottomBaseView.heightAnchor.constraint(equalToConstant: 55),

            self.bottomTitlesStackView.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor, constant: 25),
            self.bottomTitlesStackView.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor, constant: -25),
            self.bottomTitlesStackView.topAnchor.constraint(equalTo: self.bottomBaseView.topAnchor, constant: 0),
            self.bottomTitlesStackView.heightAnchor.constraint(equalToConstant: 25),

            self.bottomSeparatorLineView.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor, constant: 25),
            self.bottomSeparatorLineView.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor, constant: -25),
            self.bottomSeparatorLineView.topAnchor.constraint(equalTo: self.bottomTitlesStackView.bottomAnchor, constant: 2),
            self.bottomSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),

            self.bottomSubtitlesStackView.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor, constant: 25),
            self.bottomSubtitlesStackView.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor, constant: -25),
            self.bottomSubtitlesStackView.topAnchor.constraint(equalTo: self.bottomSeparatorLineView.bottomAnchor, constant: 2),
            self.bottomSubtitlesStackView.bottomAnchor.constraint(equalTo: self.bottomBaseView.bottomAnchor, constant: 0),
            self.bottomSubtitlesStackView.heightAnchor.constraint(equalToConstant: 25),

            self.cashbackInfoView.centerXAnchor.constraint(equalTo: self.cashbackInfoBaseView.centerXAnchor),
            self.cashbackInfoView.centerYAnchor.constraint(equalTo: self.cashbackInfoBaseView.centerYAnchor),

            self.cashbackIconImageView.widthAnchor.constraint(equalToConstant: 20),
            self.cashbackIconImageView.heightAnchor.constraint(equalTo: self.cashbackIconImageView.widthAnchor),
            self.cashbackIconImageView.leadingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor, constant: 10),
            self.cashbackIconImageView.centerYAnchor.constraint(equalTo: self.titleLabel.centerYAnchor),
            
            self.winBoostInfoView.leadingAnchor.constraint(equalTo: self.bottomContainerStackView.leadingAnchor, constant: 16),
            self.winBoostInfoView.trailingAnchor.constraint(equalTo: self.bottomContainerStackView.trailingAnchor, constant: -16)

        ])

        // Learn more view
        NSLayoutConstraint.activate([

            self.learnMoreBaseView.bottomAnchor.constraint(equalTo: self.cashbackInfoView.topAnchor, constant: -10),
            self.learnMoreBaseView.trailingAnchor.constraint(equalTo: self.cashbackInfoView.trailingAnchor, constant: 10),
            self.learnMoreBaseView.widthAnchor.constraint(equalToConstant: 220)
        ])

        self.subtitleLabelTopToTitleConstraint = self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 3)

        self.subtitleLabelTopToTitleConstraint.isActive = true
        
        self.subtitleLabelTopToUsedCashbackConstraint = self.subtitleLabel.topAnchor.constraint(equalTo: self.cashbackUsedBaseView.bottomAnchor, constant: 3)

        self.subtitleLabelTopToUsedCashbackConstraint.isActive = false
    }
}
