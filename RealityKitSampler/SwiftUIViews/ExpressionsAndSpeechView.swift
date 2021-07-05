//
//  ExpressionsAndSpeechView.swift
//  RealityKitSampler
//
//  Created by Daisuke Majima on 2021/06/26.
//

import SwiftUI

struct ExpressionsAndSpeechView: View {
    @State var expression:ExpressionsAndSpeechARView.Expression = .normal
    var body: some View {
        ZStack {
            ExpressionsAndSpeechARViewContainer(expression: $expression)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ExpressionsAndSpeechARViewContainer: UIViewRepresentable {

    
    @Binding var expression:ExpressionsAndSpeechARView.Expression
    func makeUIView(context: Context) -> ExpressionsAndSpeechARView {
        let arView = ExpressionsAndSpeechARView(frame: .zero, expression: $expression)
        return arView
    }
    
    func updateUIView(_ uiView: ExpressionsAndSpeechARView, context: Context) {

    }
}
