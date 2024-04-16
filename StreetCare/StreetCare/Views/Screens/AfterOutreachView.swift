//
//  ContentView.swift
//  StreetCare
//
//  Created by Michael on 3/26/23.
//

import SwiftUI

struct AfterOutreachView: View {
 
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    Spacer().frame(height: 90)
                    Image("Clothes").resizable().frame(width: 60.0, height: 60.0)
                    Spacer().frame(height: 20)
                    Text("Would you like to Log your visit?")
                        .font(.subheadline).padding(EdgeInsets(top: 15.0, leading: 0.0, bottom: 10.0, trailing:0.0)) .fontWeight(.bold).foregroundColor(.black)
                    Spacer().frame(height: 40)
                    
                    NavigationLink {
                        VisitLogEntry()
                    } label: {
                        ZStack {
                            NavLinkButton(title: "Log your visit", width: UIScreen.main.bounds.width - 100,height: 60.0, cornerRadius: 7.0,buttonColor: Color("BackgroundColor"))
                        }
                    }
                }
            }
            .padding()
        }.navigationTitle("After Outreach")

    } // end body
} // end struct

struct AfterOutreachView_Previews: PreviewProvider {
    static var previews: some View {
        AfterOutreachView()
    }
}
