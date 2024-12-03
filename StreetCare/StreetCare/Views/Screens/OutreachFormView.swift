//
//  OutreachFormView.swift
//  StreetCare
//
//  Created by Marian John on 11/12/24.
//
import SwiftUI
import Firebase

struct OutreachFormView: View {
    @Binding var isPresented: Bool // Binding to dismiss the view
    @Environment(\.dismiss) var dismiss

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
    @State private var showAlert = false
    @State private var isLoading = false

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

    func saveToFirestore() {
        guard allFieldsFilled else {
            alertMessage = "Please fill in all required fields."
            showAlert = true
            return
        }
        isLoading = true

        // Simulate save action
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
            alertMessage = "Event saved successfully!"
            showAlert = true
            isPresented = false // Close the view after saving
        }
    }

    var body: some View {
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

                // Event Description
                Text(NSLocalizedString("eventDescription", comment: ""))
                    .font(.headline)

                TextEditor(text: $eventDescription)
                    .frame(height: 200)
                    .border(Color.gray, width: 0.5)
                    .cornerRadius(5)
                    .onChange(of: eventDescription) { newValue in
                        if newValue.count > descriptionLimit {
                            eventDescription = String(newValue.prefix(descriptionLimit))
                        }
                    }

                HStack {
                    Spacer()
                    Text("\(eventDescription.count)/\(descriptionLimit)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

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
