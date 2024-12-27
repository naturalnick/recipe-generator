//
//  RecipeView.swift
//  Pantry Menu
//
//  Created by Nick Schaefer on 12/24/24.
//

import SwiftUI

struct RecipeView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack {
                if let imageUrl = recipe.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .frame(maxWidth: .infinity)
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        RecipeImagePlaceholder()
                    }
                } else {
                    RecipeImagePlaceholder()
                }
                
                VStack {
                    Text(recipe.title)
                        .font(.system(size: 28, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        
                    } label: {
                        Text("Save to cookbook")
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 100))
                    }

                    
                    if let estimatedTime = recipe.estimatedTime {
                        Text("\(estimatedTime.hours > 0 ? "\(estimatedTime.hours)h" : "")\(estimatedTime.minutes > 0 ? "\(estimatedTime.minutes)m" : "")")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    VStack {
                        Text("Ingredients (\(recipe.ingredients.count))")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.black)
                        
                        ForEach(recipe.ingredients) { ingredient in
                            HStack {
                                Text(ingredient.name)
                                    .font(.system(size: 17, weight: .medium))
                                Spacer()
                                Text("\(ingredient.amount) \(ingredient.unit)")
                            }
                            .padding(.vertical, 5)
                            .foregroundStyle(.black)
                            
                            if (recipe.ingredients.last?.id != ingredient.id) {
                                Divider()
                            }
                        }
                    }
                    .padding()
                    .background(Color("AppGray"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.gray.opacity(0.4), lineWidth: 1)
                    )
                    .padding(.vertical)
                    
                    VStack {
                        Text("Directions")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 22, weight: .bold))
                        
                        ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                            HStack {
                                ZStack {
                                   Circle()
                                       .stroke(lineWidth: 2)
                                       .frame(width: 40, height: 40)
                                   
                                   Text("\(index + 1)")
                                       .font(.system(size: 20, weight: .bold))
                                }
                                Spacer()
                                Text(instruction)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: 17, weight: .medium))
                                    .lineSpacing(4)
                                    .tracking(0.3)
                                    .padding(.vertical, 10)
                                    .padding(.leading)
                            }
                            .frame(maxWidth: .infinity)
                            if (index < recipe.instructions.count - 1) {
                                Divider()
                                    .background(colorScheme == .dark ? Color.white : Color.gray)
                            }
                        }
                    }
                    
                }
                .padding(.top, 8)
                .padding(.horizontal)
                Spacer()
            }
            .padding(.bottom)
        }
        .ignoresSafeArea(.all, edges: .top)
    }
}

#Preview {
    RecipeView(recipe: Recipe(storageId: nil, collectionId: nil, imageUrl: nil, title: "Hummus", ingredients: [Ingredient(id: "1", name: "Garbanzo Beans", amount: "2", unit: "cups"),Ingredient(id: "2", name: "Tahini", amount: "0.5", unit: "cup")], instructions: ["Add all ingredients to blender.","Blend until smooth.","Serve with pita bread."], saved: nil, estimatedTime: nil))
}
