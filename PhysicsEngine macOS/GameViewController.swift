//
//  GameViewController.swift
//  PhysicsEngine macOS
//
//  Created by David Nadoba on 09.04.19.
//  Copyright © 2019 David Nadoba. All rights reserved.
//

import Cocoa
import SceneKit

class GameViewController: NSViewController {
    
    @IBOutlet weak var gameView: SCNView!
    @IBOutlet weak var iterationCountSlider: NSSlider!
    @IBOutlet weak var dynamicΔtSegmentedControl: NSSegmentedControl!
    var gameController: GameController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameController = GameController(sceneRenderer: gameView)
        self.gameController.delegate = self
        
        // Allow the user to manipulate the camera
        self.gameView.allowsCameraControl = true
        
        // Show statistics such as fps and timing information
        self.gameView.showsStatistics = true
        
        // Configure the view
        self.gameView.backgroundColor = NSColor.black
        
        self.gameView.rendersContinuously = true
        
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = gameView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        self.gameView.gestureRecognizers = gestureRecognizers
    }
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // Highlight the clicked nodes
        let p = gestureRecognizer.location(in: gameView)
        gameController.highlightNodes(atPoint: p)
    }
    @IBAction func handleReset(_ sender: Any) {
        gameController.resetSimulation()
    }
    @IBAction func nextDemo(_ sender: Any) {
        gameController.nextDemo()
    }
    @IBAction func previousDemo(_ sender: Any) {
        gameController.previousDemo()
    }
    @IBAction func ΔtSelectionDidChange(_ sender: NSSegmentedControl) {
        gameController.dynamicΔt = sender.selectedSegment == 1
    }
    @IBAction func itterationCountSliderDidChange(_ sender: NSSlider) {
        gameController.iterationCount = sender.integerValue
    }
}

extension GameViewController: GameControllerDelegate {
    func gameController(_ gameController: GameController, didChangeConfig newConfig: PhysicsEngineConfig) {
        iterationCountSlider.integerValue = newConfig.iterationCount
        dynamicΔtSegmentedControl.selectedSegment = newConfig.dynamicΔt ? 1 : 0
    }
}
