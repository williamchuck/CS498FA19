//
//  ViewController.swift
//  CS498VR_Final_Project
//
//  Created by Junli on 11/28/19.
//  Copyright © 2019 Junli Wu. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var moreinfo: UIButton!
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var close: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/scene.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        resetButton.isHidden = true
        moreinfo.isHidden = true
        close.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.detectionObjects = ARReferenceObject.referenceObjects(inGroupNamed: "Cup", bundle: Bundle.main)!

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        print("Remove nodes")
        print(sceneView.session.currentFrame?.anchors as Any)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //let node = SCNNode()
        if let objectAnchor = anchor as? ARObjectAnchor {
            print(objectAnchor.referenceObject.extent.x)
            let plane = SCNPlane(width: CGFloat(0.2 * 0.8), height: CGFloat(0.2 * 0.8))
            plane.cornerRadius = plane.width * 0.125
            let detail =   SCNPlane(width: CGFloat(0.3), height: CGFloat(0.3))
            detail.cornerRadius = detail.width * 0.125
            var detected = "None"
            var displayScene = SKScene.init()
            var detailScene = SKScene.init()
            moreinfo.backgroundColor = UIColor.lightGray
            resetButton.backgroundColor = UIColor.systemGreen
            resetButton.isHidden = false
            moreinfo.isHidden = false
            
            if(objectAnchor.referenceObject.name != nil){
                detected = objectAnchor.referenceObject.name!
            }
            
            print(objectAnchor.referenceObject.name as Any)
            //print(detected)
            if (detected != "None"){
                displayScene = SKScene(fileNamed: detected) != nil ? SKScene(fileNamed: detected)! : SKScene.init()
                detailScene = SKScene(fileNamed: detected + "_detail") != nil ? SKScene(fileNamed: detected + "_detail")! : SKScene.init()
                moreinfo.backgroundColor = UIColor.systemBlue
            
                //print(objectAnchor.referenceObject.name as Any)
                
                plane.firstMaterial?.diffuse.contents = displayScene
                plane.firstMaterial?.isDoubleSided = true
                plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
                detail.firstMaterial?.diffuse.contents = detailScene
                detail.firstMaterial?.isDoubleSided = true
                detail.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
                let planeNode = SCNNode(geometry: plane)
                let detailNode = SCNNode(geometry: detail)
                planeNode.name = detected + "_basic"
                detailNode.name = detected + "_detail"
                planeNode.position = SCNVector3Make(objectAnchor.referenceObject.center.x, objectAnchor.referenceObject.center.y + 0.1, objectAnchor.referenceObject.center.z)
                detailNode.position = SCNVector3Make(objectAnchor.referenceObject.center.x, objectAnchor.referenceObject.center.y + 0.1, objectAnchor.referenceObject.center.z)
                detailNode.isHidden = true
                node.addChildNode(planeNode)
                node.addChildNode(detailNode)
            }
        }
        //return node
    }
    
//    @IBAction func displaymi(_ sender: UIButton) {
//
//        let node = sceneView.scene.rootNode.childNode(withName: name, recursively: true)
//
//        let position = node.position
//        let newplane = SCNNode(geometry: plane)
//        newplane.position =
//
//    }

    @IBAction func moreinfo(_ sender: Any) {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            //node.removeFromParentNode()
            if (node.name != nil){
                if (node.name!.contains("detail")){
                    node.isHidden = false
                }
                else{
                    node.isHidden = true
                }
                moreinfo.isHidden = true
                close.isHidden = false
        }
        }
        
    }
    @IBAction func closeButton(_ sender: UIButton) {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            //node.removeFromParentNode()
            if (node.name != nil){
                if (node.name!.contains("detail")){
                    node.isHidden = true
                }
                else{
                    node.isHidden = false
                }
                resetButton.isHidden = false
                moreinfo.isHidden = false
                close.isHidden = true
        }
        }
    }
    @IBAction func reset(_ sender: UIButton) {
        print("FUCK you")
        if(sceneView.session.configuration != nil){
            sceneView.session.pause()
            sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                node.removeFromParentNode()
            }
            print(sceneView.scene.rootNode.childNodes)
            let configuration = ARWorldTrackingConfiguration()
            configuration.detectionObjects = ARReferenceObject.referenceObjects(inGroupNamed: "Cup", bundle: Bundle.main)!

            sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking, .stopTrackedRaycasts])
        }
        resetButton.backgroundColor = UIColor.darkGray
        resetButton.isHidden = true
        moreinfo.isHidden = true
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
}
