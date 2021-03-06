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

extension Vector {
    static let up = Vector(0, 1, 0)
}

infix operator •: MultiplicationPrecedence
func •(lhs: Vector, rhs: Vector) -> Double {
    return dot(lhs, rhs)
}

struct Plane {
    var support_vector: Vector
    var normal_vector: Vector
}

extension Plane {
    init(at position: Vector, direction: Vector) {
        support_vector = position
        normal_vector = direction.normalized
    }
}

struct Sphere {
    /// position in meter
    var position: Vector
    /// velicity in meter per second
    var velocity: Vector
    /// mass in kilogramm
    var mass: Scalar { return (4/3) * .pi * radius * radius * radius }
    /// radius in meter
    let radius: Scalar
    init(position: Vector, velocity: Vector = .zero, radius: Scalar = 0.5) {
        self.position = position
        self.velocity = velocity
        self.radius = radius
    }
    /// updates position and velocity of this `Sphere` using euler's method
    ///
    /// - Parameters:
    ///   - Δt: elapsed time in seconds
    ///   - world: current world configuration
    mutating func eulerUpdate(Δt: TimeInterval, world: World) {
        position += velocity * Δt
        velocity += world.gravity * Δt
    }
    /// updates position and velocity of this `Sphere` using middle point method
    ///
    /// - Parameters:
    ///   - Δt: elapsed time in seconds
    ///   - world: current world configuration
    mutating func midpointUpdate(Δt: TimeInterval, world: World) {
//      let estimated_position = position + velocity * 0.5 * Δt
        let estimated_velocity = velocity + world.gravity * 0.5 * Δt
        
        position += estimated_velocity * Δt
        velocity += world.gravity * Δt
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
        return (position - other.support_vector) • other.normal_vector - radius
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
        let nr = other.position - position
        
        let vn_s = nr * ((nr • velocity) / (nr • nr))
        let ve_s = velocity - vn_s
        
        let vn_o = nr * ((nr • other.velocity) / (nr • nr))
        let ve_o = other.velocity - vn_o
        
        let sum_mass = mass + other.mass
        
        let nun_s = 2 * other.mass * vn_o + (mass - other.mass) * vn_s
        let nun_o = 2 * mass * vn_s + (other.mass - mass) * vn_o
        
        let un_s = nun_s / sum_mass
        let un_o = nun_o / sum_mass
        
        velocity = un_s + ve_s
        other.velocity = un_o + ve_o
        
        let normalized_nr = simd_normalize(nr)
        
        let combined_vn_length = simd_length(vn_s) + simd_length(vn_o)
        let relative_velocitiy = combined_vn_length != 0 ? 2 * simd_length(vn_s) / combined_vn_length : 0
        let relative_other_velocitiy = combined_vn_length != 0 ? 2 * simd_length(vn_o) / combined_vn_length : 0
        
        position = position + relative_velocitiy * normalized_nr * distance(to: other)
        other.position = other.position - relative_other_velocitiy * normalized_nr * distance(to: other)
    }
    mutating func resolveCollision(with other: Plane, Δt: TimeInterval, world: World) -> Vector {
        //simd_reflect(other.normal_vector, self.velocity)
        let distance = self.distance(to: other)
        let collision_point = position - other.normal_vector * (distance + radius)
        position -= other.normal_vector * distance * 2
        velocity = reflect(velocity, n: other.normal_vector)
        
        let vn = other.normal_vector * ((other.normal_vector • velocity) / (other.normal_vector • other.normal_vector))
        let time_since_collision = abs(distance / simd_length(vn))
        let velocity_change_gravitation = time_since_collision * world.gravity
        velocity -= reflect(velocity_change_gravitation, n: other.normal_vector)
        velocity += velocity_change_gravitation
        
        return collision_point
    }
}

struct World {
    static let earth = World(gravity: .init(0, -9.807, 0), floorHeight: 0)
    static let moon = World(gravity: .init(0, -1.62 , 0), floorHeight: 0)
    static let zero = World(gravity: .init(0, 0 , 0), floorHeight: 0)
    /// gravity in meter per second
    let gravity: Vector
    /// floor plane height in meter
    let floorHeight: Scalar
}

protocol PhysicsEngineDelegate: AnyObject {
    func pyhsicEngine(
        _ engine: PhysicsEngine,
        didDetectCollisionBetween sphere: Sphere,
        sphereId: Int,
        and other: Sphere,
        otherId: Int,
        at collisionPoint: Vector
    )
    func pyhsicEngine(
        _ engine: PhysicsEngine,
        didDetectCollisionBetween sphere: Sphere,
        sphereId: Int,
        and other: Plane,
        at collisionPoint: Vector
    )
}

final class PhysicsEngine {
    enum Algorithm {
        case euler
        case midpoint
    }
    /// maximum delta time in seconds for one update
    static let maximumΔt: TimeInterval = 1/30
    
    static let `default` = PhysicsEngine()
    private(set) var world: World
    var algorithm: Algorithm = .midpoint
    private(set) var spheres: [Sphere] = []
    private(set) var planes: [Plane] = []
    weak var delegate: PhysicsEngineDelegate?
    init(world: World = .earth) {
        self.world = world
    }
    /// computes the new position and velocity of all spheres
    /// usually called during the render loop
    ///
    /// - Parameter elapsedTime: elapsed time in seconds since previous update
    func update(elapsedTime: TimeInterval) {
        let Δt = min(elapsedTime, PhysicsEngine.maximumΔt)
        
        updateSpheres(Δt: Δt)
        detectAndResolveCollsions(Δt: Δt)
    }
    
    private func updateSpheres(Δt: Scalar) {
        switch algorithm {
        case .euler:
            for i in spheres.indices {
                spheres[i].eulerUpdate(Δt: Δt, world: world)
            }
        case .midpoint:
            for i in spheres.indices {
                spheres[i].midpointUpdate(Δt: Δt, world: world)
            }
        }
    }
    private func detectAndResolveCollsions(Δt: Scalar) {
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
                    delegate?.pyhsicEngine(self, didDetectCollisionBetween: spheres[i], sphereId: i, and: other, otherId: iOther, at: collisionPoint)
                    
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
                    
                    // resolve collision
                    let collisionPoint = spheres[i].resolveCollision(with: plane, Δt: Δt, world: world)
                    // notify delegate
                    delegate?.pyhsicEngine(self, didDetectCollisionBetween: spheres[i], sphereId: i, and: plane, at: collisionPoint)
                }
            }
        }
    }
    
    func setConfig(_ config: PhysicsEngineConfig) {
        self.planes = config.planes
        self.spheres = config.spheres
        self.algorithm = config.algorithm
        self.world = config.world
    }
    func copy() -> PhysicsEngine {
        let engine = PhysicsEngine(world: world)
        engine.spheres = spheres
        engine.planes = planes
        engine.delegate = delegate
        engine.algorithm = algorithm
        return engine
    }
}
