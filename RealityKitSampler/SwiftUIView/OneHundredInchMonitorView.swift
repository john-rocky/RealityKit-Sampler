//
//  ContainerView.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/22.
//

import SwiftUI
import RealityKit

struct OneHundredInchMonitorView: View {
    @State var didTap = false
    
    var body: some View {
        ZStack {
            TwoHundredInchMonitorContainerView(didTap: $didTap)
            Button(action: didTapButton, label: {
                Text("Select Video")
                    .font(.headline)
                    .position(CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.maxY - 90))
            })
        }
    }
    
    func didTapButton() {
        didTap = true
    }
}

struct TwoHundredInchMonitorContainerView: View {
    @Binding var didTap:Bool
    var body: some View {
        return TwoHundredInchMonitorARViewContainer(didTap: $didTap)
            .edgesIgnoringSafeArea(.all)
    }
}

struct TwoHundredInchMonitorARViewContainer: UIViewControllerRepresentable {
    @Binding var didTap:Bool

    func makeUIViewController(context: UIViewControllerRepresentableContext<TwoHundredInchMonitorARViewContainer>) -> OneHundredInchMonitorARViewController {
        let viewController = OneHundredInchMonitorARViewController(didTap: $didTap)
        return viewController
    }

    func updateUIViewController(_ uiViewController: OneHundredInchMonitorARViewController, context: UIViewControllerRepresentableContext<TwoHundredInchMonitorARViewContainer>) {
        if didTap {
            uiViewController.showPicker()
        }
    }
    
    func makeCoordinator() -> TwoHundredInchMonitorARViewContainer.Coordinator {
        return Coordinator()
    }
    
    class Coordinator {
        
    }
}

struct ContainerView_Previews: PreviewProvider {
    static var previews: some View {
        OneHundredInchMonitorView()
    }
}
