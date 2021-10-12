//
//  ARSceneView.swift
//  ARGalleryApp
//
//  Created by Higashihara Yoki on 2021/10/07.
//

import ARKit
import SceneKit
import SwiftUI

// MARK: UIViewRepresentable

struct ARSceneView: UIViewRepresentable {
    @Binding var session: ARSession
    @Binding var scene: SCNScene
    
    @State var grids: [GridNode] = []
    @Binding var selectedImage: UIImage

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        
        let gestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped(gesture:)))
        sceneView.addGestureRecognizer(gestureRecognizer)
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
        var sceneView: ARSCNView!
        private let parent: ARSceneView
        
        init(parent: ARSceneView) {
            self.parent = parent
        }
        
        @objc func tapped(gesture: UITapGestureRecognizer) {
            let touchPosition = gesture.location(in: sceneView)
            
            guard let query = sceneView.raycastQuery(from: touchPosition, allowing: .existingPlaneGeometry, alignment: .vertical) else {
                return
            }
            
            let hitTestResults = parent.session.raycast(query)
            guard let hitTest = hitTestResults.first,
                  let anchor = hitTest.anchor as? ARPlaneAnchor,
                  let gridIndex = parent.grids.firstIndex(where: { $0.anchor == anchor }) else {
                return
            }
            addPainting(image: parent.selectedImage,
                        hitResult: hitTest,
                        grid: parent.grids[gridIndex])
        }
        
        func addPainting(image: UIImage, hitResult: ARRaycastResult, grid: GridNode) {
            // Set up plane size
            let shortSide: CGFloat = 0.3
            let imageSizeRatio: CGFloat = image.size.width / image.size.height
            var planeSize: (width: CGFloat, height: CGFloat) = (1, 1)
            if imageSizeRatio >= 1 {
                planeSize = (imageSizeRatio*shortSide, shortSide)
            } else {
                planeSize = (shortSide, imageSizeRatio*shortSide)
            }
            
            let planeGeometry = SCNPlane(width: planeSize.width, height: planeSize.height)
            let material = SCNMaterial()
            material.diffuse.contents = parent.selectedImage
            planeGeometry.materials = [material]

            let paintingNode = SCNNode(geometry: planeGeometry)
            paintingNode.transform = SCNMatrix4(hitResult.anchor!.transform)
            // 画像が見えるようにx軸に関して90度回転させる
            paintingNode.eulerAngles = SCNVector3(paintingNode.eulerAngles.x + (-Float.pi / 2), paintingNode.eulerAngles.y, paintingNode.eulerAngles.z)
            paintingNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)

            parent.scene.rootNode.addChildNode(paintingNode)
            grid.removeFromParentNode()
        }
    }
}

// MARK: ARSessionDelegate

extension ARSceneView.Coordinator: ARSessionDelegate {}

// MARK: ARSCNViewDelegate

extension ARSceneView.Coordinator: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
        let grid = GridNode(anchor: planeAnchor)
        parent.grids.append(grid)
        node.addChildNode(grid)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical else { return }
        let grid = parent.grids
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
