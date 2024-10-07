//
//  ICanHelpView.swift
//  StreetCare
//
//  Created by Amey Kanunje on 9/27/24.
//

import SwiftUI

struct ICanHelpView: View {
    
    @Binding var isPresented: Bool
    @State private var isOutreachCreated = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer()
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text("Make sure you are not going alone")
                        .font(.headline)
                    
                    Text("Group presence offers security and effectiveness in engaging with unfamiliar situations and individuals, benefiting both volunteers and the homeless.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("How outreach on Street Care works?")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("We post the outreach for you and other volunteers can sign up to go with you.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        // Action for RSVP EXISTING OUTREACH
                    }) {
                        Text("RSVP EXISTING OUTREACH")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(#colorLiteral(red: 0.208, green: 0.290, blue: 0.129, alpha: 1)))
                            .foregroundColor(.yellow)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("CANCEL")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(#colorLiteral(red: 0.208, green: 0.290, blue: 0.129, alpha: 1)))
                            .foregroundColor(.yellow)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        isOutreachCreated = true
                    }) {
                        Text("CREATE AN OUTREACH")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(#colorLiteral(red: 0.208, green: 0.290, blue: 0.129, alpha: 1)))
                            .foregroundColor(.yellow)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .frame(maxWidth: 300)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 10)
                .alert(isPresented: $isOutreachCreated) {
                    Alert(title: Text("Outreach Created"), message: Text("Your outreach has been created successfully."), dismissButton: .default(Text("OK")))
                }
            }
    }

//#Preview {
//    ICanHelpView(isPresented: )
//}
