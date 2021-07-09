//
//  GrabAR.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/07/09.
//

import SwiftUI

struct GrabARView: View {
    var body: some View {
        GrabARARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct GrabARARViewContainer: UIViewControllerRepresentable {

    func makeUIViewController(context: UIViewControllerRepresentableContext<GrabARARViewContainer>) -> GrabARARViewController {
        let viewController = GrabARARViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: GrabARARViewController, context: UIViewControllerRepresentableContext<GrabARARViewContainer>) {

    }
    
    func makeCoordinator() -> GrabARARViewContainer.Coordinator {
        return Coordinator()
    }
    
    class Coordinator {
        
    }
}
