//
//  JustPlaceBoxView.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/21.
//

import SwiftUI
import RealityKit

struct JustPlaceBoxView: View {
    var body: some View {
        return JustPlaceBoxARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct JustPlaceBoxARViewContainer: UIViewRepresentable {
        
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let anchorEntity = AnchorEntity(plane: .horizontal)
        let boxEntity = ModelEntity(mesh: .generateBox(size: [0.1,0.1,0.1],cornerRadius: 0.02))
        let material = SimpleMaterial(color: .blue, isMetallic: true)
        boxEntity.model?.materials = [material]
        anchorEntity.addChild(boxEntity)
        arView.scene.addAnchor(anchorEntity)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}

struct JustPlaceBoxView_Previews: PreviewProvider {
    static var previews: some View {
        JustPlaceBoxView()
    }
}
