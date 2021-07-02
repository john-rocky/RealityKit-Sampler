//
//  ShootTheDeviceViewController.swift
//  RealityKitSampler
//
//  Created by Daisuke Majima on 2021/06/30.
//

import UIKit
import RealityKit
import ARKit
import MultipeerConnectivity
import Combine

protocol ShootTheDeviceARViewControllerDelegate:NSObjectProtocol {
    func connected(isHost:Bool)
    func gameStateChanged(state:GameState)
}

class ShootTheDeviceARViewController: UIViewController, ARSessionDelegate, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    
    weak var delegate: ShootTheDeviceARViewControllerDelegate?
    
    var arView:ARView!
    
    private static let serviceType = "shoot-device"
    private var session: MCSession!
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var serviceAdvertiser: MCNearbyServiceAdvertiser!
    private var serviceBrowser: MCNearbyServiceBrowser!
    private var connectedPeers: [MCPeerID] {
        return session.connectedPeers
    }
    var browsingTime: Int?
    var isHost: Bool?
    var gameState = GameState()
    var boardAdded = false
    
    lazy var hockeyBoard: Tools._Tools = {
        let scene = try! Tools.load_Tools()
        return scene
    }()
    
    var puck: ModelEntity!
    var hostStriker: ModelEntity!
    var guestStriker: ModelEntity!
    
    var table: ModelEntity!
    var wallFront1: ModelEntity!
    var wallFront2: ModelEntity!
    var wallBack1: ModelEntity!
    var wallBack2: ModelEntity!
    var wallLeft: ModelEntity!
    var wallRight: ModelEntity!
    
    var hostGoal: ModelEntity!
    var guestGoal: ModelEntity!
    
    var collisionSub:Cancellable?
    
    var tableMinX:Float?
    var tableMaxX:Float?
    var tableMinZ:Float?
    var tableMaxZ:Float?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let browserTime = Int(Date().timeIntervalSince1970)
        self.browsingTime = browserTime
        
        arView = ARView(frame: view.bounds)
        view.addSubview(arView)
        let arViewTap = UITapGestureRecognizer(target: self, action: #selector(tapped(sender:)))
        arView.addGestureRecognizer(arViewTap)

        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: ShootTheDeviceARViewController.serviceType)
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: ShootTheDeviceARViewController.serviceType)
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
        
        arView.session.delegate = self
        arView.scene.synchronizationService = try? MultipeerConnectivityService(session: session)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.isCollaborationEnabled = true
        arView.session.run(config, options: [])
                    setupTable()

    }
    
    func setupTable() {
        puck = hockeyBoard.puck?.children.first as! ModelEntity
        hostStriker = hockeyBoard.hostStriker?.children.first as! ModelEntity
        guestStriker = hockeyBoard.guestStriker?.children.first as! ModelEntity
        puck.generateCollisionShapes(recursive: true)
        puck.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .generate(friction: 0.1, restitution: 0.7), mode: .dynamic)
        
        hostStriker.generateCollisionShapes(recursive: true)
        hostStriker.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .kinematic)
        
        guestStriker.generateCollisionShapes(recursive: true)
        guestStriker.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .kinematic)
        
        table = hockeyBoard.table?.children.first as! ModelEntity
        table.generateCollisionShapes(recursive: true)
        table.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .generate(friction: 0, restitution: 0), mode: .static)
        
        wallBack1 = hockeyBoard.wallBack1?.children.first as! ModelEntity
        wallBack2 = hockeyBoard.wallBack2?.children.first as? ModelEntity
        wallFront1 = hockeyBoard.wallFront1?.children.first as! ModelEntity
        wallFront2 = hockeyBoard.wallFront2?.children.first as! ModelEntity
        wallLeft = hockeyBoard.wallLeft?.children.first as! ModelEntity
        wallRight = hockeyBoard.wallRight?.children.first as! ModelEntity
        
        wallLeft.generateCollisionShapes(recursive: true)
        wallRight.generateCollisionShapes(recursive: true)
        wallBack1.generateCollisionShapes(recursive: true)
        wallBack2.generateCollisionShapes(recursive: true)
        wallFront1.generateCollisionShapes(recursive: true)
        wallFront2.generateCollisionShapes(recursive: true)

        wallLeft.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .generate(friction: 0.9, restitution: 0.9), mode: .kinematic)

        hostGoal = hockeyBoard.hostGoal?.children.first?.children.first?.children.first?.children.first?.children.first?.children.first?.children.first as! ModelEntity
        guestGoal = hockeyBoard.guestGoal?.children.first?.children.first?.children.first?.children.first?.children.first?.children.first?.children.first as! ModelEntity
        
        hostGoal.generateCollisionShapes(recursive: true)
        guestGoal.generateCollisionShapes(recursive: true)
        print(hostGoal.children)
        print(hostGoal.children.first?.children.first?.children.first?.children.first?.children.first?.children.first?.name)

        // Sorry about this simple imitation of table force.
        
        collisionSub = arView.scene.subscribe(to: CollisionEvents.Began.self, { [self] event in
            
            // wall
            
            if event.entityA == wallLeft, event.entityB == puck {
                puck.addForce([10,0,0], relativeTo: puck)
            }
            if event.entityB == wallLeft, event.entityA == puck {
                puck.addForce([10,0,0], relativeTo: puck)
            }
            if event.entityA == wallRight, event.entityB == puck {
                puck.addForce([-10,0,0], relativeTo: puck)
            }
            if event.entityB == wallRight, event.entityA == puck {
                puck.addForce([-10,0,0], relativeTo: puck)
            }
            if event.entityA == wallFront1, event.entityB == puck {
                puck.addForce([0,0,10], relativeTo: puck)
            }
            if event.entityB == wallFront1, event.entityA == puck {
                puck.addForce([0,0,10], relativeTo: puck)
            }
            if event.entityA == wallFront2, event.entityB == puck {
                puck.addForce([0,0,10], relativeTo: puck)
            }
            if event.entityB == wallFront2, event.entityA == puck {
                puck.addForce([0,0,10], relativeTo: puck)
            }
            if event.entityA == wallBack1, event.entityB == puck {
                puck.addForce([0,0,-10], relativeTo: puck)
            }
            if event.entityB == wallBack1, event.entityA == puck {
                puck.addForce([0,0,-10], relativeTo: puck)
            }
            if event.entityA == wallBack2, event.entityB == puck {
                puck.addForce([0,0,-10], relativeTo: puck)
            }
            if event.entityB == wallBack2, event.entityA == puck {
                puck.addForce([0,0,-10], relativeTo: puck)
            }
            
            // Goal
            
            if event.entityA == hostGoal, event.entityB == puck {
                goal(hostGoal: true)
            }
            if event.entityB == hostGoal, event.entityA == puck {
                goal(hostGoal: true)
            }
            
            if event.entityA == guestGoal, event.entityB == puck {
                goal(hostGoal: false)
            }
            if event.entityB == guestGoal, event.entityA == puck {
                goal(hostGoal: false)
            }
        })
        
        let tableSize = table.model!.mesh.bounds.extents
        
        tableMinX = -tableSize.x / 2
        tableMaxX = tableSize.x / 2
        tableMinZ = -tableSize.z / 2
        tableMaxZ = tableSize.z / 2
        
        
        puck.removeFromParent()
//        hostStriker.removeFromParent()
//        guestStriker.removeFromParent()
        
        let arPuckAnchor = ARAnchor(transform: hockeyBoard.transformMatrix(relativeTo: nil))
        arView.session.add(anchor: arPuckAnchor)
        puckAnchor = AnchorEntity(anchor: arPuckAnchor)
        arView.scene.addAnchor(puckAnchor)
        puckAnchor.addChild(puck)
        
        arView.installGestures(.translation, for: hostStriker!)
    }
    
    var puckAnchor:AnchorEntity!
    
    @objc func tapped(sender: UITapGestureRecognizer) {
        let location = sender.location(in: arView)
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
        if results.first != nil {
            let arAnchor = ARAnchor(transform: results.first!.worldTransform)
            arView.session.add(anchor: arAnchor)
            
            let anchor = AnchorEntity(anchor: arAnchor)
            let box = ModelEntity(mesh: .generateBox(size: 0.1), materials: [SimpleMaterial(color: .black, isMetallic: true)])
//            let hockeyBoard = HockeyBoard(width: 0.2, depth: 0.3)
            hockeyBoard = try! Tools.load_Tools()
            anchor.addChild(hockeyBoard)

            arView.scene.addAnchor(anchor)

            boardAdded = true
        }
    }
    
    func goal(hostGoal: Bool) {
        if hostGoal {
            gameState.guestScore += 1
        } else {
            gameState.hostScore += 1
        }
        print(gameState)
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if tableMinX != nil {
            
            print(puckAnchor.position)
            print(hostStriker.parent?.position)
            
            let out:Bool = puck.position.x < tableMinX! || puck.position.x > tableMaxX! || puck.position.z < tableMinZ! || puck.position.z > tableMaxZ!
            if out {
                puck.removeFromParent()
                puck.position = [0,0.05,0]
                puck.orientation = simd_quatf(angle: 0, axis: [1,1,1])
                hockeyBoard.addChild(puck)
            }
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let participantAnchor = anchor as? ARParticipantAnchor {
                let anchorEntity = AnchorEntity(anchor: participantAnchor)
                arView.scene.addAnchor(anchorEntity)
            }
        }
    }
    
    // MARK: - MultiPeerConnectivity Delegates
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        guard let browsingTime = self.browsingTime else {return}
        guard let context = context else {return}
        guard let invitationTimeString = String(data:context,encoding: .ascii) else {return}
        guard let invitationTime = Int(invitationTimeString) else {return}
        isHost = browsingTime < invitationTime
        delegate?.connected(isHost: isHost!)
        print(browsingTime)
        print(invitationTime)
        invitationHandler(true, self.session)
        print(peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard let browsingTime = browsingTime else {return}
        let timeData = browsingTime.description.data(using: .ascii)
        browser.invitePeer(peerID, to: session, withContext: timeData, timeout: 10)
        print(peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
}
