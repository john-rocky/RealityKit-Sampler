//
//  ExpressionsAndSpeechARView.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/26.
//

import UIKit
import SwiftUI
import RealityKit
import ARKit
import Speech
import AVFoundation

protocol ExpressionsAndSpeechARViewDelegate: NSObjectProtocol {
    func expressionDidChange(expression:ExpressionsAndSpeechARView.Expression)
}

class ExpressionsAndSpeechARView: ARView, ARSessionDelegate {

    private var speechBalloon:Entity!
    
    private var speechRecognizer:SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine:AVAudioEngine?
    private var inputNode:AVAudioInputNode?

    private var recognitionInitialized = false
    
    @Binding var expression: Expression
    weak var delegate: ExpressionsAndSpeechARViewDelegate?
    
    public enum Expression:String {
        case normal
        case smile
        case angry
        case surprise
        case naughty
    }
        
    init(frame: CGRect, expression:Binding<Expression>){
        self._expression = expression
        super.init(frame: frame)
        let config = ARFaceTrackingConfiguration()
        session.delegate = self
        session.run(config, options: [])
        
        guard let faceScene = try? Face.loadFaceScene() else {return}
        scene.addAnchor(faceScene)
        speechBalloon = faceScene.speechBalloon
        updateSpeechText(speechText: "chocolate")
        
        startSpeechRecognition()
        addExpressionSpheres()
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    func startSpeechRecognition() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale.current) ?? SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
        audioEngine = AVAudioEngine()
        SFSpeechRecognizer.requestAuthorization { authStatus in
            
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    print("Say something")
                case .denied:
                    print("Please allow access to speech recognition")
                case .restricted:
                    print("Speech recognition restricted on this device")
                    
                case .notDetermined:
                    print("Please allow access to speech recognition")
                default:
                    break
                }
            }
        }

        recognitionTask?.cancel()
        self.recognitionTask = nil
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch let error {
            print(error)
        }
        inputNode = audioEngine!.inputNode
        // Configure the audio session for the app.

        
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        speechRecognizer?.defaultTaskHint = .confirmation
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                // Update the text view with the results.
                isFinal = result.isFinal
                print("Text \(result.bestTranscription.formattedString)")
                let resultString = result.bestTranscription.formattedString
                self.getCurrentText(speechText: resultString)
//                self.updateSpeechText(speechText: resultString)
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                print(error)
//                self.audioEngine?.stop()
//                self.inputNode?.removeTap(onBus: 0)
//
//                self.recognitionRequest = nil
//                self.recognitionTask = nil
            }
        }
        
        // Configure the microphone input.
        let recordingFormat = inputNode?.outputFormat(forBus: 0)
        inputNode?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine?.prepare()
        do {
            try audioEngine?.start()
        } catch let error {
            print(error)
        }
        recognitionInitialized = false
    }
    
    
    func getCurrentText(speechText: String) {

        print(speechText.count)
        var currentText = speechText
        switch speechText.count {
        case 21...40 :
            currentText.insert("\n", at: currentText.index(currentText.startIndex, offsetBy: 20))
            updateSpeechText(speechText: currentText)
        case 41...60 :
            currentText.insert("\n", at: currentText.index(currentText.startIndex, offsetBy: 20))
            currentText.insert("\n", at: currentText.index(currentText.startIndex, offsetBy: 40))
            updateSpeechText(speechText: currentText)
        case 61...80 :
            currentText.insert("\n", at: currentText.index(currentText.startIndex, offsetBy: 20))
            currentText.insert("\n", at: currentText.index(currentText.startIndex, offsetBy: 40))
            currentText.insert("\n", at: currentText.index(currentText.startIndex, offsetBy: 60))
            updateSpeechText(speechText: currentText)
        case 81...:
            self.audioEngine?.stop()
            self.inputNode?.removeTap(onBus: 0)
            recognitionTask?.cancel()
            self.recognitionRequest = nil
            self.recognitionTask = nil
            if !recognitionInitialized {
                recognitionInitialized = true
                
                startSpeechRecognition()
            }
        default:
            updateSpeechText(speechText: currentText)
        }
    }
    
    func updateSpeechText(speechText: String) {
        guard let text = speechBalloon?.children[1].children.first?.children.first as? ModelEntity, let balloon = speechBalloon?.children[0] else {return}
        var textComponent:ModelComponent = (text.components[ModelComponent])!
        textComponent.mesh = .generateText(speechText,extrusionDepth: 0.01,
                                           font: .systemFont(ofSize: 0.08),
                                           containerFrame: CGRect(),
                                           alignment: .left,
                                           lineBreakMode: .byCharWrapping)
        text.components.set(textComponent)
    }
    
    func addExpressionSpheres() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.font = .systemFont(ofSize: 20)
        label.text = "😁"
        addSubview(label)
        if let snapShot = label.snapshot, let data = snapShot.pngData() {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = documentsDirectory.appendingPathComponent("temp.png")
            try? data.write(to: filePath)
            let anchorEntity = AnchorEntity(world: [0,0,-0.5])
            let modelEntity = ModelEntity(mesh: .generateBox(size: 0.1))
            guard let texture = try? TextureResource.load(contentsOf: filePath) else {return}
            var material = UnlitMaterial()
            material.baseColor = MaterialColorParameter.texture(texture)
            modelEntity.model?.materials = [material]
            anchorEntity.addChild(modelEntity)
            scene.addAnchor(anchorEntity)
        }

    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let faceAnchor = anchor as? ARFaceAnchor else { continue }
            let blendShapes = faceAnchor.blendShapes
            guard let smile = blendShapes[.mouthSmileLeft]?.doubleValue,
                  let angry = blendShapes[.cheekPuff]?.doubleValue,
                  let surprise = blendShapes[.jawOpen]?.doubleValue,
                  let nauty = blendShapes[.tongueOut]?.doubleValue,
                  (smile > 0.75 || angry > 0.75 || surprise > 0.75 || nauty > 0.75) else {
                self.expression = .normal
                continue
            }
                
            let expression = max(smile, angry, surprise)
            switch expression {
            case smile:
                delegate?.expressionDidChange(expression: .smile)
            case angry:
                delegate?.expressionDidChange(expression: .angry)
            case surprise:
                delegate?.expressionDidChange(expression: .surprise)
            case nauty:
                delegate?.expressionDidChange(expression: .naughty)
            default:
                delegate?.expressionDidChange(expression: .normal)
            }
        }
    }
}

extension UIView {
    var snapshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
