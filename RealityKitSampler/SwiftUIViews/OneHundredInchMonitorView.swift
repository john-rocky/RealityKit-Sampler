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
            OneHundredInchMonitorContainerView(didTap: $didTap)
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

struct OneHundredInchMonitorContainerView: View {
    @Binding var didTap:Bool
    var body: some View {
        return OneHundredInchMonitorARViewContainer(didTap: $didTap)
            .edgesIgnoringSafeArea(.all)
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

struct ContainerView_Previews: PreviewProvider {
    static var previews: some View {
        OneHundredInchMonitorView()
    }
}
