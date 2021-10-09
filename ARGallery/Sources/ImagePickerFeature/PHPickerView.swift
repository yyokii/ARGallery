//
//  PHPickerView.swift
//  
//
//  Created by Higashihara Yoki on 2021/10/08.
//

import Foundation
import PhotosUI
import SwiftUI

/*
 PHPickerViewController: https://developer.apple.com/documentation/photokit/phpickerviewcontroller
 Selecting Photos and Videos in iOS:
 https://developer.apple.com/documentation/photokit/selecting_photos_and_videos_in_ios
 */
public struct PHPickerView: UIViewControllerRepresentable {
    let configuration: PHPickerConfiguration
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImage: UIImage
    
    public init(configuration: PHPickerConfiguration,
                selectedImage: Binding<UIImage>) {
        self.configuration = configuration
        self._selectedImage = selectedImage
    }

    public func makeUIViewController(context: Context) -> PHPickerViewController {
            let controller = PHPickerViewController(configuration: configuration)
            controller.delegate = context.coordinator
            return controller
    }

    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension PHPickerView {
    public class Coordinator: PHPickerViewControllerDelegate {
        private let parent: PHPickerView

        init(_ parent: PHPickerView) {
            self.parent = parent
        }
        
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            for image in results {
                image.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (selectedImage, error) in
                    if let error = error {
                        print("error: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let wrapImage = selectedImage as? UIImage else {
                        return
                    }
                    
                    self?.parent.selectedImage = wrapImage
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
