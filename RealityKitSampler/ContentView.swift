//
//  ContentView.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/21.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    
    var body: some View {
        NavigationView {
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
            }
        }.navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
