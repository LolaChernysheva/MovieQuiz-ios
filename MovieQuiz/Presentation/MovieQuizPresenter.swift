//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Lolita Chernysheva on 31.10.2023.
//  
//

import UIKit

protocol MovieQuizPresenterProtocol: AnyObject {
    func convert(model: QuizQuestion) -> QuizStepViewModel
    
}

final class MovieQuizPresenter: MovieQuizPresenterProtocol {
    
    weak var view: MovieQuizViewProtocol?
    
    private let questionsAmount: Int = 10
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
    
}
