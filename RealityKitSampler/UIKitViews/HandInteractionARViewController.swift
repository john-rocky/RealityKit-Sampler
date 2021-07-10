//
//  GrabARARViewController.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/07/09.
//

import UIKit
import Vision
import RealityKit
import ARKit

class HandInteractionARViewController: UIViewController, ARSessionDelegate {

    private var arView:ARView!
    lazy var request:VNRequest = {
        var handPoseRequest = VNDetectHumanHandPoseRequest(completionHandler: handDetectionCompletionHandler)
        handPoseRequest.maximumHandCount = 1
        return handPoseRequest
    }()
    var viewWidth:Int = 0
    var viewHeight:Int = 0
    var box:ModelEntity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView = ARView(frame: view.bounds)
        arView.session.delegate = self
        view.addSubview(arView)
        let config = ARWorldTrackingConfiguration()
        config.environmentTexturing = .automatic
        config.frameSemantics = [.personSegmentation]
        config.planeDetection = [.horizontal]
        arView.session.run(config, options: [])
        viewWidth = Int(arView.bounds.width)
        viewHeight = Int(arView.bounds.height)
        setupObject()
    }
    

    private func setupObject(){
        let anchor = AnchorEntity(plane: .horizontal)
        
        let plane = ModelEntity(mesh: .generatePlane(width: 2, depth: 2), materials: [OcclusionMaterial()])
        anchor.addChild(plane)
        plane.generateCollisionShapes(recursive: false)
        plane.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
        
        box = ModelEntity(mesh: .generateBox(size: 0.05), materials: [SimpleMaterial(color: .white, isMetallic: true)])
        box.generateCollisionShapes(recursive: false)
        box.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
        box.position = [0,0.025,0]
        anchor.addChild(box)
        arView.scene.addAnchor(anchor)
    }
    
    var recentIndexFingerPoint:CGPoint = .zero
    
    func handDetectionCompletionHandler(request: VNRequest?, error: Error?) {
        guard let observation = request?.results?.first as? VNHumanHandPoseObservation else { return }
        guard let indexFingerTip = try? observation.recognizedPoints(.all)[.indexTip],
            indexFingerTip.confidence > 0.3 else {return}
        let normalizedIndexPoint = VNImagePointForNormalizedPoint(CGPoint(x: indexFingerTip.location.y, y: indexFingerTip.location.x), viewWidth,  viewHeight)
        if let entity = arView.entity(at: normalizedIndexPoint) as? ModelEntity, entity == box {
            entity.addForce([0,40,0], relativeTo: nil)
        }
        recentIndexFingerPoint = normalizedIndexPoint
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let pixelBuffer = frame.capturedImage
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let handler = VNImageRequestHandler(cvPixelBuffer:pixelBuffer, orientation: .up, options: [:])
            do {
                try handler.perform([(self?.request)!])

            } catch let error {
                print(error)
            }
        }
    }
}
