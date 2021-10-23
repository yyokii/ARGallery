//
//  ARSceneView.swift
//  ARGalleryApp
//
//  Created by Higashihara Yoki on 2021/10/07.
//

import ARKit
import SceneKit
import SwiftUI

import UIKitHelpers

// MARK: UIViewRepresentable

struct ARSceneView: UIViewRepresentable {
    @Binding var session: ARSession
    @Binding var scene: SCNScene
    
    @Binding var selectedImage: UIImage

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        
        // Set up gesture recognizer
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.pinched(gesture:)))
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped(gesture:)))
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        sceneView.delegate = context.coordinator
        
        #if DEBUG
        sceneView.showsStatistics = true
        sceneView.debugOptions = .showFeaturePoints
        #endif
        
        context.coordinator.sceneView = sceneView
        
        return sceneView
    }
    
    func makeCoordinator() -> Self.Coordinator {
        Self.Coordinator(parent: self)
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

// MARK: Coordinator

extension ARSceneView {
    final class Coordinator: NSObject {
        private var lastGestureScale: CGFloat = 1
        private var paintingNode: SCNNode?
        var sceneView: ARSCNView!
        
        private let parent: ARSceneView
        
        init(parent: ARSceneView) {
            self.parent = parent
        }
        
        @objc func pinched(gesture: UIPinchGestureRecognizer) {
            guard let paintingNode = paintingNode else {
                return
            }
            
            let newGestureScale: CGFloat = gesture.scale
            
            let diff = Float(newGestureScale - lastGestureScale)
            let currentScale = paintingNode.scale
            
            // Modify scale
            paintingNode.scale = SCNVector3Make(
                currentScale.x * (1 + diff),
                currentScale.y * (1 + diff),
                currentScale.z * (1 + diff)
            )
            
            lastGestureScale = newGestureScale
        }
        
        @objc func tapped(gesture: UITapGestureRecognizer) {
            placePainting()
        }
        
        func placePainting() {
            // Set up plane size
            let image = parent.selectedImage
            let shortSide: CGFloat = 0.3
            let imageSizeRatio: CGFloat = image.size.width / image.size.height
            var planeSize: (width: CGFloat, height: CGFloat) = (1, 1)
            if imageSizeRatio >= 1 {
                planeSize = (shortSide, imageSizeRatio*shortSide)
            } else {
                planeSize = (imageSizeRatio*shortSide, shortSide)
            }
            
            // Create paintingNode
            let planeGeometry = SCNPlane(width: planeSize.width, height: planeSize.height)
            let material = SCNMaterial()
            material.diffuse.contents = image
            planeGeometry.materials = [material]
            let paintingNode = SCNNode(geometry: planeGeometry)
            
            // Set up node position
            let position = SCNVector3(x: 0, y: 0, z: -0.7)
            let camera = sceneView.pointOfView!
            let nodePosition = camera.convertPosition(position, to: nil)
            
            paintingNode.position = nodePosition
            paintingNode.eulerAngles = camera.eulerAngles
            
            deleteCurrentPainting()
            parent.scene.rootNode.addChildNode(paintingNode)
            self.paintingNode = paintingNode
        }
        
        func deleteCurrentPainting() {
            paintingNode?.removeFromParentNode()
            paintingNode = nil
        }
    }
}

// MARK: ARSessionDelegate

extension ARSceneView.Coordinator: ARSessionDelegate {}

// MARK: ARSCNViewDelegate

extension ARSceneView.Coordinator: ARSCNViewDelegate {
    
}
