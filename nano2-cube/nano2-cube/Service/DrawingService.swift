//
//  DrawingServices.swift
//  nano2-cube
//
//  Created by Risa on 26/05/24.
//

import SceneKit
import ARKit

class DrawingService: NSObject, SCNPhysicsContactDelegate {
    let sceneView = ARManager.shared.sceneView
    var geometryNodes: [SCNNode] = []
    
    let geometries: [SCNGeometry] = [
        SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0),
        SCNCylinder(radius: 0.5, height: 1),
        SCNCone(topRadius: 0, bottomRadius: 0.5, height: 1),
        SCNPyramid(width: 1, height: 1, length: 1)
    ]
    
    override init() {
        super.init()
        sceneView.scene.physicsWorld.contactDelegate = self
        setupCubeNodes(count: Int.random(in: 5...10))
     }
    
    func randomizePosition(xRange: ClosedRange<Float>, yRange: ClosedRange<Float>, zRange: ClosedRange<Float>) -> SCNVector3 {
        let x = Float.random(in: xRange)
        let y = Float.random(in: yRange)
        let z = Float.random(in: zRange)
        return SCNVector3(x, y, z)
    }
    
    func randomColor() -> UIColor {
        return UIColor(
            red: CGFloat(Float.random(in: 0...1)),
            green: CGFloat(Float.random(in: 0...1)),
            blue: CGFloat(Float.random(in: 0...1)),
            alpha: 1.0
        )
    }
    
    func createGeometryNode(n: Int) -> SCNNode {
        let geometry = geometries[n]
        
        let material = SCNMaterial()
        material.diffuse.contents = randomColor()
        geometry.materials = [material]
        
        let node = SCNNode(geometry: geometry)
        node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        node.physicsBody?.categoryBitMask = 2
        node.physicsBody?.contactTestBitMask = 1
        node.position = randomizePosition(xRange: -2...2, yRange: -1...1, zRange: -0.7 ... -0.1)
        node.physicsBody?.velocity = SCNVector3(0, 0, 1) // Apply constant velocity in z-axis
        
        let floatingAction = SCNAction.repeatForever(SCNAction.sequence([
            SCNAction.move(by: randomizePosition(xRange: -0...0, yRange: -1...1, zRange: -0.5 ... -0.1), duration: 1.0),
            SCNAction.move(by: randomizePosition(xRange: -0...0, yRange: -1...1, zRange: -0.2 ... -0.1), duration: 1.0)
        ]))
        
        node.runAction(floatingAction)
        return node
    }

    func setupCubeNodes(count: Int) {
        for _ in 0..<count {
            let randomIndex = Int.random(in: 0..<geometries.count)
            let geoNode = createGeometryNode(n: randomIndex)
            geometryNodes.append(geoNode)
            sceneView.scene.rootNode.addChildNode(geoNode)
        }
    }
    
    func makeNewParentNode() {
        let node = SCNNode()
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    func addChildNode(node: SCNNode){
        guard let currentFrame = sceneView.session.currentFrame else {return}
        let camera = currentFrame.camera
        let transform = camera.transform
        var translationMatrix = matrix_identity_float4x4
        let cameraRelativePosition = SCNVector3(0,0,-0.1)
        translationMatrix.columns.3.x = cameraRelativePosition.x
        translationMatrix.columns.3.y = cameraRelativePosition.y
        translationMatrix.columns.3.z = cameraRelativePosition.z
        
        let modifiedMatrix = simd_mul(transform, translationMatrix)
        node.simdTransform = modifiedMatrix
        sceneView.scene.rootNode.childNodes.last?.addChildNode(node)
        
    }
    
    func lastAddedNode() -> SCNNode? {
        guard let lastNode = sceneView.scene.rootNode.childNodes.last else {
            return nil
        }
        
        return lastNode
    }
  
    func applyPhysicsToNode() {
        guard let node = lastAddedNode() else { return }
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.categoryBitMask = 1
        node.physicsBody?.contactTestBitMask = 2

        guard let currentFrame = sceneView.session.currentFrame else { return }
        let cameraTransform = currentFrame.camera.transform
        let matrix = SCNMatrix4(cameraTransform)
        let forwardDirection = SCNVector3(-matrix.m31, -matrix.m32, -matrix.m33)

        let forceMultiplier: Float = 10.0
        let scaledForwardDirection = SCNVector3(
            forwardDirection.x * forceMultiplier,
            forwardDirection.y * forceMultiplier,
            forwardDirection.z * forceMultiplier
        )

        node.physicsBody?.applyForce(scaledForwardDirection, asImpulse: true)
    }
}
