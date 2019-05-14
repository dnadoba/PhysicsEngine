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
        .someSpheresAndSomePlanes,
        .sebSingleSphere,
        .sebMovingSingleSphere,
        .sebTwoSpheresSameMass,
        .sebTwoSpheresDifferentMass,
        .sebTwoSpheresNotAligned,
        .sebTwoPlanesSingleSphere,
        .sebThreePlanesSingleSphere,
        .sebPresentAllTogether
    ]
    static let `default` = PhysicsEngineConfig()
    static let sphereOnly = PhysicsEngineConfig().addSphere(at: .init(0, 3, 0))
    static let sphereWithStartVelocity = PhysicsEngineConfig.sphereOnly.setVelocityOfAllSpheres(.init(0.5, 0, 0))
    static let sphereWithGravity = PhysicsEngineConfig.sphereOnly.setWorld(.earth)
    static let sphereWithGravityAndFloor = PhysicsEngineConfig.sphereWithGravity.addPlane(at: .zero, direction: .up)
    static let sphereWithStartVelocityAndGravityAndFloor = PhysicsEngineConfig.default
        .addSphere(at: .init(-5, 3, 0))
        .setVelocityOfAllSpheres(.init(0.5, 0.5, 0))
        .setWorld(.earth)
        .addPlane(at: .zero, direction: .up)
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
    static let sphereCollistion3D = PhysicsEngineConfig.worldWithoutGravityAndPlaneOnEachSide
        .addSphere(at: .init(2, 2, 2),      velocity: Vector(-1, -1, -1).normalized)
        .addSphere(at: .init(-2, -2, -1),   velocity: Vector(1, 1, 1).normalized)
    static let worldWithoutGravityAndInclinedPlanes = PhysicsEngineConfig.default
        .addPlane(.init(at: Vector(-2, 2, 0),   direction: Vector(1, -1, 0)))
        .addPlane(.init(at: Vector(2, 2, 0),    direction: Vector(-1, -1, 0)))
        .addPlane(.init(at: Vector(2, -2, 0),    direction: Vector(-1, 1, 0)))
        .addPlane(.init(at: Vector(-2, -2, 0),    direction: Vector(1, 1, 0)))
    static let inclinedPlanes2D = PhysicsEngineConfig.worldWithoutGravityAndInclinedPlanes
        .addSphere(at: Vector(0, 2, 0), velocity: Vector(1, 0, 0))
    static let someSpheresAndSomePlanes = PhysicsEngineConfig
        .default
        .setWorld(.earth)
        .addSphere(Sphere(position: Vector(-2,   4,      2.1)))
        .addSphere(Sphere(position: Vector(-2.1, 0.9,      2)))
        .addSphere(Sphere(position: Vector(-4,   1.1,      1.9)))
        .addSphere(Sphere(position: Vector(-3.1,   4,      1)))
        .addPlane(Plane(support_vector: .init(x: 0, y: 0, z: 0), normal_vector: .init(x: 0, y: 1, z: 0)))
        .addPlane(Plane(support_vector: .init(x: 0, y: 0, z: -5), normal_vector: .init(x: 0, y: 0, z: 1)))
        .addPlane(Plane(support_vector: .init(x: -5, y: 0, z: 0), normal_vector: .init(x: 1, y: 0, z: 0)))
        .addPlane(Plane(support_vector: .init(x: 5, y: 0, z: 0), normal_vector: .init(x: -1, y: 0, z: 0)))
        .addPlane(Plane(support_vector: .init(x: 0, y: 0, z: 5), normal_vector: .init(x: 0, y: 0, z: -1)))
        .addPlane(Plane(support_vector: .init(x: 0, y: 8, z: 0), normal_vector: Vector(x: -1, y: -1, z: 0).normalized))
        .setIterationCount(200)
    
    static let sebDefault = PhysicsEngineConfig
        .default
        .setWorld(.earth)
        .addPlane(.init(at: .zero, direction: Vector(0, 1, 0)))
    static let sebSingleSphere = sebDefault
        .addSphere(at: .init(0, 3, 0),  velocity: .zero)
    static let sebMovingSingleSphere = sebDefault
        .addSphere(at: .init(-5, 3, 0),  velocity: Vector(2, 0, 0))
    static let sebTwoSpheresSameMass = sebDefault
        .addSphere(at: .init(0, 3, 0),  velocity: .zero)
        .addSphere(at: .init(0, 5, 0),  velocity: .zero)
    static let sebTwoSpheresDifferentMass = sebDefault
        .addSphere(at: .init(0, 3, 0),  velocity: .zero, radius: 1)
        .addSphere(at: .init(0, 5, 0),  velocity: .zero)
    static let sebTwoSpheresNotAligned = sebDefault
        .addSphere(at: .init(0, 3, 0),  velocity: Vector(0, 7, 0))
        .addSphere(at: .init(0.1, 7, 0),  velocity: .zero)
    static let sebTwoPlanesSingleSphere = sebDefault
        .addSphere(at: .init(0, 3, 0),  velocity: Vector(5, 0, 0))
        .addPlane(.init(at: .init(-5, 5, 0), direction: Vector(1, 0, 0)))
        .addPlane(.init(at: .init(5, 5, 0), direction: Vector(-1, 0, 0)))
    static let sebThreePlanesSingleSphere = sebTwoPlanesSingleSphere
        .addPlane(.init(at: .init(-3, 3, 0), direction: Vector(1, 1, 0)))
    static let sebPresentAllTogether = sebTwoPlanesSingleSphere
        .addSphere(at: .init(-2, 4, 3),  velocity: Vector(1.4, 1.1, -3.2), radius: 1)
        .addSphere(at: .init(2, 2, 2),  velocity: Vector(-1.5, 3.2, -0.3), radius: 0.8)
        .addSphere(at: .init(1, 1, 1),  velocity: Vector(1.5, -3.2, -2.3))
        .addSphere(at: .init(2, 4, -2),  velocity: Vector(-1.5, 3.2, 0.3))
        .addPlane(.init(at: .init(0, 5, -5), direction: Vector(0, 0, 1)))
        .addPlane(.init(at: .init(0, 5, 5), direction: Vector(0, 0, -1)))
        .addPlane(.init(at: .init(-3, 3, -3), direction: Vector(1, 1, 1)))

    
    
    
    var planes: [Plane] = []
    var spheres: [Sphere] = []
    var world: World = .zero
    var iterationCount: Int = 1
    var dynamicΔt = true
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
    func setIterationCount(_ count: Int) -> PhysicsEngineConfig {
        var copy = self
        copy.iterationCount = count
        return copy
    }
}

