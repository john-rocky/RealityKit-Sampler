//
//  ContentView.swift
//  RealityKitSampler
//
//  Created by Daisuke Majima on 2021/06/21.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @State var view:BigRobotView? = BigRobotView()
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
                                .font(.headline)
                        })
                    NavigationLink(
                        destination: view,
                        label: {
                            Text("Big Robots")
                                .font(.headline)
                        }).onDisappear {
                            view = BigRobotView()
                        }
                    NavigationLink(
                        destination: OneHundredInchMonitorView(),
                        label: {
                            Text("100-inch Monitor")
                                .font(.headline)
                        })
                    NavigationLink(
                        destination: PlaceObjectView(),
                        label: {
                            Text("Place Objects")
                                .font(.headline)
                        })
                    NavigationLink(
                        destination: ExpressionsAndSpeechView(),
                        label: {
                            Text("Expressions And Speech")
                                .font(.headline)
                        })
                    NavigationLink(
                        destination: SpecialMoveView(),
                        label: {
                            Text("Special Move")
                                .font(.headline)
                        })
                    NavigationLink(
                        destination: ARHockeyView(),
                        label: {
                            Text("AR Hockey")
                                .font(.headline)
                        })
                    NavigationLink(
                        destination: FaceCropperView(),
                        label: {
                            Text("Face Cropper")
                                .font(.headline)
                        })
                    NavigationLink(
                        destination: HandInteractionView(),
                        label: {
                            Text("Hand Interaction")
                                .font(.headline)
                        })
                }
            }.navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
