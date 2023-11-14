//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Lolita Chernysheva on 24.09.2023.
//  
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
