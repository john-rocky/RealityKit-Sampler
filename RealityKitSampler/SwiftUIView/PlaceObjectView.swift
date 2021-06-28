//
//  PlacingObjectView.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/21.
//

import SwiftUI
import RealityKit

struct PlaceObjectView: View {
    @State private var model = PlacingObjectModel()
    @State private var meshMenuText = "Mesh:Box"
    @State private var color = Color(.white)
    @State var showImagePicker: Bool = false
    @State var showMoviePicker: Bool = false

    var body: some View {
        
        ZStack {
            ARContainerView(model: $model)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                Spacer()
                
                HStack {
                    VStack(spacing: -20) {
                        
                        Text("Mesh")
                            .font(.headline)
                        Picker("", selection: $model.meshType) {
                            Text(PlacingObjectModel.MeshType.box.rawValue).tag(PlacingObjectModel.MeshType.box)
                                .foregroundColor(.white)
                            Text(PlacingObjectModel.MeshType.plane.rawValue).tag(PlacingObjectModel.MeshType.plane)
                                .foregroundColor(.white)
                            Text(PlacingObjectModel.MeshType.sphere.rawValue).tag(PlacingObjectModel.MeshType.sphere)
                                .foregroundColor(.white)

                        }
                        .frame(width: 70)
                        .clipped()
                        
                    }
                    VStack(spacing: -20) {
                    Text("Material")
                        .font(.headline)
                    Picker("", selection: $model.materialType) {
                        Text(PlacingObjectModel.MaterialType.simple.rawValue).tag(PlacingObjectModel.MaterialType.simple)
                            .foregroundColor(.white)
                        Text(PlacingObjectModel.MaterialType.unlit.rawValue).tag(PlacingObjectModel.MaterialType.unlit)
                            .foregroundColor(.white)
                        Text(PlacingObjectModel.MaterialType.image.rawValue).tag(PlacingObjectModel.MaterialType.image)
                            .foregroundColor(.white)
                        Text(PlacingObjectModel.MaterialType.video.rawValue).tag(PlacingObjectModel.MaterialType.video)
                            .foregroundColor(.white)
                        Text(PlacingObjectModel.MaterialType.occlusion.rawValue).tag(PlacingObjectModel.MaterialType.occlusion)
                            .foregroundColor(.white)
                    }
                    .frame(width: 100)
                    .clipped()
                    }
                    
                    switch model.materialType {
                    case .image:
                        Button(action: {
                            showImagePicker.toggle()
                        }) {
                            Image(uiImage: self.model.image ?? UIImage())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50, alignment:.center)
                        }
                        .frame(width: 50, height: 50, alignment:.center)
                    case .video:
                        Button(action: {
                            showMoviePicker.toggle()
                        }) {
                            Image(uiImage:UIImage(systemName: "play.rectangle.fill") ?? UIImage())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50, alignment:.center)
                        }
                        .frame(width: 50, height: 50, alignment:.center)
                    default:
                        ColorPicker("", selection: $color)
                            .frame(width: 50, height: 50, alignment:.center)
                            .onChange(of: color) { _color in
                                model.color = UIColor(_color)
                            }
                            .labelsHidden()
                    }
                    Spacer(minLength: 30)
                    VStack(spacing: -20) {
                        Text("Physics")
                            .font(.headline)
                        Picker("", selection: $model.physics) {
                            Text(PlacingObjectModel.PhysicsBodyType._kinematic.rawValue).font(.caption2).tag(PlacingObjectModel.PhysicsBodyType._kinematic)
                                .foregroundColor(.white)
                            Text(PlacingObjectModel.PhysicsBodyType._static.rawValue).font(.caption2).tag(PlacingObjectModel.PhysicsBodyType._static)
                                .foregroundColor(.white)
                            Text(PlacingObjectModel.PhysicsBodyType._dynamic.rawValue).font(.caption2).tag(PlacingObjectModel.PhysicsBodyType._dynamic)
                                .foregroundColor(.white)
                        }
                        .frame(width: 70)
                        .clipped()
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(sourceType: .photoLibrary, mediaType: "public.image") { image,url in
                        self.model.image = image
                        self.model.imageURL = url
                    }
        }
        .sheet(isPresented: $showMoviePicker) {
            ImagePickerView(sourceType: .photoLibrary, mediaType: "public.movie") { image,url in
                        self.model.videoURL = url
                    }
        }
    }
}

struct ARContainerView: View {
    @Binding var model:PlacingObjectModel
    var body: some View {
        return ARViewContainer(model: $model)
            .edgesIgnoringSafeArea(.all)
    }
}


struct ARViewContainer: UIViewRepresentable {
    @Binding var model:PlacingObjectModel
    
    func makeUIView(context: Context) -> PlacingObjectARView {
        let arView = PlacingObjectARView(frame: .zero,model: model)
        
        return arView
    }
    
    func updateUIView(_ uiView: PlacingObjectARView, context: Context) {
        uiView.model = model
    }
}

struct PlacingObjectView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceObjectView()
    }
}
