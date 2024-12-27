import SwiftUI
import ConvexMobile

let convex = ConvexClient(deploymentUrl: Bundle.main.infoDictionary?["CONVEX_URL"] as? String ?? "")

struct ContentView: View {
    @State private var items: [PantryItem] = []
    @State private var currentTab = "Pantry"

    var body: some View {
        ZStack {
            TabView(selection: $currentTab) {
                PantryView(items: items)
                    .tabItem {
                        Label("Pantry", systemImage: "cabinet")
                    }
                    .tag("Pantry")
                
                
                NavigationStack {
                    MenuView()
                }
                .tabItem {
                    Label("Menu", systemImage: "fork.knife")
                }
                .tag("Menu")
                
                NavigationStack {
                    CookbookView()
                }
                .tabItem {
                    Label("Cookbook", systemImage: "book")
                }
                .tag("Cookbook")
                
            }
            VStack {
                Spacer()
                Button {
                    withAnimation(.easeInOut) {
                        currentTab = "Menu"
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(.black)
                            .frame(width: currentTab != "Menu" ? 103 : 100, height: currentTab != "Menu" ? 103 : 100)
                            .offset(y: currentTab == "Menu" ? 0 : 4)
                        Circle()
                            .stroke(.black, lineWidth: 2)
                            .fill(.blue)
                            .frame(width: 100, height: 100)
                        VStack {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 24, weight: .bold))
                            Text("Menu")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.white)
                    }
                }
                .offset(y: currentTab == "Menu" ? 10 : 5)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentTab)
            }
            .allowsHitTesting(false)
        }
        .task {
            for await items: [PantryItem] in convex.subscribe(to: "items:get")
                .replaceError(with: []).values
            {
                self.items = items
            }
        }
        
    }
}

#Preview {
    ContentView()
}
