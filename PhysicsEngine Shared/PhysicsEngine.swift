//
//  PhysicsEngine.swift
//  PhysicsEngine
//
//  Created by David Nadoba on 09.04.19.
//  Copyright © 2019 David Nadoba. All rights reserved.
//

import Foundation
import simd

typealias Scalar = Double
typealias Vector = SIMD3<Scalar>

struct Sphere {
    var position: Vector
    var velocity: Vector
    let radius: Scalar = 0.5

    mutating func update(Δt: TimeInterval, world: World) {
        velocity += world.gravity * Δt
        position += velocity * Δt
        // collision with floor plane
        if (position.y - radius) < world.floorHeight {
            position.y = world.floorHeight + radius
            velocity.y *= -1
        }
    }
}

struct World {
    static let earth = World(gravity: .init(0, -9.807, 0), floorHeight: 0)
    static let moon = World(gravity: .init(0, -1.62 , 0), floorHeight: 0)
    let gravity: Vector
    let floorHeight: Scalar
}

final class PhysicsEngine {
    static let maximumΔt: TimeInterval = 1/30
    static let `default` = PhysicsEngine()
    let world: World
    private(set) var spheres: [Sphere] = []
    init(world: World = .earth) {
        self.world = world
        self.reset()
    }
    func update(elapsedTime: TimeInterval) {
        let Δt = min(elapsedTime, PhysicsEngine.maximumΔt)
        for i in spheres.indices {
            spheres[i].update(Δt: Δt, world: world)
        }
    }
    func reset() {
        self.spheres = [
            Sphere(position: Vector(-2,   4,    2), velocity: Vector(0,0,0)),
            .init(position: .init(0,    5,      0), velocity: .zero),
            .init(position: .init(1,    3,      1), velocity: .zero),
            .init(position: .init(2,    4,      2), velocity: .zero),
        ]
    }
}
