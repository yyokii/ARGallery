//
//  Home.swift
//  ARGalleryApp
//
//  Created by Higashihara Yoki on 2021/10/07.
//

import ARKit
import SwiftUI
import SceneKit
import PhotosUI

import ImagePickerFeature
import SwiftUIHelpers

public struct Home: View {
    @State var isPresentedImagePicker = false

    @StateObject var vm = HomeViewModel()

    @State private var selectedPickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage =  UIImage(named: "dotcat", in: .module, with: nil)!

    public init() {}

    public var body: some View {
        ZStack(alignment: .top) {
            ARSceneView(
                session: $vm.arSession,
                scene: $vm.scene,
                selectedImage: $selectedImage
            )
            VStack {
                ProgressView(progress: $vm.progress,
                             progressTintColor: .blue)

                Spacer()

                Image(uiImage: vm.selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height:150)

                PhotosPicker("Select image", selection: $selectedPickerItem, matching: .images)
            }
        }
        .sheet(isPresented: $isPresentedImagePicker) {
            PHPickerView(configuration: vm.pickerConfig,
                         selectedImage: $vm.selectedImage,
                         progress: $vm.progress)
        }
        .onChange(of: selectedPickerItem) { _ in
            Task {
                if let data = try? await selectedPickerItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data),
                    let rotatedImage = uiImage.reorientToUp() {
                        selectedImage = rotatedImage
                        return
                    }
                }

                print("📝 Failed")
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
