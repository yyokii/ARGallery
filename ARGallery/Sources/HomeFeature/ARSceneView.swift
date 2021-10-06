//
//  ARSceneView.swift
//  ARGalleryApp
//
//  Created by Higashihara Yoki on 2021/10/07.
//

import ARKit
import SceneKit
import SwiftUI

struct ARSceneView {
    @Binding var session: ARSession
    @Binding var scene: SCNScene
}

extension ARSceneView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        
        #if DEBUG
        sceneView.showsStatistics = true
        #endif
        
        return sceneView
    }

    func makeCoordinator() -> Self.Coordinator {
        Self.Coordinator(scene: self.$scene)
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        if uiView.session != self.session {
            uiView.session.delegate = nil
            uiView.session = self.session
            uiView.session.delegate = context.coordinator
        }
        uiView.scene = self.scene
    }
}

extension ARSceneView {
    final class Coordinator: NSObject {
        @Binding var scene: SCNScene

        init(scene: Binding<SCNScene>) {
            self._scene = scene
        }
    }
}

extension ARSceneView.Coordinator: ARSessionDelegate {}
