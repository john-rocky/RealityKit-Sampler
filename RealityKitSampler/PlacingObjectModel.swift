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
    
    var meshType: MeshType = .box
    var color: UIColor = .white    
}
