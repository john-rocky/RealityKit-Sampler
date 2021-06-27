//
//  KillMoveView.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/27.
//

import SwiftUI

struct KillMoveView: View {
    var body: some View {
        return KillMoveARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct KillMoveView_Previews: PreviewProvider {
    static var previews: some View {
        KillMoveView()
    }
}

struct KillMoveARViewContainer: UIViewControllerRepresentable {

    func makeUIViewController(context: UIViewControllerRepresentableContext<KillMoveARViewContainer>) -> KillMoveARViewController {
        let viewController = KillMoveARViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: KillMoveARViewController, context: UIViewControllerRepresentableContext<KillMoveARViewContainer>) {

    }
    
    func makeCoordinator() -> KillMoveARViewContainer.Coordinator {
        return Coordinator()
    }
    
    class Coordinator {
        
    }
}
