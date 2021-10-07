//
//  ARSceneView.swift
//  ARGalleryApp
//
//  Created by Higashihara Yoki on 2021/10/07.
//

import ARKit
import SceneKit
import SwiftUI

struct ARSceneView: UIViewRepresentable {
    @Binding var session: ARSession
    @Binding var scene: SCNScene
    
    @Binding var grids: [GridNode]
    
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        
        #if DEBUG
        sceneView.showsStatistics = true
        sceneView.debugOptions = .showFeaturePoints
        #endif
        
        return sceneView
    }
    
    func makeCoordinator() -> Self.Coordinator {
        Self.Coordinator(scene: self.$scene, grids: self.$grids)
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        if uiView.session != self.session {
            uiView.session.delegate = nil
            uiView.session = self.session
            uiView.session.delegate = context.coordinator
            uiView.delegate = context.coordinator
        }
        uiView.scene = self.scene
    }
}

extension ARSceneView {
    final class Coordinator: NSObject {
        @Binding var scene: SCNScene
        @Binding var grids: [GridNode]

        init(scene: Binding<SCNScene>, grids: Binding<[GridNode]>) {
            self._scene = scene
            self._grids = grids
        }
    }
}

extension ARSceneView.Coordinator: ARSessionDelegate {}

extension ARSceneView.Coordinator: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
        let grid = GridNode(anchor: planeAnchor)
        self.grids.append(grid)
        node.addChildNode(grid)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
        let grid = self.grids
            .filter { grid in
                grid.anchor.identifier == planeAnchor.identifier
            }
            .first
        
        guard let foundGrid = grid else {
            return
        }
        
        foundGrid.update(anchor: planeAnchor)
    }
    
}
