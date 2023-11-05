//
//  StatisticServiceImplementation.swift
//  MovieQuiz
//
//  Created by Lolita Chernysheva on 27.09.2023.
//  
//

import Foundation

final class StatisticServiceImplementation {
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    private let userDefaults = UserDefaults.standard
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

}

extension StatisticServiceImplementation: StatisticService {
    
    var total: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    var correct: Int {
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord? {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? decoder.decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        
        set {
            guard let data = try? encoder.encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
            
        }
    }
    
    var totalAccuracy: Double {
        Double(correct) / Double(total) * 100
    }
    
    func store(correct count: Int, total amount: Int) {
        correct += count
        total += amount
        gamesCount += 1
        saveBestGameIfNeeded(correctCount: count, totalAmount: amount)
    }
    
    private func saveBestGameIfNeeded(correctCount: Int, totalAmount: Int) {
        let currentGame = GameRecord(correct: correctCount, total: totalAmount, date: Date())
        guard let bestGame else {
            self.bestGame = currentGame
            return
        }
        if currentGame > bestGame {
            self.bestGame = currentGame
        }
    }
}
