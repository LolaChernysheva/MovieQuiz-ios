//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Lolita Chernysheva on 24.09.2023.
//  
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}

