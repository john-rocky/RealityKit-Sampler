//
//  PlacingObjectARView.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/21.
//

import UIKit
import SwiftUI
import RealityKit
import ARKit
import AVFoundation

class PlacingObjectARView: ARView, ARSessionDelegate {
    
    var tappedLocation: CGPoint = CGPoint.zero {
        didSet {
            print(tappedLocation)
            print(model.meshType)
        }
    }
    
    var model:PlacingObjectModel!
    var resolution:CGAffineTransform?
    
    init(frame: CGRect, model: PlacingObjectModel) {
        super.init(frame: frame)
        self.model = model
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(sender:)))
        self.addGestureRecognizer(tapGesture)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @objc func tapped(sender: UITapGestureRecognizer){
        let location = sender.location(in: self)
        let results = self.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
        if let firstResult = results.first {
            let anchor = ARAnchor(name: "Anchor for object placement", transform: firstResult.worldTransform)
            self.session.add(anchor: anchor)
            let anchorEntity = AnchorEntity(anchor: anchor)
            let modelEntity = ModelEntity(mesh: generateMesh())
            modelEntity.model?.materials = [generateMaterial()]
            anchorEntity.addChild(modelEntity)
            
            if model.materialType == .video {
                if resolution!.b != 0{
                    modelEntity.orientation = simd_quatf(angle: -1.5708, axis: [0,0,1])
                } else if resolution!.a != 1.0 {
                    modelEntity.orientation = simd_quatf(angle: 1.5708 * 2, axis: [0,0,1])
                }
            }
            
            self.scene.addAnchor(anchorEntity)
        }
    }
    
    func generateMesh() -> MeshResource {
        var mesh:MeshResource
        switch model.meshType {
        case .box:
            switch model.materialType {
            case .image:
                let size = getBoxSizeForImage()
                mesh = .generateBox(size: [size.0,size.1,size.1])
            case .video:
                let size = getBoxSizeForVideo()
                mesh = .generateBox(size: [size.0,size.1,size.0])
            default:
                mesh = .generateBox(size: 0.05)
            }
        case .plane:
            switch model.materialType {
            case .image:
                let size = getBoxSizeForImage()
                mesh = .generatePlane(width: size.0, depth: size.1)
            default:
                mesh = .generatePlane(width: 0.05, depth: 0.05)
            }
        case .sphere:
            mesh = .generateSphere(radius: 0.025)
        }
        return mesh
    }
    
    func generateMaterial() -> Material {
        var material:Material
        switch model.materialType {
        case .simple:
            material = SimpleMaterial(color: model.color, isMetallic: true)
        case .unlit:
            material = UnlitMaterial(color: model.color)
        case .image:
            material = UnlitMaterial(color: model.color)
            if let imageURL = model.imageURL {
                if let texture = try? TextureResource.load(contentsOf: imageURL) {
                    var unlitMateril = UnlitMaterial()
                    unlitMateril.baseColor = MaterialColorParameter.texture(texture)
                    material = unlitMateril
                }
            }
        case .video:
            if let videoURL = model.videoURL {
                let asset = AVURLAsset(url: videoURL)
                let playerItem = AVPlayerItem(asset: asset)
                let player = AVPlayer(playerItem: playerItem)
                material = VideoMaterial(avPlayer: player)
                player.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(didPlayToEnd),
                                                       name: NSNotification.Name("AVPlayerItemDidPlayToEndTimeNotification"),
                                                       object: player.currentItem)
                player.play()
            } else {
                material = SimpleMaterial(color: model.color, isMetallic: true)
            }
        case .occlusion:
            material = OcclusionMaterial()
        }
        return material
    }
    
    func getBoxSizeForImage() -> (Float, Float){
        guard let imageSize = model.image?.size else { return (0.05, 0.05) }
        if imageSize.width > imageSize.height {
            let aspect = imageSize.width / imageSize.height
            return (Float(aspect) * 0.05, 0.05)
        } else {
            let aspect = imageSize.height / imageSize.width
            return (0.05, Float(aspect) * 0.05)
        }
    }
    
    func getBoxSizeForVideo() -> (Float, Float) {
        guard let url = model.videoURL else { return (0.05, 0.05) }
        let resolution = resolutionForVideo(url: url)
        self.resolution = resolution.1
        let width = resolution.0!.width
        let height = resolution.0!.height
        
        guard resolution.1!.b == 0 else {
            if width > height {
                let aspect = Float(width / height)
                return (0.05, Float(aspect) * 0.05)
            } else {
                let aspect = Float(height / width )
                return (Float(aspect) * 0.05, 0.05)
            }
        }
        
        if width > height {
            let aspect = Float(width / height)
            return (Float(aspect) * 0.05, 0.05)
        } else {
            let aspect = Float(height / width )
            return (0.05, Float(aspect) * 0.05)
        }
    }
    
    private func resolutionForVideo(url: URL) -> (CGSize?,CGAffineTransform?) {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return (nil,nil) }
        let size = track.naturalSize.applying(track.preferredTransform)
        print(track.preferredTransform)
        return (CGSize(width: abs(size.width), height: abs(size.height)),track.preferredTransform)
    }
    
    @objc func didPlayToEnd(notification: NSNotification) {
        let item: AVPlayerItem = notification.object as! AVPlayerItem
        item.seek(to: CMTime.zero, completionHandler: nil)
    }
    
    func setup() {
        
    }
    
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    }

}
