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
    @State private var location = ""
    @State private var date = Date()
    @State private var time = Date()
    @State private var eventDescription = ""
    @State private var skillsDescription = ""  // Skills description field
    @State private var showAlert = false
    @State private var alertMessage = ""

    private let db = Firestore.firestore()
    private let titleLimit = 15
    private let descriptionLimit = 200

    var allFieldsFilled: Bool {
        !title.isEmpty && !location.isEmpty
    }

    func saveToFirestore() {
        guard allFieldsFilled else {
            alertMessage = "Please fill in all required fields."
            showAlert = true
            return
        }

        let formData: [String: Any] = [
            "title": title,
            "location": location,
            "date": date,
            "time": time,
            "eventDescription": eventDescription,
            "skillsDescription": skillsDescription  // Add skills description to Firestore data
        ]

        db.collection("outreachEventsDev").addDocument(data: formData) { error in
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

                    Text("Add new")
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
                        Text("Title")
                            .font(.headline)
                        
                        TextField("Enter Event Title", text: $title)
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
                        //.padding(.bottom, 5)

                        // Location field
                        Text("Location")
                            .font(.headline)
                        
                        TextField("Enter Location", text: $location)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        // Date and Time fields with capsule style and icons
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Date")
                                    .font(.headline)
                                
                                HStack {
                                    Image(systemName: "calendar")
                                    
                                    DatePicker("", selection: $date, displayedComponents: .date)
                                        .datePickerStyle(CompactDatePickerStyle())
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color(.clear))
                                .cornerRadius(20)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Text("Time")
                                    .font(.headline)
                                
                                HStack {
                                    Image(systemName: "clock")
                                    
                                    DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(CompactDatePickerStyle())
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color(.clear))
                                .cornerRadius(20)
                            }
                        }
                        .padding(.bottom, 5)

                        // Event Description with character counter
                        Text("Event Description")
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

                        // Skills Description section
                        Text("Skills Description")
                            .font(.headline)
                        
                        TextEditor(text: $skillsDescription)
                            .frame(height: 100)
                            .border(Color.gray, width: 0.5)
                            .cornerRadius(5)
                            .padding(.bottom, 5)

                        // Save Button
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
                        
                        // Discard Button
                        NavLinkButton(title: NSLocalizedString("discardButtonTitle", comment: ""), width: 300, secondaryButton: true)
                            .onTapGesture {
                                presentationMode.wrappedValue.dismiss()  // Close the form on discard
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
            }
        }
    }
}

