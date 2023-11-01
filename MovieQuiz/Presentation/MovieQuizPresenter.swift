//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Lolita Chernysheva on 31.10.2023.
//  
//

import UIKit

protocol MovieQuizPresenterProtocol: AnyObject {
    var questionsAmount: Int { get }
    var currentQuestion: QuizQuestion? { get set }
    func convert(model: QuizQuestion) -> QuizStepViewModel
    func isLastQuestion() -> Bool
    func resetQuestionIndex()
    func noButtonClicked()
    func yesButtonClicked()
    
}

final class MovieQuizPresenter: MovieQuizPresenterProtocol {
    
    weak var view: MovieQuizViewProtocol?
    
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    
    private var currentQuestionIndex: Int = 0
    
    init(view: MovieQuizViewProtocol) {
        self.view = view
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        currentQuestionIndex += 1
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func yesButtonClicked() {
        isAnswerCorrect(answer: true)
    }
    
    func noButtonClicked() {
        isAnswerCorrect(answer: false)
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func isAnswerCorrect(answer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let isCorrect = currentQuestion.correctAnswer == answer
        view?.showAnswerResult(isCorrect: isCorrect)
    }
}
