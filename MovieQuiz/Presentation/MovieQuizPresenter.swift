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
    var correctAnswers: Int { get set }
    func convert(model: QuizQuestion) -> QuizStepViewModel
    func isLastQuestion() -> Bool
    func resetQuestionIndex()
    func noButtonClicked()
    func yesButtonClicked()
    func didReceiveNextQuestion(question: QuizQuestion?)
    func showNextQuestionOrResults()
    func generateResultText() -> String
    
}

final class MovieQuizPresenter: MovieQuizPresenterProtocol {
    
    weak var view: MovieQuizViewProtocol?
    
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    
    private var currentQuestionIndex: Int = 0
    private var playedQuizes = 0
    var correctAnswers = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    
    private lazy var statisticService: StatisticService = {
        StatisticServiceImplementation()
    }()
    
    init(view: MovieQuizViewProtocol?, questionFactory: QuestionFactoryProtocol?) {
        self.view = view
        self.questionFactory = questionFactory
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
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view?.show(quiz: viewModel)
        }
    }
    
    func generateResultText() -> String {
        let bestGame = statisticService.bestGame
        let yourResultText = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
        let gamesCountText = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let recordText = bestGame?.textRepresention
        let avarageAccuracyText = " Средняя точность: \(String(format: "%.2F", statisticService.totalAccuracy))%"
        
        let message = [yourResultText ,gamesCountText, recordText, avarageAccuracyText].compactMap { $0 }.joined(separator: "\n")

        return message
    }
    
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            playedQuizes += 1
            let resultText = generateResultText()
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: resultText,
                buttonText: "Сыграть ещё раз")
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            view?.showAlert(quiz: viewModel)
        } else {
            questionFactory?.requestNextQuestion()
        }
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


