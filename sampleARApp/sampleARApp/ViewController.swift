//
//  ViewController.swift
//  sampleARApp
//
//  Created by Elshad Karimov on 9/10/19.
//  Copyright © 2019 Elshad Karimov. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var objectArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    
        //let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        let sphere = SCNSphere(radius: 0.2)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg") //UIColor.green
        
        sphere.materials = [material]
        
        let node = SCNNode()
        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
        node.geometry = sphere
        sceneView.scene.rootNode.addChildNode(node)
        sceneView.autoenablesDefaultLighting = true
        
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ARWorldTrackingConfiguration.isSupported {
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal

            // Run the view's session
            sceneView.session.run(configuration)
        } else {
            //notify user that it is nor supportted
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
            
        } else {
            return
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
//            if !results.isEmpty { //is not empty
//                print("touch is detected")
//            } else {
//                print("touched somewhere else")
//            }
            
            if let hitResult = results.first {
                let shipScene = SCNScene(named: "art.scnassets/ship.scn")
                if let shipNode = shipScene?.rootNode.childNode(withName: "Ship", recursively: true) {
                    shipNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y + shipNode.boundingSphere.radius
                        ,hitResult.worldTransform.columns.3.z)
                    
                    objectArray.append(shipNode)
                    
                    sceneView.scene.rootNode.addChildNode(shipNode)
                    
                    let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
                    
                    let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
                    
                    shipNode.runAction(
                        SCNAction.rotateBy(
                            x: CGFloat(randomX * 5),
                            y: 0,
                            z: CGFloat(randomZ * 5),
                            duration: 0.5))
                }
            }
        }
    }
    
    
    @IBAction func removeObjects(_ sender: UIBarButtonItem) {
        if !objectArray.isEmpty {
            for node in objectArray {
                node.removeFromParentNode()
            }
        }
    }
    
 
}
