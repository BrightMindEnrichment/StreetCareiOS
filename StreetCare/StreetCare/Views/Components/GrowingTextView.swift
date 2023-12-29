//
//  GrowingTextView.swift
//  StreetCare
//
//  Created by Michael on 5/8/23.
//

import SwiftUI

struct GrowingTextView: View {

    @State var title: String
    @State var description: String

    @State private var isOpen = false
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 8.0)
                .strokeBorder()
                .foregroundColor(Color("SecondaryColor"))
            
            VStack {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))
                    Spacer()
                    
                    Button {
                        isOpen.toggle()
                    } label: {
                        Image(systemName: isOpen ? "arrow.up.square.fill" : "arrow.down.square.fill")
                            .foregroundColor(Color("SecondaryColor"))
                            .imageScale(.large)
                    }
                }
                onTapGesture {
                    isOpen.toggle()
                }
             
                if isOpen {
                    HStack {
                        Text(description)
                            .foregroundColor(Color("TextColor"))
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        
    } // end body
} // end struct

struct GrowingTextView_Previews: PreviewProvider {
    static var previews: some View {
        GrowingTextView(title: "Title of this mess", description: "Some long description.  Some long description.  Some long description.  Some long description.  Some long description.  Some long description.  Some long description.  Some long description.")
            .padding()
    }
}
