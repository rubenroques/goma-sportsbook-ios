//
//  PreSubmissionBetslipViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/11/2021.
//

import UIKit
import Combine

class PreSubmissionBetslipViewController: UIViewController {

    @IBOutlet private weak var topSafeArea: UIView!
    @IBOutlet private weak var bottomSafeArea: UIView!

    @IBOutlet private weak var betTypeSegmentControlBaseView: UIView!
    @IBOutlet private weak var betTypeSegmentControl: UISegmentedControl!

    @IBOutlet private weak var clearBaseView: UIView!
    @IBOutlet private weak var clearButton: UIButton!

    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var winningsTitleLabel: UILabel!
    @IBOutlet private weak var winningsValueMultipleLabel: UILabel!
    @IBOutlet private weak var winningsValueSingleLabel: UILabel!

    @IBOutlet private weak var oddsTitleLabel: UILabel!
    @IBOutlet private weak var oddsValueLabel: UILabel!

    @IBOutlet private weak var placeBetBaseView: UIView!

    @IBOutlet private weak var placeBetValuesBaseView: UIView!
    @IBOutlet private weak var placeBetValuesSeparatorView: UIView!

    @IBOutlet private weak var placeBetButtonsBaseView: UIView!
    @IBOutlet private weak var placeBetButtonsSeparatorView: UIView!
    @IBOutlet private weak var amountBaseView: UIView!
    @IBOutlet private weak var amountTextfield: UITextField!
    @IBOutlet private weak var plusOneButtonView: UIButton!
    @IBOutlet private weak var plusFiveButtonView: UIButton!
    @IBOutlet private weak var maxValueButtonView: UIButton!

    @IBOutlet private weak var placeBetSendButtonBaseView: UIView!
    @IBOutlet private weak var placeBetButton: UIButton!

    @IBOutlet private weak var placeBetBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var emptyBetsBaseView: UIView!


    @IBOutlet weak var loadingBaseView: UIView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!

    private var singleBettingTicketDataSource = SingleBettingTicketDataSource.init(bettingTickets: [])
    private var multipleBettingTicketDataSource = MultipleBettingTicketDataSource.init(bettingTickets: [])
    private var systemBettingTicketDataSource = SystemBettingTicketDataSource()

    var cancellables = Set<AnyCancellable>()

    enum BetslipType {
        case simple
        case multiple
        case system
    }

    private var listTypePublisher: CurrentValueSubject<BetslipType, Never> = .init(.simple)

    // Multiple Bets values
    private var displayBetValue: Int = 0 {
        didSet {
            self.realBetValuePublisher.send(self.realBetValue)
        }
    }
    private var realBetValue: Double {
        if displayBetValue == 0 {
            return 0
        }
        else {
            return Double(displayBetValue)/Double(100)
        }
    }

    // Simple Bets values
    private var simpleBetsBettingValues: CurrentValueSubject<[String: Double], Never> = .init([:])
    private var simpleBetPlacedDetails: [String: LoadableContent<BetPlacedDetails>] = [:]

    private var maxBetValue: Double = Double.greatestFiniteMagnitude

    private var realBetValuePublisher: CurrentValueSubject<Double, Never> = .init(0.0)
    private var multiplierPublisher: CurrentValueSubject<Double, Never> = .init(0.0)

    private var isLoading = false {
        didSet {
            if isLoading {
                self.loadingBaseView.alpha = 1.0
            }
            else {
                self.loadingBaseView.alpha = 0.0
            }
        }
    }

    var betPlacedAction: (([BetPlacedDetails]) -> ())?

    init() {
        super.init(nibName: "PreSubmissionBetslipViewController", bundle: nil)

        self.title = "Betslip"
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadingBaseView.alpha = 0.0

        self.view.bringSubviewToFront(emptyBetsBaseView)
        self.view.bringSubviewToFront(loadingBaseView)

        self.placeBetButtonsBaseView.isHidden = true
        self.placeBetButtonsSeparatorView.alpha = 0.5

        self.winningsValueSingleLabel.text = "-.--€"
        self.winningsValueMultipleLabel.text = "-.--€"
        self.oddsValueLabel.text = "-.--"

        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false

        self.tableView.register(SingleBettingTicketTableViewCell.nib, forCellReuseIdentifier: SingleBettingTicketTableViewCell.identifier)
        self.tableView.register(MultipleBettingTicketTableViewCell.nib, forCellReuseIdentifier: MultipleBettingTicketTableViewCell.identifier)

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.amountTextfield.delegate = self


        if Env.betslipManager.bettingTicketsPublisher.value.count > 1 {
            self.betTypeSegmentControl.selectedSegmentIndex = 1
            self.didChangeSegmentValue(self.betTypeSegmentControl)
        }


        singleBettingTicketDataSource.didUpdateBettingValueAction = { id, value in
            if value == 0 {
                self.simpleBetsBettingValues.value[id] = nil
            }
            else {
                self.simpleBetsBettingValues.value[id] = value
            }
        }
        singleBettingTicketDataSource.bettingValueForId = { id in
            self.simpleBetsBettingValues.value[id]
        }


        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .map(Array.init)
            .sink { tickets in
                self.singleBettingTicketDataSource.bettingTickets = tickets
                self.multipleBettingTicketDataSource.bettingTickets = tickets

                self.simpleBetPlacedDetails = [:]
                //self.simpleBetsBettingValues.send([:])

                self.tableView.reloadData()
            }
            .store(in: &cancellables)

        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .map({ orderedSet -> Double in
                let newArray = orderedSet.map { $0.value }
                let multiple: Double = newArray.reduce(1.0, *)
                return multiple
            })
            .sink(receiveValue: { multiplier in
                self.multiplierPublisher.send(multiplier)
            })
            .store(in: &cancellables)

        self.multiplierPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] multiplier in
                self?.oddsValueLabel.text = "\(Double(floor(multiplier * 100)/100))"
            })
            .store(in: &cancellables)

        Env.betslipManager.bettingTicketsPublisher
            .receive(on: DispatchQueue.main)
            .map(\.isEmpty)
            .sink(receiveValue: { isEmpty in
                self.emptyBetsBaseView.isHidden = !isEmpty
            })
            .store(in: &cancellables)

        self.listTypePublisher
            .receive(on: DispatchQueue.main)
            .map({ $0 == .simple })
            .sink(receiveValue: { [weak self] isSimpleBet in
                self?.placeBetButtonsBaseView.isHidden = isSimpleBet
            })
            .store(in: &cancellables)

        self.listTypePublisher
            .receive(on: DispatchQueue.main)
            .map({ $0 == .simple })
            .sink(receiveValue: { [weak self] isSimpleBet in
                self?.oddsTitleLabel.isHidden = isSimpleBet
                self?.oddsValueLabel.isHidden = isSimpleBet

                self?.winningsValueSingleLabel.isHidden = !isSimpleBet
                self?.winningsValueMultipleLabel.isHidden = isSimpleBet
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(self.listTypePublisher, self.realBetValuePublisher)
            .receive(on: DispatchQueue.main)
            .filter { (betslipType, _) in
                betslipType == .multiple
            }
            .map({ [weak self] (_, bettingValue) in
                return bettingValue > 0 && bettingValue < (self?.maxBetValue ?? 0)
            })
            .sink(receiveValue: { [weak self] hasValidBettingValue in
                self?.placeBetButton.isEnabled = hasValidBettingValue
            })
            .store(in: &cancellables)


        Publishers.CombineLatest(self.multiplierPublisher, self.realBetValuePublisher)
            .receive(on: DispatchQueue.main)
            .map({ (multiplier, betValue) -> String in
                if multiplier >= 1 && betValue > 0 {
                    let totalValue = multiplier * betValue
                    return CurrencyFormater.defaultFormat.string(from: NSNumber(value: totalValue)) ?? "-.--€"
                }
                else {
                    return "-.--€"
                }
            })
            .sink(receiveValue: { [weak self] possibleEarnings in
                self?.winningsValueMultipleLabel.text = possibleEarnings
            })
            .store(in: &cancellables)


        Publishers.CombineLatest3(self.listTypePublisher, self.simpleBetsBettingValues, Env.betslipManager.bettingTicketsPublisher)
            .receive(on: DispatchQueue.main)
            .filter { (betslipType, _, _) in
                betslipType == .simple
            }
            .map({ (_, simpleBetsBettingValues, tickets) -> String in
                var expectedReturn = 0.0
                for ticket in tickets {
                    if let betValue = simpleBetsBettingValues[ticket.id] {
                        let expectedTicketReturn = ticket.value * betValue
                        expectedReturn = expectedReturn + expectedTicketReturn
                    }
                }
                if expectedReturn == 0 {
                    return "-.--€"
                }
                else {
                    return CurrencyFormater.defaultFormat.string(from: NSNumber(value: expectedReturn)) ?? "-.--€"
                }
            })
            .sink(receiveValue: { [weak self] possibleEarningsString in
                self?.winningsValueSingleLabel.text = possibleEarningsString
            })
            .store(in: &cancellables)


        Publishers.CombineLatest3(self.listTypePublisher, self.simpleBetsBettingValues, Env.betslipManager.bettingTicketsPublisher)
            .receive(on: DispatchQueue.main)
            .filter { (betslipType, _, _) in
                betslipType == .simple
            }
            .map({ (_, simpleBetsBettingValues, tickets) -> Bool in
                var hasValidAmounts = true
                for ticket in tickets {
                    if simpleBetsBettingValues[ticket.id] == nil {
                        hasValidAmounts = false
                        break
                    }
                }
                return hasValidAmounts
            })
            .sink(receiveValue: { [weak self] hasValidBettingValue in
                self?.placeBetButton.isEnabled = hasValidBettingValue
            })
            .store(in: &cancellables)

        self.addDoneAccessoryView()
        self.setupWithTheme()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.placeBetButton.isEnabled = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.plusOneButtonView.layer.cornerRadius = CornerRadius.view
        self.plusOneButtonView.clipsToBounds = true
        self.plusFiveButtonView.layer.cornerRadius = CornerRadius.view
        self.plusFiveButtonView.clipsToBounds = true
        self.maxValueButtonView.layer.cornerRadius = CornerRadius.view
        self.maxValueButtonView.clipsToBounds = true

        self.amountBaseView.layer.cornerRadius = CornerRadius.view
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func setupWithTheme() {

        self.betTypeSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ], for: .selected)
        self.betTypeSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.with(type: .bold, size: 13),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ], for: .normal)

        self.topSafeArea.backgroundColor = UIColor.App.mainBackground
        self.bottomSafeArea.backgroundColor = UIColor.App.mainBackground
        self.betTypeSegmentControlBaseView.backgroundColor = UIColor.App.mainBackground


        self.amountTextfield.font = AppFont.with(type: .semibold, size: 14)
        self.amountTextfield.textColor = UIColor.App.headingMain
        self.amountTextfield.attributedPlaceholder = NSAttributedString(string: "Amount", attributes: [
            NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 14),
            NSAttributedString.Key.foregroundColor: UIColor.App.headingDisabled
        ])
        self.amountBaseView.backgroundColor = UIColor.App.tertiaryBackground

        self.tableView.backgroundView?.backgroundColor = UIColor.App.mainBackground
        self.tableView.backgroundColor = UIColor.App.mainBackground
        self.tableView.contentInset.bottom = 12


        self.placeBetBaseView.backgroundColor = UIColor.App.mainBackground
        self.placeBetValuesBaseView.backgroundColor = UIColor.App.mainBackground
        self.placeBetValuesSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.placeBetButtonsBaseView.backgroundColor = UIColor.App.mainBackground
        self.placeBetButtonsSeparatorView.backgroundColor = UIColor.App.separatorLine
        self.placeBetSendButtonBaseView.backgroundColor = UIColor.App.mainBackground

        self.amountBaseView.backgroundColor = UIColor.App.tertiaryBackground

        self.plusOneButtonView.setBackgroundColor(UIColor.App.tertiaryBackground, for: .normal)
        self.plusOneButtonView.setTitleColor(UIColor.App.headingMain, for: .normal)
        self.plusOneButtonView.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)

        self.plusFiveButtonView.setBackgroundColor(UIColor.App.tertiaryBackground, for: .normal)
        self.plusFiveButtonView.setTitleColor(UIColor.App.headingMain, for: .normal)
        self.plusFiveButtonView.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)

        self.maxValueButtonView.setBackgroundColor(UIColor.App.tertiaryBackground, for: .normal)
        self.maxValueButtonView.setTitleColor(UIColor.App.headingMain, for: .normal)
        self.maxValueButtonView.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)

        self.emptyBetsBaseView.backgroundColor = UIColor.App.mainBackground

        self.winningsValueSingleLabel.textColor = UIColor.App.headingMain
        self.winningsValueMultipleLabel.textColor = UIColor.App.headingMain

        StyleHelper.styleButton(button: self.placeBetButton)
    }

    func addDoneAccessoryView() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        self.amountTextfield.inputAccessoryView = keyboardToolbar
    }

    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }

    @IBAction func didTapClearButton() {
        Env.betslipManager.clearAllBettingTickets()
    }

    @IBAction func didChangeSegmentValue(_ segmentControl: UISegmentedControl) {

        switch segmentControl.selectedSegmentIndex {
        case 0:
            self.listTypePublisher.value = .simple
        case 1:
            self.listTypePublisher.value = .multiple
        case 2:
            self.listTypePublisher.value = .system
        default:
            ()
        }

        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        self.tableView.setContentOffset(.zero, animated: true)
    }

    @IBAction func didTapPlaceBetButton() {

        self.isLoading = true

        if self.listTypePublisher.value == .simple {
            let requests = Env.betslipManager.placeSingleBets(withSkateAmount: self.simpleBetsBettingValues.value)
            for request in requests {
                request
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        print(completion)
                    } receiveValue: { [weak self] betPlacedDetails in

                        if let betId = betPlacedDetails.response.betId {
                            self?.simpleBetPlacedDetails[betId] = .loaded(betPlacedDetails)
                        }
                        self?.checkSubmitedSingles()

                    }
                    .store(in: &cancellables)
            }
        }
        else if self.listTypePublisher.value == .multiple {
            Env.betslipManager.placeMultipleBet(withSkateAmount: self.realBetValue)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    print(completion)
                    self.isLoading = false
                } receiveValue: { betPlacedDetails in
                    self.isLoading = false
                    self.betPlacedAction?([betPlacedDetails])
                }
                .store(in: &cancellables)
        }

    }

    func checkSubmitedSingles() {

        var betPlacedDetailsArray: [BetPlacedDetails] = []
        var canProceedToNextScreen = true
        var stillLoading = false

        if self.simpleBetsBettingValues.value.count != self.simpleBetPlacedDetails.values.count {
            //Still loading requests
            return
        }

        for value in self.simpleBetPlacedDetails.values {
            switch value {
            case .loaded(let betPlacedDetails):
                if !(betPlacedDetails.response.betSucceed ?? false) {
                    canProceedToNextScreen = false
                    break
                }
                else {
                    betPlacedDetailsArray.append(betPlacedDetails)
                }
            case .loading:
                stillLoading = true
                break
            case .idle:
                stillLoading = true
                break
            }
        }

        if canProceedToNextScreen && !stillLoading {
            self.isLoading = false
            self.betPlacedAction?(betPlacedDetailsArray)
        }
    }


    func currentDataSource() -> UITableViewDelegateDataSource {
        switch self.listTypePublisher.value {
        case .simple:
            return self.singleBettingTicketDataSource
        case .multiple:
            return self.multipleBettingTicketDataSource
        case .system:
            return self.systemBettingTicketDataSource
        }
    }


    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.tableView.contentInset.bottom = (keyboardSize.height - placeBetBaseView.frame.size.height)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.tableView.contentInset.bottom = 12
    }
    

    @IBAction func didTapPlusOneButton() {
        self.addAmountValue(1)
    }

    @IBAction func didTapPlusFiveButton() {
        self.addAmountValue(5)
    }

    @IBAction func didTapPlusMaxButton() {
        self.addAmountValue(100)
    }

}

extension PreSubmissionBetslipViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.updateAmountValue(string)
        return false
    }

    func addAmountValue(_ value: Int) {
        displayBetValue = displayBetValue + (value * 100)

        let calculatedAmount = Double(displayBetValue/100) + Double(displayBetValue%100)/100
        amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: calculatedAmount))
    }

    func updateAmountValue(_ newValue: String) {
        if let insertedDigit = Int(newValue) {
            displayBetValue = displayBetValue * 10 + insertedDigit
        }
        if newValue == "" {
            displayBetValue = displayBetValue/10
        }
        let calculatedAmount = Double(displayBetValue/100) + Double(displayBetValue%100)/100
        amountTextfield.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: calculatedAmount))
    }

}

typealias UITableViewDelegateDataSource = UITableViewDelegate & UITableViewDataSource

extension PreSubmissionBetslipViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentDataSource().tableView(tableView, numberOfRowsInSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.currentDataSource().tableView(tableView, cellForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.currentDataSource().tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.currentDataSource().tableView?(tableView, heightForRowAt: indexPath) ?? 0.0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.currentDataSource().tableView?(tableView, heightForRowAt: indexPath) ?? 0.0
    }
}

class SingleBettingTicketDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    var bettingTickets: [BettingTicket] = []

    var didUpdateBettingValueAction: ((String, Double) -> ())?
    var bettingValueForId: ((String) -> (Double?))?

    init(bettingTickets: [BettingTicket]) {
        self.bettingTickets = bettingTickets
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bettingTickets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueCellType(SingleBettingTicketTableViewCell.self),
            let bettingTicket = self.bettingTickets[safe: indexPath.row]
        else {
            fatalError()
        }

        let storedValue = self.bettingValueForId?(bettingTicket.id)
        cell.configureWithBettingTicket(bettingTicket, previousBettingAmount: storedValue)
        cell.didUpdateBettingValueAction = self.didUpdateBettingValueAction
        return cell
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}


class MultipleBettingTicketDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    var bettingTickets: [BettingTicket] = []

    init(bettingTickets: [BettingTicket]) {
        self.bettingTickets = bettingTickets
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bettingTickets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueCellType(MultipleBettingTicketTableViewCell.self),
            let bettingTicket = self.bettingTickets[safe: indexPath.row]
        else {
            fatalError()
        }
        cell.configureWithBettingTicket(bettingTicket)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }
}

class SystemBettingTicketDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError()
    }
}
