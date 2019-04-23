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

extension Vector {
    func distance(to other: Vector) -> Scalar {
        return simd_distance(self, other)
    }
    var normalized: Vector {
        return normalize(self)
    }
}

struct Plane {
    var support_vector: Vector
    var normal_vector: Vector
}

struct Sphere {
    /// position in meter
    var position: Vector
    /// velicity in meter per second
    var velocity: Vector
    /// radius in meter
    let radius: Scalar = 0.5
    init(position: Vector, velocity: Vector = .zero) {
        self.position = position
        self.velocity = velocity
    }
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
            let belowFloor = world.floorHeight - (position.y - radius)
            position.y += belowFloor * 2
            velocity.y *= -1
        }
    }
    /// distance between `self` and the `other`
    ///
    /// - Parameter other: `Sphere`
    /// - Returns: distance between `self` and `other`. Can be negative if `self` and `other` overlap
    func distance(to other: Sphere) -> Scalar {
        let centerDistance = position.distance(to: other.position)
        return centerDistance - radius - other.radius
    }
    func distance(to other: Plane) -> Scalar {
        return simd_dot(position - other.support_vector, other.normal_vector) - radius
    }
    func collides(with other: Sphere) -> Bool {
        return distance(to: other) <= 0
    }
    func collides(with other: Plane) -> Bool {
        return distance(to: other) <= 0
    }
    func collisionPoint(with other: Sphere) -> Vector {
        return position + simd_normalize(other.position - position) * radius
    }
    func collisionPoint(with other: Plane) -> Vector {
        return .zero //fatalError("not implemented")
    }
    mutating func resolveCollision(with other: inout Sphere, Δt: TimeInterval, world: World) {
        let nr = other.position - self.position
        
        let vn_s = nr * (simd_dot(nr, self.velocity) / (pow(nr.x, 2) + pow(nr.y,2) + pow(nr.z, 2)))
        let ve_s = self.velocity - vn_s
        
        let vn_o = nr * (simd_dot(nr, other.velocity) / (pow(nr.x, 2) + pow(nr.y, 2) + pow(nr.z, 2)))
        let ve_o = other.velocity - vn_o
        
        self.velocity = vn_o + ve_s
        other.velocity = vn_s + ve_o
    }
    mutating func resolveCollision(with other: Plane, Δt: TimeInterval, world: World) -> Vector {
        //simd_reflect(other.normal_vector, self.velocity)
        let distance = self.distance(to: other)
        let collision_point = self.position - other.normal_vector * (distance + self.radius)
        self.position -= other.normal_vector * distance * 2
        self.velocity = reflect(velocity, n: other.normal_vector)
        
        return collision_point
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

protocol PhysicsEngineDelegate: AnyObject {
    func pyhsicEngine(_ engine: PhysicsEngine, didDetectCollisionBetween sphere: Sphere, and other: Sphere, at collisionPoint: Vector)
    func pyhsicEngine(_ engine: PhysicsEngine, didDetectCollisionBetween sphere: Sphere, and other: Plane, at collisionPoint: Vector)
}

final class PhysicsEngine {
    /// maximum delta time in seconds for one update
    static let maximumΔt: TimeInterval = 1/30
    
    static let `default` = PhysicsEngine()
    let world: World
    private(set) var spheres: [Sphere] = []
    private(set) var planes: [Plane] = []
    weak var delegate: PhysicsEngineDelegate?
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
        
        // check for collisions between all spheres exactly once
        for i in spheres.indices {
            // do not test collision with itself and skip all previous spheres
            let start = i + 1
            for iOther in start..<spheres.endIndex {
                var other = spheres[iOther]
                if spheres[i].collides(with: other) {
                    // collision detectet
                    // notify delegate
                    let collisionPoint = spheres[i].collisionPoint(with: other)
                    delegate?.pyhsicEngine(self, didDetectCollisionBetween: spheres[i], and: other, at: collisionPoint)
                    
                    // resolve collision
                    spheres[i].resolveCollision(with: &other, Δt: Δt, world: world)
                    spheres[iOther] = other
                }
            }
        }
        // check for collisions between speares and planes
        for i in spheres.indices {
            for plane in planes {
                if spheres[i].collides(with: plane) {
                    // collision detectet
                    // notify delegate
                    let collisionPoint = spheres[i].collisionPoint(with: plane)
                    delegate?.pyhsicEngine(self, didDetectCollisionBetween: spheres[i], and: plane, at: collisionPoint)
                    // resolve collision
                    spheres[i].resolveCollision(with: plane, Δt: Δt, world: world)
                }
            }
        }
    }
    func reset() {
        self.spheres = [
            //                      x     y       z
            Sphere(position: Vector(-2,   4,      2)),
            Sphere(position: Vector(-2.5, 6,      2)),
            Sphere(position: Vector(0,    5,      -0.3)),
            Sphere(position: Vector(0,    6,      0.4)),
            Sphere(position: Vector(1,    3,      1)),
            
            Sphere(position: Vector(2,    4,      2)),
            Sphere(position: Vector(2,    10,      2)),
            Sphere(position: Vector(2,    12,      2)),
            Sphere(position: Vector(0,    4,      2), velocity: Vector(0.1, 0, 1)),
            Sphere(position: Vector(-2,   3,    2.5), velocity: Vector(-0.1, 2, 1.5)),
        ]
        self.planes = [
            Plane.init(support_vector: .init(x: 0, y: 0, z: 0), normal_vector: .init(x: 0, y: 1, z: 0)),
            Plane.init(support_vector: .init(x: 0, y: 0, z: -5), normal_vector: .init(x: 0, y: 0, z: 1)),
            Plane.init(support_vector: .init(x: -5, y: 0, z: 0), normal_vector: .init(x: 1, y: 0, z: 0)),
            Plane.init(support_vector: .init(x: 5, y: 0, z: 0), normal_vector: .init(x: -1, y: 0, z: 0)),
            Plane.init(support_vector: .init(x: 0, y: 0, z: 5), normal_vector: .init(x: 0, y: 0, z: -1)),
            Plane.init(support_vector: .init(x: 0, y: 8, z: 0), normal_vector: Vector(x: -1, y: -1, z: 0).normalized),
        ]
    }
}
