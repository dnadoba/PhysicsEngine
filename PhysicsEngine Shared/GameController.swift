//
//  GameController.swift
//  PhysicsEngine Shared
//
//  Created by David Nadoba on 09.04.19.
//  Copyright © 2019 David Nadoba. All rights reserved.
//

import SceneKit

#if os(watchOS)
    import WatchKit
#endif

#if os(macOS)
    typealias SCNColor = NSColor
#else
    typealias SCNColor = UIColor
#endif

class GameController: NSObject, SCNSceneRendererDelegate {
    let physicsEngine: PhysicsEngine = .default
    let spheres: [SCNNode]
    let scene: SCNScene
    let sceneRenderer: SCNSceneRenderer
    
    init(sceneRenderer renderer: SCNSceneRenderer) {
        sceneRenderer = renderer
        let scene = SCNScene(named: "Art.scnassets/scene.scn")!
        self.scene = scene
        spheres = physicsEngine.spheres.map { sphere -> SCNNode in
            let geometry = SCNSphere(radius: CGFloat(sphere.radius))
            let node = SCNNode(geometry: geometry)
            scene.rootNode.addChildNode(node)
            return node
        }
        
        super.init()
        
        sceneRenderer.delegate = self
        
        sceneRenderer.scene = scene
    }
    
    func highlightNodes(atPoint point: CGPoint) {
        let hitResults = self.sceneRenderer.hitTest(point, options: [:])
        for result in hitResults {
            // get its material
            guard let material = result.node.geometry?.firstMaterial else {
                return
            }
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = SCNColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = SCNColor.red
            
            SCNTransaction.commit()
        }
    }
    var lastUpdateTime: TimeInterval?
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Called before each frame is rendered
        if let lastUpdateTime = self.lastUpdateTime {
            physicsEngine.update(Δt: time - lastUpdateTime)
        }
        lastUpdateTime = time
        updateSpheresFromPhysicsEngine()
    }
    func updateSpheresFromPhysicsEngine() {
        for (node, sphere) in zip(spheres, physicsEngine.spheres) {
            node.simdPosition = SIMD3<Float>(sphere.position)
        }
    }
}
