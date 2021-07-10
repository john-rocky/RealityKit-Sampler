//
//  PlacingObjectARView.swift
//  RealityKitSampler
//
//  Created by Daisuke Majima on 2021/06/21.
//

import UIKit
import SwiftUI
import RealityKit
import ARKit
import AVFoundation

class PlacingObjectARView: ARView, ARSessionDelegate {

    var model:PlacingObjectModel!
    var resolution:CGAffineTransform?
    private var planeEntities: [UUID:ModelEntity] = [:]
    var physicsChanged: Bool = false
    
    
    var pannedEntity:ModelEntity?
    var lastPan = CGPoint.zero
    var materialXPan:Float = 0
    var materialYPan:Float = 0
    var twoFingerPhysicsChanged: Bool = false


    init(frame: CGRect, model: PlacingObjectModel) {
        super.init(frame: frame)
        self.model = model
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.addGestureRecognizer(tapGesture)
        let pan = UIPanGestureRecognizer(target: self, action:  #selector(handlePan(sender:)))
        pan.minimumNumberOfTouches = 2
        self.addGestureRecognizer(pan)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    // MARK: - Gestures
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        let location = sender.location(in: self)
        if let entity = self.entity(at: location) as? ModelEntity, entity.physicsBody?.mode == .dynamic, !planeEntities.values.contains(entity) {
            
            entity.addForce([0,0,-100], relativeTo: nil)
        
        } else {
            
            let results = self.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
            if let firstResult = results.first {
                let anchor = ARAnchor(name: "Anchor for object placement", transform: firstResult.worldTransform)
                self.session.add(anchor: anchor)
                let anchorEntity = AnchorEntity(anchor: anchor)
                let modelEntity = ModelEntity(mesh: generateMesh())
                modelEntity.model?.materials = [generateMaterial()]
                anchorEntity.addChild(modelEntity)
                modelEntity.generateCollisionShapes(recursive: true)
                switch model.physics {
                case ._kinematic:
                    modelEntity.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .kinematic)
                case ._static:
                    modelEntity.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
                case ._dynamic:
                    modelEntity.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
                }
                if model.materialType == .video {
                    if resolution!.b != 0{
                        modelEntity.orientation = simd_quatf(angle: -1.5708, axis: [0,0,1])
                    } else if resolution!.a != 1.0 {
                        modelEntity.orientation = simd_quatf(angle: 1.5708 * 2, axis: [0,0,1])
                    }
                }
                installGestures(.all, for: modelEntity).forEach { recognizer in
                    recognizer.addTarget(self, action: #selector(handleGesture(sender:)))
                }
                
                modelEntity.position.y = (modelEntity.model?.mesh.bounds.extents.y)! / 2
                self.scene.addAnchor(anchorEntity)
            }
        }
    }
    
    @objc func handleGesture(sender: UIGestureRecognizer){
        if let panGesture = sender as? EntityTranslationGestureRecognizer {
            switch sender.state {
            case .began:
                guard let modelEntity = panGesture.entity as? ModelEntity else { return }
                if modelEntity.physicsBody?.mode == .dynamic {
                    physicsChanged = true
                    modelEntity.physicsBody?.mode = .kinematic
                }
            case .ended:
                guard let modelEntity = panGesture.entity as? ModelEntity else { return }
                if physicsChanged {
                    physicsChanged = false
                    modelEntity.physicsBody?.mode = .dynamic
                }
            default: break
            }
        }
        if let pintchGesture = sender as? EntityScaleGestureRecognizer {
            print(pintchGesture.scale)
        }
        
        if let doubleFingerGesture = sender as? EntityRotationGestureRecognizer {
            print(doubleFingerGesture.rotation)
        }
    }

    
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            materialXPan = 0
            materialYPan = 0
            lastPan = CGPoint.zero
            let location = sender.location(in: self)
            if let entity = self.entity(at: location) as? ModelEntity, !planeEntities.values.contains(entity) {
                if entity.physicsBody?.mode == .dynamic {
                    twoFingerPhysicsChanged = true
                    entity.physicsBody?.mode = .kinematic
                }
                pannedEntity = entity
            }
        case .changed:
            let newTranslation = sender.translation(in: self)
            materialXPan = (Float(newTranslation.x) - Float(lastPan.x)) * -0.001
            materialYPan = (Float(newTranslation.y) - Float(lastPan.y)) * -0.001
            guard let position = pannedEntity?.position else { return }
            pannedEntity?.position = [position.x - materialXPan,position.y + materialYPan, position.z]
            lastPan = newTranslation
            
        case .ended:
            if twoFingerPhysicsChanged {
                twoFingerPhysicsChanged = false
                pannedEntity?.physicsBody?.mode = .dynamic
                pannedEntity = nil
            }
        default: break
        }
    }
    
    // MARK:- Generate Object Model
    
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
                let z = min(size.0, size.1)
                mesh = .generateBox(size: [size.0,size.1,z])
            default:
                mesh = .generateBox(size: 0.05)
            }
        case .plane:
            switch model.materialType {
            case .image:
                let size = getBoxSizeForImage()
                mesh = .generatePlane(width: size.0, depth: size.1)
            default:
                mesh = .generatePlane(width: 0.1, depth: 0.1)
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
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    }

}
