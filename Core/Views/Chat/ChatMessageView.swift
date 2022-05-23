//
//  ChatMessageView.swift
//  Sportsbook
//
//  Created by André Lascas on 08/04/2022.
//

import UIKit
import Combine

class ChatMessageView: UIView {
    // MARK: Private Properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var inputTextView: UITextView = Self.createInputTextView()
    private lazy var ticketButton: UIButton = Self.createTicketButton()

    // MARK: Public Properties
    var textPublisher: CurrentValueSubject<String, Never> = .init("")

    var showPlaceholder: Bool = false {
        didSet {
            if showPlaceholder {
                self.inputTextView.text = localized("message")
            }
            else {
                self.inputTextView.text = nil
            }
        }
    }

    var hasTicketButton: Bool = true {
        didSet {
            self.ticketButton.isHidden = !hasTicketButton
        }
    }

    var shouldShowBetSelection: (() -> Void)?

    // MARK: Lifetime and Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }

    func commonInit() {
        self.inputTextView.delegate = self

        self.ticketButton.addTarget(self, action: #selector(didTapTicketButton), for: .touchUpInside)

        self.showPlaceholder = true

        self.hasTicketButton = true

    }

    func setupWithTheme() {
        self.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.inputTextView.backgroundColor = .clear

        self.inputTextView.textColor = UIColor.App.textSecondary

        self.ticketButton.backgroundColor = .clear
    }

    // MARK: Functions

    func getTextViewValue() -> String {
        let textViewValue = self.inputTextView.text ?? ""

        return textViewValue
    }

    func clearTextView() {
        self.inputTextView.text = ""
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        self.inputTextView.resignFirstResponder()
        return true
    }

    // MARK: Actions
    @objc private func didTapTicketButton() {
        self.shouldShowBetSelection?()
    }

}

extension ChatMessageView: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.showPlaceholder == true {
            self.showPlaceholder = false
        }

    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.inputTextView.text.isEmpty {
            self.showPlaceholder = true
        }

    }

    func textViewDidChangeSelection(_ textView: UITextView) {

        if !self.showPlaceholder {
            self.textPublisher.send(textView.text)
        }

    }
}

//
// MARK: Subviews initialization and setup
//
extension ChatMessageView {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        return view
    }

    private static func createInputTextView() -> UITextView {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = true
        textView.font = AppFont.with(type: .semibold, size: 14)
        textView.text = localized("message")
        return textView
    }

    private static func createTicketButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "chat_ticket_icon"), for: .normal)
        return button
    }

    private func setupSubviews() {
        self.addSubview(self.containerView)

        self.containerView.addSubview(self.inputTextView)

        self.containerView.addSubview(self.ticketButton)

        self.initConstraints()
    }

    private func initConstraints() {

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.containerView.heightAnchor.constraint(equalToConstant: 50),

            self.inputTextView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 8),
//            self.inputTextView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -30),
            self.inputTextView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            self.inputTextView.heightAnchor.constraint(equalToConstant: 30),

            self.ticketButton.leadingAnchor.constraint(equalTo: self.inputTextView.trailingAnchor, constant: 16),
            self.ticketButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.ticketButton.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            self.ticketButton.widthAnchor.constraint(equalToConstant: 40),
            self.ticketButton.heightAnchor.constraint(equalTo: self.ticketButton.widthAnchor)
        ])

    }

}
