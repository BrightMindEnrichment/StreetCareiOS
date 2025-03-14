//
//  AddHelpRequestForm.swift
//
//
//  Created by Marian John on 11/21/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct AddHelpRequestForm: View {
    @Environment(\.presentationMode) var presentationMode
    @State var user: User?
    @State private var title: String = ""
    @State private var additionalNotes: String = ""
    @State private var street: String = ""
    @State private var state: String = ""
    @State private var city: String = ""
    @State private var zipcode: String = ""
    @State private var identification: String = ""
    @State private var selectedhelp: [String] = []
    @State private var ishelpneeded = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var isLoading = false

    let skills = ["Childcare", "Counselling and Support", "Clothing", "Education", "Personal Care", "Employment and Training", "Food and Water", "Healthcare", "Chinese", "Spanish", "Language (please specify)", "Legal", "Shelter", "Transportation", "LGBTQ Support", "Technology Access", "Social Integration", "Pet Care"]

    private let db = Firestore.firestore()
    private let titleLimit = 50
    private let additionalnotesLimit = 200

    var allFieldsFilled: Bool {
        !title.isEmpty &&
        !street.isEmpty &&
        !state.isEmpty &&
        !city.isEmpty &&
        !zipcode.isEmpty &&
        !identification.isEmpty &&
        !selectedhelp.isEmpty
    }

    func saveToFirestore() {
        guard allFieldsFilled else {
            alertMessage = "Please fill in all required fields."
            showAlert = true
            return
        }
        isLoading = true
        let formData: [String: Any] = [
            "title": title,
            "additionalnotes": additionalNotes,
            "street": street,
            "state": state,
            "city": city,
            "zipcode": zipcode,
            "identification": identification,
            "selectedhelp": selectedhelp
        ]

        db.collection("helpRequests").addDocument(data: formData) { error in
            isLoading = false
            if let error = error {
                alertMessage = "Error saving data: \(error.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "Event saved successfully!"
                showAlert = true
            }
        }
    }

    var body: some View {
        if let _ = self.user {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                FormHeaderView()

                TextFieldWithLimit(
                    title: NSLocalizedString("title", comment: ""),
                    placeholder: NSLocalizedString("enterEventTitle", comment: ""),
                    text: $title,
                    limit: titleLimit
                )

                TextEditorWithLimit(
                    title: NSLocalizedString("additionalNotes", comment: ""),
                    text: $additionalNotes,
                    limit: additionalnotesLimit
                )
                
                LocationView()
                
                LocationFields(
                    street: $street,
                    state: $state,
                    city: $city,
                    zipcode: $zipcode
                )

                IdentificationField(identification: $identification)

                HelpSelectionSection(
                    ishelpneeded: $ishelpneeded,
                    selectedhelp: $selectedhelp,
                    skills: skills
                )

                FormButtons(
                    allFieldsFilled: allFieldsFilled,
                    saveToFirestore: saveToFirestore,
                    discardAction: { presentationMode.wrappedValue.dismiss() },
                    alertMessage: $alertMessage,
                    showAlert: $showAlert
                )
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Add Help Request")
                    .font(.headline)
            }
        }
        .sheet(isPresented: $ishelpneeded) {
            HelpSelectionView(selectedhelp: $selectedhelp, skills: skills)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Form Submission"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage == "Event saved successfully!" {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
        .overlay(
            isLoading ? ProgressView("Saving...")
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
                : nil
        )
        }
        else {
            Image("CommunityOfThree").padding()
            Text("Log in to connect with your local community.")
        }
    }
}

struct FormButtons: View {
    @Environment(\.presentationMode) var presentationMode
    var allFieldsFilled: Bool
    var saveToFirestore: () -> Void
    var discardAction: () -> Void
    @Binding var alertMessage: String
    @Binding var showAlert: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Save Button
            HStack {
                Spacer() 
                NavLinkButton(title: NSLocalizedString("saveEventButtonTitle", comment: ""), width: 300, secondaryButton: false)
                    .padding()
                    .background(Color.clear)
                    .disabled(!allFieldsFilled)
                    .onTapGesture {
                        if allFieldsFilled {
                            saveToFirestore()
                        } else {
                            alertMessage = "Please fill in all required fields."
                            showAlert = true
                        }
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Form Submission"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK")) {
                                if alertMessage == "Event saved successfully!" {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        )
                    }
                Spacer()
            }

            
            HStack {
                Spacer()
                NavLinkButton(title: NSLocalizedString("discardButtonTitle", comment: ""), width: 300, secondaryButton: true)
                    .padding()
                    .background(Color.clear)
                    .onTapGesture {
                        discardAction()
                    }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct FormHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("🙌 Need extra help?\nLet us spread the word!")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer()

            Text("Publish a request to Community Hub")
                .font(.title3)
                .fontWeight(.semibold)
                

            Text("If this homeless person requires further assistance, please provide additional details so we can share with the community and rally support to help them.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 12)
    }
}


struct LocationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            Text("Help other volunteers to find them")
                .font(.title3)
                .fontWeight(.semibold)
                
            
            Text("Please provide as many details as you can to help us locate them")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Text Field with Character Limit
private struct TextFieldWithLimit: View {
    var title: String
    var placeholder: String
    @Binding var text: String
    var limit: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            
            // TextField with border
            TextField(placeholder, text: Binding(
                get: { text },
                set: { text = String($0.prefix(limit)) }
            ))
            .frame(height:20)
            .textFieldStyle(PlainTextFieldStyle())
            .padding()
            .background(Color.white)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray, lineWidth: 0.5)
            )
            
            
            HStack {
                Spacer()
                Text("\(text.count)/\(limit)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}



/// Text Editor with Character Limit
struct TextEditorWithLimit: View {
    var title: String
    @Binding var text: String
    var limit: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            
            
            TextEditor(text: Binding(
                get: { text },
                set: { text = String($0.prefix(limit)) }
            ))
            .padding(8)
            .background(Color.white)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray, lineWidth: 0.5)
            )
            .frame(height: 150)

            HStack {
                Spacer()
                Text("\(text.count)/\(limit)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}



/// Location Fields
struct LocationFields: View {
    @Binding var street: String
    @Binding var state: String
    @Binding var city: String
    @Binding var zipcode: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("location", comment: ""))
                .font(.headline)
                .padding(.vertical, 4)

            TextField(NSLocalizedString("street", comment: ""), text: $street)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 4)

            TextField(NSLocalizedString("state", comment: ""), text: $state)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 4)

            TextField(NSLocalizedString("city", comment: ""), text: $city)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 4)

            TextField(NSLocalizedString("zipcode", comment: ""), text: $zipcode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 4)
        }
    }
}

/// Identification Field
struct IdentificationField: View {
    @Binding var identification: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("How can we identify this person?*").font(.headline)
                .padding(.vertical)
            TextField(NSLocalizedString("blueshirt", comment: ""), text: $identification)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct HelpSelectionSection: View {
    @Binding var ishelpneeded: Bool
    @Binding var selectedhelp: [String]
    var skills: [String]

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            
            HStack {
                Spacer()
                NavLinkButton(title: NSLocalizedString("selecthelp", comment: ""), width: 300, secondaryButton: false)
                    .padding()
                    .background(Color.clear)
                    .onTapGesture {
                        ishelpneeded.toggle()
                    }
                Spacer()
            }

            
            if !selectedhelp.isEmpty {
                Text("Selected Help:")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.top)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(selectedhelp, id: \.self) { skill in
                            Text(skill)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct HelpSelectionView: View {
    @Binding var selectedhelp: [String]
    let skills: [String]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Select the help they need")
                .font(.headline)
                .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(skills, id: \.self) { skill in
                        Button(action: {
                            if selectedhelp.contains(skill) {
                                selectedhelp.removeAll { $0 == skill }
                            } else {
                                selectedhelp.append(skill)
                            }
                        }) {
                            HStack {
                                Image(systemName: selectedhelp.contains(skill) ? "checkmark.square" : "square")
                                Text(skill)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                .padding()
            }
            
            HStack {
                NavLinkButton(title: "Clear All", width: 120, secondaryButton: true)
                    .onTapGesture {
                        selectedhelp.removeAll()
                    }
                
                NavLinkButton(title: "Cancel", width: 120, secondaryButton: true)
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
                
                NavLinkButton(title: "Done", width: 120, secondaryButton: false)
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
            }
            .padding()
        }
    }
}
