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

// LATER:
// - Check that this implementation works for iPad as well
// - Resize the image
// - Rotate the image
// - Move image to another surface
// - Detect multiple planes, tap on the one you want to set the image to
// - Save the image and its placement and opacity

class TraceViewController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var opacitySlider: UISlider!

    var changingNode: SCNNode?
    let isPad = UIDevice.current.userInterfaceIdiom == .pad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical, .horizontal]
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    @IBAction func adjustOpacity(_ sender: Any) {
        changingNode?.opacity = CGFloat(opacitySlider.value)
    }

    @IBAction func openPhotoOptions(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "Take New Photo", style: .default) { (action:UIAlertAction) in self.openImagePicker(withSourceType: .camera) }
        let albumAction = UIAlertAction(title: "Choose Existing Photo", style: .default) { (action:UIAlertAction) in self.openImagePicker(withSourceType: .photoLibrary) }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        [cameraAction, albumAction, cancelAction].forEach { actionSheet.addAction($0) }

        present(actionSheet, animated: true, completion: nil)
    }

    func openImagePicker(withSourceType sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        if sourceType == .camera && !UIImagePickerController.isSourceTypeAvailable(.camera) { return }
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.preferredContentSize = view.frame.size
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension TraceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let newImage = info[.originalImage] as? UIImage, let node = changingNode { node.geometry?.firstMaterial?.diffuse.contents = newImage }
        dismiss(animated: true, completion: .none)
    }
}

// MARK: - ARSCNViewDelegate
extension TraceViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor  else { return }
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)

        changingNode = SCNNode(geometry: SCNPlane(width: width, height: height))
        changingNode?.eulerAngles.x = -.pi / 2

        node.addChildNode(changingNode!)
    }
}
