//
//  BeforeOutreachView.swift
//  StreetCare
//
//  Created by Michael on 5/8/23.
//

import SwiftUI

struct BeforeOutreachView: View {
    
    private struct BeforeData {
        let title: String
        let description: String
    }

    private var data: [BeforeData] = [
        BeforeData(title: "Let someone know", description: "Doing an outreach, you may run into new neighbourhoods. It would help to keep someone informed about this outreach."),
        BeforeData(title: "How to prepare your care bags", description: "Handing out individual bags gives the recipient a way to move the items around while not bogging them down with more than they can carry.\n\nShare essential items - socks, soap, and healthy snacks are great for    care bags."),
        BeforeData(title: "Must carry", description: "IDs, infographics for street outreach (print them if you can!), charged phone, water and snack for yourself. Avoid carrying too much cash."),
        BeforeData(title: "Plan an introduction", description: "Approach with compassion, introduce yourself, smile, be open, and keep it simple.")
    ]
    
    var body: some View {

        VStack {
            HStack {
                Text("Introduction")
                    .font(.headline)
                    .foregroundColor(Color("TextColor"))
                Spacer()
            }
            
            HStack {
                Text("Homeless people are a diverse group of people just like everyone else, no matter their appearance gender, age or race.\n\nSome have fallen on hard times. Some may be struggling with mental illness. But everyone wants to be treated with respect and dignity. \n\nHere are some steps to follow before outreach.")
                    .foregroundColor(Color("TextColor"))
                Spacer()
            }
            
            ScrollView {
                ForEach(data, id:\.title) { d in
                    GrowingTextView(title: d.title, description: d.description)
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Before outreach")
    }
}

struct BeforeOutreachView_Previews: PreviewProvider {
    static var previews: some View {
        BeforeOutreachView()
    }
}
