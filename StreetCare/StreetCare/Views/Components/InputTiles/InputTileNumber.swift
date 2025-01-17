//
//  InputTileNumber.swift
//  StreetCare
//
//  Created by Michael on 4/19/23.
//


import SwiftUI

struct InputTileNumber: View {

    var questionNumber: Int
    var totalQuestions: Int
    
    var size = CGSize(width: 300.0, height: 450.0)
    var question: String
        
    @Binding var number: Int
        
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
                
                Stepper("\(number) people helped", value: $number)
                    .padding()
                
                Spacer()
                
                ProgressView(value: Double(questionNumber) / Double(totalQuestions))
                    .tint(.yellow)
                    .background(.black)
                    .padding()


                Spacer()
                
                HStack {
                    Button("Previous") {
                        previousAction()
                    }
                    .foregroundColor(Color("TextColor"))
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


struct InputTileNumber_Previews: PreviewProvider {

    @State static var input = 5

    static var previews: some View {
        InputTileNumber(questionNumber: 1, totalQuestions: 2, question: "Luck number?", number: $input) {
            //
        } previousAction: {
            //
        } skipAction: {
            //
        }

    }
}
