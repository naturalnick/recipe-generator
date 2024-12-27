//
//  CameraView.swift
//  Pantry Menu
//
//  Created by Nick Schaefer on 12/22/24.
//

import AVFoundation
import SwiftUI

struct CapturedImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    let onImageCaptured: (CapturedImage) -> Void
    
    var body: some View {
        ZStack {
            CustomCameraView(onImageCaptured: onImageCaptured)
        }
        .ignoresSafeArea()
    }
}

struct CustomCameraView: UIViewControllerRepresentable {
    let onImageCaptured: (CapturedImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.showsCameraControls = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImageCaptured: onImageCaptured)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageCaptured: (CapturedImage) -> Void
        
        init(onImageCaptured: @escaping (CapturedImage) -> Void) {
            self.onImageCaptured = onImageCaptured
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                let capturedImage = CapturedImage(image: image)
                onImageCaptured(capturedImage)
            }
        }
    }
}

