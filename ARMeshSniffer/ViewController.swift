//
//  ViewController.swift
//  ARMeshSniffer
//
//  Created by Ethan on 09/12/2020.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var contentNode: SCNNode?
    var framesCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Verify a real device
        #if targetEnvironment(simulator)
        
        #error("ARKit is not supported in iOS Simulator. Connect a physical iOS device or select Generic iOS Device as a build-only destination.")
        
        #else

        // Verify true depth cam
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("ERROR: Device is not supporting TrueDepth camera (iPhone X and above required)")
        }

        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a Face-Tracking session configuration
        let configuration = ARFaceTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let sceneView = renderer as? ARSCNView, anchor is ARFaceAnchor else {
            return nil
        }
        
        // Render the face Mesh
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
        contentNode = SCNNode(geometry: faceGeometry)
        contentNode!.geometry?.firstMaterial?.fillMode = .lines
        
        return contentNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        print("–––––––––––––––––––––– Frame No. \(framesCount) ––––––––––––––––––––––")
        framesCount += 1
        print("Vertices\n")
        let vertices = (anchor as! ARFaceAnchor).geometry.vertices
        dump(vertices[0])
        dump(vertices[10])
        dump(vertices[100])
        print("Pixel Buff\n")
        let cvPixelBuffer = self.sceneView.session.currentFrame!.capturedImage
        dump(cvPixelBuffer)
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
