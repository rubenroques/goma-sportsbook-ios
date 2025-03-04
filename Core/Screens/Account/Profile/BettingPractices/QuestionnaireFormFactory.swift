//
//  QuestionnaireFormFactory.swift
//  Sportsbook
//
//  Created by André Lascas on 31/01/2025.
//

import Foundation

class QuestionnaireFormFactory {
    
    init() {
    }
    
    func createQuestionViews(form: QuestionFormStep) -> [TripleAnswerQuestionView] {
        
        switch form {
        case .first:
            let firstQuestionView = TripleAnswerQuestionView(questionNumber: 1)
            firstQuestionView.setupQuestionData(question: localized("questionnaire_question_1"), firstChoice: localized("no"), secondChoice: localized("yes"), thirdChoice: localized("sometimes"))
            
            let secondQuestionView = TripleAnswerQuestionView(questionNumber: 2)
            secondQuestionView.setupQuestionData(question: localized("questionnaire_question_2"), firstChoice: localized("no"), secondChoice: localized("yes"), thirdChoice: localized("sometimes"))
            
            return [firstQuestionView, secondQuestionView]
        case .second:
            let firstQuestionView = TripleAnswerQuestionView(questionNumber: 3)
            firstQuestionView.setupQuestionData(question: localized("questionnaire_question_3"), firstChoice: localized("no"), secondChoice: localized("yes"), thirdChoice: localized("sometimes"))
            
            let secondQuestionView = TripleAnswerQuestionView(questionNumber: 4)
            secondQuestionView.setupQuestionData(question: localized("questionnaire_question_4"), firstChoice: localized("no"), secondChoice: localized("yes"), thirdChoice: localized("sometimes"))
            
            return [firstQuestionView, secondQuestionView]
        case .third:
            let firstQuestionView = TripleAnswerQuestionView(questionNumber: 5)
            firstQuestionView.setupQuestionData(question: localized("questionnaire_question_5"), firstChoice: localized("no"), secondChoice: localized("yes"), thirdChoice: localized("sometimes"))
            
            let secondQuestionView = TripleAnswerQuestionView(questionNumber: 6)
            secondQuestionView.setupQuestionData(question: localized("questionnaire_question_6"), firstChoice: localized("no"), secondChoice: localized("yes"), thirdChoice: localized("sometimes"))
            
            return [firstQuestionView, secondQuestionView]
        case .fourth:
            let firstQuestionView = TripleAnswerQuestionView(questionNumber: 7)
            firstQuestionView.setupQuestionData(question: localized("questionnaire_question_7"), firstChoice: localized("no"), secondChoice: localized("yes"), thirdChoice: localized("sometimes"))
            
            let secondQuestionView = TripleAnswerQuestionView(questionNumber: 8)
            secondQuestionView.setupQuestionData(question: localized("questionnaire_question_8"), firstChoice: localized("no"), secondChoice: localized("yes"), thirdChoice: localized("sometimes"))
            
            return [firstQuestionView, secondQuestionView]
        case .fifth:
            let firstQuestionView = TripleAnswerQuestionView(questionNumber: 9)
            firstQuestionView.setupQuestionData(question: localized("questionnaire_question_9"), firstChoice: localized("no"), secondChoice: localized("yes"), thirdChoice: localized("sometimes"))
            
            let secondQuestionView = TripleAnswerQuestionView(questionNumber: 10)
            secondQuestionView.setupQuestionData(question: localized("questionnaire_question_10"), firstChoice: localized("no"), secondChoice: localized("yes"), thirdChoice: localized("sometimes"))
            
            return [firstQuestionView, secondQuestionView]
        }
    }
}
