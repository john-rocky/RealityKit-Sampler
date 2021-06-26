//
//  ExpressionsAndSpeechView.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/26.
//

import SwiftUI

struct ExpressionsAndSpeechView: View {
    var body: some View {
        return ExpressionsAndSpeechARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ExpressionsAndSpeechARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ExpressionsAndSpeechARView {
        let arView = ExpressionsAndSpeechARView(frame: .zero)
        
        return arView
    }
    
    func updateUIView(_ uiView: ExpressionsAndSpeechARView, context: Context) {

    }
}
