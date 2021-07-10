//
//  ShootTheDeviceView.swift
//  RealityKitSampler
//
//  Created by Daisuke Majima on 2021/06/30.
//

import SwiftUI

struct ARHockeyView: View {
    @State var gameState: GameState?
    @State var isHost:Bool?
    @State var hostScore:Int = 0
    @State var guestScore:Int = 0
    @State var gameStateText:String = ""
    
    var body: some View {
        ZStack {
            ShootTheDeviceARViewContainer(gameState: $gameState, isHost: $isHost, hostScore: $hostScore, guestScore: $guestScore)
                .edgesIgnoringSafeArea(.all)
            VStack {
                switch gameState?.isHost {
                case true: Text("(You) black \(gameState?.hostScore ?? 0) : \(gameState?.guestScore ?? 0) white" )
                    .font(.system(size: 24, weight:.bold))
                    .foregroundColor(.black)
                case false: Text("black \(gameState?.hostScore ?? 0) : \(gameState?.guestScore ?? 0) white (You)" )
                    .font(.system(size: 24, weight:.bold))
                    .foregroundColor(.white)
                default:
                    Text("(You) black \(gameState?.hostScore ?? 0) : \(gameState?.guestScore ?? 0) white (NPC)")
                        .font(.system(size: 24, weight:.bold))
                        .foregroundColor(.white)
                }
                switch gameState?.boardAdded {
                case true: Text("")
                default: Text("Place board by tapping plane.")
                }
                Spacer()
                if gameState?.isHost == nil {
                    Text("If an another device lauch this game, you automatically connect")
                }
            }
        }
    }
}

struct ShootTheDeviceARViewContainer: UIViewControllerRepresentable {
    
    @Binding var gameState: GameState?
    @Binding var isHost:Bool?
    @Binding var hostScore:Int
    @Binding var guestScore:Int

    func makeUIViewController(context: UIViewControllerRepresentableContext<ShootTheDeviceARViewContainer>) -> ARHockeyARViewController {
        let viewController = ARHockeyARViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: ARHockeyARViewController, context: UIViewControllerRepresentableContext<ShootTheDeviceARViewContainer>) {

    }
    
    func makeCoordinator() -> ShootTheDeviceARViewContainer.Coordinator {
        return Coordinator(gameState: $gameState, isHost: $isHost, hostScore: $hostScore, guestScore:  $guestScore)
    }
    
    class Coordinator: NSObject, ARHockeyARViewControllerDelegate {
        
        @Binding var gameState: GameState!
        @Binding var isHost:Bool?
        @Binding var hostScore:Int
        @Binding var guestScore:Int
        
        init(gameState:Binding<GameState?>, isHost: Binding<Bool?>, hostScore: Binding<Int>, guestScore: Binding<Int>) {
            _gameState = gameState
            _isHost = isHost
            _hostScore = hostScore
            _guestScore = guestScore
        }
        
        func connected(isHost: Bool) {
            self.isHost = isHost
        }
        
        func gameStateChanged(state: GameState) {
            self.gameState = state
        }
        
        
    }
}
struct ShootTheDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        ARHockeyView()
    }
}
