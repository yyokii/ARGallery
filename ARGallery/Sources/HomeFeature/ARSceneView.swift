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

struct CubicObject {
    var position: CGPoint
}

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
        
        /**
         Place an image in space.
         The node hierarchy is as follows
         
         paintingNode
            - image
            - frameNode
                - leftFrameNode
                - TopFrameNode
                - ...
            - (others)
         */
        private func placePainting() {
            deleteCurrentPainting()

            let paintingSize = computePaintingSize()
            let capture = sceneView.snapshot()
            
            // Create nodes
            let paintingNode = createPaintingNode(paintingSize: paintingSize)
            let frameNode = createFrameNode(contentWith: Float(paintingSize.width), contentHeight: Float(paintingSize.height))
            let objectNode = createCubicObjectNodes(of: paintingSize, capturedImage: capture)
            
            // Add nodes
            paintingNode.addChildNode(frameNode)
            paintingNode.addChildNode(objectNode)
            
            parent.scene.rootNode.addChildNode(paintingNode)
            self.paintingNode = paintingNode
        }
        
        func computePaintingSize() -> CGSize {
            let image = parent.selectedImage
            let shortSide: CGFloat = 0.3
            let imageSizeRatio: CGFloat = image.size.width / image.size.height
            var planeSize: CGSize = .init(width: 0, height: 0)
            if imageSizeRatio >= 1 {
                planeSize = .init(width: shortSide, height: imageSizeRatio*shortSide)
            } else {
                planeSize = .init(width: imageSizeRatio*shortSide, height: shortSide)
            }
            return planeSize
        }
        
        func createPaintingNode(paintingSize: CGSize) -> SCNNode {
            // Create paintingNode
            let planeGeometry = SCNPlane(width: paintingSize.width, height: paintingSize.height)
            let material = SCNMaterial()
            material.diffuse.contents = parent.selectedImage
            planeGeometry.materials = [material]
            let paintingNode = SCNNode(geometry: planeGeometry)
            
            // Set up node position
            let position = SCNVector3(x: 0, y: 0, z: -0.7)
            let camera = sceneView.pointOfView!
            let nodePosition = camera.convertPosition(position, to: nil)
            
            paintingNode.position = nodePosition
            paintingNode.eulerAngles = camera.eulerAngles
            
            return paintingNode
        }
        
        func createFrameNode(contentWith: Float, contentHeight: Float) -> SCNNode {
            // Set up parent frame node
            let framePosition = SCNVector3(x: 0, y: 0, z: 0)
            let frameNode = SCNNode()
            frameNode.position = framePosition
            
            // Set up frames
            let frameWidth: CGFloat = 0.02
            let frameHeight: CGFloat = CGFloat(contentHeight)
            let frameLength: CGFloat = 0.01
            let texture =  UIImage(named:"texture_wood_dark", in: .module, with: nil)
            let absPositionX: Float = contentWith/2 + Float(frameWidth)/2
            let absPositionY: Float = contentHeight/2 + Float(frameWidth)/2
            
            let leftFrameGeometry = SCNBox(width: frameWidth, height: frameHeight, length: frameLength, chamferRadius: 0)
            leftFrameGeometry.firstMaterial?.diffuse.contents = texture
            let leftFrameNode = SCNNode(geometry: leftFrameGeometry)
            let leftFramePosition = SCNVector3(x: -(absPositionX), y: 0, z: 0)
            leftFrameNode.position = leftFramePosition
            
            let topFrameGeometry = SCNBox(width: frameWidth, height: CGFloat(contentWith) + frameWidth * 2, length: frameLength, chamferRadius: 0)
            topFrameGeometry.firstMaterial?.diffuse.contents = texture
            let topFrameNode = SCNNode(geometry: topFrameGeometry)
            let topFramePosition = SCNVector3(x: 0, y: absPositionY, z: 0)
            topFrameNode.eulerAngles.z = .pi/2
            topFrameNode.position = topFramePosition
            
            let rightFrameGeometry = SCNBox(width: frameWidth, height: frameHeight, length: frameLength, chamferRadius: 0)
            rightFrameGeometry.firstMaterial?.diffuse.contents = texture
            let rightFrameNode = SCNNode(geometry: rightFrameGeometry)
            let rightFramePosition = SCNVector3(x: absPositionX, y: 0, z: 0)
            rightFrameNode.position = rightFramePosition
            
            let bottomFrameGeometry = SCNBox(width: frameWidth, height: CGFloat(contentWith) + frameWidth * 2, length: frameLength, chamferRadius: 0)
            bottomFrameGeometry.firstMaterial?.diffuse.contents = texture
            let bottomFrameNode = SCNNode(geometry: bottomFrameGeometry)
            let bottomFramePosition = SCNVector3(x: 0, y: -absPositionY, z: 0)
            bottomFrameNode.eulerAngles.z = .pi/2
            bottomFrameNode.position = bottomFramePosition
            
            // Add nodes
            frameNode.addChildNode(leftFrameNode)
            frameNode.addChildNode(topFrameNode)
            frameNode.addChildNode(rightFrameNode)
            frameNode.addChildNode(bottomFrameNode)
            
            return frameNode
        }
        
        private func createCubicObjectNodes(of painting: CGSize, capturedImage: UIImage) -> SCNNode {
            // Set up parent frame node
            let surroundingObjectsNode = SCNNode()
            surroundingObjectsNode.position = SCNVector3(x: 0, y: 0, z: 0)
            
            // Set up objects
            let size: CGFloat = .random(in: 0.05...0.07)
            
            let objects: [CubicObject] = [
                .init(position: .init(x: -(painting.width/2), y: painting.height/2)),
                .init(position: .init(x: -(painting.width/2), y: -painting.height/2)),
                .init(position: .init(x: painting.width/2, y: painting.height/2)),
                .init(position: .init(x: painting.width/2, y: -painting.height/2))
            ]
            
            for object in objects {
                let geometry = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
                geometry.firstMaterial?.diffuse.contents = capturedImage
                let node = SCNNode(geometry: geometry)
                let position = SCNVector3(x: Float(object.position.x), y: Float(object.position.y), z: 0)
                node.position = position
                let rotateOne = SCNAction.rotateBy(x: .random(in: 5...10), y: .random(in: 5...10), z: .random(in: 5...10), duration: 20.0)
                let repeatForever = SCNAction.repeatForever(rotateOne)
                node.runAction(repeatForever)
                surroundingObjectsNode.addChildNode(node)
            }
            
            let rotateOne = SCNAction.rotateBy(x: .random(in: 0...10), y: .random(in: 15...20), z: .random(in: 15...20), duration: 20.0)
            let repeatForever = SCNAction.repeatForever(rotateOne)
            surroundingObjectsNode.runAction(repeatForever)
            
            return surroundingObjectsNode
        }
        
        private func deleteCurrentPainting() {
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
