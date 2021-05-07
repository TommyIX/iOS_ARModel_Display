//
//  ViewController.swift
//  ARTubes
//

import UIKit
import ARKit
import SwiftUI

var display_name = false
var display_type = false
var display_diameter = false
var display_coordinate = false

var colist = [SCNVector3]()
var namelist = [String]()
var typelist = [String]()
var dlist = [Float]()

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var Tubes: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var infolabel: UILabel!
    
    let configuration = ARWorldTrackingConfiguration()

    @IBAction func Display(_ sender: Any) {
        let alertController = UIAlertController(title: "Display Settings", message: "Tap to change the display status", preferredStyle: .actionSheet)
        var nametitle = "Display Tube Name: ON"
        var typetitle = "Display Tube Type: ON"
        var dtitle = "Display Diameter: ON"
        var cotitle = "Display Coordinate: ON"
        if !display_name {nametitle = "Display Tube Name: OFF"}
        if !display_type {typetitle = "Display Tube Type: OFF"}
        if !display_diameter {dtitle = "Display Diameter: OFF"}
        if !display_coordinate {cotitle = "Display Coordinate: OFF"}
        
        let dnameaction = UIAlertAction(title: nametitle, style: .default, handler: {_ in display_name = !display_name})
        alertController.addAction(dnameaction)
        let dtypeaction = UIAlertAction(title: typetitle, style: .default, handler: {_ in display_type = !display_type})
        alertController.addAction(dtypeaction)
        let daction = UIAlertAction(title: dtitle, style: .default, handler: {_ in display_diameter = !display_diameter})
        alertController.addAction(daction)
        let coaction = UIAlertAction(title: cotitle, style: .default, handler: {_ in display_coordinate = !display_coordinate})
        alertController.addAction(coaction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(alertController, animated: true, completion: nil)
        updatetext()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        // sceneView.showsStatistics = true
        sceneView.debugOptions = [SCNDebugOptions.showWireframe, SCNDebugOptions.showFeaturePoints, SCNDebugOptions.showCreases]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        UIApplication.shared.isIdleTimerDisabled = true
        self.sceneView.autoenablesDefaultLighting = true
        // Run the view's session
        sceneView.session.run(configuration)
        addGestures()
    }
    
    func addGestures () {
        let tapped = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        sceneView.addGestureRecognizer(tapped)
    }
    
    @objc func tapGesture (sender: UITapGestureRecognizer) {
        let tapLocation: CGPoint = sender.location(in: sceneView)
        let estimatedPlane: ARRaycastQuery.Target = .estimatedPlane
        let alignment: ARRaycastQuery.TargetAlignment = .any
        let query: ARRaycastQuery? = sceneView.raycastQuery(from: tapLocation, allowing: estimatedPlane, alignment: alignment)
        if let nonOptQuery: ARRaycastQuery = query {
            let result: [ARRaycastResult] = sceneView.session.raycast(nonOptQuery)
            guard let rayCast: ARRaycastResult = result.first
            else { return }
            self.loadGeometry(rayCast)
        }
    }
    @IBAction func Reset(_ sender: Any) {
        sceneView.session.pause()
        colist.removeAll()
        namelist.removeAll()
        typelist.removeAll()
        dlist.removeAll()
        updatetext()
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        UIApplication.shared.isIdleTimerDisabled = true
        self.sceneView.autoenablesDefaultLighting = true
        // Run the view's session
        sceneView.session.run(configuration)
        addGestures()
    }
    
    func loadGeometry(_ result: ARRaycastResult) {
        guard let scene = SCNScene(named: "art.scnassets/full_tube_model.dae") else { print("Cannot load SCNScene") ; return }
        let node: SCNNode? = scene.rootNode.childNode(withName: "TapPosition", recursively: true)
        node?.scale = SCNVector3(0.1,0.1,0.1)
        node?.position = SCNVector3(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)

        // TubeModel 1 info
        namelist.append("tube1");
        typelist.append("type_tube1")
        dlist.append(0.5)
        colist.append(SCNVector3(result.worldTransform.columns.3.x-11.3058, result.worldTransform.columns.3.y-0.3009, result.worldTransform.columns.3.z+7.0862))
        
        // TubeModel 2 info
        namelist.append("tube2");
        typelist.append("type_tube2")
        dlist.append(0.75)
        colist.append(SCNVector3(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z))
        
        // Tubemodel 3 info
        namelist.append("tubeset3");
        typelist.append("type_tube3")
        dlist.append(0.3)
        colist.append(SCNVector3(result.worldTransform.columns.3.x-1.8027, result.worldTransform.columns.3.y+0.087, result.worldTransform.columns.3.z-0.7108))
        
        self.sceneView.scene.rootNode.addChildNode(node!)
        updatetext()
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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        let meshNode : SCNNode
        let textNode : SCNNode
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}

        
        guard let meshGeometry = ARSCNPlaneGeometry(device: sceneView.device!)
            else {
                fatalError("Can't create plane geometry")
        }
        meshGeometry.update(from: planeAnchor.geometry)
        meshNode = SCNNode(geometry: meshGeometry)
        meshNode.opacity = 0.6
        meshNode.name = "MeshNode"
        
        guard let material = meshNode.geometry?.firstMaterial
            else { fatalError("ARSCNPlaneGeometry always has one material") }
        material.diffuse.contents = UIColor.blue
        
        node.addChildNode(meshNode)
        
        let textGeometry = SCNText(string: "Available Reference Plane", extrusionDepth: 1)
        textGeometry.font = UIFont(name: "Futura", size: 75)
        
        textNode = SCNNode(geometry: textGeometry)
        textNode.name = "TextNode"
        
        textNode.simdScale = SIMD3(repeating: 0.0005)
        textNode.eulerAngles = SCNVector3(x: Float(-90.degreesToradians), y: 0, z: 0)
        
        node.addChildNode(textNode)
        
        textNode.centerAlign()
        print("did add plane node")
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }

        let planeNode = node.childNode(withName: "MeshNode", recursively: false)

            if let planeGeometry = planeNode?.geometry as? ARSCNPlaneGeometry {
                planeGeometry.update(from: planeAnchor.geometry)
            }
    
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
    

    func updatetext(){
        print("updating text")
        if (!display_name && !display_type && !display_coordinate && !display_diameter) {
            infolabel.text = " "
            return
        }
        infolabel.text = "[TubeInfo]\n"
        if namelist.count == 0 {
            infolabel.text! += "No Tubes Added"
            return
        }
        for index in 1...namelist.count{
            infolabel.text! += "[Tube\(index)]\n"
            if display_name {infolabel.text! += "Name:\(namelist[index-1])\n"}
            if display_type {infolabel.text! += "Type:\(typelist[index-1])\n"}
            if display_diameter {infolabel.text! += "Diameter:\(dlist[index-1])\n"}
            if display_coordinate {infolabel.text! += "Coordinate:\(colist[index-1])\n"}
        }
        return
    }
}

extension SCNNode {
    func centerAlign() {
        let (min, max) = boundingBox
        let extents = ((max) - (min))
        simdPivot = float4x4(translation: SIMD3((extents / 2) + (min)))
    }
}

extension float4x4 {
    init(translation vector: SIMD3<Float>) {
        self.init(SIMD4(1, 0, 0, 0),
                  SIMD4(0, 1, 0, 0),
                  SIMD4(0, 0, 1, 0),
                  SIMD4(vector.x, vector.y, vector.z, 1))
    }
}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}
func / (left: SCNVector3, right: Int) -> SCNVector3 {
    return SCNVector3Make(left.x / Float(right), left.y / Float(right), left.z / Float(right))
}
extension Int {
    var degreesToradians : Double {return Double(self) * .pi/180}
}

