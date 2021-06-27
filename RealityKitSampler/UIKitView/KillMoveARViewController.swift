//
//  KillMoveARViewController.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/27.
//

import UIKit
import RealityKit
import ARKit
import Vision

class KillMoveARViewController: UIViewController, ARSessionDelegate {

    private var arView: ARView!

    override func viewDidLoad() {
        super.viewDidLoad()
        arView = ARView(frame: view.bounds)
        view.addSubview(arView)
        arView.session.delegate = self
        // Do any additional setup after loading the view.
    }
    

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
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
