//
//  ContainerView.swift
//  RealityKitSampler
//
//  Created by Daisuke Majima on 2021/06/22.
//

import SwiftUI
import RealityKit

struct OneHundredInchMonitorView: View {
    @State var didTap = false
    
    var body: some View {
        ZStack {
            OneHundredInchMonitorARViewContainer(didTap: $didTap)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Button(action: didTapButton, label: {
                    Text("Select Video")
                        .font(.system(size: 32, weight: .bold, design: .default))
                })
            }
        }
    }
    
    func didTapButton() {
        didTap = true
    }
}

struct OneHundredInchMonitorARViewContainer: UIViewControllerRepresentable {
    @Binding var didTap:Bool

    func makeUIViewController(context: UIViewControllerRepresentableContext<OneHundredInchMonitorARViewContainer>) -> OneHundredInchMonitorARViewController {
        let viewController = OneHundredInchMonitorARViewController(didTap: $didTap)
        return viewController
    }

    func updateUIViewController(_ uiViewController: OneHundredInchMonitorARViewController, context: UIViewControllerRepresentableContext<OneHundredInchMonitorARViewContainer>) {
        if didTap {
            uiViewController.showPicker()
        }
    }
    
    func makeCoordinator() -> OneHundredInchMonitorARViewContainer.Coordinator {
        return Coordinator()
    }
    
    class Coordinator {
        
    }
}
