//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Lolita Chernysheva on 22.09.2023.
//  
//

import Foundation

// массив с вопросами и один метод, который вернёт случайно выбранный вопрос
final class QuestionFactory: QuestionFactoryProtocol {
    
    private struct Text {
        static let question: String = "Рейтинг этого фильма больше чем 6?"
    }
    
    private let questions: [QuizQuestion] = [
        .init(image: Assets.godfatherImageName, text: Text.question, correctAnswer: true),
        .init(image: Assets.darkKnightImageName, text: Text.question, correctAnswer: true),
        .init(image: Assets.killBillImageName, text: Text.question, correctAnswer: true),
        .init(image: Assets.avengersImageName, text: Text.question, correctAnswer: true),
        .init(image: Assets.deadpoolImageName, text: Text.question, correctAnswer: true),
        .init(image: Assets.greenKnightImageName, text: Text.question, correctAnswer: true),
        .init(image: Assets.oldImageName, text: Text.question, correctAnswer: false),
        .init(image: Assets.iceAgeAdventuresImageName, text: Text.question, correctAnswer: false),
        .init(image: Assets.teslaImageName, text: Text.question, correctAnswer: false),
        .init(image: Assets.vivariumImageName, text: Text.question, correctAnswer: false)
    ]
    
    //Фабрика должна уметь создавать вопросы
    
    func requestNextQuestion() -> QuizQuestion? {
        guard let index = (0..<questions.count).randomElement() else {
            return nil
        }

        return questions[safe: index]
    }
}
