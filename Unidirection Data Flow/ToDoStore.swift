//
//  ToDoStore.swift
//  Unidirection Data Flow
//
//  Created by Stephen003 on 2023/10/2.
//

import Foundation

let dummy = [
    "Buy the milk",
    "walk the dog",
    "Rent a car"
]

struct ToDoStore {
    static let shared = ToDoStore()
    func getToDoItems(compeltionHandler: (([String]) -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            compeltionHandler?(dummy)
        }
    }
}
