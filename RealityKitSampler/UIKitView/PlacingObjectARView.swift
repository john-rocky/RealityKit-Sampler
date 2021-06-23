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

class PlacingObjectARView: ARView, ARSessionDelegate {
    
    var tappedLocation: CGPoint = CGPoint.zero {
        didSet {
            print(tappedLocation)
            print(model.meshType)
        }
    }
    
     var model:PlacingObjectModel!
    
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
            self.scene.addAnchor(anchorEntity)
        }
    }
    
    func generateMesh() -> MeshResource {
        var mesh:MeshResource
        switch model.meshType {
        case .box:
            mesh = .generateBox(size: 0.05)
        case .plane:
            mesh = .generatePlane(width: 0.05, depth: 0.05)
        case .sphere:
            mesh = .generateSphere(radius: 0.025)
        }
        return mesh
    }
    
    func generateMaterial() -> Material {
        var material:Material
        material = SimpleMaterial(color: model.color, isMetallic: true)
        return material
    }
    
    func setup() {
        
    }
    
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    }

}
