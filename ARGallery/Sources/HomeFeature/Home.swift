//
//  Home.swift
//  ARGalleryApp
//
//  Created by Higashihara Yoki on 2021/10/07.
//

import ARKit
import SwiftUI
import SceneKit

public struct Home: View {
    @State var session: ARSession
    @State var scene: SCNScene

    public init() {
        let session = ARSession()
        let configuration = ARWorldTrackingConfiguration()
        session.run(configuration)
        self.session = session
        self.scene = SCNScene()
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            ARSceneView(
                session: self.$session,
                scene: self.$scene
            )
        }
    }
}