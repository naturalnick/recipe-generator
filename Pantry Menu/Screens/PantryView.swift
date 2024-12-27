//
//  PantryView.swift
//  Pantry Menu
//
//  Created by Nick Schaefer on 12/22/24.
//

import SwiftUI
import SwiftData
import ConvexMobile

struct PantryView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showingAddItem = false
    @State private var showingCamera = false
    
    @State private var image: CapturedImage?
    
    @State private var name = ""
    @FocusState private var fieldFocused: Bool
    @State private var currentItem: PantryItem?
    
    var items: [PantryItem]
    
    public func setStatus(id: String, status: StockStatus) {
        Task {
            try await convex.mutation("items:updateStatus", with: ["id": id, "status": status.rawValue])
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(items) { item in
                        PantryItemRow(item: item, setStatus: setStatus, toggleAddItem: toggleAddItem, currentItem: $currentItem, name: $name)
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                onSwipeStatus(id: item._id, status: .out)
                                onSwipeStatus(id: item._id, status: .low)
                                onSwipeStatus(id: item._id, status: .in_)
                            }
                    }
                    .onDelete(perform: deleteItems)
                }
                if showingAddItem {
                    VStack {
                        Button {
                            toggleAddItem()
                        } label: {
                            Color.clear
                        }
                        VStack {
                            HStack {
                                TextField("Pantry Item", text: $name)
                                    .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                                    .padding(.vertical)
                                    .focused($fieldFocused)
                                    .onAppear {
                                        self.fieldFocused = true
                                    }
                                    .submitLabel(.done)
                                    .onSubmit {
                                        if let currentItem {
                                            handleUpdateItem(id: currentItem._id, name: name)
                                        } else {
                                            handleAddItem(name: name)
                                        }
                                    }
                                Button {
                                    name = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 21))
                                        .tint(.gray)
                                }
                            }
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.gray.opacity(0.7)),
                                alignment: .bottom
                            )
                            HStack {
                                Button{
                                    toggleAddItem()
                                } label: {
                                    Text("Cancel")
                                        .frame(maxWidth: .infinity)
                                        .padding(10)
                                        .background(Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                
                                Button{
                                    if let currentItem {
                                        handleUpdateItem(id: currentItem._id, name: name)
                                    } else {
                                        handleAddItem(name: name)
                                    }
                                }label: {
                                    Text("Done")
                                        .frame(maxWidth: .infinity)
                                        .padding(10)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        .background(colorScheme == .dark ? Color.white : Color.black)
                    }
                }
            }
            .navigationTitle("Pantry")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button(action: { showingCamera.toggle() }) {
                            Image(systemName: "camera")
                        }
                        
                        Button(action: { showingAddItem.toggle() }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCamera) {
                CameraView { image in
                    self.image = image
                    showingCamera = false
                }
            }
            .sheet(item: $image) { capturedImage in
                PantryScanView(capturedImage: capturedImage.image)
            }
        }
    }
    
    private func handleAddItem(name: String) -> Void {
        guard !name.isEmpty else { return }
        Task {
            do {
                try await convex.mutation("items:create", with: ["name": name])
                toggleAddItem()
            } catch ClientError.ConvexError(let data) {
                let errorMessage = try! JSONDecoder().decode(String.self, from: Data(data.utf8))
                print("ERROR: \(errorMessage)")
            }
        }
    }
    
    private func handleUpdateItem(id: String, name: String) -> Void {
        Task {
        if name.isEmpty {
            try await convex.mutation("items:remove", with: ["id": id])
            toggleAddItem()
            return
        }
            do {
                try await convex.mutation("items:updateName", with: ["id": id, "name": name])
                toggleAddItem()
            } catch ClientError.ConvexError(data: let data) {
                print("error", data)
            }
        }
    }
    
    private func toggleAddItem() -> Void {
        if currentItem != nil {
            self.currentItem = nil
            self.name = ""
        }
        showingAddItem.toggle()
        fieldFocused.toggle()
    }
    
    private func onSwipeStatus(id: String, status: StockStatus) -> some View {
        Button {
            setStatus(id: id, status: status)
        } label: {
            VStack {
                Text(status.rawValue)
                    .font(.headline)
            }
        }
        .tint(status.color)
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                Task {
                    try await convex.mutation("items:remove", with: ["id": items[index]._id])
                }
            }
        }
    }
}

struct PantryItemRow: View {
    let item: PantryItem
    var setStatus: (String, StockStatus) -> Void
    var toggleAddItem: () -> Void
    @Binding var currentItem: PantryItem?
    @Binding var name: String
    
    var body: some View {
        Menu {
            Button {
                toggleAddItem()
                currentItem = item
                name = item.name
            } label: {
                Text("Rename")
            }
            
            Menu {
                Button("In Stock") {
                    setStatus(item._id, .in_)
                }
                Button("Running Low") {
                    setStatus(item._id, .low)
                }
                Button("Out of Stock") {
                    setStatus(item._id, .out)
                }
            } label: {
                Text("Set Status")
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                
                if (item.status != .in_) {
                    StatusBadge(status: item.status)
                }
            }
        }
    }
}

struct StatusBadge: View {
    let status: StockStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
    
    private var backgroundColor: Color {
        switch status {
        case .in_: return .green
        case .out: return .red
        case .low: return .orange
        }
    }
}

#Preview {
    PantryView(items: [PantryItem(_id: "test", name: "Apples", status: .low)])
}
