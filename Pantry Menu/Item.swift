//
//  Item.swift
//  Pantry Menu
//
//  Created by Nick Schaefer on 12/22/24.
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
