//
//  InputTileDuration.swift
//  StreetCare
//
//  Created by Michael on 4/26/23.
//

import SwiftUI


struct InputTileDuration: View {

    var questionNumber: Int
    var totalQuestions: Int
        
    var size = CGSize(width: 300.0, height: 450.0)
    var question: String
    
    @Binding var hours: Int
    @Binding var minutes: Int
        
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
                
                TimeEditPicker(selectedHour: $hours, selectedMinute: $minutes)
                
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


struct InputTileDuration_Previews: PreviewProvider {

    @State static var hours = 5
    @State static var minutes = 30

    static var previews: some View {
        InputTileDuration(questionNumber: 1, totalQuestions: 2, question: "How long can you go?", hours: $hours, minutes: $minutes) {
            //
        } previousAction: {
            //
        } skipAction: {
            //
        }

    }
}

