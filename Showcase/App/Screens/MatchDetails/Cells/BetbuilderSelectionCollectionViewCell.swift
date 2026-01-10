//
//  BetbuilderSelectionTableViewCell.swift
//  Sportsbook
//
//  Created by André Lascas on 25/02/2025.
//

import UIKit
import Combine
import ServicesProvider

class BetbuilderSelectionCellViewModel {
    
    // MARK: Public properties
    var betSelections = [BettingTicket]()
        
    var totalOdd: CurrentValueSubject<Double, Never> = .init(0.0)
    
    var isBetbuilderSelectedSubject: CurrentValueSubject<Bool, Never> = .init(false)
    var fetchedBetbuilderValuePublisher: CurrentValueSubject<BetbuilderFetchedState, Never> = .init(.notFetched)
    
    var hasMatchHeader: Bool = false
        
    // MARK: Private properties
    private var oddUpdatesPublisher: [String: AnyCancellable] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    init(betSelections: [BettingTicket], hasMatchHeader: Bool) {
        self.betSelections = betSelections
        
        self.hasMatchHeader = hasMatchHeader
        
        self.subscribeOutcomes()
        
        self.setupPublishers()
    }
    
    func requestBetBuilderTotalOdd() {
        
        let betbuilderTransformer = BetBuilderTransformer()
        
        betbuilderTransformer.requestBetBuilderPotentialReturnForTickets(self.betSelections, withStake: 0.0)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("BetBuilder Total Odd finished")
                case .failure(let error):
                    print("BetBuilder Total Odd failure \(error)")
                    self?.fetchedBetbuilderValuePublisher.send(.fetched(fetchType: .error))

                }
            }, receiveValue: { [weak self] betBuilderCalculateResponse in
                
                self?.totalOdd.send(betBuilderCalculateResponse.totalOdd)
                
                self?.fetchedBetbuilderValuePublisher.send(.fetched(fetchType: .success))
            })
            .store(in: &cancellables)
                
    }
    
    func subscribeOutcomes() {
        for betSelection in self.betSelections {
            self.oddUpdatesPublisher[betSelection.outcomeId] = Env.servicesProvider
                .subscribeToEventOnListsOutcomeUpdates(withId: betSelection.outcomeId)
                .compactMap({ $0 })
                .map(ServiceProviderModelMapper.outcome(fromServiceProviderOutcome:))
//                .map(\.bettingOffer)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure:
                        break
                    }
                }, receiveValue: { [weak self] (updatedOutcome: Outcome) in
                    
                    let updatedBettingOffer = updatedOutcome.bettingOffer
                    
                    self?.updateSelection(outcomeId: betSelection.outcomeId, odd: updatedBettingOffer.decimalOdd)
                    
                })
            
        }
    }
    
    func setupPublishers() {
        
        Env.betslipManager.bettingTicketsPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] bettingTickets in
                
                guard let self = self else { return }
                
                let allSelectionsPresent = self.betSelections.allSatisfy { betSelection in
                    bettingTickets.contains { bettingTicket in
                        betSelection.id == bettingTicket.id
                    }
                }
                
                let isBetbuilderSelected = allSelectionsPresent
                
                self.isBetbuilderSelectedSubject.send(isBetbuilderSelected)
                
            })
            .store(in: &cancellables)
        
    }
    
    func updateSelection(outcomeId: String, odd: Double) {
        
        var betSelections = self.betSelections
        if let index = betSelections.firstIndex(where: { $0.outcomeId == outcomeId }) {
            var newBettingTicket = betSelections[index]
            newBettingTicket.odd = .decimal(odd: odd)
            betSelections[index] = newBettingTicket
        }
        self.betSelections = betSelections
        
        self.requestBetBuilderTotalOdd()
        
    }
}

class BetbuilderSelectionCollectionViewCell: UICollectionViewCell {

    // MARK: Private properties
    private lazy var gradientContainerView: GradientView = Self.createGradientContainerView()
    private lazy var containerView: UIView = Self.createContainerView()
    
    private lazy var headerInfoView: UIView = Self.createHeaderInfoView()
    private lazy var matchNameLabel: UILabel = Self.createMatchNameLabel()
    private lazy var dateLabel: UILabel = Self.createDateLabel()
    private lazy var timeLabel: UILabel = Self.createTimeLabel()
    
    private lazy var firstSelectionTitleLabel: UILabel = Self.createFirstSelectionTitleLabel()
    private lazy var firstSelectionSubtitleLabel: UILabel = Self.createFirstSelectionSubtitleLabel()
    
    private lazy var secondSelectionTitleLabel: UILabel = Self.createSecondSelectionTitleLabel()
    private lazy var secondSelectionSubtitleLabel: UILabel = Self.createSecondSelectionSubtitleLabel()
    
    private lazy var thirdSelectionTitleLabel: UILabel = Self.createThirdSelectionTitleLabel()
    private lazy var thirdSelectionSubtitleLabel: UILabel = Self.createThirdSelectionSubtitleLabel()
    
    private lazy var firstSeparatorLineView: UIView = Self.createFirstSeparatorLineView()
    private lazy var secondSeparatorLineView: UIView = Self.createSecondSeparatorLineView()

    private lazy var firstStepView: UIView = Self.createFirstStepView()
    private lazy var secondStepView: UIView = Self.createSecondStepView()
    private lazy var thirdStepView: UIView = Self.createThirdStepView()

    private lazy var firstStepLinkView: UIView = Self.createFirstStepLinkView()
    private lazy var secondStepLinkView: UIView = Self.createSecondStepLinkView()

    private lazy var actionButton: UIButton = Self.createActionButton()
    
    // Constraints
    private lazy var firstSelectionTitleTopToContainerConstraint: NSLayoutConstraint = Self.createFirstSelectionTitleTopToContainerConstraint()
    private lazy var firstSelectionTitleTopToHeaderConstraint: NSLayoutConstraint = Self.createFirstSelectionTitleTopToHeaderConstraint()

    private var stepViewSize: CGFloat = 10.0
    
    private var viewModel: BetbuilderSelectionCellViewModel?
    
    private var cancellables = Set<AnyCancellable>()
    
    private var isBetbuilderSelected: Bool = false {
        didSet {
            
            if isBetbuilderSelected {
                self.actionButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary.resolvedColor(with: self.traitCollection), for: .normal)
                self.actionButton.setTitleColor(UIColor.App.buttonTextPrimary.resolvedColor(with: self.traitCollection), for: .normal)
            }
            else {
                self.actionButton.setBackgroundColor(UIColor.App.backgroundOdds.resolvedColor(with: self.traitCollection), for: .normal)
                self.actionButton.setTitleColor(UIColor.App.textPrimary.resolvedColor(with: self.traitCollection), for: .normal)
            }
        }
    }
    
    var shouldOpenBetslip: (() -> Void)?
            
    // MARK: Lifetime and cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.setupWithTheme()
        
        self.actionButton.addTarget(self, action: #selector(self.didTapActionButton), for: .primaryActionTriggered)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.viewModel = nil
        
        self.isBetbuilderSelected = false
        
        self.cancellables.removeAll()

    }
    
    // MARK: Layout and theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.gradientContainerView.layer.cornerRadius = CornerRadius.button
        
        self.containerView.layer.cornerRadius = CornerRadius.button
        
        self.firstStepView.layer.cornerRadius = self.stepViewSize / 2
        
        self.secondStepView.layer.cornerRadius = self.stepViewSize / 2

        self.thirdStepView.layer.cornerRadius = self.stepViewSize / 2
        
    }
    
    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.gradientContainerView.colors = [(UIColor.App.highlightPrimary, NSNumber(0.0)),
                                             (UIColor.App.backgroundOdds, NSNumber(1.0))]
        
        self.containerView.backgroundColor = UIColor.App.backgroundCards
        
        self.headerInfoView.backgroundColor = .clear
        
        self.matchNameLabel.textColor = UIColor.App.textPrimary
        
        self.dateLabel.textColor = UIColor.App.textSecondary
        
        self.timeLabel.textColor = UIColor.App.textPrimary
        
        self.firstSelectionTitleLabel.textColor = UIColor.App.textPrimary
        
        self.firstSelectionSubtitleLabel.textColor = UIColor.App.textSecondary
        
        self.secondSelectionTitleLabel.textColor = UIColor.App.textPrimary
        
        self.secondSelectionSubtitleLabel.textColor = UIColor.App.textSecondary
        
        self.thirdSelectionTitleLabel.textColor = UIColor.App.textPrimary
        
        self.thirdSelectionSubtitleLabel.textColor = UIColor.App.textSecondary
        
        self.firstSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        
        self.secondSeparatorLineView.backgroundColor = UIColor.App.separatorLine
        
        self.firstStepView.backgroundColor = UIColor.App.highlightPrimary
        self.secondStepView.backgroundColor = UIColor.App.highlightPrimary
        self.thirdStepView.backgroundColor = UIColor.App.highlightPrimary

        self.firstStepLinkView.backgroundColor = UIColor.App.highlightPrimary
        self.secondStepLinkView.backgroundColor = UIColor.App.highlightPrimary
        
        StyleHelper.styleButtonWithTheme(
            button: self.actionButton,
            titleColor: UIColor.App.textPrimary.resolvedColor(with: self.traitCollection),
            titleDisabledColor: UIColor.App.buttonTextDisableSecondary.resolvedColor(with: self.traitCollection),
            backgroundColor: UIColor.App.backgroundOdds.resolvedColor(with: self.traitCollection),
            backgroundDisabledColor: UIColor.App.backgroundDisabledOdds.resolvedColor(with: self.traitCollection),
            backgroundHighlightedColor: UIColor.App.backgroundOdds.resolvedColor(with: self.traitCollection)
        )
        
//        self.actionButton.setBackgroundColor(UIColor.App.backgroundOdds, for: .normal)
//        self.actionButton.setTitleColor(UIColor.App.textPrimary, for: .normal)
        
    }
    
    // MARK: Functions
    func configure(viewModel: BetbuilderSelectionCellViewModel) {
        
        self.viewModel = viewModel
        
        // Show/hide header and update constraints based on hasMatchHeader
        self.headerInfoView.isHidden = !viewModel.hasMatchHeader

        if viewModel.hasMatchHeader {
            self.firstSelectionTitleTopToContainerConstraint.isActive = false
            self.firstSelectionTitleTopToHeaderConstraint.isActive = true
        } else {
            self.firstSelectionTitleTopToHeaderConstraint.isActive = false
            self.firstSelectionTitleTopToContainerConstraint.isActive = true
        }
        
        if let firstSelection = viewModel.betSelections[safe: 0] {
            
            self.firstSelectionTitleLabel.text = firstSelection.outcomeDescription
            
            self.firstSelectionSubtitleLabel.text = firstSelection.marketDescription
        }
        
        if let secondSelection = viewModel.betSelections[safe: 1] {
            
            self.secondSelectionTitleLabel.text = secondSelection.outcomeDescription
            
            self.secondSelectionSubtitleLabel.text = secondSelection.marketDescription
        }
        
        if let thirdSelection = viewModel.betSelections[safe: 2] {
            
            self.thirdSelectionTitleLabel.text = thirdSelection.outcomeDescription
            
            self.thirdSelectionSubtitleLabel.text = thirdSelection.marketDescription
        }
        
        viewModel.totalOdd
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] totalOdd in
                
                if totalOdd > 0.0 {
                    self?.actionButton.setTitle("\(totalOdd)", for: .normal)
                    self?.actionButton.isEnabled = true
                }
                else {
                    self?.actionButton.setTitle("-.-", for: .normal)
                    self?.actionButton.isEnabled = false
                }
            })
            .store(in: &cancellables)
        
        viewModel.isBetbuilderSelectedSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isBetbuilderSelected in
                self?.isBetbuilderSelected = isBetbuilderSelected
            })
            .store(in: &cancellables)

    }
    
    // MARK: Action
    @objc private func didTapActionButton() {
        
        if let bettingTickets = self.viewModel?.betSelections {
            
            if self.isBetbuilderSelected {
                for bettingTicket in bettingTickets {
                    if Env.betslipManager.hasBettingTicket(bettingTicket) {
                        Env.betslipManager.removeBettingTicket(bettingTicket)
                    }
                }
                
            }
            else {
                for bettingTicket in bettingTickets {
                    if !Env.betslipManager.hasBettingTicket(bettingTicket) {
                        Env.betslipManager.addBettingTicket(bettingTicket)
                    }
                    
                }
                
                self.shouldOpenBetslip?()

            }
            
        }
        
    }
}

extension BetbuilderSelectionCollectionViewCell {
    
    private static func createGradientContainerView() -> GradientView {
        let gradientView = GradientView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientView.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradientView.clipsToBounds = true
        return gradientView
    }
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    private static func createHeaderInfoView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createMatchNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Match Name"
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }
    
    private static func createDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "01.01.2025"
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .right
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }
    
    private static func createTimeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .right
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }
    
    private static func createFirstSelectionTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = AppFont.with(type: .bold, size: 12)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }
    
    private static func createFirstSelectionSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Subtitle"
        label.font = AppFont.with(type: .semibold, size: 10)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }
    
    private static func createSecondSelectionTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = AppFont.with(type: .bold, size: 12)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }
    
    private static func createSecondSelectionSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Subtitle"
        label.font = AppFont.with(type: .semibold, size: 10)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }
    
    private static func createThirdSelectionTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = AppFont.with(type: .bold, size: 12)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }
    
    private static func createThirdSelectionSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Subtitle"
        label.font = AppFont.with(type: .semibold, size: 10)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }
    
    private static func createFirstSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createSecondSeparatorLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createFirstStepView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createSecondStepView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createThirdStepView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createFirstStepLinkView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createSecondStepLinkView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createActionButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("-.-", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 14)
        return button
    }
    
    // Constraints
    private static func createFirstSelectionTitleTopToContainerConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createFirstSelectionTitleTopToHeaderConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }
    
    private func setupSubviews() {
        
        self.contentView.addSubview(self.gradientContainerView)
        
        self.gradientContainerView.addSubview(self.containerView)
        
        self.containerView.addSubview(self.headerInfoView)
        
        self.headerInfoView.addSubview(self.matchNameLabel)
        self.headerInfoView.addSubview(self.dateLabel)
        self.headerInfoView.addSubview(self.timeLabel)
        
        self.containerView.addSubview(self.firstSelectionTitleLabel)
        self.containerView.addSubview(self.firstSelectionSubtitleLabel)
        
        self.containerView.addSubview(self.firstSeparatorLineView)
        
        self.containerView.addSubview(self.secondSelectionTitleLabel)
        self.containerView.addSubview(self.secondSelectionSubtitleLabel)
        
        self.containerView.addSubview(self.secondSeparatorLineView)
        
        self.containerView.addSubview(self.thirdSelectionTitleLabel)
        self.containerView.addSubview(self.thirdSelectionSubtitleLabel)
        
        self.containerView.addSubview(self.firstStepView)
        self.containerView.addSubview(self.firstStepLinkView)
        self.containerView.addSubview(self.secondStepView)
        self.containerView.addSubview(self.secondStepLinkView)
        self.containerView.addSubview(self.thirdStepView)
        
        self.containerView.addSubview(self.actionButton)
        
        self.initConstraints()
    }
    
    private func initConstraints() {
        
        NSLayoutConstraint.activate( [
            self.gradientContainerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.gradientContainerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.gradientContainerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.gradientContainerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            
            self.containerView.leadingAnchor.constraint(equalTo: self.gradientContainerView.leadingAnchor, constant: 1),
            self.containerView.trailingAnchor.constraint(equalTo: self.gradientContainerView.trailingAnchor, constant: -1),
            self.containerView.topAnchor.constraint(equalTo: self.gradientContainerView.topAnchor, constant: 1),
            self.containerView.bottomAnchor.constraint(equalTo: self.gradientContainerView.bottomAnchor, constant: -1),
            
            self.headerInfoView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.headerInfoView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.headerInfoView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            
            self.matchNameLabel.leadingAnchor.constraint(equalTo: self.headerInfoView.leadingAnchor, constant: 12),
            self.matchNameLabel.topAnchor.constraint(equalTo: self.headerInfoView.topAnchor, constant: 8),
            
            self.dateLabel.trailingAnchor.constraint(equalTo: self.headerInfoView.trailingAnchor, constant: -12),
            self.dateLabel.topAnchor.constraint(equalTo: self.headerInfoView.topAnchor, constant: 8),
            self.dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.matchNameLabel.trailingAnchor, constant: 4),
            
            self.timeLabel.trailingAnchor.constraint(equalTo: self.headerInfoView.trailingAnchor, constant: -12),
            self.timeLabel.topAnchor.constraint(equalTo: self.dateLabel.bottomAnchor, constant: 2),
            self.timeLabel.bottomAnchor.constraint(equalTo: self.headerInfoView.bottomAnchor, constant: -4),
            
//            self.firstSelectionTitleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 8),
            self.firstSelectionTitleLabel.leadingAnchor.constraint(equalTo: self.firstStepView.trailingAnchor, constant: 10),
            self.firstSelectionTitleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            
            self.firstSelectionSubtitleLabel.leadingAnchor.constraint(equalTo: self.firstSelectionTitleLabel.leadingAnchor),
            self.firstSelectionSubtitleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.firstSelectionSubtitleLabel.topAnchor.constraint(equalTo: self.firstSelectionTitleLabel.bottomAnchor, constant: 6),
            
            self.firstSeparatorLineView.leadingAnchor.constraint(equalTo: self.firstSelectionTitleLabel.leadingAnchor),
            self.firstSeparatorLineView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.firstSeparatorLineView.topAnchor.constraint(equalTo: self.firstSelectionSubtitleLabel.bottomAnchor, constant: 4),
            self.firstSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),
            
            self.secondSelectionTitleLabel.topAnchor.constraint(equalTo: self.firstSeparatorLineView.bottomAnchor, constant: 8),
            self.secondSelectionTitleLabel.leadingAnchor.constraint(equalTo: self.secondStepView.trailingAnchor, constant: 10),
            self.secondSelectionTitleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            
            self.secondSelectionSubtitleLabel.leadingAnchor.constraint(equalTo: self.secondSelectionTitleLabel.leadingAnchor),
            self.secondSelectionSubtitleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.secondSelectionSubtitleLabel.topAnchor.constraint(equalTo: self.secondSelectionTitleLabel.bottomAnchor, constant: 6),
            
            self.secondSeparatorLineView.leadingAnchor.constraint(equalTo: self.secondSelectionTitleLabel.leadingAnchor),
            self.secondSeparatorLineView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.secondSeparatorLineView.topAnchor.constraint(equalTo: self.secondSelectionSubtitleLabel.bottomAnchor, constant: 4),
            self.secondSeparatorLineView.heightAnchor.constraint(equalToConstant: 1),
            
            self.thirdSelectionTitleLabel.topAnchor.constraint(equalTo: self.secondSeparatorLineView.bottomAnchor, constant: 8),
            self.thirdSelectionTitleLabel.leadingAnchor.constraint(equalTo: self.thirdStepView.trailingAnchor, constant: 10),
            self.thirdSelectionTitleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            
            self.thirdSelectionSubtitleLabel.leadingAnchor.constraint(equalTo: self.thirdSelectionTitleLabel.leadingAnchor),
            self.thirdSelectionSubtitleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -8),
            self.thirdSelectionSubtitleLabel.topAnchor.constraint(equalTo: self.thirdSelectionTitleLabel.bottomAnchor, constant: 6),
            
            self.actionButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.actionButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -12),
            self.actionButton.topAnchor.constraint(equalTo: self.thirdSelectionSubtitleLabel.bottomAnchor, constant: 8),
            self.actionButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -8),
            self.actionButton.heightAnchor.constraint(equalToConstant: 35),
            
            self.firstStepView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.firstStepView.widthAnchor.constraint(equalToConstant: self.stepViewSize),
            self.firstStepView.heightAnchor.constraint(equalTo: self.firstStepView.widthAnchor),
            self.firstStepView.centerYAnchor.constraint(equalTo: self.firstSelectionTitleLabel.centerYAnchor),
            
            self.secondStepView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.secondStepView.widthAnchor.constraint(equalToConstant: self.stepViewSize),
            self.secondStepView.heightAnchor.constraint(equalTo: self.secondStepView.widthAnchor),
            self.secondStepView.centerYAnchor.constraint(equalTo: self.secondSelectionTitleLabel.centerYAnchor),
            
            self.thirdStepView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 12),
            self.thirdStepView.widthAnchor.constraint(equalToConstant: self.stepViewSize),
            self.thirdStepView.heightAnchor.constraint(equalTo: self.thirdStepView.widthAnchor),
            self.thirdStepView.centerYAnchor.constraint(equalTo: self.thirdSelectionTitleLabel.centerYAnchor),
            
            self.firstStepLinkView.widthAnchor.constraint(equalToConstant: 2),
            self.firstStepLinkView.topAnchor.constraint(equalTo: self.firstStepView.bottomAnchor),
            self.firstStepLinkView.bottomAnchor.constraint(equalTo: self.secondStepView.topAnchor),
            self.firstStepLinkView.centerXAnchor.constraint(equalTo: self.firstStepView.centerXAnchor),
            
            self.secondStepLinkView.widthAnchor.constraint(equalToConstant: 2),
            self.secondStepLinkView.topAnchor.constraint(equalTo: self.secondStepView.bottomAnchor),
            self.secondStepLinkView.bottomAnchor.constraint(equalTo: self.thirdStepView.topAnchor),
            self.secondStepLinkView.centerXAnchor.constraint(equalTo: self.secondStepView.centerXAnchor)
        ])
        
        // Setup conditional constraints for firstSelectionTitleLabel
        self.firstSelectionTitleTopToContainerConstraint = NSLayoutConstraint(item: self.firstSelectionTitleLabel,
                                                                                attribute: .top,
                                                                                relatedBy: .equal,
                                                                                toItem: self.containerView,
                                                                                attribute: .top,
                                                                                multiplier: 1,
                                                                                constant: 8)
        self.firstSelectionTitleTopToContainerConstraint.isActive = true

        self.firstSelectionTitleTopToHeaderConstraint = NSLayoutConstraint(item: self.firstSelectionTitleLabel,
                                                                             attribute: .top,
                                                                             relatedBy: .equal,
                                                                             toItem: self.headerInfoView,
                                                                             attribute: .bottom,
                                                                             multiplier: 1,
                                                                             constant: 0)
        self.firstSelectionTitleTopToHeaderConstraint.isActive = false
        
    }
}

enum BetbuilderFetchedState {
    case notFetched
    case fetched(fetchType: AlertType)
}
