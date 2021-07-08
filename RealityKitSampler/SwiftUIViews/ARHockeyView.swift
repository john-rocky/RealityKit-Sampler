//
//  ShootTheDeviceView.swift
//  RealityKitSampler
//
//  Created by Daisuke Majima on 2021/06/30.
//

import SwiftUI

struct ARHockeyView: View {
    @State var isHost:Bool?
    @State var gameStateText:String = ""
    
    var body: some View {
        ZStack {
            ShootTheDeviceARViewContainer(isHost: $isHost)
                .edgesIgnoringSafeArea(.all)
            VStack {
                switch isHost {
                case true: Text("Host")
                    .font(.system(size: 24, weight:.bold))
                    .foregroundColor(.white)
                case false: Text("Guest")
                    .font(.system(size: 24, weight:.bold))
                    .foregroundColor(.white)
                default:
                    Text("Not Connected")
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
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShootTheDeviceARViewContainer>) -> ARHockeyARViewController {
        let viewController = ARHockeyARViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: ARHockeyARViewController, context: UIViewControllerRepresentableContext<ShootTheDeviceARViewContainer>) {

    }
    
    func makeCoordinator() -> ShootTheDeviceARViewContainer.Coordinator {
        return Coordinator(isHost: $isHost)
    }
    
    class Coordinator: NSObject, ARHockeyARViewControllerDelegate {
        
        @Binding var isHost:Bool?
        
        init(isHost: Binding<Bool?>) {
            _isHost = isHost
        }
        
        func connected(isHost: Bool) {
            self.isHost = isHost
        }
        
        func gameStateChanged(state: GameState) {
            
        }
        
        
    }
}
struct ShootTheDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        ARHockeyView()
    }
}
