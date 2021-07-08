//
//  BigRobotsBattleView.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/07/07.
//

import SwiftUI

struct BigRobotView: View {
    var body: some View {
        BigRobotARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct BigRobotARViewContainer: UIViewControllerRepresentable {

    func makeUIViewController(context: UIViewControllerRepresentableContext<BigRobotARViewContainer>) -> BigRobotARViewController {
        let viewController = BigRobotARViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: BigRobotARViewController, context: UIViewControllerRepresentableContext<BigRobotARViewContainer>) {
    }
    
    func makeCoordinator() -> BigRobotARViewContainer.Coordinator {
        return Coordinator()
    }
    
    class Coordinator {
        
    }
}
