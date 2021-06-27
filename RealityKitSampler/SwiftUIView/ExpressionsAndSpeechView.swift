//
//  ExpressionsAndSpeechView.swift
//  RealityKitSampler
//
//  Created by 間嶋大輔 on 2021/06/26.
//

import SwiftUI

struct ExpressionsAndSpeechView: View {
    @State var expression:ExpressionsAndSpeechARView.Expression = .normal
    var body: some View {
        ZStack {
            ExpressionsAndSpeechARViewContainer(expression: $expression)
            .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Text(makeExpressionText())
                    .font(.system(size: 24,weight: .black))
                    .foregroundColor(.white)
            }
        }
    }
    
    func makeExpressionText()-> String {
        switch expression {
        case .smile: return "Smiling😁!!"
        case .angry: return "Angry😡"
        case .surprise: return "Surprise😲"
        case .naughty: return "Naughty😝"
        case .normal: return ""
        }
    }
}

struct ExpressionsAndSpeechARViewContainer: UIViewRepresentable {

    
    @Binding var expression:ExpressionsAndSpeechARView.Expression
    func makeUIView(context: Context) -> ExpressionsAndSpeechARView {
        let arView = ExpressionsAndSpeechARView(frame: .zero, expression: $expression)
        arView.delegate = context.coordinator as? ExpressionsAndSpeechARViewDelegate
        return arView
    }
    
    func updateUIView(_ uiView: ExpressionsAndSpeechARView, context: Context) {

    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(expression: $expression)
    }
    
    class Coordinator:NSObject, ExpressionsAndSpeechARViewDelegate {
        @Binding var expression:ExpressionsAndSpeechARView.Expression
        
        init(expression: Binding<ExpressionsAndSpeechARView.Expression>) {
            _expression = expression
        }
        
        func expressionDidChange(expression: ExpressionsAndSpeechARView.Expression) {
            self.expression = expression
        }
    }
    

}
