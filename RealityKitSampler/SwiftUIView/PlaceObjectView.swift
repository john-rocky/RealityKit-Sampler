//
//  PlacingObjectView.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/21.
//

import SwiftUI
import RealityKit

struct PlaceObjectView: View {
    @State private var tappedLocation: CGPoint = .zero
    @State private var model = PlacingObjectModel()
    @State private var meshMenuText = "Mesh:Box"
    @State private var color = Color(.white)

    var body: some View {
        
        ZStack {
            ARContainerView(tappedLocation: $tappedLocation, model: $model)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                Spacer()
                
                HStack {
                    VStack(spacing: -20) {
                        Text("Mesh")
                            .font(.headline)
                        Picker("", selection: $model.meshType) {
                            Text(PlacingObjectModel.MeshType.box.rawValue).tag(PlacingObjectModel.MeshType.box)
                            Text(PlacingObjectModel.MeshType.plane.rawValue).tag(PlacingObjectModel.MeshType.plane)
                            Text(PlacingObjectModel.MeshType.sphere.rawValue).tag(PlacingObjectModel.MeshType.sphere)
                        }
                        .frame(width: 70)
                        .clipped()
                        
                    }
//                    Menu(meshMenuText) {
//                        Button("Box",action:{
//                            meshMenuText = "Mesh:Box"
//                            model.meshType = .box
//                        })
//                        Button("Plane",action:{
//                            meshMenuText = "Mesh:Plane"
//                            model.meshType = .plane
//                        })
//                        Button("Sphere",action:{
//                            meshMenuText = "Mesh:Sphere"
//                            model.meshType = .sphere
//                        })
//                    }
                    Menu("Material:") {
                        Button("SimpleColor",action:{
                            print(color)
                        })
                        Button("Image",action:{})
                        Button("Video",action:{})
                        Button("Occlusion",action:{})
                    }
                    ColorPicker("", selection: $color)
                        .frame(width: 50, height: 50, alignment:.center)
                        .onChange(of: color) { _color in
                            model.color = UIColor(_color)
                        }
                    Menu("Physics") {
                        Button("false",action:{})
                        Button("true",action:{})
                    }
                }
            }
        }
    }
}

struct ARContainerView: View {
    @Binding var tappedLocation: CGPoint
    @Binding var model:PlacingObjectModel
    var body: some View {
        return ARViewContainer(tappedLocation: $tappedLocation,model: $model)
            .edgesIgnoringSafeArea(.all)
    }
}


struct ARViewContainer: UIViewRepresentable {
    @Binding var tappedLocation: CGPoint
    @Binding var model:PlacingObjectModel

    func update(angles:simd_float3) {
        
    }
    
    func makeUIView(context: Context) -> PlacingObjectARView {
        let arView = PlacingObjectARView(frame: .zero,model: model)
        
        return arView
    }
    
    func updateUIView(_ uiView: PlacingObjectARView, context: Context) {
        uiView.tappedLocation = tappedLocation
        uiView.model = model
    }
}

struct PlacingObjectView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceObjectView()
    }
}
