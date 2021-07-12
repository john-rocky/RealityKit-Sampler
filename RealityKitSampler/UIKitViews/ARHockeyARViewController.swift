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

protocol ARHockeyARViewControllerDelegate:NSObjectProtocol {
    func modelChanged(model:ARHockeyModel)
}

class ARHockeyARViewController: UIViewController, ARSessionDelegate, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, ARCoachingOverlayViewDelegate {
    
    weak var delegate: ARHockeyARViewControllerDelegate?
    
    var arView:ARView!
    let coachingOverlay = ARCoachingOverlayView()
    
    private static let serviceType = "ar-hockey"
    private var session: MCSession!
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var serviceAdvertiser: MCNearbyServiceAdvertiser!
    private var serviceBrowser: MCNearbyServiceBrowser!
    private var connectedPeers: [MCPeerID] {
        return session.connectedPeers
    }
    var browsingTime: Int?
    var model = ARHockeyModel()
    
    private var hapticsManager = HapticsManager()
    var audioPlaybackController:AudioPlaybackController?
    var goalPlayBackController:AudioPlaybackController?
    lazy var sceneElement: Tools._Tools = {
        let scene = try! Tools.load_Tools()
        return scene
    }()
    
    var anchor:AnchorEntity?
    
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
    
    lazy var goalText: ModelEntity = {
        let text = ModelEntity(mesh: .generateText("Goal", extrusionDepth: 0.01, font: .systemFont(ofSize: 0.04, weight: .bold), containerFrame: CGRect(), alignment: .left, lineBreakMode: .byCharWrapping), materials: [hostMaterial])
        text.position = [-0.05,0,0]
        return text
    }()
    
    var hostMaterial: SimpleMaterial = SimpleMaterial(color: .white, isMetallic: true)
    var guestMaterial: SimpleMaterial = SimpleMaterial(color: .black, isMetallic: true)
    
    var collisionSub:Cancellable!
    var animationSub:Cancellable!
    var recievedAnchorSub:Cancellable?
    
    var tableMinX:Float?
    var tableMaxX:Float?
    var tableMinZ:Float?
    var tableMaxZ:Float?
    
    var goalScaleCount = 0
    
    var nonPlayerCharacterTimer: Timer?
    
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
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: ARHockeyARViewController.serviceType)
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: ARHockeyARViewController.serviceType)
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
        
        arView.session.delegate = self
        arView.scene.synchronizationService = try? MultipeerConnectivityService(session: session)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        config.isCollaborationEnabled = true
        arView.session.run(config, options: [])
        setupTable()
        
        hapticsManager.createEngine()
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.session = arView.session
        coachingOverlay.delegate = self
        coachingOverlay.frame = arView.bounds
        arView.addSubview(coachingOverlay)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nonPlayerCharacterTimer?.invalidate()
        arView.session.pause()
    }
    
    func setupTable() {
        puck = sceneElement.puck?.children.first as! ModelEntity
        hostStriker = sceneElement.hostStriker?.children.first as! ModelEntity
        guestStriker = sceneElement.guestStriker?.children.first as! ModelEntity
        puck.generateCollisionShapes(recursive: true)
        puck.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .generate(friction: 0.1, restitution: 0.7), mode: .dynamic)
        
        hostStriker.generateCollisionShapes(recursive: true)
        hostStriker.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .kinematic)
        
        guestStriker.generateCollisionShapes(recursive: true)
        guestStriker.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .kinematic)
        
        table = sceneElement.table?.children.first as! ModelEntity
        table.generateCollisionShapes(recursive: true)
        table.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .generate(friction: 0, restitution: 0), mode: .static)
        
        wallBack1 = sceneElement.wallBack1?.children.first as! ModelEntity
        wallBack2 = sceneElement.wallBack2?.children.first as? ModelEntity
        wallFront1 = sceneElement.wallFront1?.children.first as! ModelEntity
        wallFront2 = sceneElement.wallFront2?.children.first as! ModelEntity
        wallLeft = sceneElement.wallLeft?.children.first as! ModelEntity
        wallRight = sceneElement.wallRight?.children.first as! ModelEntity
        
        wallLeft.generateCollisionShapes(recursive: true)
        wallRight.generateCollisionShapes(recursive: true)
        wallBack1.generateCollisionShapes(recursive: true)
        wallBack2.generateCollisionShapes(recursive: true)
        wallFront1.generateCollisionShapes(recursive: true)
        wallFront2.generateCollisionShapes(recursive: true)
        
        wallLeft.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .generate(friction: 0.9, restitution: 0.9), mode: .kinematic)
        
        let goalModel = ModelEntity(mesh: .generateBox(size: [0.07,0.01,0.02]), materials: [SimpleMaterial(color: .black, isMetallic: true)])
        
        
        hostGoal = goalModel.clone(recursive: true)
        guestGoal = goalModel.clone(recursive: true)
        hostGoal.generateCollisionShapes(recursive: true)
        guestGoal.generateCollisionShapes(recursive: true)
        
        
        do {
            let audioResource = try AudioFileResource.load(named: "Collision.mp3",
                                                           in: nil,
                                                           inputMode: .spatial,
                                                           loadingStrategy: .preload,
                                                           shouldLoop: false)
            
            audioPlaybackController = puck.prepareAudio(audioResource)
            
        } catch {
            print("Error loading audio file")
        }
        
        
        do {
            let audioResource = try AudioFileResource.load(named: "goal.mp3",
                                                           in: nil,
                                                           inputMode: .spatial,
                                                           loadingStrategy: .preload,
                                                           shouldLoop: false)
            
            goalPlayBackController = table.prepareAudio(audioResource)
        } catch {
            print("Error loading audio file")
        }
        
        
        // Set collisions between the puck and the other objects.
        
        collisionSub = arView.scene.subscribe(to: CollisionEvents.Began.self, { [self] event in
            hapticsManager.playHapticTransient()
            
            // The simple bounce of the walls and puck.
            
            if event.entityA == wallLeft, event.entityB == puck {
                puck.addForce([10,0,0], relativeTo: puck)
                audioPlaybackController?.play()
                
            }
            
            if event.entityA == wallRight, event.entityB == puck {
                puck.addForce([-10,0,0], relativeTo: puck)
                audioPlaybackController?.play()
                
            }
            
            if event.entityA == wallFront1, event.entityB == puck {
                puck.addForce([0,0,10], relativeTo: puck)
                audioPlaybackController?.play()
                
            }
            
            if event.entityA == wallFront2, event.entityB == puck {
                puck.addForce([0,0,10], relativeTo: puck)
                audioPlaybackController?.play()
                
            }
            
            if event.entityA == wallBack1, event.entityB == puck {
                puck.addForce([0,0,-10], relativeTo: puck)
                audioPlaybackController?.play()
            }
            
            if event.entityA == wallBack2, event.entityB == puck {
                puck.addForce([0,0,-10], relativeTo: puck)
                audioPlaybackController?.play()
            }
            
            if event.entityA == hostStriker, event.entityB == puck {
                audioPlaybackController?.play()
            }
            
            if event.entityA == guestStriker, event.entityB == puck {
                audioPlaybackController?.play()
            }
            
            // Goal
            
            if event.entityA == hostGoal, event.entityB == puck {
                goal(hostGoal: true)
            }
            
            if event.entityA == guestGoal, event.entityB == puck {
                goal(hostGoal: false)
            }
        })
        
        
        // Setup the goal animation.
        animationSub = arView.scene.subscribe(to: AnimationEvents.PlaybackCompleted.self, on: goalText, { [self] event in
            goalText.isEnabled = false
            goalText.position = [-0.05,0,0]
        })
        
        
        // Capture table size for turning back the puck when it is out of table.
        
        let tableSize = table.model!.mesh.bounds.extents
        
        tableMinX = -tableSize.x / 2
        tableMaxX = tableSize.x / 2
        tableMinZ = -tableSize.z / 2
        tableMaxZ = tableSize.z / 2
        
        guestStriker.name = "guestStriker"
        guestStriker.synchronization?.ownershipTransferMode = .autoAccept
        
        recievedAnchorSub = arView.scene.subscribe(to: SceneEvents.AnchoredStateChanged.self, on: anchor) { [self] event in
            if event.isAnchored , let isHost = model.isHost, !isHost {
                // [Guest] The host's table has been shared.
                tableSharedFromHost()
            }
        }
    }
    
    @objc func tapped(sender: UITapGestureRecognizer) {
        // Place the table on the tapped plane.
        guard !model.tableAdded, model.isHost ?? true else {
            // If the table have alredy been added or this device is the guest, do nothing.
            return
        }
        let location = sender.location(in: arView)
        let results = arView.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .any)
        if results.first != nil {
            
            // Make anchor from tapped plane.
            let arAnchor = ARAnchor(transform: results.first!.worldTransform)
            arView.session.add(anchor: arAnchor)
            
            anchor = AnchorEntity(anchor: arAnchor)
            
            // Place table and puck in the anchor.
            wallFront1.position = [-0.0666,0.01,-0.151]
            wallFront2.position = [0.0686,0.01,-0.151]
            wallBack1.position = [-0.0666,0.01,0.151]
            wallBack2.position = [0.067,0.01,0.151]
            wallLeft.position = [-0.099,0.01,0]
            wallRight.position = [0.101,0.01,0]
            
            wallFront1.scale = [0.94,0.94,0.94]
            wallFront2.scale = [0.94,0.94,0.94]
            wallBack1.scale = [0.94,0.94,0.94]
            wallBack2.scale = [0.94,0.94,0.94]
            hostStriker.position = [0.0072,0.01,0.1084]
            guestStriker.position = [0.0024,0.01,-0.1019]
            hostGoal.position = [0,0, -0.15]
            guestGoal.position = [0,0, 0.15]
            
            anchor!.addChild(table)
            anchor!.addChild(wallFront1)
            anchor!.addChild(wallFront2)
            anchor!.addChild(wallBack1)
            anchor!.addChild(wallBack2)
            anchor!.addChild(wallLeft)
            anchor!.addChild(wallRight)
            anchor!.addChild(hostStriker)
            anchor!.addChild(guestStriker)
            anchor!.addChild(puck)
            anchor!.addChild(hostGoal)
            anchor!.addChild(guestGoal)
            anchor!.addChild(goalText)
            
            goalText.isEnabled = false
            
            arView.scene.addAnchor(anchor!)
            
            // Set gesture to the host striker.
            arView.installGestures(.translation, for: hostStriker!)
            
            model.tableAdded = true
            gameStateChanged()
            
            
            if let isHost = model.isHost {
                if isHost {
                    // If connected, let guest know table added.
                    sendHostTableAdded()
                }
            } else {
                // If not connected, set non player character.
                setNonPlayerCharacter()
            }
        }
    }
    
    private func setNonPlayerCharacter() {
        
        // Non player charactor move the guest striker until the game is connected with another device.
        
        nonPlayerCharacterTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { [unowned self] timer in
            guard model.isHost == nil else {
                // If connected, stop the non player character.
                timer.invalidate()
                return
            }
            let positionDiff = puck.position - guestStriker.position
            guestStriker.move(to: Transform(translation: positionDiff), relativeTo: guestStriker, duration: 1, timingFunction: .easeInOut)
            
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _timer in
                let backPositionDiff = [Float.random(in: -0.1...0.1),0.01,-0.1019] - guestStriker.position
                guestStriker.move(to: Transform(translation:backPositionDiff), relativeTo: guestStriker, duration: 0.75, timingFunction: .easeOut)
            }
        })
    }
    
    private func goal(hostGoal: Bool) {
        if hostGoal {
            goalText.model?.materials = [guestMaterial]
            model.gameState.hostScore += 1
            
        } else {
            model.gameState.guestScore += 1
            goalText.model?.materials = [hostMaterial]
        }
        goalText.isEnabled = true
        goalText.move(to: Transform(translation:[0,0.1,0]), relativeTo: goalText, duration: 1, timingFunction: .easeInOut)
        gameStateChanged()
        goalPlayBackController?.play()
    }
    
    private func gameStateChanged(){
        delegate?.modelChanged(model: model)
        
        // If connected, send game state to another peer.
        
        guard model.isHost ?? true else {
            return
        }
        let encoder = JSONEncoder()
        do {
            let stateData = try encoder.encode(model.gameState)
            sendToAllPeers(stateData)
        } catch let err {
            print(err)
        }
    }
    
    private func sendHostTableAdded() {
        let guestTableAddedString = "hostTableAdded"
        guard let stringData = guestTableAddedString.data(using: .ascii) else {return}
        sendToAllPeers(stringData)
    }
    
    private func setupMultiPlayersGame() {
        
        // [Both] Reset the scores.
        model.gameState.hostScore = 0
        model.gameState.guestScore = 0
    }
    
    private func sendToAllPeers(_ data: Data) {
        // Send data to another peer.
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("error sending data to peers: \(error.localizedDescription)")
        }
    }
    
    // MARK: -Guest side function
    
    private func hostTableAdded() {
        model.tableAdded = true
        delegate?.modelChanged(model: model)
    }
    
    private func tableSharedFromHost() {
        model.tableAddedInGuestDevice = true
        delegate?.modelChanged(model: model)
        addGestureToGuestStriker()
        let guestTableAddedString = "guestTableAdded"
        guard let stringData = guestTableAddedString.data(using: .ascii) else {return}
        sendToAllPeers(stringData)
    }
    
    private func removeExistingTable() {
        // [Guest] Remove the existing table.
        self.anchor?.removeFromParent()
    }
    
    private func addGestureToGuestStriker() {
        for anchor in arView.scene.anchors {
            guard let guestStriker = anchor.children.first(where: {$0.name == "guestStriker"}) else { continue
            }
            guestStriker.requestOwnership { [self] result in
                if result == .granted {
                    arView.installGestures(.translation, for: arView.scene.anchors.first?.children.first(where: {$0.name == "guestStriker"})! as! HasCollision)
                    nonPlayerCharacterTimer?.invalidate()
                }
            }
        }
    }
    
    private func didReceiveGameState(state:GameState) {
        // [Guest] Update game state with received state.
        if !(model.isHost ?? false) {
            model.gameState = state
            delegate?.modelChanged(model: model)
        }
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if tableMinX != nil {
            let out:Bool = puck.position.x < tableMinX! || puck.position.x > tableMaxX! || puck.position.z < tableMinZ! || puck.position.z > tableMaxZ!
            if out {
                puck.removeFromParent()
                puck.position = [0,0.05,0]
                puck.orientation = simd_quatf(angle: 0, axis: [1,1,1])
                anchor?.addChild(puck)
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
        
        if let receivedString = String(data: data, encoding: .ascii) {
            switch receivedString {
            case "hostTableAdded" :
                
                // [Guest]
                hostTableAdded()

            case "guestTableAdded" :
                // [Host] The table shared with the guest.
                model.tableAddedInGuestDevice = true
                delegate?.modelChanged(model: model)
                // Game start
                setupMultiPlayersGame()
            default:
                break
            }
            
        }
        
        
        
        let decoder = JSONDecoder()
        if let receivedState = try?  decoder.decode(GameState.self, from: data) {
            didReceiveGameState(state: receivedState)
        }
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
        model.isHost = browsingTime < invitationTime
        model.connectedDeviceName = peerID.displayName
        delegate?.modelChanged(model: model)
        setupMultiPlayersGame()
        gameStateChanged()
        if !self.model.isHost! {
            // [Guest]
            removeExistingTable()
        } else if model.tableAdded {
            // If host table has been already added, let guest know it and move guest's device.
            sendHostTableAdded()
        }
        invitationHandler(true, self.session)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard let browsingTime = browsingTime else {return}
        let timeData = browsingTime.description.data(using: .ascii)
        browser.invitePeer(peerID, to: session, withContext: timeData, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
}
