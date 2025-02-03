//
//  BettingPracticesQuestionnaireViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 31/01/2025.
//

import Foundation
import Combine
import FirebaseCore
import FirebaseFirestore

class BettingPracticesQuestionnaireViewModel {
    
    var questionnaireSteps: [QuestionnaireStep]
    
    var currentStep: CurrentValueSubject<Int, Never> = .init(0)
    var numberOfSteps: Int {
        return self.questionnaireSteps.count
    }
    
    var progressPercentage: AnyPublisher<Float, Never> {
        return self.currentStep.map { [weak self] currentStep in
            let totalSteps = self?.numberOfSteps ?? 0
            if totalSteps > 0 {
                let calculatedPercentage =  Float(currentStep+1) / Float(totalSteps)
                return calculatedPercentage
            }
            return Float(0.0)
        }.eraseToAnyPublisher()
    }
    
    var questionResults: [Int: String] = [:]
    
    // Callbacks
    var shouldShowSuccessScreen: (() -> Void)?
    var shouldShowErrorAlert: (() -> Void)?
        
    // MARK: Init
    init() {
        self.questionnaireSteps = Self.defaultQuestionnaireSteps()
    }
    
    // MARK: Functions
    private static func defaultQuestionnaireSteps() -> [QuestionnaireStep] {
        return [
            QuestionnaireStep(form: .first),
            QuestionnaireStep(form: .second),
            QuestionnaireStep(form: .third),
            QuestionnaireStep(form: .fourth),
            QuestionnaireStep(form: .fifth),
        ]
    }
    
    func scrollToPreviousStep() {
        var nextStep = currentStep.value - 1
        if nextStep < 0 {
            nextStep = 0
        }
        self.currentStep.send(nextStep)
    }

    func scrollToNextStep() {
        var nextStep = currentStep.value + 1
        if nextStep > numberOfSteps {
            nextStep = numberOfSteps
        }
        self.currentStep.send(nextStep)
    }

    func scrollToIndex(_ index: Int) {

        if index > numberOfSteps {
            return
        }
        else if index < 0 {
            return
        }

        self.currentStep.send(index)
    }

    func isLastStep(index: Int) -> Bool {
        return index == self.numberOfSteps-1
    }

    func indexForFormStep(_ formStep: QuestionFormStep) -> Int? {
        for (index, questionnaireStep) in self.questionnaireSteps.enumerated() {
            if questionnaireStep.form == formStep {
                return index
            }
        }
        return nil
    }
    
    func storeQuestionAnswered(number: Int, question: String, answer: String) {
        self.questionResults[number] = "\(question):\(answer)"
        
    }
    
    func createQuestionnaireResult() {
        
        let partyId = Env.userSessionStore.userProfilePublisher.value?.userIdentifier ?? ""
        
        let userEmail = Env.userSessionStore.userProfilePublisher.value?.email ?? ""
        
        var questions = [QuestionData]()
        
        for (key, value) in self.questionResults {
            let components = value.split(separator: ":")
            
            if components.count == 2 {
                let question = components[0]
                let answer = components[1]
                
                let questionData = QuestionData(number: key, question: "\(question)", answer: "\(answer)")
                
                questions.append(questionData)
            }
            
        }
        
        let questionsSorted = questions.sorted(by: {
            $0.number < $1.number
        })
        
        let questionnaireResult = QuestionnaireResult(partyId: partyId, email: userEmail, questions: questionsSorted)
        
        let db = Firestore.firestore()
        
        // Convert questionnaireResult to a dictionary for Firestore
        let questionnaireData: [String: Any] = [
            "partyId": questionnaireResult.partyId,
            "email": questionnaireResult.email,
            "questions": questionnaireResult.questions.map {
                ["number": $0.number, "question": $0.question, "answer": $0.answer]
            }
        ]
        
        // Save to Firestore
        db.collection("questionnaire_results").document("user_\(partyId)").setData(questionnaireData, merge: true) { error in
            if let error = error {
                print("Error saving questionnaire result: \(error)")
                self.shouldShowErrorAlert?()
            }
            else {
                self.shouldShowSuccessScreen?()
            }
        }
        
    }
}

enum QuestionFormStep: String {
    case first
    case second
    case third
    case fourth
    case fifth
}

struct QuestionnaireStep {
    var form: QuestionFormStep
    
    public init(form: QuestionFormStep) {
        self.form = form
    }
}


struct QuestionnaireResult {
    var partyId: String
    var email: String
    var questions: [QuestionData]
}

struct QuestionData {
    var number: Int
    var question: String
    var answer: String
}
