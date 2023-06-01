//
//  InputTileMoreQuestions.swift
//  StreetCare
//
//  Created by Michael on 4/24/23.
//

import SwiftUI

struct InputTileMoreQuestions: View {

    var size = CGSize(width: 300.0, height: 450.0)
    var question: String
        
    var nextAction: () -> ()
    var skipAction: () -> ()
    var yesAction: () -> ()
    var noAction: () -> ()

    var body: some View {

        ZStack {
            BasicTile(size: CGSize(width: size.width, height: size.height))
            
            VStack {
                Spacer()
    
                Text(question)
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                HStack {
                    Button("Yes") {
                        yesAction()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    
                    Button("No") {
                        noAction()
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
                
                Spacer()
                
                HStack {
                    Button("Previous") {
                        skipAction()
                    }
                    .foregroundColor(Color("TextColor"))
                    Spacer()
                    Button("Submit") {
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


//struct InputTileMoreQuestions_Previews: PreviewProvider {
//
//    @State static var inputText = ""
//
//    static var previews: some View {
//        InputTileMoreQuestions(questionNumber: 5, totalQuestions: 5, question: "Would you like to answer additional questions?") {
//            // nothing
//        } skipAction: {
//            //
//        } yesAction: {
//            //
//        } noAction: {
//            //
//        }
//
//    }
//}


