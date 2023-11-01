//
//  MovieQuizViewControllerMock.swift
//  MovieQuizTests
//
//  Created by Lolita Chernysheva on 01.11.2023.
//  
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewProtocol {
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func showAlert(quiz result: MovieQuiz.QuizResultsViewModel) {
        
    }
    
    func hideActivityIndicator() {
        
    }
    
    func showNetworkError(message: String) {
        
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        
    }
    
    func resetImageSettings() {
        
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(view: viewControllerMock as! MovieQuizViewProtocol)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
         XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
