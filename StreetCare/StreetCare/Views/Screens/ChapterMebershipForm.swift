//
//  Chaptermebershipform.swift
//  StreetCare
//
//  Created by Marian John on 1/10/25.
//

import SwiftUI

struct ChapterMembershipForm: View {
    @Binding var isPresented: Bool // Pass this from the parent to handle dismissal
    @State private var currentStep: Int = 1
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var addressLine1 = ""
    @State private var addressLine2 = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var country = ""
    @State private var daysAvailable = ""
    @State private var hoursAvailable = ""
    @State private var heardAbout = ""
    @State private var reason = ""
    @State private var signature = ""
    @State private var guardianSignature = ""
    @State private var signatureDate = Date()
    @State private var comments = ""
    @State private var navigateToSubmissionScreen = false

    var allPersonalFieldsFilled: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !phoneNumber.isEmpty
            && !addressLine1.isEmpty && !city.isEmpty && !state.isEmpty && !zipCode.isEmpty && !country.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack {
                if currentStep == 1 {
                    personalDetailsView
                } else if currentStep == 2 {
                    availabilityView
                } else if currentStep == 3 {
                    signatureView
                }

                Spacer()

                HStack {
                    if currentStep > 1 {
                        Button("Back") {
                            currentStep -= 1
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }

                    Button(currentStep < 3 ? "Next" : "Submit") {
                        if currentStep < 3 {
                            currentStep += 1
                        } else {
                            navigateToSubmissionScreen = true
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(allPersonalFieldsFilled || currentStep != 1 ? Color.yellow : Color.gray)
                    .cornerRadius(8)
                    .disabled(!allPersonalFieldsFilled && currentStep == 1)
                }
                .padding()
            }
            .background(
                NavigationLink(
                    destination: SubmissionNotificationView(onDismiss: {
                        isPresented = false // Dismiss the parent form when "Back to home" is tapped
                    }),
                    isActive: $navigateToSubmissionScreen
                ) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }

    @State private var selectedCountry: String = "" // Selected value for the dropdown
    let countries = ["United States", "Canada", "India", "United Kingdom", "Germany"]

    var personalDetailsView: some View {
        VStack {
            // Back Button at the Top
            HStack {
                Button(action: {
                    // Handle back navigation
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.body)
                    .foregroundColor(.black)
                }
                Spacer()
            }
            .padding()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title and Intro Section
                    Text(NSLocalizedString("cmtitle", comment: ""))
                        .font(.title)
                        .fontWeight(.bold)

                    Text(NSLocalizedString("Chapter Membership", comment: ""))
                        .font(.headline)

                    Text(NSLocalizedString("cmintrotext" , comment: ""))
                    
                    Text(NSLocalizedString("cmintrotext2", comment: ""))
                        .font(.body)

                    Text(NSLocalizedString("cmintrowithlink1", comment: ""))
                        .font(.body)

                    Text(NSLocalizedString("cmintrowithlink2", comment: ""))
                        .font(.body)

                    
                    // Personal Details Section
                    Text("Personal Details")
                        .font(.title)
                        .fontWeight(.bold)

                    // First Name and Last Name (Horizontal Alignment)
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("First Name")
                                    .font(.body)
                                    .fontWeight(.bold)
                                Text("*")
                                    .foregroundColor(.red)
                            }
                            TextField("First Name", text: $firstName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Last Name")
                                    .font(.body)
                                    .fontWeight(.bold)
                                Text("*")
                                    .foregroundColor(.red)
                            }
                            TextField("Last Name", text: $lastName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }

                    // Email and Phone Number (Horizontal Alignment)
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Email")
                                    .font(.body)
                                    .fontWeight(.bold)
                                Text("*")
                                    .foregroundColor(.red)
                            }
                            TextField("Email Address", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Phone Number")
                                    .font(.body)
                                    .fontWeight(.bold)
                                Text("*")
                                    .foregroundColor(.red)
                            }
                            TextField("Mobile Number", text: $phoneNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }

                    // Address Section
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Address Line 1")
                                .font(.body)
                                .fontWeight(.bold)
                            Text("*")
                                .foregroundColor(.red)
                        }
                        TextField("Address Line 1", text: $addressLine1)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Address Line 2")
                            .font(.body)
                            .fontWeight(.bold)
                        TextField("Address Line 2", text: $addressLine2)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    // City and State (Horizontal Alignment)
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("City")
                                    .font(.body)
                                    .fontWeight(.bold)
                                Text("*")
                                    .foregroundColor(.red)
                            }
                            TextField("City", text: $city)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("State")
                                    .font(.body)
                                    .fontWeight(.bold)
                                Text("*")
                                    .foregroundColor(.red)
                            }
                            TextField("State", text: $state)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }

                    // Zip Code and Country (Horizontal Alignment)
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Zip Code")
                                    .font(.body)
                                    .fontWeight(.bold)
                                Text("*")
                                    .foregroundColor(.red)
                            }
                            TextField("Zip Code", text: $zipCode)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Country")
                                .font(.body)
                                .fontWeight(.bold)
                            Menu {
                                ForEach(countries, id: \.self) { country in
                                    Button(action: {
                                        selectedCountry = country
                                    }) {
                                        Text(country)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedCountry.isEmpty ? "Select Country" : selectedCountry)
                                        .foregroundColor(selectedCountry.isEmpty ? .gray : .black)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.gray, lineWidth: 0.5)
                                )
                            }
                        }
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
        }
    }

    var availabilityView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Availability to Volunteer")
                    .font(.title)
                    .fontWeight(.bold)

                Text(NSLocalizedString("cmintrotext3", comment: ""))
                    .font(.body)

                TextField("Days Available", text: $daysAvailable).textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Hours Available Weekly", text: $hoursAvailable).textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("How did you hear about us?", text: $heardAbout).textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Why do you want to volunteer?", text: $reason).textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
        }
    }

    var signatureView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Agreement and Signature")
                    .font(.title)
                    .fontWeight(.bold)

                Text(NSLocalizedString("cmintrotext4", comment: ""))
                    .font(.body)

                Text(NSLocalizedString("cmintrotext5", comment: ""))
                    .font(.body)

                TextField("Your Signature", text: $signature).textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Guardian Signature (if applicable)", text: $guardianSignature).textFieldStyle(RoundedBorderTextFieldStyle())
                DatePicker("Date of Signature", selection: $signatureDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                TextField("Comments (Optional)", text: $comments).textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
        }
    }
}

struct SubmissionNotificationView: View {
    var onDismiss: () -> Void // Callback for dismissing the view

    var body: some View {
        VStack {
            Spacer()

            // Title Section
            Text("Chapter Membership Form")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 20)

            // Notification Box
            VStack(alignment: .leading, spacing: 15) {
                Text("Thank you for applying to be a Chapter Member!")
                    .font(.headline)
                    .fontWeight(.bold)

                Text("Approval may take up to 5 business days.")
                    .font(.body)

                // Yellow Divider
                Rectangle()
                    .fill(Color.yellow)
                    .frame(height: 2)

                // Back to Home Text
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back to home")
                        .font(.body)
                }
                .onTapGesture {
                    onDismiss()
                }
                .padding(.top, 10)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .padding(.horizontal, 20)

            Spacer()
        }
        .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all))
        .navigationBarBackButtonHidden(true)
    }
}

struct ChapterMembershipForm_Previews: PreviewProvider {
    static var previews: some View {
        ChapterMembershipForm(isPresented: .constant(true))
    }
}
