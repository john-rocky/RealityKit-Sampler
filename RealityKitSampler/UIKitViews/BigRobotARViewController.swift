//
//  BigRobotARViewController.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/07/07.
//

import UIKit
import RealityKit
import ARKit
import Combine

class BigRobotARViewController: UIViewController, ARCoachingOverlayViewDelegate {

    private var arView: ARView!
    private let coachingOverlay = ARCoachingOverlayView()
    private var animationEnd: Cancellable!
    private var go = true
    private var robot:Entity!
    private var drummer:Entity!
    private var moveFoward = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        arView = ARView(frame: view.bounds)
        view.addSubview(arView)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        arView.environment.sceneUnderstanding.options = [.occlusion]
        arView.session.run(config, options: [])
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.activatesAutomatically = false
        coachingOverlay.session = arView.session
        coachingOverlay.delegate = self
        coachingOverlay.frame = arView.bounds
        arView.addSubview(coachingOverlay)
        placeRobots()
    }
    
    private func placeRobots() {
        guard let robot = try? Entity.load(named: "robot"),
              let drummer = try? Entity.load(named: "drummer") else { return }
        self.robot = robot
        self.drummer = drummer
        let anchor = AnchorEntity(plane: .horizontal)
        anchor.addChild(robot)
        anchor.addChild(drummer)


        robot.orientation = simd_quatf(angle:.pi , axis: [0,1,0])

        arView.scene.addAnchor(anchor)
        
        robot.position = [-10,0,-30]
        print(robot.visualBounds(relativeTo: nil))
        drummer.position = [0,0,-60]
        robot.setScale([100,100,100], relativeTo: robot)
        drummer.setScale([100,100,100], relativeTo: drummer)

        for animation in robot.availableAnimations {
            robot.playAnimation(animation.repeat())
        }
        
        for animation in drummer.availableAnimations {
            drummer.playAnimation(animation.repeat())
        }
        
        robot.orientation = simd_quatf(angle: 90 * .pi / 180, axis: [0,1,0])
        robot.move(to: Transform(translation: [0,0,20]), relativeTo: robot, duration: 4, timingFunction: .easeInOut)
        
        
        
        animationEnd = arView.scene.subscribe(to: AnimationEvents.PlaybackCompleted.self, { [self] event in
            moveFoward.toggle()
            if moveFoward {
                robot.move(to: Transform(translation: [0,0,20]), relativeTo: robot, duration: 4, timingFunction: .easeInOut)
            } else {
                robot.move(to: Transform(rotation: simd_quatf(angle: 90 * .pi / 180, axis: [0,1,0]) ), relativeTo: robot, duration: 3, timingFunction: .easeInOut)
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
