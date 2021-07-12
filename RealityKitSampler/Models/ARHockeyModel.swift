//
//  GameState.swift
//  RealityKitSampler
//
//  Created by Daisuke Majima on 2021/06/30.
//

import Foundation


struct ARHockeyModel {
    var isHost: Bool?
    var connectedDeviceName: String?
    var tableAdded = false
    var tableAddedInGuestDevice = false
    var gameState = GameState()
}

struct GameState: Codable {
    var hostScore:Int = 0
    var guestScore:Int = 0
}
