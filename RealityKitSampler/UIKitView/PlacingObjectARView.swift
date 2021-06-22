//
//  PlacingObjectARView.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/21.
//

import UIKit
import RealityKit
import ARKit

class PlacingObjectARView: ARView, ARSessionDelegate {
    
    var tappedLocation: CGPoint = CGPoint.zero {
        didSet {
            print(tappedLocation)
        }
    }
    
    init(frame: CGRect, settings: String) {
        super.init(frame: frame)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    func setup() {
        
    }
    
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    }

}
