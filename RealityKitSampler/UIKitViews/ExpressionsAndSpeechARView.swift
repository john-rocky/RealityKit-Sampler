//
//  ExpressionsAndSpeechARView.swift
//  RealityKitSampler
//
//  Created by Daisuke Majima on 2021/06/26.
//

import UIKit
import SwiftUI
import RealityKit
import ARKit
import Speech
import AVFoundation

class ExpressionsAndSpeechARView: ARView, ARSessionDelegate {

    private var speechBalloon:Entity!
    private var smileLeft:ModelEntity!
    private var smileRight:ModelEntity!
    private var smileText:Entity!
    private var cheekLeft:ModelEntity!
    private var cheekRight:ModelEntity!
    private var cheekText:Entity!

    private var speechRecognizer:SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine:AVAudioEngine?
    private var inputNode:AVAudioInputNode?

    private var recognitionInitialized = false
    
    @Binding var expression: Expression
    
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
        smileLeft = faceScene.smileLeft?.children.first as! ModelEntity
        smileRight = faceScene.smileRight?.children.first as! ModelEntity
        smileText = faceScene.smileText
        cheekLeft = faceScene.cheekLeft?.children.first as! ModelEntity
        cheekRight = faceScene.cheekRight?.children.first as! ModelEntity
        cheekText = faceScene.cheekText
        
        let smileColor = UIColor.init(cgColor: #colorLiteral(red: 1, green: 0.7907919884, blue: 0.9095974565, alpha: 0.147529118))
        smileLeft.model?.materials = [UnlitMaterial(color: smileColor)]
        smileRight.model?.materials = [UnlitMaterial(color: smileColor)]
        smileLeft.isEnabled = false
        smileRight.isEnabled = false
        smileText.isEnabled = false
        
        let cheekColor = UIColor.init(cgColor: #colorLiteral(red: 1, green: 0.7203390002, blue: 0.3678158522, alpha: 0.147529118))
        cheekLeft.model?.materials = [UnlitMaterial(color: cheekColor)]
        cheekRight.model?.materials = [UnlitMaterial(color: cheekColor)]
        cheekLeft.isEnabled = false
        cheekRight.isEnabled = false
        cheekText.isEnabled = false

        startSpeechRecognition()
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

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        speechRecognizer?.defaultTaskHint = .confirmation
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                isFinal = result.isFinal
                print("Text \(result.bestTranscription.formattedString)")
                let resultString = result.bestTranscription.formattedString
                self.getCurrentText(speechText: resultString)
            }
            
            if error != nil || isFinal {
                print(error)
            }
        }
        
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
                
                smileLeft.isEnabled = false
                smileRight.isEnabled = false
                smileText.isEnabled = false

                cheekLeft.isEnabled = false
                cheekRight.isEnabled = false
                cheekText.isEnabled = false

                continue
            }
                
            let expression = max(smile, angry, surprise)
            
            switch expression {
            
            case smile:
                smileLeft.isEnabled = true
                smileRight.isEnabled = true
                smileText.isEnabled = true

            case angry:
                cheekLeft.isEnabled = true
                cheekRight.isEnabled = true
                cheekText.isEnabled = true

            default:
                break
            
            }
        }
    }
}
