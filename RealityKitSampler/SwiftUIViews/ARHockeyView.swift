//
//  ShootTheDeviceView.swift
//  RealityKitSampler
//
//  Created by Daisuke Majima on 2021/06/30.
//

import SwiftUI

struct ARHockeyView: View {
    @State var model:ARHockeyModel?
    @State var gameStateText:String = ""
    
    var body: some View {
        ZStack {
            ShootTheDeviceARViewContainer(model: $model)
                .edgesIgnoringSafeArea(.all)
            VStack {
                getGameText()
                Spacer()
                if model?.isHost == nil {
                    Text("Once an another device lauch this game, you automatically connect it")
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    func getGameText() -> Text {
        var textString: String = ""
        var textColor: Color = .gray
        
        switch model?.isHost {
        case true:
            // host
            switch model?.tableAdded {
            case true:
                // table has been added
                switch model?.tableAddedInGuestDevice {
                case true:
                    // table has been shared
                    textString = "(You) black \(model?.gameState.hostScore ?? 0) : \(model?.gameState.guestScore ?? 0) white (\(model?.connectedDeviceName ?? "other device"))"
                    textColor = .black
                default:
                    // table has not been shared
                    textString = "Move device to share the table position with \(model?.connectedDeviceName ?? "other device")"
                }
                
            default:
                // table has not been added
                textString = "Place board by tapping plane."
            }
            
        case false:
            // guest
            switch model?.tableAdded  {
            case true:
                // table has been added
                switch model?.tableAddedInGuestDevice {
                case true:
                    // table has been shared
                    textString = "(\(model?.connectedDeviceName ?? "other device")) black \(model?.gameState.hostScore ?? 0) : \(model?.gameState.guestScore ?? 0) white (You)"
                    textColor = .white
                    
                default:
                    // table has not been shared
                    textString = "Move device to share the table position from \(model?.connectedDeviceName ?? "other device")"
                }
            default:
                // table has not been added
                textString = "Please wait the table will be added by \(model?.connectedDeviceName ?? "other device")"
            }
            
        default:
            // not connected
            switch model?.tableAdded {
            case true: // table added
                textString = "(You) black \(model?.gameState.hostScore ?? 0) : \(model?.gameState.guestScore ?? 0) white (Auto)"
                textColor = .black
            default:
                //no table
                textString = "Place board by tapping plane."
            }
        }
        return Text(textString)
            .font(.system(size: 24, weight:.bold))
            .foregroundColor(textColor)
    }
}

struct ShootTheDeviceARViewContainer: UIViewControllerRepresentable {
    
    @Binding var model: ARHockeyModel?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShootTheDeviceARViewContainer>) -> ARHockeyARViewController {
        let viewController = ARHockeyARViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ARHockeyARViewController, context: UIViewControllerRepresentableContext<ShootTheDeviceARViewContainer>) {
        
    }
    
    func makeCoordinator() -> ShootTheDeviceARViewContainer.Coordinator {
        return Coordinator(model: $model)
    }
    
    class Coordinator: NSObject, ARHockeyARViewControllerDelegate {
        
        @Binding var model: ARHockeyModel?
        
        init(model:Binding<ARHockeyModel?>) {
            _model = model
        }
        
        func modelChanged(model: ARHockeyModel) {
            self.model = model
        }
    }
}
struct ShootTheDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        ARHockeyView()
    }
}
