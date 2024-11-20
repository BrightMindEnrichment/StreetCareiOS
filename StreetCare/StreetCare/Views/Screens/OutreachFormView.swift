//
//  OutreachFormView.swift
//  StreetCare
//
//  Created by Marian John on 11/12/24.
//
import SwiftUI
import FirebaseFirestore

struct OutreachFormView: View {
    @Environment(\.presentationMode) var presentationMode  // Environment property to dismiss view
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
    //@State private var alertMessage: AlertMessage?
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var isLoading = false // Track the loading state

    let skills = ["Childcare", "Counselling and Support", "Clothing", "Education", "Personal Care", "Employment and Training", "Food and Water", "Healthcare", "Chinese", "Spanish", "Language (please specify)", "Legal", "Shelter", "Transportation", "LGBTQ Support", "Technology Access", "Social Integration", "Pet Care"]
    

    /*private enum AlertMessage: String {
        case emptyFields = "Please fill in all required fields."
        case success = "Event saved successfully!"
        case error = "Error saving data"
        }*/
    private let db = Firestore.firestore()
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
        let formData: [String: Any] = [
            "title": title,
            "street": street,
            "state": state,
            "city": city,
            "zipcode": zipcode,
            "startDate": startDate,
            "startTime": startTime,
            "endDate": endDate,
            "endTime": endTime,
            "helpType": helpType,
            "maxCapacity": maxCapacity,
            "eventDescription": eventDescription,
            "selectedSkills": selectedSkills
        ]

        db.collection("outreachEventsDev").addDocument(data: formData) { error in
            isLoading = false
            if let error = error {
                alertMessage = "Error saving data"
                showAlert = true
            } else {
                alertMessage = "Event saved successfully!"
                showAlert = true
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Custom back button with title centered
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text(NSLocalizedString("addNew", comment: ""))
                        .font(.title2)  // Larger font size
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)  // Center-align title text
                        .padding(.leading, -30)  // Adjust padding to balance button and title alignment
                    
                    Spacer()
                }
                .padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Title field with character counter
                        Text(NSLocalizedString("title", comment: ""))
                            .font(.headline)
                        
                        TextField((NSLocalizedString("enterEventTitle", comment: "")), text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: title) { newValue in
                                if newValue.count > titleLimit {
                                    title = String(newValue.prefix(titleLimit))
                                }
                            }
                            .padding(.bottom, 5)
                        
                        HStack {
                            Spacer()
                            Text("\(title.count)/\(titleLimit)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Text(NSLocalizedString("location", comment: ""))
                            .font(.headline)
                        
                        TextField((NSLocalizedString("street", comment: "")), text: $street)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField((NSLocalizedString("state", comment: "")), text: $state)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField((NSLocalizedString("city", comment: "")), text: $city)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField((NSLocalizedString("zipcode", comment: "")), text: $zipcode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        DatePicker((NSLocalizedString("startDate", comment: "")), selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                        
                        DatePicker((NSLocalizedString("startTime", comment: "")), selection: $startTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                        
                        DatePicker((NSLocalizedString("endDate", comment: "")), selection: $endDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                        
                        DatePicker((NSLocalizedString("endTime", comment: "")), selection: $endTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(CompactDatePickerStyle())
                        
                        Text(NSLocalizedString("helpType", comment: ""))
                            .font(.headline)
                        
                        TextField(NSLocalizedString("eghelpType", comment: ""), text: $helpType)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text(NSLocalizedString("maximumCapacity", comment: ""))
                            .font(.headline)
                        
                        TextField(NSLocalizedString("egmaximumCapacity", comment: ""), text: $maxCapacity)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        
                        // Event Description with character counter
                        Text(NSLocalizedString("eventDescription", comment: ""))
                            .font(.headline)
                
                        TextEditor(text: $eventDescription)
                            .frame(height: 200)  // Larger frame for description
                            .border(Color.gray, width: 0.5)
                            .cornerRadius(5)
                            .onChange(of: eventDescription) { newValue in
                                if newValue.count > descriptionLimit {
                                    eventDescription = String(newValue.prefix(descriptionLimit))
                                }
                            }
                            .padding(.bottom, 5)

                        HStack {
                            Spacer()
                            Text("\(eventDescription.count)/\(descriptionLimit)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 5)
                        
                        NavLinkButton(title: NSLocalizedString("selectSkillsButtonTitle", comment: ""), width: 300, secondaryButton: false)
                            .padding()
                            .background(Color.clear)
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
                            .padding()
                            .background(Color.clear)
                            .disabled(!allFieldsFilled)
                            .onTapGesture {
                                saveToFirestore()
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
                        
                        NavLinkButton(title: NSLocalizedString("discardButtonTitle", comment: ""), width: 300, secondaryButton: true)
                            .onTapGesture {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .padding()
                            .background(Color.clear)
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 10)
                .padding(.horizontal)
                .sheet(isPresented: $isSkillSheetPresented) {
                    SkillSelectionView(selectedSkills: $selectedSkills, skills: skills)
                }
                
            }
            .overlay(
                isLoading ? ProgressView("Saving...").padding().background(Color.white.opacity(0.8)).cornerRadius(10) : nil
            )
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
