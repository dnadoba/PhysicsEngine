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

extension RandomAccessCollection {
    subscript(safe i: Index) -> Element? {
        return indices.contains(i) ? self[i] : nil
    }
}
fileprivate let maxIterationCount = 100

class GameController: NSObject, SCNSceneRendererDelegate {
    let physicsEngine: PhysicsEngine = .default
    let spheres: [[SCNNode]]
    let scene: SCNScene
    let sceneRenderer: SCNSceneRenderer
    var collisionParticleSystem = SCNParticleSystem(named: "SceneKit Particle System.scnp", inDirectory: nil)

    
    init(sceneRenderer renderer: SCNSceneRenderer) {
        sceneRenderer = renderer
        let scene = SCNScene(named: "Art.scnassets/scene.scn")!
        self.scene = scene
        let sphereColors: [SCNColor] = [.red, .orange, .blue, .purple, .yellow, .cyan, .gray, .magenta, .green]
        
        spheres = zip(physicsEngine.spheres, 0...).map { (sphere, i) -> [SCNNode] in
            let geometry = SCNSphere(radius: CGFloat(sphere.radius))
            
            let color = sphereColors[(i + 5) % sphereColors.count]
            if let material = geometry.firstMaterial {
                material.lightingModel = .physicallyBased
                material.metalness.contents = 0.3
                material.roughness.contents = 0.5
                material.diffuse.contents = color
            }
            
            
            let node = SCNNode(geometry: geometry)
            
            return (0..<maxIterationCount).map { _ in
                let copy = node.clone()
                scene.rootNode.addChildNode(copy)
                return copy
            }
        }
        
        
        
        let oriantations: [SCNVector3] = [
            .init(-CGFloat.pi/2, 0, 0),
            .init(0, 0, 0),
            .init(0, CGFloat.pi/2, 0),
            .init(0, -CGFloat.pi/2, 0),
            .init(CGFloat.pi, 0, 0),
            .init(CGFloat.pi/2, 0, -CGFloat.pi/4),
        ]
        zip(physicsEngine.planes, zip(oriantations, 0...)).forEach { args in
            let (plane, (orientation, i)) = args
            let geometry = SCNPlane(width: 15, height: 15)
            geometry.heightSegmentCount = 100
            geometry.widthSegmentCount = 100
            
            let color = sphereColors[i % sphereColors.count]
            if let material = geometry.firstMaterial {
                material.lightingModel = .physicallyBased
                material.metalness.contents = 0.3
                material.roughness.contents = 0.5
                material.diffuse.contents = color
            }
            
        
            let node = SCNNode(geometry: geometry)
            node.eulerAngles = orientation
            node.position = .init(plane.support_vector)
            scene.rootNode.addChildNode(node)
        }

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
        
        let spheres = simulateUntilCollisionWithASphere(engine: physicsEngine.copy(), Δt: 1/60, maxIterationCount: maxIterationCount)
        physicsEngine.update(elapsedTime: 1/60)
        updateSpheresFromPhysicsEngine(spheres: spheres)
    }
    func updateSpheresFromPhysicsEngine(spheres: [Int: [Sphere]]) {
        for (id, sphereNodes) in self.spheres.enumerated() {
            for i in 0..<maxIterationCount {
                let node = sphereNodes[i]
                if let sphere = spheres[id]?[safe: i] {
                    node.position = SCNVector3(sphere.position)
                    node.opacity = (1 - CGFloat(i) / CGFloat(spheres[id]?.count ?? 1)) * 0.5
                    node.scale = SCNVector3(0.3, 0.3, 0.3)
                    if i == 0 {
                        node.opacity = 1
                        node.scale = SCNVector3(1, 1, 1)
                    }
                    node.isHidden = false
                } else {
                    node.isHidden = true
                }
            }
        }
    }
}

extension GameController: PhysicsEngineDelegate {
    func addCollisionParticleSystem(at collisionPoint: Vector) {
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
    func pyhsicEngine(_ engine: PhysicsEngine, didDetectCollisionBetween sphere: Sphere, sphereId: Int, and other: Plane, at collisionPoint: Vector) {
        addCollisionParticleSystem(at: collisionPoint)
    }
    
    func pyhsicEngine(_ engine: PhysicsEngine, didDetectCollisionBetween sphere: Sphere, sphereId: Int, and other: Sphere, otherId: Int, at collisionPoint: Vector) {
        addCollisionParticleSystem(at: collisionPoint)
    }
}


func makeLine(vertices: [SCNVector3], color: SCNColor) {
    let source = SCNGeometrySource(vertices: vertices)
    let element = SCNGeometryElement(indices: Array(vertices.indices), primitiveType: .line)
    
    let line = SCNGeometry(sources: [source], elements: [element])
    line.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
    line.firstMaterial?.diffuse.contents = color
}

class CallbackDelegate: PhysicsEngineDelegate {
    var spherersDidCollide: (Sphere, Int, Sphere, Int, Vector) -> () = { _,_,_,_,_ in }
    var sphererDidCollideWithPlane: (Sphere, Int, Plane, Vector) -> () = { _,_,_,_ in }
    func pyhsicEngine(_ engine: PhysicsEngine, didDetectCollisionBetween sphere: Sphere, sphereId: Int, and other: Sphere, otherId: Int, at collisionPoint: Vector) {
        spherersDidCollide(sphere, sphereId, other, otherId, collisionPoint)
    }
    func pyhsicEngine(_ engine: PhysicsEngine, didDetectCollisionBetween sphere: Sphere, sphereId: Int, and other: Plane, at collisionPoint: Vector) {
        sphererDidCollideWithPlane(sphere, sphereId, other, collisionPoint)
    }
}

func simulateUntilCollisionWithASphere(engine: PhysicsEngine, Δt: TimeInterval, maxIterationCount: Int = 10 * 60) -> [Int: [Sphere]] {
    var spheres : [Int: [Sphere]] = [:]
    var spheresThatDidCollide = Set<Int>()
    let delegate = CallbackDelegate()
    delegate.spherersDidCollide = { (sphere1, id1, sphere2, id2, collisionPoint) in
        spheresThatDidCollide.insert(id1)
        spheresThatDidCollide.insert(id2)
    }
    engine.delegate = delegate
    for _ in 0..<maxIterationCount {
        let spheresThatDidCollideInPreviousItteration = spheresThatDidCollide
        
        engine.update(elapsedTime: Δt)
        
        let spheresThatDidNotCollide = zip(engine.spheres.indices, engine.spheres)
            .filter({ !spheresThatDidCollideInPreviousItteration.contains($0.0) })
        
        for (i, sphere) in spheresThatDidNotCollide {
            spheres[i, default: []].append(sphere)
        }
        
        if spheresThatDidCollide.count == engine.spheres.count {
            break
        }
    }
    return spheres
}
