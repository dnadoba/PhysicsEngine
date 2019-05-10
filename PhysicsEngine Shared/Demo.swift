//
//  Demo.swift
//  PhysicsEngine iOS
//
//  Created by David Nadoba on 07.05.19.
//  Copyright © 2019 David Nadoba. All rights reserved.
//

import Foundation

struct PhysicsEngineConfig {
    static let all: [PhysicsEngineConfig] = [
        .sphereOnly,
        .sphereWithStartVelocity,
        .sphereWithGravity,
        .sphereWithGravityAndFloor,
        .sphereWithStartVelocityAndGravityAndFloor,
        .sphereCollistion1D,
        .sphereCollistion2D,
        .sphereCollistion3D,
        .inclinedPlanes2D,
    ]
    static let `default` = PhysicsEngineConfig()
    static let sphereOnly = PhysicsEngineConfig().addSphere(at: .init(0, 3, 0))
    static let sphereWithStartVelocity = PhysicsEngineConfig.sphereOnly.setVelocityOfAllSpheres(.init(0.5, 0, 0))
    static let sphereWithGravity = PhysicsEngineConfig.sphereOnly.setWorld(.earth)
    static let sphereWithGravityAndFloor = PhysicsEngineConfig.sphereWithGravity.addPlane(at: .zero, direction: .up)
    static let sphereWithStartVelocityAndGravityAndFloor = PhysicsEngineConfig.sphereWithGravityAndFloor.setVelocityOfAllSpheres(.init(0.5, 0.5, 0))
    static let worldWithoutGravityAndPlaneOnTheLeftAndRight = PhysicsEngineConfig.default
        .addPlane(.init(at: Vector(4, 0, 0),    direction: Vector(-1, 0, 0)))
        .addPlane(.init(at: Vector(-4, 0, 0),   direction: Vector(1, 0, 0)))
    static let sphereCollistion1D = PhysicsEngineConfig.worldWithoutGravityAndPlaneOnTheLeftAndRight
        .addSphere(at: .init(2, 0, 0),  velocity: .init(-1, 0, 0))
        .addSphere(at: .init(-2, 0, 0), velocity: .init(1, 0, 0))
    static let worldWithoutGravityAndPlaneOnTheLeftRightTopAndBottom = PhysicsEngineConfig.worldWithoutGravityAndPlaneOnTheLeftAndRight
        .addPlane(.init(at: Vector(0, 4, 0),    direction: Vector(0, -1, 0)))
        .addPlane(.init(at: Vector(0, -4, 0),   direction: Vector(0, 1, 0)))
    static let sphereCollistion2D = PhysicsEngineConfig.worldWithoutGravityAndPlaneOnTheLeftRightTopAndBottom
        .addSphere(at: .init(2, 2, 0),  velocity: Vector(-1, -1, 0).normalized)
        .addSphere(at: .init(-2, -2, 0), velocity: Vector(1, 1, 0).normalized)
    static let worldWithoutGravityAndPlaneOnEachSide = PhysicsEngineConfig.worldWithoutGravityAndPlaneOnTheLeftRightTopAndBottom
        .addPlane(.init(at: Vector(0, 0, 4),    direction: Vector(0, 0, -1)))
        .addPlane(.init(at: Vector(0, 0, -4),   direction: Vector(0, 0, 1)))
    static let sphereCollistion3D = PhysicsEngineConfig.worldWithoutGravityAndPlaneOnTheLeftRightTopAndBottom
        .addSphere(at: .init(2, 2, 2),      velocity: Vector(-1, -1, -1).normalized)
        .addSphere(at: .init(-2, -2, -1),   velocity: Vector(1, 1, 1).normalized)
    static let worldWithoutGravityAndInclinedPlanes = PhysicsEngineConfig.default
        .addPlane(.init(at: Vector(-2, 2, 0),   direction: Vector(1, -1, 0)))
        .addPlane(.init(at: Vector(2, 2, 0),    direction: Vector(-1, -1, 0)))
        .addPlane(.init(at: Vector(2, -2, 0),    direction: Vector(-1, 1, 0)))
        .addPlane(.init(at: Vector(-2, -2, 0),    direction: Vector(1, 1, 0)))
    static let inclinedPlanes2D = PhysicsEngineConfig.worldWithoutGravityAndInclinedPlanes
        .addSphere(at: Vector(0, 2, 0), velocity: Vector(1, 0, 0))
    
    var planes: [Plane] = []
    var spheres: [Sphere] = []
    var world: World = .zero
}

extension PhysicsEngineConfig {
    func addSphere(_ sphere: Sphere) -> PhysicsEngineConfig {
        var copy = self
        copy.spheres.append(sphere)
        return copy
    }
    func setVelocityOfAllSpheres(_ velocity: Vector) -> PhysicsEngineConfig {
        var copy = self
        for i in copy.spheres.indices {
            copy.spheres[i].velocity = velocity
        }
        return copy
    }
    func addSphere(at position: Vector, velocity: Vector = .zero, radius: Scalar = 0.5) -> PhysicsEngineConfig {
        return addSphere(.init(position: position, velocity: velocity, radius: radius))
    }
    func addPlane(_ plane: Plane) -> PhysicsEngineConfig {
        var copy = self
        copy.planes.append(plane)
        return copy
    }
    func addPlane(at position: Vector, direction: Vector = .init(0, 1, 0)) -> PhysicsEngineConfig {
        return addPlane(.init(at: position, direction: direction))
    }
    func setWorld(_ world: World) -> PhysicsEngineConfig {
        var copy = self
        copy.world = world
        return copy
    }
}

