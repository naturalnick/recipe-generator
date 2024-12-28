//
//  MenuGuide.swift
//  Pantry Menu
//
//  Created by Nick Schaefer on 12/27/24.
//

import SwiftUI

struct MenuGuide: View {
    @State private var selection: Int = 0
    @State private var mealType: MealType? = nil
    @State private var servingSize: Int? = 2
    @State private var dietary: [DietaryLabel] = []
    
    private func turnPage() {
        withAnimation {
            selection += 1
        }
    }
    
    var body: some View {
        TabView(selection: $selection) {
            VStack {
                Text("Meal Type")
                ForEach(MealType.allCases, id: \.self) { mealType in
                    Button {
                        self.mealType = mealType
                        turnPage()
                    } label: {
                        Text(mealType.rawValue.titlecased())
                            .padding()
                    }
                }
            }
            .tag(0)
            VStack {
                Text("Serving Size")
                ForEach(1...6, id: \.self) { number in
                    Button(action: {
                        self.servingSize = number
                        turnPage()
                    }) {
                        Text("\(number)")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .tag(1)
            VStack {
                Text("Dietary")
                ForEach(DietaryLabel.allCases, id: \.self) { dietary in
                    Button {
                        if let index = self.dietary.firstIndex(of: dietary) {
                            self.dietary.remove(at: index)
                        } else {
                            self.dietary.append(dietary)
                        }
//                        turnPage()
                    } label: {
                        Text(dietary.rawValue.titlecased())
                            .background(self.dietary.contains(where: { $0 == dietary }) ? Color.blue : Color.white)
                            .padding()
                    }
                }
            }
            .tag(2)
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

#Preview {
    MenuGuide()
}
