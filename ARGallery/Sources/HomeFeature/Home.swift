//
//  Home.swift
//  ARGalleryApp
//
//  Created by Higashihara Yoki on 2021/10/07.
//

import ARKit
import SwiftUI
import SceneKit

import ImagePickerFeature

public struct Home: View {
    @State var isPresentedImagePicker = false
    @State var selectedImage: UIImage
    
    @StateObject var vm = HomeViewModel()
    
    public init() {
        self.selectedImage = UIImage(named: "dotcat", in: .module, with: nil)!
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            ARSceneView(
                session: $vm.arSession,
                scene: $vm.scene,
                selectedImage: $selectedImage
            )
            
            Button("Select Image") {
                isPresentedImagePicker.toggle()
            }
        }
        .sheet(isPresented: $isPresentedImagePicker) {
            PHPickerView(configuration: vm.pickerConfig,
                         selectedImage: $selectedImage)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
