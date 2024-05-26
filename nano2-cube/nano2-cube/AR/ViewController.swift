//
//  ViewController.swift
//  nano2-cube
//
//  Created by Risa on 26/05/24.
//

import UIKit
import SceneKit
import ARKit
import SwiftUI


class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    let drawingService = DrawingService()
    var hitCount: Binding<Int>? = nil
    
    var isBrushPressing: Bool = false {
        didSet {
            if isBrushPressing {
                drawingService.makeNewParentNode()
                
            } else {
                drawingService.applyPhysicsToNode()
            }
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = ARManager.shared.sceneView
        sceneView.frame = self.view.frame
        self.view.addSubview(sceneView)
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = drawingService
        sceneView.autoenablesDefaultLighting = true
        
        let mainScene = SCNScene()
        
        for (_, node) in drawingService.geometryNodes.enumerated() {
            mainScene.rootNode.addChildNode(node)
        }
        
        sceneView.scene = mainScene

        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    private func createParticleSystemProgrammatically() -> SCNParticleSystem {
        let particleSystem = SCNParticleSystem()
        particleSystem.birthRate = 700
        particleSystem.particleLifeSpan = 1.0
        particleSystem.emitterShape = SCNSphere(radius: 0.1)
        particleSystem.particleColor = UIColor.orange
        particleSystem.particleSize = 0.03
        particleSystem.spreadingAngle = 360
        particleSystem.blendMode = .additive
        return particleSystem
    }
    
    private func createParticleEffect(at position: SCNVector3) {
        let particleSystem = createParticleSystemProgrammatically()
        let particleNode = SCNNode()
        particleNode.position = position
        particleNode.addParticleSystem(particleSystem)
        sceneView.scene.rootNode.addChildNode(particleNode)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            particleNode.removeFromParentNode()
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.physicsBody?.categoryBitMask == 1 && contact.nodeB.physicsBody?.categoryBitMask == 2 {
            self.createParticleEffect(at: contact.nodeB.position)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                contact.nodeB.removeFromParentNode()
//                cubeRemainder -= 1
            }
        } else if contact.nodeA.physicsBody?.categoryBitMask == 2 && contact.nodeB.physicsBody?.categoryBitMask == 1 {
            self.createParticleEffect(at: contact.nodeA.position)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                contact.nodeA.removeFromParentNode()
//                cubeRemainder -= 1
            }
        }
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: any SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        let constants = Constants()
        
        let sphere = SCNNode()
        sphere.name = constants.sphereName
        sphere.geometry = SCNSphere(radius:0.04)
        sphere.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 1.1, green: 0.7, blue: 0.0, alpha: 1.0)
        
        if isBrushPressing {
            drawingService.addChildNode(node: sphere)
        }
    }
}
