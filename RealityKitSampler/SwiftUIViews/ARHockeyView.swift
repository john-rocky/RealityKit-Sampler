//
//  ShootTheDeviceView.swift
//  RealityKitSampler
//
//  Created by Daisuke Majima on 2021/06/30.
//

import SwiftUI

struct ARHockeyView: View {
    @State var isHost:Bool?
    @State var hostScore:Int = 0
    @State var guestScore:Int = 0
    @State var gameStateText:String = ""
    
    var body: some View {
        ZStack {
            ShootTheDeviceARViewContainer(isHost: $isHost, hostScore: $hostScore, guestScore: $guestScore)
                .edgesIgnoringSafeArea(.all)
            VStack {
                switch isHost {
                case true: Text("(You) black \(hostScore) : \(guestScore) white" )
                    .font(.system(size: 24, weight:.bold))
                    .foregroundColor(.black)
                case false: Text("black \(hostScore) : \(guestScore) white (You)" )
                    .font(.system(size: 24, weight:.bold))
                    .foregroundColor(.white)
                default:
                    Text("(You) black \(hostScore) : \(guestScore) white" )
                        .font(.system(size: 24, weight:.bold))
                        .foregroundColor(.white)
                }
                Spacer()
            }
        }
    }
    
    func updateGameStateText(){
        var text:String
        if let isHost = isHost {
            text = "\(isHost)"
        } else {
            text = ""
        }
        gameStateText = text
    }
}

struct ShootTheDeviceARViewContainer: UIViewControllerRepresentable {

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
        return Coordinator(isHost: $isHost, hostScore: $hostScore, guestScore:  $guestScore)
    }
    
    class Coordinator: NSObject, ARHockeyARViewControllerDelegate {
        
        @Binding var isHost:Bool?
        @Binding var hostScore:Int
        @Binding var guestScore:Int
        
        init(isHost: Binding<Bool?>, hostScore: Binding<Int>, guestScore: Binding<Int>) {
            _isHost = isHost
            _hostScore = hostScore
            _guestScore = guestScore
        }
        
        func connected(isHost: Bool) {
            self.isHost = isHost
        }
        
        func gameStateChanged(state: GameState) {
            self.hostScore = state.hostScore
            self.guestScore = state.guestScore
        }
        
        
    }
}
struct ShootTheDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        ARHockeyView()
    }
}
