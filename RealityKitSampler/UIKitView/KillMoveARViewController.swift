//
//  KillMoveARViewController.swift
//  RealityKitSampler
//
//  Created by Daisuke Majima on 2021/06/27.
//

import UIKit
import RealityKit
import ARKit
import Vision

class KillMoveARViewController: UIViewController, ARSessionDelegate {

    private var arView: ARView!

    
    private var audioPlayer:AVAudioPlayer?
    
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
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
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
    
    var isPlayingAudio = false
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor,
                  let rightHand = bodyAnchor.skeleton.modelTransform(for: .rightHand)else { continue }
            let rightHandPosition = rightHand.columns.3.x
            if rightHandPosition < -0.4 || rightHandPosition > 0.4, !isPlayingAudio {
                isPlayingAudio = true
                do {
                    guard let url = Bundle.main.url(forResource: "nmehameha", withExtension: "mp3") else {
                        print("couldn't play sound"); return
                    }
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.play()
                    Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { Timer in
                        self.isPlayingAudio = false
                    }
                } catch let error {
                    print(error)
                }
            }

            let handTransform = bodyAnchor.transform * rightHand
            handAnchor.transform = Transform(matrix: handTransform)
            
        }
    }
}
