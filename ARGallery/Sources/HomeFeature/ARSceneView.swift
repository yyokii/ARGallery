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
    
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        
        let gestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped(gesture:)))
        sceneView.addGestureRecognizer(gestureRecognizer)
        
        #if DEBUG
        sceneView.showsStatistics = true
        sceneView.debugOptions = .showFeaturePoints
        #endif
        
        context.coordinator.sceneView = sceneView
        
        return sceneView
    }
    
    func makeCoordinator() -> Self.Coordinator {
        Self.Coordinator(scene: $scene, session: $session, grids: $grids)
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

// MARK: Coordinator

extension ARSceneView {
    final class Coordinator: NSObject {
        var sceneView: ARSCNView!
        @Binding var scene: SCNScene
        @Binding var session: ARSession
        @Binding var grids: [GridNode]

        init(scene: Binding<SCNScene>, session: Binding<ARSession>, grids: Binding<[GridNode]>) {
            _scene = scene
            _session = session
            _grids = grids
        }
        
        @objc func tapped(gesture: UITapGestureRecognizer) {
            // Get 2D position of touch event on screen
            let touchPosition = gesture.location(in: sceneView)
            
            // Translate those 2D points to 3D points using hitTest (existing plane)
            guard let query = sceneView.raycastQuery(from: touchPosition, allowing: .existingPlaneGeometry, alignment: .vertical) else {
                return
            }
            let hitTestResults = session.raycast(query)
            
//            let hitTestResults = sceneView.hitTest(touchPosition, types: .existingPlaneUsingExtent)

            // Get hitTest results and ensure that the hitTest corresponds to a grid that has been placed on a wall
            guard let hitTest = hitTestResults.first,
                  let anchor = hitTest.anchor as? ARPlaneAnchor,
                  let gridIndex = grids.firstIndex(where: { $0.anchor == anchor }) else {
                return
            }
            addPainting(hitTest, grids[gridIndex])
        }
        
        func addPainting(_ hitResult: ARRaycastResult, _ grid: GridNode) {
            let planeGeometry = SCNPlane(width: 0.2, height: 0.35)
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: "dotcat", in: .module, with: nil)
            planeGeometry.materials = [material]

            let paintingNode = SCNNode(geometry: planeGeometry)
            paintingNode.transform = SCNMatrix4(hitResult.anchor!.transform)
            // 画像が見えるようにx軸に関して90度回転させる
            paintingNode.eulerAngles = SCNVector3(paintingNode.eulerAngles.x + (-Float.pi / 2), paintingNode.eulerAngles.y, paintingNode.eulerAngles.z)
            paintingNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)

            scene.rootNode.addChildNode(paintingNode)
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
