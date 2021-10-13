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
import SwiftUIHelpers

public struct Home: View {
    #warning("move to VM")
    @State var isPresentedImagePicker = false
    @State var selectedImage: UIImage
    
    @StateObject var vm = HomeViewModel()
    
    public init() {
        self.selectedImage = UIImage(named: "dotcat", in: .module, with: nil)!
    }
    
    #warning("現在選択されている画像を表示する")
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
                
                Button("Select Image") {
                    isPresentedImagePicker.toggle()
                }
            }
        }
        .sheet(isPresented: $isPresentedImagePicker) {
            PHPickerView(configuration: vm.pickerConfig,
                         selectedImage: $selectedImage,
                         progress: $vm.progress)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
