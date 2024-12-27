//
//  MenuView.swift
//  Pantry Menu
//
//  Created by Nick Schaefer on 12/23/24.
//

import SwiftUI
import ConvexMobile

import SwiftUI
import ConvexMobile

struct CollectionResponse: Decodable {
    let collectionID: String?
    let error: String?
}

struct MenuView: View {
    @State private var isLoading: Bool = true
    @State private var collections: [RecipeCollection] = []
    @State private var isLoadButtonVisible: Bool = false
    @State private var isMenuSheetVisible: Bool = true
    
    var body: some View {
        VStack {
            Button(action: {
                Task {
                    let collection = RecipeCollection(mealType: .breakfast, isSavory: false, servingSize: 2, dietary: [.dairyFree])
                    let response: CollectionResponse = try await convex.mutation("recipes:createCollection", with: ["collection": collection])
                    
                    if let error = response.error {
                        print("Error creating collection: \(error)")
                    }
                    
                    if let collectionID = response.collectionID {
                        try await convex.action("ai:getRecipes", with: ["collectionId": collectionID])
                    } else {
                        print("Error: Collection ID not provided")
                    }
                }
            }) {
                Text("Generate New Menu")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding()
            
            if !collections.isEmpty {
                Text("Previous Menus")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                ScrollView {
                    ForEach(collections, id: \._id) { collection in
                        Text("\(collection.title)")
                    }
                }
            }
        }
        .task {
            for await collections: [RecipeCollection] in convex.subscribe(to: "recipes:getCollections")
                .replaceError(with: []).values
            {
                self.collections = collections
            }
        }
        .onChange(of: collections.count) {
            print(collections.count)
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        MenuView()
    }
}
