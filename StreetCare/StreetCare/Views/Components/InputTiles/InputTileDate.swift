//
//  InputTileDate.swift
//  StreetCare
//
//  Created by Michael on 4/19/23.
//

import SwiftUI


struct InputTileDate: View {

    var questionNumber: Int
    var totalQuestions: Int
    
    var size = CGSize(width: 300.0, height: 450.0)
    var question: String
        
    @Binding var datetimeValue: Date
        
    var nextAction: () -> ()
    var skipAction: () -> ()
    var previousAction: () -> ()
    
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
                
                DatePicker("", selection: $datetimeValue)
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


struct InputTileDate_Previews: PreviewProvider {

    @State static var input = Date()

    static var previews: some View {

        InputTileDate(questionNumber: 1, totalQuestions: 4, question: "Enter a date to remember.", datetimeValue: $input) {
            //
        } skipAction: {
            //
        } previousAction: {
            //
        }

    }
}

