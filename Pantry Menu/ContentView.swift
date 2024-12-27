import SwiftUI
import ConvexMobile

let convex: ConvexClient = {
    guard let url = Bundle.main.infoDictionary?["CONVEX_URL"] as? String,
          !url.isEmpty else {
        fatalError("Missing CONVEX_URL")
    }
    return ConvexClient(deploymentUrl: url)
}()

struct ContentView: View {
    @State private var items: [PantryItem] = []
    @State private var collections: [RecipeCollection] = []
    
    var body: some View {
        ZStack {
            TabView {
                PantryView(items: items)
                    .tabItem {
                        Label("Pantry", systemImage: "cabinet")
                    }
                
                MenuListView(collections: collections)
                .tabItem {
                    Label("Menu", systemImage: "fork.knife")
                }
                
                NavigationStack {
                    CookbookView()
                }
                .tabItem {
                    Label("Cookbook", systemImage: "book")
                }
            }
        }
        .task {
            for await items: [PantryItem] in convex.subscribe(to: "items:get")
                .replaceError(with: []).values
            {
                self.items = items
            }
        }
        .task {
            for await collections: [RecipeCollection] in convex.subscribe(to: "recipes:getCollections")
                .replaceError(with: []).values
            {
                self.collections = collections
            }
        }
    }
}

#Preview {
    ContentView()
}
