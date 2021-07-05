//
//  HockeyBoard.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/07/01.
//

import Foundation
import RealityKit

class HockeyBoard: Entity {
    
    var puck:ModelEntity!
    var hostStriker:ModelEntity!
    var guestStriker:ModelEntity!
    var width: Float!
    var depth: Float!

    init(width: Float, depth: Float) {
        super.init()
        self.width = width
        self.depth = depth

        setupBoard()
        setupPuck()
        
    }
    
    private func setupBoard() {
        let table = ModelEntity(mesh: .generatePlane(width: width, depth: depth), materials: [SimpleMaterial(color: .white, isMetallic: true)])
        table.generateCollisionShapes(recursive: false)
        table.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
        let wallFront = ModelEntity(mesh: .generateBox(size: [width, 0.05, 0.01]), materials: [SimpleMaterial(color: .white, isMetallic: false)])
        wallFront.generateCollisionShapes(recursive: false)
        wallFront.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
        let wallLeft = ModelEntity(mesh: .generateBox(size: [0.01, 0.05, depth]), materials: [SimpleMaterial(color: .white, isMetallic: false)])
        wallLeft.generateCollisionShapes(recursive: false)
        wallLeft.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)

        let wallBack = wallFront.clone(recursive: false)
        let wallRight = wallLeft.clone(recursive: false)
        
        wallFront.position = [0,0.025,depth/2]
        wallBack.position = [0,0.025,-depth/2]
        wallLeft.position = [-width/2,0.025,0]
        wallRight.position = [width/2,0.025,0]
        
        addChild(table)
        addChild(wallFront)
        addChild(wallBack)
        addChild(wallLeft)
        addChild(wallRight)
    }
    
    private func setupPuck() {
        let sceneElement = try! Tools.load_Tools()
        puck = sceneElement.puck?.children.first as? ModelEntity
        hostStriker = sceneElement.hostStriker?.children.first as? ModelEntity
        guestStriker = sceneElement.guestStriker?.children.first as? ModelEntity
        
        hostStriker.position = [0,0.005,depth/2-0.02]
        guestStriker.position = [0,0.005,-(depth/2-0.02)]

        addChild(puck)
        addChild(hostStriker)
        addChild(guestStriker)

    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
