//
//  OneHundredInchMonitorARView.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/22.
//

import UIKit
import SwiftUI
import RealityKit
import AVFoundation

class OneHundredInchMonitorARViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var videoLooper: AVPlayerLooper?
    private var arView: ARView!
    private var player: AVQueuePlayer!
    private var planeEntity: ModelEntity!
    @Binding var didTap:Bool
    
    init(didTap:Binding<Bool>) {
        _didTap = didTap
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView = ARView(frame: view.bounds)
        view.addSubview(arView)
        addMonitorEntity()
    }

    func addMonitorEntity() {
        let anchorEntity = AnchorEntity(world: [0,0,-1])
        let boxEntity = ModelEntity(mesh: .generateBox(size: [2.21,1.24,0.05,],cornerRadius: 0.02))
        let material = SimpleMaterial(color: .black, isMetallic: true)
        boxEntity.model?.materials = [material]
        
        planeEntity = ModelEntity(mesh: .generatePlane(width: 2, depth: 1))
        planeEntity.position = [0,0,0.026]
        planeEntity.orientation = simd_quatf(angle: 90 * .pi / 180 , axis: [1,0,0])
        
        if let videoURL = Bundle.main.url(forResource: "windChimes", withExtension: "mp4") {
            let asset = AVURLAsset(url: videoURL)
            let playerItem = AVPlayerItem(asset: asset)
            player = AVQueuePlayer(playerItem: playerItem)
            videoLooper = AVPlayerLooper(player: player, templateItem: playerItem)
            let videoMaterial = VideoMaterial(avPlayer: player)
            planeEntity.model?.materials = [videoMaterial]
            player.play()
        }
        boxEntity.addChild(planeEntity)
        anchorEntity.addChild(boxEntity)
        arView.scene.addAnchor(anchorEntity)
    }
    
    func showPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        picker.delegate = self
        present(picker, animated: true) {
            self.didTap = false
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoURL = info[.mediaURL]  as? URL {
            let asset = AVURLAsset(url: videoURL)
            let playerItem = AVPlayerItem(asset: asset)
            player = AVQueuePlayer(playerItem: playerItem)
            videoLooper = AVPlayerLooper(player: player, templateItem: playerItem)
            let videoMaterial = VideoMaterial(avPlayer: player)
            planeEntity.model?.materials = [videoMaterial]
            player.play()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
