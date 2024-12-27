//
//  PantryScanView.swift
//  Pantry Menu
//
//  Created by Nick Schaefer on 12/22/24.
//

import SwiftUI
import ConvexMobile

struct ScannedItem: Identifiable {
    let id = UUID()
    var name: String
    var isSelected: Bool
}

struct ScanResponse: Decodable {
    var data: [String]?
    var error: String?
}

struct ScanError: Decodable {
    @ConvexInt
    var status: Int
    var message: String
}

struct ScanRequest: Codable, ConvexEncodable {
    var items: [String]
    
    func convexEncode() throws -> String {
        try (items as [ConvexEncodable?]).convexEncode()
    }
}

class ScanViewModel: ObservableObject {
    @Published var scannedItems: [ScannedItem] = []
    @Published var isAnalyzing = true
    @Published var error: String?
    
    func analyzeImage(_ image: UIImage) {
        isAnalyzing = true
        error = nil
        
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            error = "Failed to process image"
            isAnalyzing = false
            return
        }
        
        Task {
            let response: ScanResponse = try await convex.action("ai:scanImage", with: ["image": imageData.base64EncodedString()])
            
            if let error = response.error {
                print(error)
                return
            }
            
            guard let items = response.data else {return}
            print(items)
            await MainActor.run {
                scannedItems = items.map({ ScannedItem(name: $0, isSelected: true) })
                isAnalyzing = false
            }
        }
    }
}

struct PantryScanView: View {
    let capturedImage: UIImage
    @StateObject private var viewModel = ScanViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(uiImage: capturedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                
                if viewModel.isAnalyzing {
                    ProgressView("Analyzing image...")
                } else if !viewModel.scannedItems.isEmpty {
                    List {
                        ForEach($viewModel.scannedItems) { $item in
                            HStack {
                                Toggle(isOn: $item.isSelected) {
                                    TextField("Item name", text: $item.name)
                                        .textFieldStyle(.plain)
                                }
                                .toggleStyle(CustomCheckToggle())
                                
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                
                if viewModel.scannedItems.isEmpty && !viewModel.isAnalyzing {
                    VStack(spacing: 20) {
                        Text("No items found")
                        
                        Button("Try again?") {
                            
                        }
                    }
                }
                
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Scan Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add Items") {
                        addSelectedItems()
                        dismiss()
                    }
                    .disabled(viewModel.scannedItems.isEmpty || viewModel.isAnalyzing)
                }
            }
        }
        .onAppear {
            viewModel.analyzeImage(capturedImage)
        }
    }
    
    private func addSelectedItems() {
        Task {
            let selectedItems = viewModel.scannedItems.filter({ $0.isSelected })
            let scanRequest = ScanRequest(items: selectedItems.map { $0.name })
            try await convex.mutation("items:createMany", with: ["items": scanRequest])
        }
    }
}

struct CustomCheckToggle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.circle" : "circle")
                    .font(.system(size: 24))
                configuration.label
            }
        }
    }
}

#Preview {
    PantryScanView(capturedImage: UIImage())
}
