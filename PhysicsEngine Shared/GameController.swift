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
    var collisionParticleSystem = SCNParticleSystem(named: "SceneKit Particle System.scnp", inDirectory: nil)
    
    init(sceneRenderer renderer: SCNSceneRenderer) {
        sceneRenderer = renderer
        let scene = SCNScene(named: "Art.scnassets/scene.scn")!
        self.scene = scene
        let sphereColors: [SCNColor] = [.red, .orange, .blue, .purple, .yellow, .cyan, .gray, .magenta, .green]
        spheres = zip(physicsEngine.spheres, 0...).map { (sphere, i) -> SCNNode in
            let geometry = SCNSphere(radius: CGFloat(sphere.radius))
            
            let color = sphereColors[i % sphereColors.count]
            if let material = geometry.firstMaterial {
                material.lightingModel = .physicallyBased
                material.metalness.contents = 0.3
                material.roughness.contents = 0.5
                material.diffuse.contents = color
            }
            
            
            let node = SCNNode(geometry: geometry)
            scene.rootNode.addChildNode(node)
            return node
        }
        
        let floor = SCNNode(geometry: SCNFloor())
        floor.simdPosition.y = Float(physicsEngine.world.floorHeight)
        scene.rootNode.addChildNode(floor)
        
        
        super.init()
        physicsEngine.delegate = self
        
        sceneRenderer.delegate = self
        
        sceneRenderer.scene = scene
    }
    
    func resetSimulation() {
        physicsEngine.reset()
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
        renderer.isPlaying = true
        // Called before each frame is rendered
        if let lastUpdateTime = self.lastUpdateTime {
            physicsEngine.update(elapsedTime: time - lastUpdateTime)
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

extension GameController: PhysicsEngineDelegate {
    func pyhsicEngine(_ engine: PhysicsEngine, didDetectCollisionBetween sphere: Sphere, and other: Sphere, at collisionPoint: Vector) {
        guard let collisionParticleSystem = collisionParticleSystem else {
            assertionFailure("could not load collision particle system")
            return
        }
        let collisionParticleNode = SCNNode()
        collisionParticleNode.simdPosition = simd_float3(collisionPoint)
        collisionParticleNode.addParticleSystem(collisionParticleSystem)
        scene.rootNode.addChildNode(collisionParticleNode)
        let duration = collisionParticleSystem.emissionDuration + collisionParticleSystem.emissionDurationVariation + collisionParticleSystem.particleLifeSpan + collisionParticleSystem.particleLifeSpanVariation
        collisionParticleNode.runAction(SCNAction.sequence([
            SCNAction.wait(duration: TimeInterval(duration)),
            SCNAction.removeFromParentNode(),
        ]))
        
    }
}
