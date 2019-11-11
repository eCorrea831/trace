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
// - Save the image and its placement and opacity

class TraceViewController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var opacitySlider: UISlider!

    var changingNode: SCNNode?
    var selectedNode: SCNNode?

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
}

// MARK: - Action Methods
extension TraceViewController {
    @IBAction func selectPlane(_ gesture: UITapGestureRecognizer) {
        let touchPosition = gesture.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchPosition, options: nil)

        guard !hitTestResult.isEmpty, let hitResult = hitTestResult.first else { return }
        selectedNode = hitResult.node
        highlightNode(hitResult.node) //unhighlight the others
        addCameraDirections()
    }

    @IBAction func adjustOpacity(_ sender: Any) {
        selectedNode?.opacity = CGFloat(opacitySlider.value)
    }
}

// MARK: - Camera & Photo Methods
extension TraceViewController {
    @IBAction func openPhotoOptions(_ sender: Any) {
         let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

         let cameraAction = UIAlertAction(title: "Take New Photo", style: .default) { (action:UIAlertAction) in self.openImagePicker(withSourceType: .camera) }
         let albumAction = UIAlertAction(title: "Choose Existing Photo", style: .default) { (action:UIAlertAction) in self.openImagePicker(withSourceType: .photoLibrary) }
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
         [cameraAction, albumAction, cancelAction].forEach { actionSheet.addAction($0) }

         present(actionSheet, animated: true, completion: nil)
     }

     func addCameraDirections() {
        guard let node = selectedNode else { return }
        node.geometry?.firstMaterial?.diffuse.contents = CameraDirectionsView()
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
        if let newImage = info[.originalImage] as? UIImage, let node = selectedNode { node.geometry?.firstMaterial?.diffuse.contents = newImage }
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

extension TraceViewController {
    func createLineNode(fromPos origin: SCNVector3, toPos destination: SCNVector3, color: UIColor) -> SCNNode {
        let line = lineFrom(vector: origin, toVector: destination)
        let lineNode = SCNNode(geometry: line)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = color
        line.materials = [planeMaterial]

        return lineNode
    }

    func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]

        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)

        return SCNGeometry(sources: [source], elements: [element])
    }


    func highlightNode(_ node: SCNNode) {
        let (min, max) = node.boundingBox
        let zCoord = node.position.z
        let topLeft = SCNVector3Make(min.x, max.y, zCoord)
        let bottomLeft = SCNVector3Make(min.x, min.y, zCoord)
        let topRight = SCNVector3Make(max.x, max.y, zCoord)
        let bottomRight = SCNVector3Make(max.x, min.y, zCoord)


        let bottomSide = createLineNode(fromPos: bottomLeft, toPos: bottomRight, color: .red)
        let leftSide = createLineNode(fromPos: bottomLeft, toPos: topLeft, color: .red)
        let rightSide = createLineNode(fromPos: bottomRight, toPos: topRight, color: .red)
        let topSide = createLineNode(fromPos: topLeft, toPos: topRight, color: .red)

        [bottomSide, leftSide, rightSide, topSide].forEach {
            $0.name = "test"
            node.addChildNode($0)
        }
    }

    func unhighlightNode(_ node: SCNNode) {
        let highlightningNodes = node.childNodes { (child, stop) -> Bool in
            child.name == "test"
        }
        highlightningNodes.forEach {
            $0.removeFromParentNode()
        }
    }
}
