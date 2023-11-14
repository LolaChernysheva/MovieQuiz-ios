//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Lolita Chernysheva on 27.09.2023.
//  
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord? { get }
    
    func store(correct count: Int, total amount: Int) 
}
