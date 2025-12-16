//
//  QuestionFormStepView.swift
//  Sportsbook
//
//  Created by André Lascas on 30/01/2025.
//

import Foundation
import UIKit
import Combine

class QuestionFormStepView: UIView {
    
    // MARK: Private properties
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var stackView: UIStackView = Self.createStackView()
    
    // MARK: Public properties
    var isFormComplete: CurrentValueSubject<Bool, Never> = .init(false)
    var formStep: QuestionFormStep
    var questionViews: [TripleAnswerQuestionView] = []
    
    var cancellables = Set<AnyCancellable>()
    
    // Callbacks
    var didAnswerQuestion: ((Int, String, String) -> Void)?
    
    // MARK: Lifetime and cycle
    init(formStep: QuestionFormStep) {
        
        self.formStep = formStep
        
        super.init(frame: .zero)

        self.setupSubviews()
        self.commonInit()
        self.setupWithTheme()
        
        self.addStackViews(formStep: self.formStep)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func commonInit() {
    }
    
    // MARK: Layout and theme
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setupWithTheme() {
        self.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.stackView.backgroundColor = .clear
    }
    
    // MARK: Functions
    func addStackViews(formStep: QuestionFormStep) {
        
        let questionnaireFormFactory = QuestionnaireFormFactory()
        
        let questionViews = questionnaireFormFactory.createQuestionViews(form: formStep)
        
        for view in questionViews {
            
            self.questionViews.append(view)
            
            view.answerChoice
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] answerChoice in
                    self?.checkFormValidation()
                })
                .store(in: &cancellables)
            
            view.didAnswerQuestion = { [weak self] questionNumber, question, answer in
                self?.didAnswerQuestion?(questionNumber, question, answer)
            }
            
            self.stackView.addArrangedSubview(view)
        }
        
        self.stackView.setNeedsLayout()
        self.stackView.layoutIfNeeded()
    }
    
    private func checkFormValidation() {
        
        let isFormValid = self.questionViews.allSatisfy { $0.answerChoice.value != .none
        }
        
        self.isFormComplete.send(isFormValid)
    }
    
}

extension QuestionFormStepView {
    
    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 14
        return stackView
    }
    
    func setupSubviews() {
        
        self.addSubview(self.containerView)
        
        self.containerView.addSubview(self.stackView)

        self.initConstraints()
    }
    
    func initConstraints() {
        
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.stackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 15),
            self.stackView.bottomAnchor.constraint(lessThanOrEqualTo: self.containerView.bottomAnchor, constant: -15)
        ])
    } 
}
