//
//  Demo.swift
//  PhysicsEngine iOS
//
//  Created by David Nadoba on 07.05.19.
//  Copyright © 2019 David Nadoba. All rights reserved.
//

import Foundation

struct DemoConfig {
    static let all: [DemoConfig] = [
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
    static let `default` = DemoConfig()
    static let sphereOnly = DemoConfig().addSphere(at: .init(0, 3, 0))
    static let sphereWithStartVelocity = DemoConfig.sphereOnly.setVelocityOfAllSpheres(.init(0, 0, 0.2))
    static let sphereWithGravity = DemoConfig.sphereOnly.setWorld(.earth)
    static let sphereWithGravityAndFloor = DemoConfig.sphereWithGravity.addPlane(at: .zero, direction: .up)
    static let sphereWithStartVelocityAndGravityAndFloor = DemoConfig.sphereWithGravityAndFloor.setVelocityOfAllSpheres(.init(0, 0.5, 0.5))
    static let worldWithoutGravityAndPlaneOnTheLeftAndRight = DemoConfig.default
        .addPlane(.init(at: Vector(4, 0, 0),    direction: Vector(-1, 0, 0)))
        .addPlane(.init(at: Vector(-4, 0, 0),   direction: Vector(1, 0, 0)))
    static let sphereCollistion1D = DemoConfig.worldWithoutGravityAndPlaneOnTheLeftAndRight
        .addSphere(at: .init(2, 0, 0),  velocity: .init(-1, 0, 0))
        .addSphere(at: .init(-2, 0, 0), velocity: .init(1, 0, 0))
    static let worldWithoutGravityAndPlaneOnTheLeftRightTopAndBottom = DemoConfig.worldWithoutGravityAndPlaneOnTheLeftAndRight
        .addPlane(.init(at: Vector(0, 4, 0),    direction: Vector(0, -1, 0)))
        .addPlane(.init(at: Vector(0, -4, 0),   direction: Vector(0, 1, 0)))
    static let sphereCollistion2D = DemoConfig.worldWithoutGravityAndPlaneOnTheLeftRightTopAndBottom
        .addSphere(at: .init(2, 2, 0),  velocity: Vector(-1, -1, 0).normalized)
        .addSphere(at: .init(-2, -2, 0), velocity: Vector(1, 1, 0).normalized)
    static let worldWithoutGravityAndPlaneOnEachSide = DemoConfig.worldWithoutGravityAndPlaneOnTheLeftRightTopAndBottom
        .addPlane(.init(at: Vector(0, 0, 4),    direction: Vector(0, 0, -1)))
        .addPlane(.init(at: Vector(0, 0, -4),   direction: Vector(0, 0, 1)))
    static let sphereCollistion3D = DemoConfig.worldWithoutGravityAndPlaneOnTheLeftRightTopAndBottom
        .addSphere(at: .init(2, 2, 2),      velocity: Vector(-1, -1, -1).normalized)
        .addSphere(at: .init(-2, -2, -1),   velocity: Vector(1, 1, 1).normalized)
    static let worldWithoutGravityAndInclinedPlanes = DemoConfig.default
        .addPlane(.init(at: Vector(-2, 2, 0),   direction: Vector(1, -1, 0)))
        .addPlane(.init(at: Vector(2, 2, 0),    direction: Vector(-1, -1, 0)))
        .addPlane(.init(at: Vector(2, -2, 0),    direction: Vector(-1, 1, 0)))
        .addPlane(.init(at: Vector(-2, -2, 0),    direction: Vector(1, 1, 0)))
    static let inclinedPlanes2D = DemoConfig.worldWithoutGravityAndInclinedPlanes
        .addSphere(at: Vector(0, 2, 0), velocity: Vector(1, 0, 0))
    
    var planes: [Plane] = []
    var spheres: [Sphere] = []
    var world: World = .zero
}

extension DemoConfig {
    func addSphere(_ sphere: Sphere) -> DemoConfig {
        var copy = self
        copy.spheres.append(sphere)
        return copy
    }
    func setVelocityOfAllSpheres(_ velocity: Vector) -> DemoConfig {
        var copy = self
        for i in copy.spheres.indices {
            copy.spheres[i].velocity = velocity
        }
        return copy
    }
    func addSphere(at position: Vector, velocity: Vector = .zero, radius: Scalar = 0.5) -> DemoConfig {
        return addSphere(.init(position: position, velocity: velocity, radius: radius))
    }
    func addPlane(_ plane: Plane) -> DemoConfig {
        var copy = self
        copy.planes.append(plane)
        return copy
    }
    func addPlane(at position: Vector, direction: Vector = .init(0, 1, 0)) -> DemoConfig {
        return addPlane(.init(at: position, direction: direction))
    }
    func setWorld(_ world: World) -> DemoConfig {
        var copy = self
        copy.world = world
        return copy
    }
}

