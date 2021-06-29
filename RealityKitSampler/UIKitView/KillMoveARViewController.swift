//
//  KillMoveARViewController.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/27.
//

import UIKit
import RealityKit
import ARKit
import Vision
import CoreML

class KillMoveARViewController: UIViewController, ARSessionDelegate {

    private var arView: ARView!
    private lazy var request: VNDetectHumanBodyPoseRequest = {
       let request = VNDetectHumanBodyPoseRequest()
        return request
    }()
    
    private lazy var posesWindow:[VNRecognizedPointsObservation?] = {
       var window = [VNRecognizedPointsObservation?]()
        window.reserveCapacity(predictionWindowSize)
        return window
    }() {
        didSet {
            if isReadyToMakePrediction {
                do {
                    try makePrediction()
                } catch let error {
                    print(error)
                }
            }
        }
    }
    
    var isReadyToMakePrediction: Bool {
        posesWindow.count == predictionWindowSize
    }
    
    var predictionWindowSize: Int = 64
    
    private var classifier = ExerciseClassifier()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView = ARView(frame: view.bounds)
        view.addSubview(arView)
        arView.session.delegate = self
        arView.session.run(ARBodyTrackingConfiguration(), options: [])
        let box = ModelEntity(mesh: .generateBox(size: [0.1,0.1,0.1]),materials: [SimpleMaterial(color: .white, isMetallic: true)])
        handAnchor.addChild(box)
        arView.scene.addAnchor(handAnchor)
        // Do any additional setup after loading the view.
    }
    
    
    func makePrediction() throws {
        let poseMultiArrays: [MLMultiArray] = try posesWindow.map { person in
            guard let person = person else {
                return makeZeroedMultiArray()
            }
            return try person.keypointsMultiArray()
        }
        
        let modelInput = MLMultiArray(concatenating: poseMultiArrays, axis: 0, dataType: .float)
        let prediction = try classifier.prediction(poses: modelInput)
        
        posesWindow.removeAll()
        
        print(prediction.label)
        print(prediction.labelProbabilities[prediction.label])
    }
    
    private func makeZeroedMultiArray() -> MLMultiArray {
        // Create the multiarray.
        let shape:[Int] =  [1,3,18]
        guard let array = try? MLMultiArray(shape: shape as [NSNumber],
                                            dataType: .double) else {
            fatalError("Creating a multiarray with \(shape) shouldn't fail.")
        }

        // Get a pointer to quickly set the array's values.
        guard let pointer = try? UnsafeMutableBufferPointer<Double>(array) else {
            fatalError("Unable to initialize multiarray with zeros.")
        }

        // Set every element to zero.
        pointer.initialize(repeating: 0.0)
        return array
    }

    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let capturedImage = frame.capturedImage
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            do {
                let handler = try VNImageRequestHandler(cvPixelBuffer: capturedImage)
                try handler.perform([request])
                let poses = request.results as [VNRecognizedPointsObservation]?
                posesWindow.append(poses?.first)
            } catch let error {
                print(error)
            }
        }
    }

    var handAnchor:AnchorEntity = AnchorEntity()
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            let bodyAnchorEntity = AnchorEntity(anchor: bodyAnchor)
            let box = ModelEntity(mesh: .generateBox(size: [0.1,0.1,0.1]),materials: [SimpleMaterial(color: .white, isMetallic: true)])
            bodyAnchorEntity.addChild(box)
            arView.scene.addAnchor(bodyAnchorEntity)
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor,
                  let hand = bodyAnchor.skeleton.modelTransform(for: .rightHand) else { continue }
            let handTransform = bodyAnchor.transform * hand
            handAnchor.transform = Transform(matrix: handTransform)
            
        }
    }
}
