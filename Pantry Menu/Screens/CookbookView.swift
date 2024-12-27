//
//  CookbookView.swift
//  Pantry Menu
//
//  Created by Nick Schaefer on 12/23/24.
//

import SwiftUI
import ConvexMobile

import SwiftUI
import ConvexMobile

struct MenuResponse: Decodable {
    var status: Int
    var error: String?
}

struct CookbookView: View {
    @State private var isLoading: Bool = true
    @State private var recipes: [Recipe] = []
    @State private var isLoadButtonVisible: Bool = false
    @State private var isMenuSheetVisible: Bool = true
    @Namespace private var animation
    
    private func getNewMenu() {
        
    }
    
    private func loadMoreRecipes() {
        
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    if isLoading {
                        ProgressView {
                            Text("Loading Recipes...")
                        }
                        .padding()
                    } else {
                        Carousel(title: "Saved Recipes", recipes: recipes)
                        Carousel(title: "Recently Viewed", recipes: recipes)
                        Spacer()
                    }
                }
            }
        }
        .task {
            for await recipes: [Recipe] in convex.subscribe(to: "recipes:get")
                .replaceError(with: []).values
            {
                self.recipes = recipes
            }
        }
        .onChange(of: recipes.count) {
            print(recipes.count)
            isLoading = false
        }
        .navigationDestination(for: Recipe.self) { recipe in
            RecipeView(recipe: recipe)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button{print("pressed menu bar item")
                    
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .navigationTitle("Cookbook")
    }
}

#Preview {
    NavigationStack {
        CookbookView()
    }
}
