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
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
