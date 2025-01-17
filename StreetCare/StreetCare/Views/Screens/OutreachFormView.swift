//
//  OutreachFormView.swift
//  StreetCare
//
//  Created by Marian John on 11/12/24.
//
import SwiftUI
import Firebase

struct OutreachFormView: View {
    @Binding var isPresented: Bool
    //@Environment(\.dismiss) var dismiss
    @Binding var shouldDismissAll: Bool // Shared variable
    @State private var showChapterMembershipForm = false // State to control form presentation
    @Environment(\.presentationMode) var presentationMode // Local dismissal environment
    @State private var title = ""
    @State private var street = ""
    @State private var state = ""
    @State private var city = ""
    @State private var zipcode = ""
    @State private var startDate = Date()
    @State private var startTime = Date()
    @State private var endDate = Date()
    @State private var endTime = Date()
    @State private var helpType = ""
    @State private var maxCapacity = ""
    @State private var eventDescription = ""
    @State private var selectedSkills: [String] = []
    @State private var isSkillSheetPresented = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    @State private var showAlert = false
    @State private var isLoading = false
    @State private var chaptermemberMessage1 = ""

    let skills = ["Childcare", "Counselling and Support", "Clothing", "Education", "Personal Care", "Employment and Training", "Food and Water", "Healthcare", "Chinese", "Spanish", "Language (please specify)", "Legal", "Shelter", "Transportation", "LGBTQ Support", "Technology Access", "Social Integration", "Pet Care"]

    private let titleLimit = 50
    private let descriptionLimit = 200

    var allFieldsFilled: Bool {
        !title.isEmpty &&
        !street.isEmpty &&
        !state.isEmpty &&
        !city.isEmpty &&
        !zipcode.isEmpty &&
        !helpType.isEmpty &&
        !maxCapacity.isEmpty
    }

    /*func saveToFirestore() {
        guard allFieldsFilled else {
            alertMessage = "Please fill in all required fields."
            alertTitle = "New Outreach Event"
            showAlert = true
            return
        }
        isLoading = true

        // Simulate save action
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
            //alertTitle = "New Outreach Event Created"
            alertTitle = "Thank you for submitting your request!"
            //alertMessage = "Event saved successfully!"
            alertMessage = "Approval may take up to 5 business days."
            chaptermemberMessage1 = "Streamline your experience with Chapter membership."
            showAlert = true
        }
    }*/
    func saveToFirestore() {
        guard allFieldsFilled else {
            alertMessage = "Please fill in all required fields."
            alertTitle = "New Outreach Event"
            showAlert = true
            return
        }
        isLoading = true

        let db = Firestore.firestore()

        // Prepare data for Firestore
        let outreachEvent: [String: Any] = [
            "title": title,
            "street": street,
            "state": state,
            "city": city,
            "zipcode": zipcode,
            "startDate": Timestamp(date: startDate),
            "startTime": Timestamp(date: startTime),
            "endDate": Timestamp(date: endDate),
            "endTime": Timestamp(date: endTime),
            "helpType": helpType,
            "maxCapacity": maxCapacity,
            "eventDescription": eventDescription,
            "selectedSkills": selectedSkills,
            "createdAt": Timestamp(date: Date())
        ]

        // Save to Firestore
        db.collection("outreachEventsDev").addDocument(data: outreachEvent) { error in
            isLoading = false
            if let error = error {
                // Handle error
                alertTitle = "Error"
                alertMessage = "Failed to save event: \(error.localizedDescription)"
            } else {
                // Success
                alertTitle = "Thank you for submitting your request!"
                alertMessage = "Approval may take up to 5 business days."
                chaptermemberMessage1 = "Streamline your experience with Chapter membership."
            }
            showAlert = true
        }
    }
    var body: some View {
        NavigationLink(
            //destination: ChapterMembershipForm(isPresented: $showChapterMembershipForm),
            destination: ChapterMembershipForm(
                            isPresented: $showChapterMembershipForm,
                            shouldDismissAll: $shouldDismissAll
                        ),
            isActive: $showChapterMembershipForm
        ) {
            EmptyView()
        }
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Title Field
                Text(NSLocalizedString("title", comment: ""))
                    .font(.headline)

                TextField(NSLocalizedString("enterEventTitle", comment: ""), text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: title) { newValue in
                        if newValue.count > titleLimit {
                            title = String(newValue.prefix(titleLimit))
                        }
                    }

                HStack {
                    Spacer()
                    Text("\(title.count)/\(titleLimit)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                // Location Fields
                Text(NSLocalizedString("location", comment: ""))
                    .font(.headline)

                TextField(NSLocalizedString("street", comment: ""), text: $street)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField(NSLocalizedString("state", comment: ""), text: $state)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField(NSLocalizedString("city", comment: ""), text: $city)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField(NSLocalizedString("zipcode", comment: ""), text: $zipcode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // Date and Time Pickers
                DatePicker(NSLocalizedString("startDate", comment: ""), selection: $startDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())

                DatePicker(NSLocalizedString("startTime", comment: ""), selection: $startTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(CompactDatePickerStyle())

                DatePicker(NSLocalizedString("endDate", comment: ""), selection: $endDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())

                DatePicker(NSLocalizedString("endTime", comment: ""), selection: $endTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(CompactDatePickerStyle())

                // Help Type
                Text(NSLocalizedString("helpType", comment: ""))
                    .font(.headline)

                TextField(NSLocalizedString("eghelpType", comment: ""), text: $helpType)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // Maximum Capacity
                Text(NSLocalizedString("maximumCapacity", comment: ""))
                    .font(.headline)

                TextField(NSLocalizedString("egmaximumCapacity", comment: ""), text: $maxCapacity)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)

                TextFieldWithLimit(
                    title: NSLocalizedString("eventDescription", comment: ""),
                    placeholder: NSLocalizedString("enterEventDescription", comment: ""),
                    text: $eventDescription,
                    limit: descriptionLimit
                )

                // Buttons Section
                VStack(spacing: 20) {
                    NavLinkButton(title: NSLocalizedString("selectSkillsButtonTitle", comment: ""), width: 300, secondaryButton: false)
                        .onTapGesture {
                            isSkillSheetPresented.toggle()
                        }

                    if !selectedSkills.isEmpty {
                        Text("Selected Skills:")
                            .font(.headline)
                        ForEach(selectedSkills, id: \.self) { skill in
                            Text(skill)
                                .padding(.horizontal)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }
                    }

                    NavLinkButton(title: NSLocalizedString("saveEventButtonTitle", comment: ""), width: 300, secondaryButton: false)
                        .disabled(!allFieldsFilled)
                        .onTapGesture {
                            saveToFirestore()
                        }

                    NavLinkButton(title: NSLocalizedString("discardButtonTitle", comment: ""), width: 300, secondaryButton: true)
                        .onTapGesture {
                            isPresented = false
                        }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            }
            .padding()
        }
        .overlay(
            isLoading ? ProgressView("Saving...")
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(10) : nil
        )
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage + chaptermemberMessage1),
                primaryButton: .default(Text("Sign Up")) {
                    // Navigate only if the alert message matches
                    if alertMessage == "Approval may take up to 5 business days." {
                        showChapterMembershipForm = true
                    }
                },
                secondaryButton: .cancel(Text("Remind me Later"))
            )
        }
        .onChange(of: shouldDismissAll) { value in
            if value {
                            presentationMode.wrappedValue.dismiss()
                        }
               }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Add New")
                    .font(.headline)
            }
        }
        .sheet(isPresented: $isSkillSheetPresented) {
            SkillSelectionView(selectedSkills: $selectedSkills, skills: skills)
        }
    }
}

struct SkillSelectionView: View {
    @Binding var selectedSkills: [String]
    let skills: [String]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Select the skills needed to provide help")
                .font(.headline)
                .padding()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(skills, id: \.self) { skill in
                        Button(action: {
                            if selectedSkills.contains(skill) {
                                selectedSkills.removeAll { $0 == skill }
                            } else {
                                selectedSkills.append(skill)
                            }
                        }) {
                            HStack {
                                Image(systemName: selectedSkills.contains(skill) ? "checkmark.square" : "square")
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
                        selectedSkills.removeAll()
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
            .frame(height:150, alignment: .top)
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
