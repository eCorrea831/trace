//
//  ViewController.swift
//  Trace
//
//  Created by Erica Correa on 9/23/18.
//  Copyright © 2018 Erica Correa. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

// TODO:
// - Figure out how to replace sprite with image
// - Figure out how to detect surfaces to place it
// - Check that this implementation works for iPad as well

// LATER:
// - Resize the image
// - Rotate the image
// - Adjust image opacity
// - Move image to another surface
// - Save the image and its placement and opacity

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!

    let isPad = UIDevice.current.userInterfaceIdiom == .pad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }

    @IBAction func openPhotoOptions(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "Take New Photo", style: .default) { (action:UIAlertAction) in self.takeNewPhoto() }
        let albumAction = UIAlertAction(title: "Choose Existing Photo", style: .default) { (action:UIAlertAction) in self.openPhotoLibrary() }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        [cameraAction, albumAction, cancelAction].forEach { actionSheet.addAction($0) }

        present(actionSheet, animated: true, completion: nil)
    }
}

// MARK: - Photo Options
extension ViewController {
    func takeNewPhoto() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        openImagePicker(withSourceType: .camera)
    }

    func openPhotoLibrary() { openImagePicker(withSourceType: .photoLibrary) }

    func openImagePicker(withSourceType sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.preferredContentSize = view.frame.size
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //spriteImage = info[originalImage]
        dismiss(animated: true, completion: .none)
    }
}
