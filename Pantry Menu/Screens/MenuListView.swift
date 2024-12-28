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

struct MenuListView: View {
    let collections: [RecipeCollection]
    @State private var isLoadButtonVisible: Bool = false
    @State private var isMenuSheetVisible: Bool = true
    @State private var isLoading = false
    @State private var path = NavigationPath()
    
    private func generateRecipeCollection() {
        Task {
            do {
                isLoading = true
                let collection = RecipeCollection(mealType: .breakfast, isSavory: false, servingSize: 2, dietary: [.dairyFree])
                let collectionId: String = try await convex.mutation("recipes:createCollection", with: ["collection": collection])
                path.append(collectionId)
                isLoading = false
            } catch {
                print(error)
            }
        }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                VStack {
                    Button {
                        
                    } label: {
                        Text(!isLoading ? "New Menu" : "Loading...")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .padding()
                }
                
                if !collections.isEmpty {
                    Text("Previous Menus")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    ScrollView {
                        VStack {
                            ForEach(collections, id: \._id) { collection in
                                Button {
                                    path.append(collection._id!)
                                    print(collection._id!)
                                } label: {
                                    VStack {
                                        Text("\(collection.title)")
                                            .frame(maxWidth:.infinity, alignment: .leading)
                                        Text("\(collection._id!)")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationDestination(for: String.self) { collectionId in
                MenuView(collectionId: collectionId)
            }
            .fullScreenCover(isPresented: $isMenuSheetVisible) {
                MenuGuide()
            }
        }
    }
}

#Preview {
    MenuListView(collections: [])
}
