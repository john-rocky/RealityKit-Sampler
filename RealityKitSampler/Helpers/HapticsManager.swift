//
//  HapticsManager.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/07/09.
//

import Foundation
import CoreHaptics

class HapticsManager: NSObject {
    var supportsHaptics: Bool = false
    var engine: CHHapticEngine?

    override init(){
        super.init()
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        supportsHaptics = hapticCapability.supportsHaptics
    }
    
    func createEngine() {
        
        guard supportsHaptics else {
            return
        }
        
        do {
            engine = try CHHapticEngine()
        } catch let error {
            print("Engine Creation Error: \(error)")
            return
        }
        
        engine!.stoppedHandler = { reason in
            print("Stop Handler: The engine stopped for reason: \(reason.rawValue)")
            switch reason {
            case .audioSessionInterrupt: print("Audio session interrupt")
            case .applicationSuspended: print("Application suspended")
            case .idleTimeout: print("Idle timeout")
            case .notifyWhenFinished: print("Finished")
            case .systemError: print("System error")
            case .engineDestroyed: print("engineDestroyed")
            case .gameControllerDisconnect: print("gameControllerDisconnect")
            @unknown default:
                print("Unknown error")
            }
        }
        engine!.resetHandler = { [weak self] in
            print("The engine reset --> Restarting now!")
            do {
                try self?.engine!.start()
            } catch let error {
                fatalError("Engine Start Error: \(error)")
            }
        }
        do {
            try self.engine!.start()
        } catch let error {
           fatalError("Engine Start Error: \(error)")
        }
    }
    
    func playHapticTransient() {
        
        guard supportsHaptics else {
            return
        }
        
        let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity,
                                                        value: 1)
        let sharpnessParameter = CHHapticEventParameter(parameterID: .hapticSharpness,
                                                        value: 1)

        let event = CHHapticEvent(eventType: .hapticTransient,
                                  parameters: [intensityParameter, sharpnessParameter],
                                  relativeTime: 0)

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate) // Play now.
        } catch let error {
            print("Error creating a haptic transient pattern: \(error)")
        }
    }
}
