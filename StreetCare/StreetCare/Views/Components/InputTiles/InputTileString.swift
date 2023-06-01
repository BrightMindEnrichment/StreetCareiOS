//
//  InputTileString.swift
//  StreetCare
//
//  Created by Michael on 4/19/23.
//
import SwiftUI

struct InputTileString: View {

    var questionNumber: Int
    var totalQuestions: Int
        
    var size = CGSize(width: 300.0, height: 450.0)
    var question: String
    
    @Binding var textValue: String
        
    var nextAction: () -> ()
    var previousAction: () -> ()
    var skipAction: () -> ()
    
    var body: some View {

        ZStack {
            BasicTile(size: CGSize(width: size.width, height: size.height))

            VStack {
                HStack {
                    Spacer()
                    Button("Skip") {
                        skipAction()
                    }
                    .foregroundColor(.gray)
                    .padding()
                }

                Spacer()

                Text("Question \(questionNumber)/\(totalQuestions)")
                    .foregroundColor(.gray)
                    .font(.footnote)
    
                Text(question)
                    .font(.headline)
                    .padding()
                
                TextField("optional", text: $textValue)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200.0)
                
                Spacer()
                
                ProgressView(value: Double(questionNumber) / Double(totalQuestions))
                    .tint(.yellow)
                    .background(Color("TextColor"))
                    .padding()


                Spacer()
                
                HStack {
//                    Button("Previous") {
//                        previousAction()
//                    }
//                    .foregroundColor(.black)
                    Spacer()
                    Button("Next") {
                        nextAction()
                    }
                    .foregroundColor(Color("TextColor"))
                }
                .padding()
            }
        }
        .frame(width: size.width, height: size.height)

    } // end body
} // end struct


struct InputTileString_Previews: PreviewProvider {

    @State static var inputText = ""

    static var previews: some View {

        InputTileString(questionNumber: 2, totalQuestions: 5, question: "Shall we play a game?", textValue: $inputText) {
            //
        } previousAction: {
            //
        } skipAction: {
            //
        }
    }
}

