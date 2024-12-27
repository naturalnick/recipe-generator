//
//  MenuView.swift
//  Pantry Menu
//
//  Created by Nick Schaefer on 12/27/24.
//

import SwiftUI

struct CollectionResponse: Decodable {
    let collection: RecipeCollection?
    let recipes: [Recipe]
}

struct MenuView: View {
    @State private var collection: RecipeCollection? = nil
    @State private var recipes: [Recipe] = []
    
    let collectionId: String
    
    var body: some View {
        ScrollView {
            Carousel(title: "Today's Specials", subtitle: "You have all the ingredients for these recipes", recipes: recipes)
            Carousel(title: "On Deck" /*or One Shop Away*/, subtitle: "You'll need a few more ingredients for these recipes", recipes: recipes)
        }
        .navigationTitle(collection?.title ?? "")
        .navigationBarTitleDisplayMode(.large)
        .task {
            for await response: CollectionResponse in convex.subscribe(to: "recipes:getCollection", with:["id": collectionId])
                .replaceError(with: CollectionResponse(collection: nil, recipes: [])).values
            {
                guard let collection = response.collection else { return }
                self.collection = collection
                self.recipes = response.recipes
            }
        }
    }
}

//#Preview {
//    NavigationStack {
//        MenuView(collectionId: <#String#>, collection: RecipeCollection(mealType: .breakfast, isSavory: false, servingSize: 2, dietary: []))
//    }
//}
