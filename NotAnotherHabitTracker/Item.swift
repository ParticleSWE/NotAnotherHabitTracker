//
//  Item.swift
//  NotAnotherHabitTracker
//
//  Created by Patrik Ell on 2024-04-12.
//

import Foundation
import SwiftData

@Model
final class Item {
    var datesCompleted: Date
    var nameOfHabit: String
    
    init(datesCompleted: Date, nameOfHabit: String) {
        self.datesCompleted = datesCompleted
        self.nameOfHabit = nameOfHabit
    }
}
