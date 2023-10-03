//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Lolita Chernysheva on 27.09.2023.
//  
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    var textRepresention: String {
        "Рекорд: \(correct)\\\(total)(\(date.dateTimeString))"
    }
    
    func isNewRecord(record: GameRecord) -> Bool {
        correct > record.correct
    }
    
}

extension GameRecord: Comparable {
    
    private var accuracy: Double {
        guard total != 0 else { return 0 }
        return Double(correct) / Double(total)
    }
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        lhs.accuracy < rhs.accuracy
    }
    
}
