//
//  PlacingObjectView.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/21.
//

import SwiftUI
import RealityKit

struct PlacingObjectView: View {
    @State private var tappedLocation: CGPoint = .zero
    
    var body: some View {
        return ARViewContainer(tappedLocation: $tappedLocation)
            .edgesIgnoringSafeArea(.all)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local).onEnded({ value in
                    tappedLocation = value.location
                }))
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var tappedLocation: CGPoint
    
    func update(angles:simd_float3) {
        
    }
        
    func makeUIView(context: Context) -> PlacingObjectARView {
        let arView = PlacingObjectARView(frame: .zero,settings: "")
        
        return arView
    }
    
    func updateUIView(_ uiView: PlacingObjectARView, context: Context) {
        uiView.tappedLocation = tappedLocation
    }
}

struct PlacingObjectView_Previews: PreviewProvider {
    static var previews: some View {
        PlacingObjectView()
    }
}
