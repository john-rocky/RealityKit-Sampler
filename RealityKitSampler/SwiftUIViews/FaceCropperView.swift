//
//  PersonCropper.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/07/02.
//

import SwiftUI

struct FaceCropperView: View {
    var body: some View {
        return FaceCropperARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct FaceCropperARViewContainer: UIViewControllerRepresentable {

    func makeUIViewController(context: UIViewControllerRepresentableContext<FaceCropperARViewContainer>) -> FaceCropperARViewController {
        let viewController = FaceCropperARViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: FaceCropperARViewController, context: UIViewControllerRepresentableContext<FaceCropperARViewContainer>) {

    }
    
    func makeCoordinator() -> FaceCropperARViewContainer.Coordinator {
        return Coordinator()
    }
    
    class Coordinator {
        
    }
}

