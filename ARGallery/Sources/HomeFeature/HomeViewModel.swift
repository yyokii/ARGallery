//
//  HomeViewModel.swift
//  
//
//  Created by Higashihara Yoki on 2021/10/09.
//

import ARKit
import Combine
import PhotosUI

final class HomeViewModel: ObservableObject {
    
    // AR
    var arSession: ARSession
    var scene: SCNScene
    var isPlacedImage: Bool = false
    
    // Picker
    let pickerConfig: PHPickerConfiguration
        
    // Picking Image Progress
    var progress: Progress?

    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Setup picker configuration
        var pickerConfig = PHPickerConfiguration(photoLibrary: .shared())
        pickerConfig.filter = .images
        pickerConfig.preferredAssetRepresentationMode = .current
        pickerConfig.selection = .ordered
        pickerConfig.selectionLimit = 1
        self.pickerConfig = pickerConfig
        
        //  Setup AR configuration
        let arSession = ARSession()
        let trackingConfig = ARWorldTrackingConfiguration()
        trackingConfig.planeDetection = .vertical
        arSession.run(trackingConfig)
        self.arSession = arSession
        self.scene = SCNScene()
    }
}

