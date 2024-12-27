//
//  RecipeCard.swift
//  Pantry Menu
//
//  Created by Nick Schaefer on 12/24/24.
//

import SwiftUI

struct RecipeCard: View {
    var recipe: Recipe
    @Binding var isLoadButtonVisible: Bool
    
    var body: some View {
        VStack {
            if let imageUrl = recipe.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .aspectRatio(contentMode: .fit)
                        .onAppear{
                            isLoadButtonVisible = true
                        }
                } placeholder: {
                    RecipeImagePlaceholder()
                }
            } else {
                RecipeImagePlaceholder()
            }
            
            VStack {
                Text(recipe.title)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(recipe.ingredients.count) ingredients")
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let estimatedTime = recipe.estimatedTime {
                    Text("\(estimatedTime.hours > 0 ? "\(estimatedTime.hours)h" : "")\(estimatedTime.minutes > 0 ? "\(estimatedTime.minutes)m" : "")")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .foregroundStyle(.black)
            .padding(.top, 8)
            .padding(.horizontal)
            Spacer()
            
        }
        .frame(width: UIScreen.main.bounds.width / 1.7)
        .frame(maxHeight: .infinity)
        .background(Color("AppGray"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.gray.opacity(0.4), lineWidth: 1)
        )
    }
}

struct RecipeImagePlaceholder: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(maxWidth: .infinity)
                .aspectRatio(500/500, contentMode: .fit)
                .foregroundStyle(Color("AppGray").gradient)
            Image(systemName: "fork.knife.circle.fill")
                .foregroundStyle(.black)
                .font(.system(size: 100))
                .opacity(0.1)
        }
    }
}

#Preview {
    RecipeCard(recipe: Recipe(storageId: nil, collectionId: nil, imageUrl: nil, title: "Hummus", ingredients: [Ingredient(id: "1", name: "Garbanzo Beans", amount: "2", unit: "cups"),Ingredient(id: "2", name: "Tahini", amount: "0.5", unit: "cup")], instructions: ["Add all ingredients to blender.","Blend until smooth.","Serve with pita bread."], saved: nil, estimatedTime: nil), isLoadButtonVisible: .constant(false))
        .frame(height: 400)
}
