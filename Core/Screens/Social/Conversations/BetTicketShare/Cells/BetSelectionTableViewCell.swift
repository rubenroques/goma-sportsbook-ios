//
//  BetSelectionTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 23/05/2022.
//

import UIKit
import Combine

class BetSelectionTableViewCell: UITableViewCell {

    // MARK: Private Properties
    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var checkboxBaseView: UIView = Self.createCheckboxBaseView()
    private lazy var checkboxImageView: UIImageView = Self.createCheckboxImageView()
    private lazy var ticketsStackView: UIStackView = Self.createTicketsStackView()
    private lazy var separatorLineView: UIView = Self.createSeparatorLineView()
    private lazy var totalOddTitleLabel: UILabel = Self.createTotalOddTitleLabel()
    private lazy var totalOddValueLabel: UILabel = Self.createTotalOddValueLabel()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var viewModel: BetSelectionCellViewModel?

    var didTapCheckboxAction: ((BetSelectionCellViewModel) -> Void)?
    var didTapUncheckboxAction: ((BetSelectionCellViewModel) -> Void)?

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

        self.baseView.layer.cornerRadius = CornerRadius.view

        self.ticketsStackView.layoutIfNeeded()
        self.ticketsStackView.layoutSubviews()
    }

    // MARK: Layout and Theme
    func setupWithTheme() {
        self.backgroundView?.backgroundColor = UIColor.App.backgroundPrimary
        self.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.baseView.backgroundColor = UIColor.App.backgroundSecondary
        self.checkboxBaseView.backgroundColor = .clear
        self.checkboxImageView.backgroundColor = .clear
        self.ticketsStackView.backgroundColor = .clear
        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

        self.totalOddTitleLabel.textColor = UIColor.App.textSecondary
        self.totalOddValueLabel.textColor = UIColor.App.textPrimary
    }

    // MARK: Functions
    func configure(withViewModel viewModel: BetSelectionCellViewModel) {
        self.viewModel = viewModel

        if viewModel.ticket.type?.uppercased() == "SINGLE" {
            self.titleLabel.text = localized("single")+" - \(viewModel.ticket.localizedBetStatus)"
        }
        else if viewModel.ticket.type?.uppercased() == "MULTIPLE" {
            self.titleLabel.text = localized("multiple")+" - \(viewModel.ticket.localizedBetStatus)"
        }
        else if viewModel.ticket.type?.uppercased() == "SYSTEM" {
            self.titleLabel.text = localized("system") + " - \(viewModel.ticket.systemBetType?.capitalized ?? "") - \(viewModel.ticket.localizedBetStatus)"
        }
        else {
            self.titleLabel.text = String([viewModel.ticket.type, viewModel.ticket.localizedBetStatus]
                .compactMap({ $0 })
                .map({ $0.capitalized })
                .joined(separator: " - "))
        }

        viewModel.isCheckboxSelectedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selected in
                self?.isCheckboxSelected = selected
            }
            .store(in: &cancellables)

        self.setupTicketStackView()

        self.totalOddValueLabel.text = viewModel.oddValueString
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

extension BetSelectionTableViewCell {

    private static func createBaseView() -> UIView {
        let baseView = UIView()
        baseView.translatesAutoresizingMaskIntoConstraints = false
        return baseView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("title")
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .left
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
        stackView.spacing = 20
        stackView.distribution = .equalSpacing
        return stackView
    }

    private static func createSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTotalOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Total Odd: "
        label.font = AppFont.with(type: .bold, size: 12)
        label.numberOfLines = 1
        return label
    }

    private static func createTotalOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "--"
        label.font = AppFont.with(type: .bold, size: 14)
        label.numberOfLines = 1
        return label
    }

    private func setupSubviews() {

        self.contentView.addSubview(self.baseView)

        self.baseView.addSubview(self.titleLabel)

        self.baseView.addSubview(self.checkboxBaseView)

        self.checkboxBaseView.addSubview(self.checkboxImageView)

        self.baseView.addSubview(self.ticketsStackView)
        self.baseView.addSubview(self.separatorLineView)
        self.baseView.addSubview(self.totalOddTitleLabel)
        self.baseView.addSubview(self.totalOddValueLabel)

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

            self.titleLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 15),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -50),
            self.titleLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 15),

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
            self.ticketsStackView.trailingAnchor.constraint(equalTo: self.checkboxBaseView.leadingAnchor),
            self.ticketsStackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 15),
            self.ticketsStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])

        // Bottom part
        NSLayoutConstraint.activate([
            self.separatorLineView.leadingAnchor.constraint(equalTo: self.ticketsStackView.leadingAnchor),
            self.separatorLineView.trailingAnchor.constraint(equalTo: self.checkboxBaseView.trailingAnchor, constant: -10),
            self.separatorLineView.heightAnchor.constraint(equalToConstant: 1),
            self.separatorLineView.topAnchor.constraint(equalTo: self.ticketsStackView.bottomAnchor, constant: 10),

            self.totalOddTitleLabel.heightAnchor.constraint(equalToConstant: 40),
            self.totalOddTitleLabel.leadingAnchor.constraint(equalTo: self.separatorLineView.leadingAnchor),
            self.totalOddTitleLabel.topAnchor.constraint(equalTo: self.separatorLineView.bottomAnchor),
            self.totalOddTitleLabel.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor),

            self.totalOddValueLabel.leadingAnchor.constraint(equalTo: self.totalOddTitleLabel.trailingAnchor, constant: 5),
            self.totalOddValueLabel.trailingAnchor.constraint(equalTo: self.checkboxBaseView.trailingAnchor, constant: -10),
            self.totalOddValueLabel.centerYAnchor.constraint(equalTo: self.totalOddTitleLabel.centerYAnchor)
        ])
    }

}
