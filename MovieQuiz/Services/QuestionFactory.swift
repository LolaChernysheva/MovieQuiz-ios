//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Lolita Chernysheva on 22.09.2023.
//  
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private struct Text {
        static let question: String = "Рейтинг этого фильма больше чем 6?"
    }
    
//    private let questions: [QuizQuestion] = [
//        .init(image: Assets.godfatherImageName, text: Text.question, correctAnswer: true),
//        .init(image: Assets.darkKnightImageName, text: Text.question, correctAnswer: true),
//        .init(image: Assets.killBillImageName, text: Text.question, correctAnswer: true),
//        .init(image: Assets.avengersImageName, text: Text.question, correctAnswer: true),
//        .init(image: Assets.deadpoolImageName, text: Text.question, correctAnswer: true),
//        .init(image: Assets.greenKnightImageName, text: Text.question, correctAnswer: true),
//        .init(image: Assets.oldImageName, text: Text.question, correctAnswer: false),
//        .init(image: Assets.iceAgeAdventuresImageName, text: Text.question, correctAnswer: false),
//        .init(image: Assets.teslaImageName, text: Text.question, correctAnswer: false),
//        .init(image: Assets.vivariumImageName, text: Text.question, correctAnswer: false)
//    ]
    
    private var movies: [MostPopularMovie] = []
    
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    } 
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
           
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }

}
