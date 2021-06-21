//
//  PlacingObjectModel.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/21.
//

import Foundation
import UIKit

struct PlacingObjectModel {
    enum MeshType {
        case box
        case sphere
        case text
    }
    
    var meshType: MeshType = .box
    var color: UIColor = .white
    
    
}
