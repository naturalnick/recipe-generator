//
//  Carousel.swift
//  Pantry Menu
//
//  Created by Nick Schaefer on 12/27/24.
//

import SwiftUI

struct Carousel: View {
    var title: String
    var subtitle: String?
    var recipes: [Recipe]
    @State private var isLoadButtonVisible: Bool = false
    
    var body: some View {
        VStack{
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 20, weight: .semibold))
            if let subtitle {
                Text(subtitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 15))
            }
        }
        .padding(.horizontal)
        
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(Array(recipes.enumerated()), id: \.offset) { index, recipe in
                    NavigationLink(value: recipe) {
                        RecipeCard(recipe: recipe, isLoadButtonVisible: $isLoadButtonVisible)
                    }
                    .allowsHitTesting(true)
                    .simultaneousGesture(TapGesture())
                }
                if isLoadButtonVisible {
                    VStack(spacing: 10) {
                        Image(systemName: "plus")
                            .font(.system(size: 50))
                            .foregroundStyle(.black.opacity(0.7))
                        Text("Load More")
                            .foregroundStyle(.black.opacity(0.8))
                    }
                    .frame(width: UIScreen.main.bounds.width / 1.7)
                    .frame(maxHeight: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("AppGray"))
                            .strokeBorder(.gray.opacity(0.4), lineWidth: 1)
                    }
                }
            }
            .shadow(color: .gray.opacity(0.2), radius: 3, x: 1, y: 4)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(height: 400)
    }
}

#Preview {
    Carousel(title: "Title", subtitle: "Subtitle", recipes: [Recipe(storageId: nil, collectionId: nil, imageUrl: nil, title: "Hummus", ingredients: [Ingredient(id: "1", name: "Garbanzo Beans", amount: "2", unit: "cups"),Ingredient(id: "2", name: "Tahini", amount: "0.5", unit: "cup")], instructions: ["Add all ingredients to blender.","Blend until smooth.","Serve with pita bread."], saved: nil, estimatedTime: nil, dietary: []),Recipe(storageId: nil, collectionId: nil, imageUrl: nil, title: "Hummus", ingredients: [Ingredient(id: "1", name: "Garbanzo Beans", amount: "2", unit: "cups"),Ingredient(id: "2", name: "Tahini", amount: "0.5", unit: "cup")], instructions: ["Add all ingredients to blender.","Blend until smooth.","Serve with pita bread."], saved: nil, estimatedTime: nil, dietary: [.dairyFree]), Recipe(storageId: nil, collectionId: nil, imageUrl: nil, title: "Hummus", ingredients: [Ingredient(id: "1", name: "Garbanzo Beans", amount: "2", unit: "cups"),Ingredient(id: "2", name: "Tahini", amount: "0.5", unit: "cup")], instructions: ["Add all ingredients to blender.","Blend until smooth.","Serve with pita bread."], saved: nil, estimatedTime: nil, dietary: [.glutenFree])])
}
