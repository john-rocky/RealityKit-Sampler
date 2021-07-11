//
//  GrabAR.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/07/09.
//

import SwiftUI

struct HandInteractionView: View {
    var body: some View {
        HandInteractionARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct HandInteractionARViewContainer: UIViewControllerRepresentable {
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<HandInteractionARViewContainer>) -> HandInteractionARViewController {
        let viewController = HandInteractionARViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: HandInteractionARViewController, context: UIViewControllerRepresentableContext<HandInteractionARViewContainer>) {
        
    }
    
    func makeCoordinator() -> HandInteractionARViewContainer.Coordinator {
        return Coordinator()
    }
    
    class Coordinator {
        
    }
}
