//
//  SpecialMove.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/07/04.
//

import Foundation

struct SpecialMove {
    
    var specialMoveType:SpecialMoveType = .none
    
    enum SpecialMoveType {
        case rightHand
        case leftHand
        case doubleHand
        case none
    }

    
}
