//
//  BetSelectionStateTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2022.
//

import UIKit
import Combine

class BetSelectionStateTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var topStateView: UIView = Self.createTopStateView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var dateLabel: UILabel = Self.createDateLabel()
    private lazy var betIdLabel: UILabel = Self.createBetIdLabel()
    private lazy var checkboxBaseView: UIView = Self.createCheckboxBaseView()
    private lazy var checkboxImageView: UIImageView = Self.createCheckboxImageView()
    private lazy var ticketsStackView: UIStackView = Self.createTicketsStackView()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()

    private lazy var bottomStateView: UIView = Self.createBottomStateView()

    private lazy var bottomTitlesStackView: UIStackView = Self.createBottomTitlesStackView()
    private lazy var totalOddTitleLabel: UILabel = Self.createTotalOddTitleLabel()
    private lazy var betAmountTitleLabel: UILabel = Self.createBetAmountTitleLabel()
    private lazy var possibleWinningTitleLabel: UILabel = Self.createPossibleWinningTitleLabel()

    private lazy var bottomValuesStackView: UIStackView = Self.createBottomValuesStackView()
    private lazy var totalOddValueLabel: UILabel = Self.createTotalOddValueLabel()
    private lazy var betAmountValueLabel: UILabel = Self.createBetAmountValueLabel()
    private lazy var possibleWinningValueLabel: UILabel = Self.createPossibleWinningValueLabel()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: BetSelectionCellViewModel?

    var didTapCheckboxAction: ((BetSelectionCellViewModel) -> Void)?
    var didTapUncheckboxAction: ((BetSelectionCellViewModel) -> Void)?

    var betState: BetState = .open {
        didSet {
            switch betState {
            case .won:
                self.topStateView.backgroundColor = UIColor.App.myTicketsWon
                self.bottomStateView.backgroundColor = UIColor.App.myTicketsWon
            case .lost:
                self.topStateView.backgroundColor = UIColor.App.myTicketsLost
                self.bottomStateView.backgroundColor = UIColor.App.myTicketsLost
            case .draw:
                self.topStateView.backgroundColor = UIColor.App.myTicketsOther
                self.bottomStateView.backgroundColor = UIColor.App.myTicketsOther
            case .open:
                self.topStateView.backgroundColor = UIColor.App.backgroundPrimary
                self.bottomStateView.backgroundColor = UIColor.App.backgroundPrimary
            }
        }
    }

    // MARK: Public Properties
    var isCheckboxSelected: Bool = false {
        didSet {
            if isCheckboxSelected {
                self.checkboxImageView.image = UIImage(named: "radio_selected_icon")
            }
            else {
                self.checkboxImageView.image = UIImage(named: "radio_unselected_icon")
            }
        }
    }

    // MARK: Lifetime and Cycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
        self.setupWithTheme()

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.isCheckboxSelected = false

        self.ticketsStackView.removeAllArrangedSubviews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.baseView.clipsToBounds = true
        self.baseView.layer.cornerRadius = CornerRadius.button

        self.ticketsStackView.layoutIfNeeded()
        self.ticketsStackView.layoutSubviews()
    }

    // MARK: Layout and Theme
    func setupWithTheme() {
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .clear

        self.baseView.backgroundColor = UIColor.App.backgroundPrimary

        self.topStateView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.dateLabel.textColor = UIColor.App.textSecondary
        
        self.betIdLabel.textColor = UIColor.App.textSecondary
        
        self.checkboxBaseView.backgroundColor = .clear
        self.checkboxImageView.backgroundColor = .clear
        self.ticketsStackView.backgroundColor = .clear
        
        self.separatorLineView.backgroundColor = UIColor.App.buttonTextSecondary

        self.bottomStateView.backgroundColor = UIColor.App.backgroundPrimary

        self.bottomTitlesStackView.backgroundColor = .clear
        self.totalOddTitleLabel.textColor = UIColor.App.buttonTextSecondary
        self.betAmountTitleLabel.textColor = UIColor.App.buttonTextSecondary
        self.possibleWinningTitleLabel.textColor = UIColor.App.buttonTextSecondary

        self.bottomValuesStackView.backgroundColor = .clear
        self.totalOddValueLabel.textColor = UIColor.App.buttonTextSecondary
        self.betAmountValueLabel.textColor = UIColor.App.buttonTextSecondary
        self.possibleWinningValueLabel.textColor = UIColor.App.buttonTextSecondary
    }

    // MARK: Functions
    func configure(withViewModel viewModel: BetSelectionCellViewModel) {
        self.viewModel = viewModel

        viewModel.isCheckboxSelectedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selected in
                self?.isCheckboxSelected = selected
            }
            .store(in: &cancellables)
        
        let betHistoryEntry = viewModel.ticket

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
        self.possibleWinningTitleLabel.text = localized("possible_winnings")
        if let maxWinnings = betHistoryEntry.maxWinning,
           let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
            self.possibleWinningValueLabel.text = maxWinningsString
        }

        self.setupTicketStackView()

        self.totalOddValueLabel.text = viewModel.oddValueString

        self.betAmountValueLabel.text = viewModel.betAmountString

        if viewModel.ticket.status == "WON" {
            self.possibleWinningTitleLabel.text = localized("return_text")

            self.possibleWinningValueLabel.text = viewModel.returnString

        }
        else {
            self.possibleWinningValueLabel.text = viewModel.possibleWinningString
        }
        
        if let status = betHistoryEntry.status?.uppercased() {
            switch status {
            case "WON":
                self.betState = .won
                self.possibleWinningTitleLabel.text = localized("return_text")  // Titulo
                if let maxWinnings = betHistoryEntry.overallBetReturns, // Valor  - > overallBetReturns
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.possibleWinningValueLabel.text = maxWinningsString
                }
            case "LOST":
                self.betState = .lost
                self.possibleWinningTitleLabel.text = localized("possible_winnings") // Titulo
                if let maxWinnings = betHistoryEntry.maxWinning, // Valor  - > maxWinning
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.possibleWinningValueLabel.text = maxWinningsString
                }
            case "DRAW":
                self.betState = .draw
                self.possibleWinningTitleLabel.text = localized("return_text")  // Titulo
                if let maxWinnings = betHistoryEntry.overallBetReturns, // Valor  - > overallBetReturns
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.possibleWinningValueLabel.text = maxWinningsString
                }
            case "OPEN":
                self.betState = .open
                
                self.possibleWinningTitleLabel.text = localized("possible_winnings") // Titulo
                
                if let maxWinnings = betHistoryEntry.maxWinning, // Valor  - > maxWinning
                   let maxWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: maxWinnings)) {
                    self.possibleWinningValueLabel.text = maxWinningsString
                }
            default:
                ()
            }
        }
    }

    func setupTicketStackView() {
        self.ticketsStackView.removeAllArrangedSubviews()

        if let viewModel = viewModel {
            for selection in viewModel.betSelections() {
                let ticketView = ChatTicketSelectionView(betHistoryEntrySelection: selection)
                self.ticketsStackView.addArrangedSubview(ticketView)
            }
        }

        self.ticketsStackView.layoutIfNeeded()
    }

    private func betStatusText(forCode code: String) -> String {
        switch code {
        case "OPEN": return localized("open")
        case "DRAW": return localized("draw")
        case "WON": return localized("won")
        case "HALF_WON": return localized("half_won")
        case "LOST": return localized("lost")
        case "HALF_LOST": return localized("half_lost")
        case "CANCELLED": return localized("cancelled")
        case "CASHED_OUT": return localized("cashed_out")
        default: return ""
        }
    }

    // MARK: Actions
    @objc func didTapCheckbox(_ sender: UITapGestureRecognizer) {

        if let viewModel = self.viewModel {
            if self.isCheckboxSelected {
                self.didTapUncheckboxAction?(viewModel)
            }
            else {
                self.didTapCheckboxAction?(viewModel)
            }
        }

    }

}

extension BetSelectionStateTableViewCell {

    private static func createBaseView() -> UIView {
        let baseView = UIView()
        baseView.translatesAutoresizingMaskIntoConstraints = false
        return baseView
    }

    private static func createTopStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("title")
        label.font = AppFont.with(type: .bold, size: 14)
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

    private static func createCheckboxBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCheckboxImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "radio_unselected_icon")
        imageView.contentMode = .center
        return imageView
    }

    private static func createTicketsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .equalSpacing
        return stackView
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomStateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomTitlesStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }

    private static func createTotalOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("total_odd")
        label.font = AppFont.with(type: .bold, size: 12)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }

    private static func createBetAmountTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("bet_amount")
        label.font = AppFont.with(type: .bold, size: 12)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }

    private static func createPossibleWinningTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("possible_winnings")
        label.font = AppFont.with(type: .bold, size: 12)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }

    private static func createBottomValuesStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        return stackView
    }

    private static func createTotalOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "--"
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }

    private static func createBetAmountValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "--"
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }

    private static func createPossibleWinningValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "--"
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.baseView)

        self.baseView.addSubview(self.checkboxBaseView)

        self.baseView.addSubview(self.topStateView)

        self.baseView.addSubview(self.titleLabel)
        
        self.baseView.addSubview(self.dateLabel)
        
        self.baseView.addSubview(self.betIdLabel)

        self.checkboxBaseView.addSubview(self.checkboxImageView)

        self.baseView.addSubview(self.ticketsStackView)

        self.baseView.addSubview(self.bottomStateView)

        self.bottomStateView.addSubview(self.bottomTitlesStackView)
        self.bottomTitlesStackView.addArrangedSubview(self.totalOddTitleLabel)
        self.bottomTitlesStackView.addArrangedSubview(self.betAmountTitleLabel)
        self.bottomTitlesStackView.addArrangedSubview(self.possibleWinningTitleLabel)

        self.bottomStateView.addSubview(self.separatorLineView)

        self.bottomStateView.addSubview(self.bottomValuesStackView)
        self.bottomValuesStackView.addArrangedSubview(self.totalOddValueLabel)
        self.bottomValuesStackView.addArrangedSubview(self.betAmountValueLabel)
        self.bottomValuesStackView.addArrangedSubview(self.possibleWinningValueLabel)

        self.initConstraints()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapCheckbox(_:)))
        self.checkboxBaseView.addGestureRecognizer(tapGesture)

    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.baseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 140),
            self.baseView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 25),
            self.baseView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -25),
            self.baseView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 7),
            self.baseView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -7 ),

            self.topStateView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.topStateView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.topStateView.topAnchor.constraint(equalTo: self.baseView.topAnchor),
            self.topStateView.heightAnchor.constraint(equalToConstant: 6),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 15),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -50),
            self.titleLabel.topAnchor.constraint(equalTo: self.topStateView.bottomAnchor, constant: 10),
            
            self.dateLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 14),
            self.dateLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
            
            self.betIdLabel.leadingAnchor.constraint(equalTo: self.dateLabel.trailingAnchor, constant: 10),
            self.betIdLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -14),
            self.betIdLabel.centerYAnchor.constraint(equalTo: self.dateLabel.centerYAnchor),

            self.checkboxBaseView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -5),
            self.checkboxBaseView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 5),
            self.checkboxBaseView.widthAnchor.constraint(equalToConstant: 40),
            self.checkboxBaseView.heightAnchor.constraint(equalTo: self.checkboxBaseView.widthAnchor),

            self.checkboxImageView.widthAnchor.constraint(equalToConstant: 40),
            self.checkboxImageView.heightAnchor.constraint(equalTo: self.checkboxImageView.widthAnchor),
            self.checkboxImageView.centerXAnchor.constraint(equalTo: self.checkboxBaseView.centerXAnchor),
            self.checkboxImageView.centerYAnchor.constraint(equalTo: self.checkboxBaseView.centerYAnchor),
        ])

        // Stackview
        NSLayoutConstraint.activate([
            self.ticketsStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 15),
            self.ticketsStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -15),
            self.ticketsStackView.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: 15),
            self.ticketsStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])

        // Bottom part
        NSLayoutConstraint.activate([

            self.bottomStateView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor),
            self.bottomStateView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor),
            self.bottomStateView.topAnchor.constraint(equalTo: self.ticketsStackView.bottomAnchor, constant: 15),
            self.bottomStateView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),
            self.bottomStateView.heightAnchor.constraint(equalToConstant: 60),

            self.bottomTitlesStackView.leadingAnchor.constraint(equalTo: self.bottomStateView.leadingAnchor),
            self.bottomTitlesStackView.trailingAnchor.constraint(equalTo: self.bottomStateView.trailingAnchor),
            self.bottomTitlesStackView.topAnchor.constraint(equalTo: self.bottomStateView.topAnchor),
            self.bottomTitlesStackView.heightAnchor.constraint(equalToConstant: 29),

            self.separatorLineView.leadingAnchor.constraint(equalTo: self.bottomStateView.leadingAnchor, constant: 10),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.bottomStateView.trailingAnchor, constant: -10),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),
            self.separatorLineView.topAnchor.constraint(equalTo: self.bottomTitlesStackView.bottomAnchor, constant: 1),

            self.bottomValuesStackView.leadingAnchor.constraint(equalTo: self.bottomStateView.leadingAnchor),
            self.bottomValuesStackView.trailingAnchor.constraint(equalTo: self.bottomStateView.trailingAnchor),
            self.bottomValuesStackView.topAnchor.constraint(equalTo: self.separatorLineView.bottomAnchor, constant: 1),
            self.bottomValuesStackView.heightAnchor.constraint(equalToConstant: 29)

//            self.totalOddTitleLabel.heightAnchor.constraint(equalToConstant: 40),
//            self.totalOddTitleLabel.leadingAnchor.constraint(equalTo: self.separatorLineView.leadingAnchor),
//            self.totalOddTitleLabel.topAnchor.constraint(equalTo: self.separatorLineView.bottomAnchor),
//            self.totalOddTitleLabel.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),
//
//            self.totalOddValueLabel.leadingAnchor.constraint(equalTo: self.totalOddTitleLabel.trailingAnchor, constant: 5),
//            self.totalOddValueLabel.trailingAnchor.constraint(equalTo: self.checkboxBaseView.trailingAnchor, constant: -10),
//            self.totalOddValueLabel.centerYAnchor.constraint(equalTo: self.totalOddTitleLabel.centerYAnchor)
        ])
    }

}

enum BetState {
    case won
    case lost
    case draw
    case open
}
