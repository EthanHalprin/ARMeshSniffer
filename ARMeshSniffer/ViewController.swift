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
    let viewModel = ViewModel()

    // MARK: - ViewController Life-Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        ARInit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a Face-Tracking session configuration
        let configuration = ARFaceTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
        // Set to a single operation at a time, for sequentially recording frames
        viewModel.operationQueue.maxConcurrentOperationCount = 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - @IBAction
    @IBAction func stopTouchInside(_ sender: UIButton) {
        
        // Stop
        sceneView.session.pause()
        viewModel.operationQueue.waitUntilAllOperationsAreFinished()
                
        let alert = UIAlertController(title: "Finished",
                                      message: "Session recording has finished.\n\n To see what was recorded, press close and watch Xcode's Debug Output Console.\n\n After display there is done, a sample frame data will be saved in Files App as pdf as well",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "CLOSE", style: .default, handler: { _ in
            
            // This call will dump everything recorded to outpout (including all vertices)
            self.viewModel.displaySavedFileContent()
            
            // This will keep a sample DAtaon a frame sniff block to Files App as a pdf
            self.viewModel.savePDF(presenter: self)
        }))
        
        self.present(alert, animated: true)
    }
    

    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let sceneView = renderer as? ARSCNView, anchor is ARFaceAnchor else {
            return nil
        }
        
        // Render the face Mesh
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
        viewModel.contentNode = SCNNode(geometry: faceGeometry)
        viewModel.contentNode!.geometry?.firstMaterial?.fillMode = .lines
                
        return viewModel.contentNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard anchor is ARFaceAnchor,
              let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        // Disaptch work of recording to background (OperationQueue with capacity = 1
        // gives us SniffedBlock one after another, thus acheives synchronously vertices
        // and image (jpeg data)
        viewModel.operationQueue.addOperation {
            print("–––––––––––––––––––––– Frame No. \(self.viewModel.framesCount) ––––––––––––––––––––––")
            self.viewModel.framesCount += 1
            
            let sniffedBlock = SniffBlock()
            
            sniffedBlock.vertices = (anchor as! ARFaceAnchor).geometry.vertices
            sniffedBlock.image    = RawImage(currentFrame.capturedImage)
            sniffedBlock.camInfo  = CameraInfo(imageWidth: Float(currentFrame.camera.imageResolution.width),
                                               imageHeight: Float(currentFrame.camera.imageResolution.height),
                                               exposureDuration: Double(currentFrame.camera.exposureDuration))
            
            // Dispatch a single block to file. We could have save in RAM, and
            // after session stops pass to file, but that would signifcally limit
            // session time due to mem overflow
            self.viewModel.writeToFile(sniffedBlock)
        }
    }
}

extension ViewController {
    
    func ARInit() {
    
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
}
