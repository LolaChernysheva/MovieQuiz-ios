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
    func noButtonClicked()
    func yesButtonClicked()
    func didReceiveNextQuestion(question: QuizQuestion?)
    func showNextQuestionOrResults()
    func generateResultText() -> String
    func restartGame()
}

final class MovieQuizPresenter: MovieQuizPresenterProtocol {
    
    weak var view: MovieQuizViewProtocol?
    
    let questionsAmount: Int = 10
    var correctAnswers = 0
    var currentQuestion: QuizQuestion?
    
    private var currentQuestionIndex: Int = 0
    private var playedQuizes = 0
    
    private lazy var statisticService: StatisticService = {
        StatisticServiceImplementation()
    }()
    
    private lazy var questionFactory: QuestionFactoryProtocol = {
        QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    }()
    
    init(view: MovieQuizViewProtocol?) {
        self.view = view
        questionFactory.loadData()
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

    func yesButtonClicked() {
        isAnswerCorrect(answer: true)
    }
    
    func noButtonClicked() {
        isAnswerCorrect(answer: false)
    }
    
    func restartGame() {
        resetQuestionIndex()
        resetCorrectAnswers()
        questionFactory.requestNextQuestion()
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
            questionFactory.requestNextQuestion()
        }
    }
    
    private func resetCorrectAnswers() {
        correctAnswers = 0
    }
    
    private func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        view?.highlightImageBorder(isCorrect: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [ weak self ] in
            guard let self = self else { return }
            view?.resetImageSettings()
            showNextQuestionOrResults()
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
        showAnswerResult(isCorrect: isCorrect)
    }
}

extension MovieQuizPresenter: QuestionFactoryDelegate {
    
    func didLoadDataFromServer() {
        view?.hideActivityIndicator()
        questionFactory.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        view?.showNetworkError(message: error.localizedDescription)
    }
}
