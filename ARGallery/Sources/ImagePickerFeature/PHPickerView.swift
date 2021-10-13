//
//  PHPickerView.swift
//  
//
//  Created by Higashihara Yoki on 2021/10/08.
//

import Foundation
import PhotosUI
import SwiftUI

import UIKitHelpers

/*
 PHPickerViewController: https://developer.apple.com/documentation/photokit/phpickerviewcontroller
 Selecting Photos and Videos in iOS:
 https://developer.apple.com/documentation/photokit/selecting_photos_and_videos_in_ios
 */
public struct PHPickerView: UIViewControllerRepresentable {
    let configuration: PHPickerConfiguration
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImage: UIImage
    @Binding var progress: Progress?
    
    public init(configuration: PHPickerConfiguration,
                selectedImage: Binding<UIImage>,
                progress: Binding<Progress?>) {
        self.configuration = configuration
        _selectedImage = selectedImage
        _progress = progress
    }

    public func makeUIViewController(context: Context) -> PHPickerViewController {
            let controller = PHPickerViewController(configuration: configuration)
            controller.delegate = context.coordinator
            return controller
    }

    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension PHPickerView {
    public class Coordinator: PHPickerViewControllerDelegate {
        private let parent: PHPickerView

        init(parent: PHPickerView) {
            self.parent = parent
        }
        
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            for image in results {
                parent.progress = image.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (selectedImage, error) in
                    if let error = error {
                        print("error: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let image = selectedImage as? UIImage else {
                        return
                    }
                    
                    let rotatedImage = image.reorientToUp()!
                    self?.parent.selectedImage = rotatedImage
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
