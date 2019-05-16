//
//  InterfaceController.swift
//  PhysicsEngine watchOS App Extension
//
//  Created by David Nadoba on 09.04.19.
//  Copyright © 2019 David Nadoba. All rights reserved.
//

import WatchKit
import SceneKit

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var scnInterface: WKInterfaceSCNScene!
    var gameController: GameController!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        gameController = GameController(sceneRenderer: scnInterface)
        gameController.previousDemo()
    }
    
    @IBAction func handleTap(_ gestureRecognizer: WKTapGestureRecognizer) {
        // Highlight the tapped nodes
        let p = gestureRecognizer.locationInObject()
        gameController.highlightNodes(atPoint: p)
    }
    @IBAction func handleDoubleTap(_ sender: Any) {
        gameController.resetSimulation()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
