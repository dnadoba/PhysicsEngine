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
    /// position in meter
    var position: Vector
    /// velicity in meter per second
    var velocity: Vector
    /// radius in meter
    let radius: Scalar = 0.5
    
    /// updates position and velocity of this `Sphere`
    ///
    /// - Parameters:
    ///   - Δt: elapsed time in seconds
    ///   - world: current world configuration
    mutating func update(Δt: TimeInterval, world: World) {
        velocity += world.gravity * Δt
        position += velocity * Δt
        
        // collision with floor plane
        if (position.y - radius) < world.floorHeight {
            // reset the position to be above (or on) the floor plane
            position.y = world.floorHeight + radius
            velocity.y *= -1
        }
    }
    mutating func collision(with other: inout Sphere, Δt: TimeInterval, world: World) {
        let nr = other.velocity - self.velocity
        
        let general_vn_s = simd_dot(nr, self.velocity) / (pow(nr.x, 2) + pow(nr.y, 2) + pow(nr.z, 2) )
        let vn_s = nr * general_vn_s
        let ve_s = self.velocity - vn_s
        
        let general_vn_o = simd_dot(nr, other.velocity) / (pow(nr.x, 2) + pow(nr.y, 2) + pow(nr.z, 2) )
        let vn_o = nr * general_vn_o
        let ve_o = other.velocity - vn_o
        
        self.velocity = vn_o + ve_s
        other.velocity = vn_s + ve_o
    }
}

struct World {
    static let earth = World(gravity: .init(0, -9.807, 0), floorHeight: 0)
    static let moon = World(gravity: .init(0, -1.62 , 0), floorHeight: 0)
    /// gravity in meter per second
    let gravity: Vector
    /// floor plane height in meter
    let floorHeight: Scalar
}

final class PhysicsEngine {
    /// maximum delta time in seconds for one update
    static let maximumΔt: TimeInterval = 1/30
    
    static let `default` = PhysicsEngine()
    let world: World
    private(set) var spheres: [Sphere] = []
    
    init(world: World = .earth) {
        self.world = world
        self.reset()
    }
    /// computes the new position and velocity of all spheres
    /// usually called during the render loop
    ///
    /// - Parameter elapsedTime: elapsed time in seconds since previous update
    func update(elapsedTime: TimeInterval) {
        let Δt = min(elapsedTime, PhysicsEngine.maximumΔt)
        for i in spheres.indices {
            spheres[i].update(Δt: Δt, world: world)
        }
    }
    func reset() {
        self.spheres = [
            //                      x     y       z
            Sphere(position: Vector(-2,   4,      2), velocity: Vector(0,0,0)),
            Sphere(position: Vector(0,    5,      0), velocity: .zero),
            Sphere(position: Vector(1,    3,      1), velocity: .zero),
            Sphere(position: Vector(2,    4,      2), velocity: .zero),
            Sphere(position: Vector(0,    4,      2), velocity: Vector(0.1, 0, 1)),
            Sphere(position: Vector(-2,   3,    2.5), velocity: Vector(-0.1, 2, 1.5)),
        ]
    }
}
