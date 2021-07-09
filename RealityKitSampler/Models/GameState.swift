//
//  GameState.swift
//  RealityKitSampler
//
//  Created by Daisuke Majima on 2021/06/30.
//

import Foundation

struct GameState: Codable {
    var boardAdded = false
    var isHost:Bool?
    var hostScore:Int = 0
    var guestScore:Int = 0
}
