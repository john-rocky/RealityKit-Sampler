//
//  ContentView.swift
//  RealityKitSampler
//
//  Created by Daisuke Majima on 2021/06/21.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            VStack {
                Text("RealtyKit-Sampler")
                    .font(.title)
                List {
                    NavigationLink(
                        destination: JustPlaceBoxView(),
                        label: {
                            Text("Just Place A Box")
                        })
                    NavigationLink(
                        destination: OneHundredInchMonitorView(),
                        label: {
                            Text("100-inch Monitor")
                        })
                    NavigationLink(
                        destination: PlaceObjectView(),
                        label: {
                            Text("Place Objects")
                        })
                    NavigationLink(
                        destination: ExpressionsAndSpeechView(),
                        label: {
                            Text("Expressions And Speech")
                        })
                    NavigationLink(
                        destination: KillMoveView(),
                        label: {
                            Text("Kill Move")
                        })
                    NavigationLink(
                        destination: ShootTheDeviceView(),
                        label: {
                            Text("Shoot The Device")
                        })
                    NavigationLink(
                        destination: FaceCropperView(),
                        label: {
                            Text("Face Cropper")
                        })
                }
            }.navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
