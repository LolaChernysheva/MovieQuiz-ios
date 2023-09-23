//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Lolita Chernysheva on 23.09.2023.
//  
//

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion() -> QuizQuestion?
}
