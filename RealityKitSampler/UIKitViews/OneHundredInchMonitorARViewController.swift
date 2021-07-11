//
//  OneHundredInchMonitorARView.swift
//  RealityKitSampler
//
//  Created by Daisuke Majima on 2021/06/22.
//

import UIKit
import SwiftUI
import RealityKit
import AVFoundation
import Combine
import ARKit

class OneHundredInchMonitorARViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ARCoachingOverlayViewDelegate {
    
    private var videoLooper: AVPlayerLooper!
    private var arView: ARView!
    private var player: AVQueuePlayer!
    private var displayEntity: ModelEntity!
    private var anchorEntity: AnchorEntity!
    private var isActiveSub:Cancellable!
    let coachingOverlay = ARCoachingOverlayView()
    
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
        coachingOverlay.goal = .verticalPlane
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.session = arView.session
        coachingOverlay.delegate = self
        coachingOverlay.frame = arView.bounds
        arView.addSubview(coachingOverlay)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player.pause()
    }
    
    func addMonitorEntity() {
        anchorEntity = AnchorEntity(plane: .vertical)
        displayEntity = ModelEntity(mesh: .generateBox(size: [2.21,0.2,1.24],cornerRadius: 0.02))
        displayEntity.position = [0,0,0.03]
        
        if let videoURL = Bundle.main.url(forResource: "windChimes", withExtension: "mp4") {
            let asset = AVURLAsset(url: videoURL)
            let playerItem = AVPlayerItem(asset: asset)
            player = AVQueuePlayer(playerItem: playerItem)
            videoLooper = AVPlayerLooper(player: player, templateItem: playerItem)
            let videoMaterial = VideoMaterial(avPlayer: player)
            displayEntity.model?.materials = [videoMaterial]
        }
        anchorEntity.addChild(displayEntity)
        
        isActiveSub = arView.scene.subscribe(to: SceneEvents.AnchoredStateChanged.self, on: anchorEntity, { event in
            if event.isAnchored {
                self.player.play()
            }
        })
        
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
            displayEntity.model?.materials = [videoMaterial]
            player.play()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
