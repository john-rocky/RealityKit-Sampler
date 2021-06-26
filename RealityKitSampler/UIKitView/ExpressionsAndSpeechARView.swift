//
//  ExpressionsAndSpeechARView.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/26.
//

import UIKit
import RealityKit
import ARKit
import Speech
import AVFoundation

class ExpressionsAndSpeechARView: ARView, ARSessionDelegate {

    private var speechBalloon:Entity!
    
    private var speechRecognizer:SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine:AVAudioEngine?
    private var inputNode:AVAudioInputNode?

    private var recognitionInitialized = false
        
    required init(frame: CGRect){
        super.init(frame: frame)
        let config = ARFaceTrackingConfiguration()
        session.run(config, options: [])

        guard let faceScene = try? Face.loadFaceScene() else {return}
        scene.addAnchor(faceScene)
        speechBalloon = faceScene.speechBalloon
        updateSpeechText(speechText: "chocolate")
        
        startSpeechRecognition()

    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            
        }
    }
}
