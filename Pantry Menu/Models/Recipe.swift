//
//  Recipe.swift
//  Pantry Menu
//
//  Created by Nick Schaefer on 12/24/24.
//

import SwiftUI
import ConvexMobile

struct Recipe: Decodable, Hashable {
    let storageId: String?
    let collectionId: String?
    let imageUrl: String?
    let title: String
    let ingredients: [Ingredient]
    let instructions: [String]
    let saved: Bool?
    let estimatedTime: EstimatedTime?
}

struct EstimatedTime: Decodable, Hashable {
    let minutes: Int
    let hours: Int
}

struct Ingredient: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let amount: String
    let unit: String
}

struct RecipeCollection: Codable, ConvexEncodable {
    let _id: String?
    var title: String
    let mealType: MealType
    let isSavory: Bool
    let servingSize: Int
    let dietary: [DietaryLabel]
    
    init(_id: String? = nil, mealType: MealType, isSavory: Bool, servingSize: Int, dietary: [DietaryLabel]) {
        self._id = _id
        self.title = generateRecipeTitle(dietary: dietary, servingSize: servingSize, mealType: mealType)
        self.mealType = mealType
        self.isSavory = isSavory
        self.servingSize = servingSize
        self.dietary = dietary
        
        func generateRecipeTitle(dietary: [DietaryLabel], servingSize: Int, mealType: MealType) -> String {
            let dietaryText = !dietary.isEmpty ? dietary.map { $0.rawValue }.joined(separator: ", ") + " " : ""
            let mealTypeText = mealType.rawValue.capitalized
            
            return "\(dietaryText)\(mealTypeText) Recipes for \(servingSize)"
        }
    }
}

enum MealType: String, Codable {
    case breakfast
    case lunch
    case dinner
    case snack
    case dessert
    
    func canBeSweet() -> Bool {
        switch self {
        case .lunch, .dinner:
            return false
        case .breakfast, .snack, .dessert:
            return true
        }
    }
}

enum DietaryLabel: String, Codable {
    case glutenFree = "Gluten-Free"
    case dairyFree = "Dairy-Free"
    case vegan = "Vegan"
    case vegetarian = "Vegetarian"
}
