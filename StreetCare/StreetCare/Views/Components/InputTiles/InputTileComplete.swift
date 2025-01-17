//
//  InputTileComplete.swift
//  StreetCare
//
//  Created by Michael on 4/24/23.
//

import SwiftUI

struct InputTileComplete: View {

    var size = CGSize(width: 300.0, height: 450.0)
    var question: String
                
    var finishAction: () -> ()
    
    var body: some View {

        ZStack {
            
            BasicTile(size: CGSize(width: size.width, height: size.height))
            
            VStack {
                Spacer()

                Text("Thank You")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(question)
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                HStack {
                    Button("Back to Visit Log") {
                        finishAction()
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(Color("TextButtonColor"))
                }
                .padding()
                
                Spacer()
            }
        }
        .frame(width: size.width, height: size.height)

    } // end body
} // end struct


struct InputTileComplete_Previews: PreviewProvider {

    @State static var inputText = ""

    static var previews: some View {

        InputTileComplete(question: "Complete!") {
            //
        }
    }
}


