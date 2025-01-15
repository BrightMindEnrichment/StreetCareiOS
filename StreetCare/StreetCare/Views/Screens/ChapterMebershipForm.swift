//
//  Chaptermebershipform.swift
//  StreetCare
//
//  Created by Marian John on 1/10/25.
//

import SwiftUI
import FirebaseFirestore

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
    @State private var fullname = ""
    @State private var signatureDate = Date()
    @State private var comments = ""
    @State private var navigateToSubmissionScreen = false

    var allPersonalFieldsFilled: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !phoneNumber.isEmpty
            && !addressLine1.isEmpty && !city.isEmpty && !state.isEmpty && !zipCode.isEmpty && !country.isEmpty
    }
    func saveFormDataToFirestore() {
        // Reference to Firestore
        let db = Firestore.firestore()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let formattedDateOfSignature = dateFormatter.string(from: signatureDate)
        // Data to save from the form (only the specified fields)
        let formData: [String: Any] = [
            "Address": "\(addressLine1), \(addressLine2), \(city), \(state), \(zipCode), \(country)",
            "Comments. You can add more information on how you heard about us and share any other relevant information.": comments,
            "Date of Signature": formattedDateOfSignature,
            "Days of the week available to volunteer": Array(selectedDays), // Store selected days as an array
            "Email": email,
            "How did you hear about us?": heardAbout,
            "If under 18, please provide written consent from a parent or guardian.": guardianSignature,
            "Name": "\(firstName) \(lastName)",
            "Number of hours available to volunteer (weekly)": hoursAvailable,
            "Phone Number": phoneNumber,
            "Signature (If minor, Guardian's signature)": signature,
            "Submission Create Date": Timestamp(date: Date()), // Use the current date as submission date
            "Submission ID": UUID().uuidString,
            "Submission Status": "unread",
            "Why do you want to volunteer at Street Care?": reason
        ]
        
        // Add the data to the collection
        db.collection("SCChapterMembershipForm").addDocument(data: formData) { error in
            if let error = error {
                print("Error saving data: \(error.localizedDescription)")
            } else {
                print("Form data successfully saved!")
            }
        }
    }
    var body: some View {
        NavigationStack {
            VStack {
                if navigateToSubmissionScreen {
                    SubmissionNotificationView(onDismiss: {
                        isPresented = false // Close the parent view
                    })
                } else {
                    Text(NSLocalizedString("cmtitle", comment: ""))
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding()
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
            }
                    .background(
                        NavigationLink(
                            destination: SubmissionNotificationView(onDismiss: {
                                isPresented = false
                            })
                            .onAppear {
                                saveFormDataToFirestore()
                            },
                            isActive: $navigateToSubmissionScreen
                        ) {
                            EmptyView()
                        }
                            .hidden()
                    )
            }
        }

    @State private var selectedCountry: String = "" // Selected value for the dropdown
    let countries = [
        "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Australia",
        "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin",
        "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso",
        "Burundi", "Cabo Verde", "Cambodia", "Cameroon", "Canada", "Central African Republic", "Chad", "Chile", "China",
        "Colombia", "Comoros", "Congo (Congo-Brazzaville)", "Costa Rica", "Croatia", "Cuba", "Cyprus", "Czechia (Czech Republic)",
        "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea",
        "Eritrea", "Estonia", "Eswatini (fmr. Swaziland)", "Ethiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia",
        "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Holy See",
        "Honduras", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan",
        "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia",
        "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta",
        "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro",
        "Morocco", "Mozambique", "Myanmar (formerly Burma)", "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand",
        "Nicaragua", "Niger", "Nigeria", "North Korea", "North Macedonia", "Norway", "Oman", "Pakistan", "Palau", "Palestine",
        "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia",
        "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino",
        "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia",
        "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Korea", "South Sudan", "Spain", "Sri Lanka",
        "Sudan", "Suriname", "Sweden", "Switzerland", "Syria", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo",
        "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates",
        "United Kingdom", "United States of America", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Yemen",
        "Zambia", "Zimbabwe"
    ]

    var personalDetailsView: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    Text(NSLocalizedString("Chapter Membership", comment: ""))
                        .font(.headline)
                        .fontWeight(.bold)

                    Text(NSLocalizedString("cmintrotext" , comment: ""))
                    
                    Text(NSLocalizedString("cmintrotext2", comment: ""))
                        .font(.body)

                    Text(NSLocalizedString("cmintrowithlink1", comment: ""))
                        .font(.body)

                    Text(NSLocalizedString("cmintrowithlink2", comment: ""))
                        .font(.body)
                    
                    
                    // Personal Details Section
                    Text("Personal details")
                        .font(.headline)
                        .fontWeight(.bold)

                    // First Name and Last Name (Horizontal Alignment)
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("First name")
                                    .font(.body)
                                    .fontWeight(.bold)
                                Text("*")
                                    .foregroundColor(.red)
                            }
                            TextField("First name", text: $firstName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Last name")
                                    .font(.body)
                                    .fontWeight(.bold)
                                Text("*")
                                    .foregroundColor(.red)
                            }
                            TextField("Last name", text: $lastName)
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
                            TextField("Email address", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Phone number")
                                    .font(.body)
                                    .fontWeight(.bold)
                                Text("*")
                                    .foregroundColor(.red)
                            }
                            TextField("Mobile number", text: $phoneNumber)
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
                                        self.country = country
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

    @State private var selectedDays: Set<String> = [] // Track selected days
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    var availabilityView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Availability to volunteer")
                    .font(.title)
                    .fontWeight(.bold)

                //Text(NSLocalizedString("cmintrotext3", comment: ""))
                   // .font(.body)

                // Days Available Multi-Select Dropdown
                VStack(alignment: .leading, spacing: 4) {
                    Text("Days available")
                        .font(.body)
                        .fontWeight(.bold)

                    Menu {
                        VStack {
                            ForEach(daysOfWeek, id: \.self) { day in
                                Button(action: {
                                    if selectedDays.contains(day) {
                                        selectedDays.remove(day)
                                    } else {
                                        selectedDays.insert(day)
                                    }
                                }) {
                                    HStack {
                                        Text(day)
                                        Spacer()
                                        if selectedDays.contains(day) {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedDays.isEmpty ? "Select" : selectedDays.joined(separator: ", "))
                                .foregroundColor(selectedDays.isEmpty ? .gray : .black)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .frame(height: 40) // Match the text field's height
                        .background(Color.white)
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                    }
                }

                // Hours Available Weekly
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hours available weekly")
                        .font(.body)
                        .fontWeight(.bold)
                    TextField("Number of hours", text: $hoursAvailable)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 40)
                }

                // Under 18 Dropdown
                VStack(alignment: .leading, spacing: 4) {
                    Text("Are you under 18?")
                        .font(.body)
                        .fontWeight(.bold)
                    Menu {
                        ForEach(["Yes", "No"], id: \.self) { option in
                            Button(action: {
                                guardianSignature = option
                            }) {
                                Text(option)
                            }
                        }
                    } label: {
                        HStack {
                            Text(guardianSignature.isEmpty ? "Select" : guardianSignature)
                                .foregroundColor(guardianSignature.isEmpty ? .gray : .black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .frame(height: 40)
                        .background(Color.white)
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                    }
                }

                // How did you hear about us Dropdown
                VStack(alignment: .leading, spacing: 4) {
                    Text("How did you hear about us?")
                        .font(.body)
                        .fontWeight(.bold)
                    Menu {
                        ForEach(["Website", "Social Media", "Event", "Friend", "Other"], id: \.self) { source in
                            Button(action: {
                                heardAbout = source
                            }) {
                                Text(source)
                            }
                        }
                    } label: {
                        HStack {
                            Text(heardAbout.isEmpty ? "Select" : heardAbout)
                                .foregroundColor(heardAbout.isEmpty ? .gray : .black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .frame(height: 40)
                        .background(Color.white)
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                    }
                }

                // Why do you want to volunteer
                VStack(alignment: .leading, spacing: 4) {
                    Text("Why do you want to volunteer?")
                        .font(.body)
                        .fontWeight(.bold)
                    TextEditor(text: $reason)
                        .frame(height: 120) // Increase the height for better usability
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                        .padding(.top, 4)
                }
            }
            .padding()
        }
    }
    
    var signatureView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text(NSLocalizedString("cmintrotext4", comment: ""))
                    .font(.body)
                    .fontWeight(.bold)

                Text(NSLocalizedString("cmintrotext5", comment: ""))
                    .font(.body)
                    .fontWeight(.bold)

                // Titles for Input Fields
                VStack(alignment: .leading, spacing: 8) {
                    Text("Signature (If minor, Guardian's signature)")
                        .font(.headline)
                        .fontWeight(.bold)
                    TextField("Write your full name.", text: $signature)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.headline)
                        .fontWeight(.bold)
                    TextField("Please Write your full name.", text: $fullname)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Date of Signature")
                        .font(.headline)
                        .fontWeight(.bold)
                    DatePicker("Date of Signature", selection: $signatureDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Comments. You can add more information on how you heard about us and share any other relevant information.")
                        .font(.headline)
                        .fontWeight(.bold)
                    TextField("Comments", text: $comments)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                // cmintrotext6 with bullet points and underlined email
                VStack(alignment: .leading, spacing: 10) {
                    Text(NSLocalizedString("cmintrotext6", comment: ""))
                        .font(.body)

                    Group {
                        HStack(alignment: .top) {
                            Text("•").bold()
                            Text(NSLocalizedString("cmintrotext7", comment: ""))
                                .font(.body)
                        }
                        HStack(alignment: .top) {
                            Text("•").bold()
                            Text(NSLocalizedString("cmintrotext8", comment: ""))
                                .font(.body)
                        }
                        HStack(alignment: .top) {
                            Text("•").bold()
                            Text(NSLocalizedString("cmintrotext9", comment: ""))
                                .font(.body)
                        }
                        HStack(alignment: .top) {
                            Text("•").bold()
                            Text(NSLocalizedString("cmintrotext10", comment: ""))
                                .font(.body)
                        }
                    }

                    Text("Thank you!")
                        .font(.body)

                    // Underlined email address
                    Text("For any assistance with filling out the form or any other additional support, please email us at: ")
                        .font(.body)
                    + Text("info@streetcare.us")
                        .underline()
                        .foregroundColor(.blue)
                }
                .padding()
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
