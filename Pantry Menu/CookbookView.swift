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
                        VStack{
                            Text("Saved Recipes")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 20, weight: .semibold))
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
                        Spacer()
                    }
                }
                VStack {
                    if isLoading {
                        ProgressView {
                            Text("Loading Recipes...")
                        }
                        .padding()
                    } else {
                        VStack{
                            Text("Recently Viewed")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.system(size: 20, weight: .semibold))
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
