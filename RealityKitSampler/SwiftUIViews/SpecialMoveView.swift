//
//  KillMoveView.swift
//  RealityKitSampler
//
//  Created by Daisuke Majima on 2021/06/27.
//

import SwiftUI

struct SpecialMoveView: View {
    var body: some View {
        return KillMoveARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct KillMoveView_Previews: PreviewProvider {
    static var previews: some View {
        SpecialMoveView()
    }
}

struct KillMoveARViewContainer: UIViewControllerRepresentable {

    func makeUIViewController(context: UIViewControllerRepresentableContext<KillMoveARViewContainer>) -> SpecialMoveARViewController {
        let viewController = SpecialMoveARViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: SpecialMoveARViewController, context: UIViewControllerRepresentableContext<KillMoveARViewContainer>) {

    }
    
    func makeCoordinator() -> KillMoveARViewContainer.Coordinator {
        return Coordinator()
    }
    
    class Coordinator {
        
    }
}
