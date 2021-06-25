//
//  PlacingObjectModel.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/21.
//

import Foundation
import UIKit

struct PlacingObjectModel {
    
    enum MeshType: String, CaseIterable, Identifiable {
        case box
        case plane
        case sphere
        
        var id: String { self.rawValue }
    }
    
    enum MaterialType: String, CaseIterable, Identifiable {
        case simple
        case unlit
        case image
        case video
        case occlusion
        
        var id: String { self.rawValue }
    }
    
    var meshType: MeshType = .box
    var materialType: MaterialType = .simple
    // texture
    
    var color: UIColor = .white
    var image: UIImage? = UIImage(named: "chihiro")
    var imageURL: URL? = Bundle.main.url(forResource: "chihiro", withExtension: ".jpeg")
    var videoURL: URL? = Bundle.main.url(forResource: "windChimes", withExtension: "mp4")
    var physics: Bool = false
}
