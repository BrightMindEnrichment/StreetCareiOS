//
//  InputTileDetails.swift
//  StreetCare
//
//  Created by Sahana Hemraj on 11/5/25.
//

import SwiftUI

struct InputTileDetails: View {
    
    // MARK: - Config
    var questionNumber: Int
    var totalQuestions: Int
    
    var size = CGSize(width: 360.0, height: 520.0)
    var question1: String
    var question2: String
    var question3: String = ""
    var showSkip: Bool = true
    var showProgressBar: Bool = true
    var buttonMode: ButtonMode = .navigation
    
    // MARK: - Bindings for user details
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Binding var phone: String
    
    // MARK: - Actions
    var nextAction: () -> ()
    var skipAction: () -> ()
    var previousAction: () -> ()
    
    // MARK: - Local state
    @Environment(\.presentationMode) var presentationMode
    @State private var showSuccessAlert = false
    @State private var emailIsInvalid = false
    
    // Simple email validation (local)
    private func isValidEmail(_ value: String) -> Bool {
        // Very small regex for basic validation
        let re = try? NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")
        if let re = re {
            let range = NSRange(location: 0, length: value.utf16.count)
            return re.firstMatch(in: value, options: [], range: range) != nil
        }
        return false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if buttonMode == .update {
                Text("Edit Your Interaction")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 50)
            }
            
            ZStack {
                BasicTile(size: size)
                
                VStack {
                    if buttonMode == .navigation {
                        HStack {
                            Text(NSLocalizedString("question", comment: "") + " \(questionNumber)/\(totalQuestions)")
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            if showSkip {
                                Button(NSLocalizedString("skip", comment: "")) {
                                    // If skipping, clear all detail fields (optional)
                                    firstName = ""
                                    lastName = ""
                                    email = ""
                                    phone = ""
                                    skipAction()
                                }
                                .foregroundColor(Color("SecondaryColor"))
                                .font(.footnote)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color.white))
                                .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.horizontal)
                    }
                    
                    VStack {
                        Text(question1).font(.title2).fontWeight(.bold)
                        Text(question2).font(.title2).fontWeight(.bold)
                        if !question3.isEmpty { Text(question3).font(.title2).fontWeight(.bold) }
                    }
                    .padding(.bottom, 12)
                    
                    if buttonMode == .navigation {
                        Spacer()
                    }
                    
                    // Input fields
                    VStack(spacing: 12) {
                        // First + Last name in one row
                        HStack(spacing: 12) {
                            TextField(NSLocalizedString("firstName", comment: ""), text: $firstName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: .infinity)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                            
                            TextField(NSLocalizedString("lastName", comment: ""), text: $lastName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 140)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                        }
                        .padding(.horizontal)
                        
                        // Email
                        TextField(NSLocalizedString("email", comment: ""), text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(emailIsInvalid ? Color.red : Color.gray.opacity(0.5), lineWidth: 1))
                            .padding(.horizontal)
                        
                        // Phone
                        TextField(NSLocalizedString("phoneNumber", comment: ""), text: $phone)
                            .keyboardType(.phonePad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                            .padding(.horizontal)
                    }
                    .padding(.top, 6)
                    
                    if buttonMode == .navigation {
                        Spacer()
                    }
                    
                    // Buttons
                    if buttonMode == .navigation {
                        HStack {
                            Button(NSLocalizedString("previous", comment: "")) {
                                previousAction()
                            }
                            .foregroundColor(Color("SecondaryColor"))
                            .font(.footnote)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.white))
                            .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
                            
                            Spacer()
                            
                            Button(" " + NSLocalizedString("next", comment: "") + " ") {
                                // Validate email (optional)
                                if !email.isEmpty && !isValidEmail(email) {
                                    emailIsInvalid = true
                                    return
                                } else {
                                    emailIsInvalid = false
                                }
                                
                                // Trim whitespace
                                firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
                                lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
                                email = email.trimmingCharacters(in: .whitespacesAndNewlines)
                                phone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                nextAction()
                            }
                            .foregroundColor(Color("PrimaryColor"))
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(Color("SecondaryColor")))
                            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 2)
                        }
                        .padding()
                    } else if buttonMode == .update {
                        HStack {
                            Button("Cancel") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .foregroundColor(Color("SecondaryColor"))
                            .font(.footnote)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.white))
                            .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
                            
                            Spacer()
                            
                            Button("Update") {
                                if !email.isEmpty && !isValidEmail(email) {
                                    emailIsInvalid = true
                                    return
                                }
                                // Optionally show success alert
                                showSuccessAlert = true
                                nextAction()
                            }
                            .foregroundColor(Color("PrimaryColor"))
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(Color("SecondaryColor")))
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Interaction Log")
        .frame(width: size.width, height: size.height)
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Updated"),
                message: Text("Contact details were successfully updated."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        // Progress bar
        if showProgressBar {
            SegmentedProgressBar(
                totalSegments: totalQuestions,
                filledSegments: questionNumber,
                tileWidth: size.width
            )
            Text(NSLocalizedString("progress", comment: ""))
                .font(.footnote)
                .padding(.top, 4)
                .fontWeight(.bold)
        }
    }
}

struct InputTileDetails_Previews: PreviewProvider {
    @State static var fn = ""
    @State static var ln = ""
    @State static var em = ""
    @State static var ph = ""
    
    static var previews: some View {
        InputTileDetails(
            questionNumber: 2,
            totalQuestions: 6,
            question1: NSLocalizedString("questionTwo", comment: ""),
            question2: NSLocalizedString("interaction", comment: "") + "?",
            firstName: $fn,
            lastName: $ln,
            email: $em,
            phone: $ph,
            nextAction: {},
            skipAction: {},
            previousAction: {}
        )
    }
}
