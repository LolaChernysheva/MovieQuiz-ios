//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Lolita Chernysheva on 18.10.2023.
//  
//

import XCTest
@testable import MovieQuiz //импортируем наше приложение для тестирования

final class ArrayTests: XCTestCase {
    
    func testGetValueInRange() throws { // тест на успешное взятие элемента по индексу
        /*
         дано — массив (например, массив чисел) из 5 элементов,
         когда — мы берём элемент по индексу 2, используя наш сабскрипт,
         тогда — этот элемент существует и равен третьему элементу из массива (потому что отсчёт индексов в массиве начинается с 0).
         */
        
       // Given
        let array = [1, 1, 2, 3, 5]
       
       // When
        let value = array[safe: 2]
       
       // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws { // тест на взятие элемента по неправильному индексу
        // Given
        let array = [1, 1, 2, 3, 5]
       
       // When
        let value = array[safe: 20]
       // Then
        XCTAssertNil(value)
    }
    
}
