//
//  PersonCropperARViewController.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/07/02.
//

import UIKit
import RealityKit
import Vision
import ARKit

class FaceCropperARViewController: UIViewController, ARSessionDelegate {
    
    var arView: ARView!
    
    lazy var request:VNRequest = {
        let request = VNDetectFaceRectanglesRequest(completionHandler: completionHandler)
        return request
    }()
    
    lazy var qualityRequest: VNRequest = {
        let request = VNDetectFaceCaptureQualityRequest(completionHandler: completionHandler)
        return request
    }()
    
    var isRequesting = false
    var currentPixelBuffer: CVPixelBuffer!
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView = ARView(frame: view.bounds)
        view.addSubview(arView)
        arView.session.delegate = self
        
    }
    
    func completionHandler(request: VNRequest?, error: Error?) {
        guard let result = request?.results?.first as? VNFaceObservation else {
            isRequesting = false
            return
        }
        
        let boundingBox = result.boundingBox
        print(boundingBox)
        print(result.faceCaptureQuality)
        if let quality = result.faceCaptureQuality, quality > 0.4 {
            let ciImage = CIImage(cvImageBuffer: currentPixelBuffer)
            let faceRect = VNImageRectForNormalizedRect((boundingBox),Int(ciImage.extent.size.width), Int(ciImage.extent.size.height))
            let croppedImage = ciImage.cropped(to: faceRect)
            let rotatedImage:CIImage = croppedImage.transformed(by: CGAffineTransform(rotationAngle: -90 * .pi / 180))
            let context = CIContext()
            
            guard let cgImage = context.createCGImage(rotatedImage, from: rotatedImage.extent),
                  let imageData = UIImage(cgImage: cgImage).pngData(),
                  let url = try? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("temp.png"),
                  ((try? imageData.write(to: url)) != nil) else {isRequesting = false; return}
            
            self.url = url
            let referenceImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: 0.1)
            let config = ARImageTrackingConfiguration()
            config.trackingImages = [referenceImage]
            arView.session.run(config, options: [.removeExistingAnchors])
            
        } else {
            isRequesting = false
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if !isRequesting {
            isRequesting = true
            DispatchQueue.global(qos: .userInitiated).async {
                let pixelBuffer = frame.capturedImage
                self.currentPixelBuffer = pixelBuffer
                let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
                do {
                    try handler.perform([self.qualityRequest])
                } catch let error {
                    print(error)
                }
            }
        }
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let imageAnchor = anchor as? ARImageAnchor else {continue}
            print(imageAnchor.estimatedScaleFactor)
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
                let anchorEntity = AnchorEntity(anchor: imageAnchor)
                var material = UnlitMaterial(color: .white)
                let texture = try? TextureResource.load(contentsOf: self.url!)
                material.baseColor = MaterialColorParameter.texture(texture!)
                let faceBox = ModelEntity(mesh: .generateBox(size: [0.1,0.02,Float(imageAnchor.referenceImage.physicalSize.height)]), materials: [material])
                
                let croppedBox = ModelEntity(mesh: .generateBox(size: [0.1,0.02,Float(imageAnchor.referenceImage.physicalSize.height)]), materials: [SimpleMaterial(color: .black, isMetallic: true)])
                croppedBox.position = [0,-0.01,0]
                anchorEntity.addChild(croppedBox)
                anchorEntity.addChild(faceBox)
                self.arView.scene.addAnchor(anchorEntity)
                faceBox.move(to: Transform(translation:[0,0,0.3]), relativeTo: faceBox, duration: 3, timingFunction: .easeInOut)
            }
            
        }
    }
}
