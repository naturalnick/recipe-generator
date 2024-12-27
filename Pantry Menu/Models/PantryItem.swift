//
//  PantryItem.swift
//  Pantry Menu
//
//  Created by Nick Schaefer on 12/22/24.
//

import SwiftUI
import SwiftData
import Foundation

struct PantryItem: Decodable, Identifiable {
    let _id: String
    let name: String
    let status: StockStatus
    
    var id: String { _id }
}

enum StockStatus: String, Codable {
    case in_ = "IN"
    case out = "OUT"
    case low = "LOW"
    
    var color: Color {
        switch self {
        case .in_: return .green
        case .out: return .red
        case .low: return .yellow
        }
    }
    
    var icon: String {
        switch self {
        case .in_: return "checkmark.square.fill"
        case .out: return "exclamationmark.triangle.fill"
        case .low: return "exclamationmark.circle.fill"
        }
    }
}
