//
//  TripleAnswerQuestionView.swift
//  Sportsbook
//
//  Created by André Lascas on 31/01/2025.
//

import Foundation
import UIKit
import Combine

class TripleAnswerQuestionView: UIView {
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var firstAnswerBaseView: UIView = Self.createFirstAnswerBaseView()
    private lazy var firstAnswerCheckImageView: UIImageView = Self.createFirstAnswerCheckImageView()
    private lazy var firstAnswerLabel: UILabel = Self.createFirstAnswerLabel()
    
    private lazy var secondAnswerBaseView: UIView = Self.createSecondAnswerBaseView()
    private lazy var secondAnswerCheckImageView: UIImageView = Self.createSecondAnswerCheckImageView()
    private lazy var secondAnswerLabel: UILabel = Self.createSecondAnswerLabel()
    
    private lazy var thirdAnswerBaseView: UIView = Self.createThirdAnswerBaseView()
    private lazy var thirdAnswerCheckImageView: UIImageView = Self.createThirdAnswerCheckImageView()
    private lazy var thirdAnswerLabel: UILabel = Self.createThirdAnswerLabel()
    
    // Callbacks
    var didAnswerQuestion: ((Int, String, String) -> Void)?
    
    // MARK: Public properties
    var answerChoice: CurrentValueSubject<MultipleAnswerChoice, Never> = .init(.none)
    
    var questionNumber: Int
    
    // MARK: Lifetime and cycle
    init(questionNumber: Int) {
        self.questionNumber = questionNumber
        
        super.init(frame: .zero)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func commonInit() {
        
        let firstTapGesture = UITapGestureRecognizer(target: self, action: #selector(firstAnswerViewTapped))
        self.firstAnswerBaseView.addGestureRecognizer(firstTapGesture)
        self.firstAnswerBaseView.isUserInteractionEnabled = true
        
        let secondTapGesture = UITapGestureRecognizer(target: self, action: #selector(secondAnswerViewTapped))
        self.secondAnswerBaseView.addGestureRecognizer(secondTapGesture)
        self.secondAnswerBaseView.isUserInteractionEnabled = true
        
        let thirdTapGesture = UITapGestureRecognizer(target: self, action: #selector(thirdAnswerViewTapped))
        self.thirdAnswerBaseView.addGestureRecognizer(thirdTapGesture)
        self.thirdAnswerBaseView.isUserInteractionEnabled = true
    }
    
    // MARK: Layout and theme
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.containerView.layer.cornerRadius = CornerRadius.card
        
        self.firstAnswerCheckImageView.layer.cornerRadius = self.firstAnswerCheckImageView.frame.size.width / 2
        
        self.secondAnswerCheckImageView.layer.cornerRadius = self.secondAnswerCheckImageView.frame.size.width / 2
        
        self.thirdAnswerCheckImageView.layer.cornerRadius = self.thirdAnswerCheckImageView.frame.size.width / 2
    }
    
    func setupWithTheme() {
        self.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary
        
        self.firstAnswerBaseView.backgroundColor = .clear
        self.firstAnswerCheckImageView.backgroundColor = .clear
        self.firstAnswerLabel.textColor = UIColor.App.textPrimary
        
        self.secondAnswerBaseView.backgroundColor = .clear
        self.secondAnswerCheckImageView.backgroundColor = .clear
        self.secondAnswerLabel.textColor = UIColor.App.textPrimary
        
        self.thirdAnswerBaseView.backgroundColor = .clear
        self.thirdAnswerCheckImageView.backgroundColor = .clear
        self.thirdAnswerLabel.textColor = UIColor.App.textPrimary
    }
    
    // MARK: Functions
    func setupQuestionData(question: String, firstChoice: String, secondChoice: String, thirdChoice: String) {
        
        self.titleLabel.text = question
        
        self.firstAnswerLabel.text = firstChoice
        
        self.secondAnswerLabel.text = secondChoice
        
        self.thirdAnswerLabel.text = thirdChoice
    }
    
    private func checkSelectedViews() {
        
        switch self.answerChoice.value {
        case .first:
            self.firstAnswerCheckImageView.image = UIImage(named: "selected_answer_icon")
            self.secondAnswerCheckImageView.image = UIImage(named: "unselected_answer_icon")
            self.thirdAnswerCheckImageView.image = UIImage(named: "unselected_answer_icon")
            
            if let question = self.titleLabel.text,
               let answer = self.firstAnswerLabel.text {
                
                self.didAnswerQuestion?(self.questionNumber, question, answer)
                
            }
            
        case .second:
            self.firstAnswerCheckImageView.image = UIImage(named: "unselected_answer_icon")
            self.secondAnswerCheckImageView.image = UIImage(named: "selected_answer_icon")
            self.thirdAnswerCheckImageView.image = UIImage(named: "unselected_answer_icon")
            
            if let question = self.titleLabel.text,
               let answer = self.secondAnswerLabel.text {
                
                self.didAnswerQuestion?(self.questionNumber, question, answer)
                
            }
            
        case .third:
            self.firstAnswerCheckImageView.image = UIImage(named: "unselected_answer_icon")
            self.secondAnswerCheckImageView.image = UIImage(named: "unselected_answer_icon")
            self.thirdAnswerCheckImageView.image = UIImage(named: "selected_answer_icon")
            
            if let question = self.titleLabel.text,
               let answer = self.thirdAnswerLabel.text {
                
                self.didAnswerQuestion?(self.questionNumber, question, answer)
                
            }
            
        default:
            self.firstAnswerCheckImageView.image = UIImage(named: "unselected_answer_icon")
            self.secondAnswerCheckImageView.image = UIImage(named: "unselected_answer_icon")
            self.thirdAnswerCheckImageView.image = UIImage(named: "unselected_answer_icon")
        }
    }
    
    // MARK: Actions
    @objc private func firstAnswerViewTapped() {
        self.answerChoice.send(.first)
        self.checkSelectedViews()
    }
    
    @objc private func secondAnswerViewTapped() {
        self.answerChoice.send(.second)
        self.checkSelectedViews()
    }
    
    @objc private func thirdAnswerViewTapped() {
        self.answerChoice.send(.third)
        self.checkSelectedViews()
    }
}

extension TripleAnswerQuestionView {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = AppFont.with(type: .bold, size: 18)
        label.numberOfLines = 0
        return label
    }
    
    private static func createFirstAnswerBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createFirstAnswerCheckImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "unselected_answer_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createFirstAnswerLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("no")
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }
    
    private static func createSecondAnswerBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createSecondAnswerCheckImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "unselected_answer_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createSecondAnswerLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("yes")
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }
    
    private static func createThirdAnswerBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createThirdAnswerCheckImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "unselected_answer_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private static func createThirdAnswerLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("maybe")
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }
    
    private func setupSubviews() {
        
        self.addSubview(self.containerView)
        
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.firstAnswerBaseView)
        
        self.firstAnswerBaseView.addSubview(self.firstAnswerCheckImageView)
        self.firstAnswerBaseView.addSubview(self.firstAnswerLabel)
        
        self.containerView.addSubview(self.secondAnswerBaseView)
        
        self.secondAnswerBaseView.addSubview(self.secondAnswerCheckImageView)
        self.secondAnswerBaseView.addSubview(self.secondAnswerLabel)
        
        self.containerView.addSubview(self.thirdAnswerBaseView)
        
        self.thirdAnswerBaseView.addSubview(self.thirdAnswerCheckImageView)
        self.thirdAnswerBaseView.addSubview(self.thirdAnswerLabel)
        
        self.initConstraints()
        
        self.containerView.setNeedsLayout()
        self.containerView.layoutIfNeeded()
    }
    
    private func initConstraints() {
        
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 16),
            
            self.firstAnswerBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.firstAnswerBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.firstAnswerBaseView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 14),
            
            self.firstAnswerCheckImageView.leadingAnchor.constraint(equalTo: self.firstAnswerBaseView.leadingAnchor, constant: 16),
            self.firstAnswerCheckImageView.topAnchor.constraint(equalTo: self.firstAnswerBaseView.topAnchor, constant: 2),
            self.firstAnswerCheckImageView.bottomAnchor.constraint(equalTo: self.firstAnswerBaseView.bottomAnchor, constant: -2),
            self.firstAnswerCheckImageView.widthAnchor.constraint(equalToConstant: 26),
            self.firstAnswerCheckImageView.heightAnchor.constraint(equalTo: self.firstAnswerCheckImageView.widthAnchor),
            
            self.firstAnswerLabel.leadingAnchor.constraint(equalTo: self.firstAnswerCheckImageView.trailingAnchor, constant: 8),
            self.firstAnswerLabel.trailingAnchor.constraint(equalTo: self.firstAnswerBaseView.trailingAnchor, constant: -16),
            self.firstAnswerLabel.centerYAnchor.constraint(equalTo: self.firstAnswerCheckImageView.centerYAnchor),
            
            self.secondAnswerBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.secondAnswerBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.secondAnswerBaseView.topAnchor.constraint(equalTo: self.firstAnswerBaseView.bottomAnchor, constant: 20),
            
            self.secondAnswerCheckImageView.leadingAnchor.constraint(equalTo: self.secondAnswerBaseView.leadingAnchor, constant: 16),
            self.secondAnswerCheckImageView.topAnchor.constraint(equalTo: self.secondAnswerBaseView.topAnchor, constant: 2),
            self.secondAnswerCheckImageView.bottomAnchor.constraint(equalTo: self.secondAnswerBaseView.bottomAnchor, constant: -2),
            self.secondAnswerCheckImageView.widthAnchor.constraint(equalToConstant: 26),
            self.secondAnswerCheckImageView.heightAnchor.constraint(equalTo: self.secondAnswerCheckImageView.widthAnchor),
            
            self.secondAnswerLabel.leadingAnchor.constraint(equalTo: self.secondAnswerCheckImageView.trailingAnchor, constant: 8),
            self.secondAnswerLabel.trailingAnchor.constraint(equalTo: self.secondAnswerBaseView.trailingAnchor, constant: -16),
            self.secondAnswerLabel.centerYAnchor.constraint(equalTo: self.secondAnswerCheckImageView.centerYAnchor),
            
            self.thirdAnswerBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.thirdAnswerBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.thirdAnswerBaseView.topAnchor.constraint(equalTo: self.secondAnswerBaseView.bottomAnchor, constant: 20),
            self.thirdAnswerBaseView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -14),
            
            self.thirdAnswerCheckImageView.leadingAnchor.constraint(equalTo: self.thirdAnswerBaseView.leadingAnchor, constant: 16),
            self.thirdAnswerCheckImageView.topAnchor.constraint(equalTo: self.thirdAnswerBaseView.topAnchor, constant: 2),
            self.thirdAnswerCheckImageView.bottomAnchor.constraint(equalTo: self.thirdAnswerBaseView.bottomAnchor, constant: -2),
            self.thirdAnswerCheckImageView.widthAnchor.constraint(equalToConstant: 26),
            self.thirdAnswerCheckImageView.heightAnchor.constraint(equalTo: self.thirdAnswerCheckImageView.widthAnchor),
            
            self.thirdAnswerLabel.leadingAnchor.constraint(equalTo: self.thirdAnswerCheckImageView.trailingAnchor, constant: 8),
            self.thirdAnswerLabel.trailingAnchor.constraint(equalTo: self.thirdAnswerBaseView.trailingAnchor, constant: -16),
            self.thirdAnswerLabel.centerYAnchor.constraint(equalTo: self.thirdAnswerCheckImageView.centerYAnchor),
            
        ])
        
    }
}

enum MultipleAnswerChoice{
    case none
    case first
    case second
    case third
}
