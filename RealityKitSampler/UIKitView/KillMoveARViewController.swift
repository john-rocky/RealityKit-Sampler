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

    var handAnchor:AnchorEntity = AnchorEntity()
    
    private lazy var cylinder:ModelEntity = {
        let cylinder = try! Energy.loadScene().cylinder?.children.first as! ModelEntity
        cylinder.model?.materials = [SimpleMaterial(color: .white, isMetallic: false)]
        cylinder.orientation = simd_quatf(angle: -90 * .pi / 180, axis: [0,0,1])

        return cylinder
    }()
    
    private lazy var sphere:ModelEntity = {
        let sphere = ModelEntity(mesh: .generateSphere(radius: 0.15), materials: [SimpleMaterial(color: .cyan, isMetallic: false)])
        return sphere
    }()
    
    private lazy var layer:CALayer = {
       let layer = CALayer()
        layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.75)
        return layer
    }()
    
    private var audioPlayer:AVAudioPlayer?
    var isPlayingAudio = false

    override func viewDidLoad() {
        super.viewDidLoad()
        arView = ARView(frame: view.bounds)
        view.addSubview(arView)
        arView.session.delegate = self
        arView.session.run(ARBodyTrackingConfiguration(), options: [])

        specialMove()
    }
    
    func specialMove() {
        let anchor = AnchorEntity(world: [0,0,-5])
        
        let originSphere = sphere.clone(recursive: true)
        let destinationSphere = sphere.clone(recursive: true)
        anchor.addChild(originSphere)
        anchor.addChild(destinationSphere)
        
        let cylinder = cylinder.clone(recursive: true)
        anchor.addChild(cylinder)
        
        let lightEntity = PointLight()
        lightEntity.light.color = .cyan
        lightEntity.light.intensity = 300000
        lightEntity.look(at: [0,0,0], from: [1,0,0.3], relativeTo: lightEntity)
        lightEntity.light.attenuationRadius = 10
        anchor.addChild(lightEntity)
                
        let lightEntity2 = PointLight()
        lightEntity2.light.color = .cyan
        lightEntity2.light.intensity = 300000
        lightEntity2.look(at: [0,0,0], from: [-1,0,0.3], relativeTo: lightEntity)
        lightEntity2.light.attenuationRadius = 10
        originSphere.addChild(lightEntity2)
        
        let lightEntity3 = PointLight()
        lightEntity3.light.color = .cyan
        lightEntity3.light.intensity = 300000
        lightEntity3.look(at: [0,0,0], from: [1,0,0.3], relativeTo: lightEntity)
        lightEntity3.light.attenuationRadius = 10
        destinationSphere.addChild(lightEntity3)
        
        Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { timer in
            cylinder.move(to: Transform(scale: [1,300,1], translation: [0,1.5,0]), relativeTo: cylinder, duration: 3, timingFunction: .easeInOut)
            destinationSphere.move(to: Transform(translation: [0,3,0]), relativeTo: cylinder, duration: 3, timingFunction: .easeInOut)
            if !self.isPlayingAudio {
                self.isPlayingAudio = true
                do {
                    guard let url = Bundle.main.url(forResource: "nmehameha", withExtension: "mp3") else {
                        print("couldn't play sound"); return
                    }
                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                    self.audioPlayer?.play()
                } catch let error {
                    print(error)
                }
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
                    self.isPlayingAudio = false
                    UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 1, delay: 0, options: [.curveEaseInOut]) {
                        self.arView.alpha = 0
                    } completion: { UIViewAnimatingPosition in
                        originSphere.removeFromParent()
                        destinationSphere.removeFromParent()
                        cylinder.removeFromParent()
                        lightEntity.removeFromParent()
                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 2, delay: 1, options: [.curveEaseOut]) {
                            self.arView.alpha = 1
                        } completion: { UIViewAnimatingPosition in
                        }
                    }

                }
            }
        }
        arView.scene.addAnchor(anchor)
    }
    
    func layerAnimation() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.arView.layer.add(animation, forKey: nil)
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _timer in
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = 2
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            self.arView.layer.add(animation, forKey: nil)
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    }
    
    
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
