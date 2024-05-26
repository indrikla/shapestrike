//
//  ARManager.swift
//  nano2-cube
//
//  Created by Risa on 26/05/24.
//

import ARKit

class ARManager {
    static let shared = ARManager()
    
    private init() {
        sceneView = ARSCNView()
    }
    
    let sceneView: ARSCNView
}
