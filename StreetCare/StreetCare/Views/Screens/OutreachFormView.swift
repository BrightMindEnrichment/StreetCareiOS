//
//  OutreachFormView.swift
//  StreetCare
//
//  Created by Marian John on 11/12/24.
//
import SwiftUI
import Firebase
import GooglePlaces
import FirebaseAuth

struct OutreachFormView: View {
    @Binding var isPresented: Bool
    //@Environment(\.dismiss) var dismiss
    @State var user: User?
    @Binding var shouldDismissAll: Bool
    @State private var showChapterMembershipForm = false
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var contactNumber = ""
    @State private var emailAddress = ""
    @State private var street = ""
    @State private var state = ""
    @State private var city = ""
    @State private var zipcode = ""
    @State private var stateAbbreviation = ""
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
    @State private var showAddressSearch = false
    @State private var consentStatus: Bool = false
    @State private var primaryButtonText = ""
    @State private var secondaryButtonText = ""



    let skills = ["Childcare", "Counselling and Support", "Clothing", "Education", "Personal Care", "Employment and Training", "Food and Water", "Healthcare", "Chinese", "Spanish", "Language (please specify)", "Legal", "Shelter", "Transportation", "LGBTQ Support", "Technology Access", "Social Integration", "Pet Care"]

    private let titleLimit = 50
    private let descriptionLimit = 200

    var allFieldsFilled: Bool {
        !title.isEmpty &&
        !state.isEmpty &&
        !city.isEmpty &&
        !helpType.isEmpty &&
        !maxCapacity.isEmpty &&
        !eventDescription.isEmpty
        
    }

    func saveToFirestore() {
//        guard allFieldsFilled else {
//            alertMessage = "Please fill in all required fields."
//            alertTitle = "New Outreach Event"
//            chaptermemberMessage1 = ""
//            primaryButtonText = "OK"
//            secondaryButtonText = "Exit"
//            showAlert = true
//            return
//        }
        if title.isEmpty {
            alertMessage = "Please enter the event title."
            alertTitle = "Missing Title"
            chaptermemberMessage1 = ""
            primaryButtonText = "OK"
            secondaryButtonText = "Exit"
            showAlert = true
                return
            }
        if state.isEmpty {
            alertMessage = "Please enter the state."
            alertTitle = "Missing State"
            chaptermemberMessage1 = ""
            primaryButtonText = "OK"
            secondaryButtonText = "Exit"
            showAlert = true
            return
            
        }
        if city.isEmpty {
            alertMessage = "Please enter the city."
            alertTitle = "Missing City"
            chaptermemberMessage1 = ""
            primaryButtonText = "OK"
            secondaryButtonText = "Exit"
            showAlert = true
            return
            
        }
        if helpType.isEmpty {
            alertMessage = "Please enter the type of support offered."
            alertTitle = "Missing support type"
            chaptermemberMessage1 = ""
            primaryButtonText = "OK"
            secondaryButtonText = "Exit"
            showAlert = true
            return
           }
        if maxCapacity.isEmpty {
            alertMessage = "Please enter Total allowable participants"
            alertTitle = "Missing Total allowable participants"
            chaptermemberMessage1 = ""
            primaryButtonText = "OK"
            secondaryButtonText = "Exit"
            showAlert = true
            return
            
        }
        if eventDescription.isEmpty{
            alertMessage = "Please enter Event Description"
            alertTitle = "Missing Event Description"
            chaptermemberMessage1 = ""
            primaryButtonText = "OK"
            secondaryButtonText = "Exit"
            showAlert = true
            return
        }
        if !contactNumber.isEmpty && contactNumber.count < 10 {
            alertTitle = "Invalid Number"
            alertMessage = "Please enter a 10-digit contact number."
            chaptermemberMessage1 = ""
            primaryButtonText = "OK"
            secondaryButtonText = "Exit"
            showAlert = true
            return
        }
        
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user")
            return
        }
        isLoading = true

        let db = Firestore.firestore()

        let stateAbbreviation = StateHelper.getStateAbbreviation(for: state)
        
        let outreachEvent: [String: Any] = [
            "approved": false,
            "createdAt": Timestamp(date: Date()),
            "description": eventDescription,
            "eventDate": Timestamp(date: startDate),
            "eventStartTime": Timestamp(date: startTime),
            "eventEndTime": Timestamp(date: endTime),
            "timeZone": TimeZoneHelper.getLocalizedTimeZoneAbbreviation(),
            "helpRequest": [
                "helpType": helpType,
                "interests": 1,
                "isFlagged": false,
                "flaggedByUser": ""
            ],
            "location": [
                "city": city,
                "state": state,
                "stateAbbv": stateAbbreviation,
                "street": street,
                "zipcode": zipcode
            ],
            "participants": [user.uid],
            "skills": selectedSkills,
            "status": "pending",
            "title": title,
            "totalSlots": maxCapacity,
            "uid": user.uid,
            "contactNumber": contactNumber,
            "consentStatus": consentStatus,
            "emailAddress": emailAddress
        ]

        // Save to Firestore
        var eventDocumentRef: DocumentReference? = nil
        eventDocumentRef = db.collection("outreachEventsDev").addDocument(data: outreachEvent) { error in
            isLoading = false
            if let error = error {
                alertTitle = "Error"
                alertMessage = "Failed to save event: \(error.localizedDescription)"
            } else if let eventDocId = eventDocumentRef?.documentID {
                addCreatedEventToUser(userId: user.uid, eventId: eventDocId)
                
                alertTitle = "Thank you for submitting your request!"
                alertMessage = "Approval can take typically within four business days."
                chaptermemberMessage1 = " Streamline your experience with Chapter membership."
                primaryButtonText = "Sign Up"
                secondaryButtonText = "Remind me Later"
                showAlert = true
            }
        }
    }
    func addCreatedEventToUser(userId: String, eventId: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        userRef.updateData([
            "createdOutreaches": FieldValue.arrayUnion([eventId])
        ]) { error in
            if let error = error {
                print("Error updating user document: \(error.localizedDescription)")
            } else {
                print("Successfully added event ID to createdOutreaches array in user document")
            }
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
                
                //contact field
                Text(NSLocalizedString("Contact Number", comment: ""))
                    .font(.headline)
                
                TextField(NSLocalizedString("enterContactNumber", comment: ""), text: $contactNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                    .onChange(of: contactNumber) { newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        contactNumber = String(filtered.prefix(10))
                    }

                
        
                //email
                Text(NSLocalizedString("Email", comment: ""))
                    .font(.headline)

                TextField(NSLocalizedString("enterContactNumber", comment: ""), text: $emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                //address
                Text(NSLocalizedString("enterEmailAddress", comment: ""))
                    .font(.headline)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    Text(street.isEmpty ? "Search Address" : street)
                        .foregroundColor(street.isEmpty ? .gray : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading) //
                }
                .padding()
                .frame(height: 45)
                .background()
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .onTapGesture {
                    showAddressSearch = true
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

                TimePickerWithTimeZone(
                    startDate: $startDate,
                    startTime: $startTime,
                    endDate: $endDate,
                    endTime: $endTime
                )

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
                
                //checkbox disclaimer
                HStack(alignment: .top, spacing: 10) {
                    Button(action: {
                        consentStatus.toggle()
                        print("consentStatus toggled: \(consentStatus)")
                    }) {
                        Image(systemName: consentStatus ? "checkmark.square" : "square")
                            .foregroundColor(consentStatus ? .black : .gray)
                            .font(.body)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Text(NSLocalizedString("consentLine", comment: ""))
                        .font(.body)
                        .multilineTextAlignment(.leading)
                }
                .padding(.top, 20)

                
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
                            presentationMode.wrappedValue.dismiss()
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
                primaryButton: .default(Text(primaryButtonText)) {
                    // Navigate only if the alert message matches
                    if alertMessage.contains("Approval can take typically within four business days.") {
                        //isPresented = false
                       // shouldDismissAll = true
                        showChapterMembershipForm = true
                    }
                },
                secondaryButton: .cancel(Text(secondaryButtonText)){
                    presentationMode.wrappedValue.dismiss()
                }
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
                    presentationMode.wrappedValue.dismiss()
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
        .sheet(isPresented: $showAddressSearch) {
            GooglePlacesAutocomplete(street: $street, city: $city, state: $state, stateAbbreviation: $stateAbbreviation, zipcode: $zipcode)
        }
    }
}
struct SkillSelectionView: View {
    @Binding var selectedSkills: [String]
    let skills: [String]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Select the skills required to provide support")
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
struct StateHelper {
    static let stateAbbreviations: [String: String] = [
        "Alabama": "AL", "Alaska": "AK", "Arizona": "AZ", "Arkansas": "AR",
        "California": "CA", "Colorado": "CO", "Connecticut": "CT", "Delaware": "DE",
        "Florida": "FL", "Georgia": "GA", "Hawaii": "HI", "Idaho": "ID",
        "Illinois": "IL", "Indiana": "IN", "Iowa": "IA", "Kansas": "KS",
        "Kentucky": "KY", "Louisiana": "LA", "Maine": "ME", "Maryland": "MD",
        "Massachusetts": "MA", "Michigan": "MI", "Minnesota": "MN", "Mississippi": "MS",
        "Missouri": "MO", "Montana": "MT", "Nebraska": "NE", "Nevada": "NV",
        "New Hampshire": "NH", "New Jersey": "NJ", "New Mexico": "NM", "New York": "NY",
        "North Carolina": "NC", "North Dakota": "ND", "Ohio": "OH", "Oklahoma": "OK",
        "Oregon": "OR", "Pennsylvania": "PA", "Rhode Island": "RI", "South Carolina": "SC",
        "South Dakota": "SD", "Tennessee": "TN", "Texas": "TX", "Utah": "UT",
        "Vermont": "VT", "Virginia": "VA", "Washington": "WA", "West Virginia": "WV",
        "Wisconsin": "WI", "Wyoming": "WY"
    ]

    static func getStateAbbreviation(for stateName: String) -> String? {
        let normalizedState = stateName.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
        return stateAbbreviations[normalizedState]
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
struct TimePickerWithTimeZone: View {
    @Binding var startDate: Date
    @Binding var startTime: Date
    @Binding var endDate: Date
    @Binding var endTime: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Start Date
            HStack {
                Text(NSLocalizedString("startDate", comment: "Start Date Label"))
                    .font(.headline)
                
                Spacer()
                
                DatePicker("", selection: $startDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(CompactDatePickerStyle())
            }
            
            // Start Time
            HStack {
                Text(NSLocalizedString("startTime", comment: "Start Time Label"))
                    .font(.headline)
                
                Spacer()
                
                DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(CompactDatePickerStyle())
                
                Text(TimeZoneHelper.getLocalizedTimeZoneAbbreviation())
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // End Date
            HStack {
                Text(NSLocalizedString("endDate", comment: "End Date Label"))
                    .font(.headline)
                
                Spacer()
                
                DatePicker("", selection: $endDate, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(CompactDatePickerStyle())
            }
            
            // End Time
            HStack {
                Text(NSLocalizedString("endTime", comment: "End Time Label"))
                    .font(.headline)
                
                Spacer()
                
                DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(CompactDatePickerStyle())
                
                Text(TimeZoneHelper.getLocalizedTimeZoneAbbreviation())
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

    // Function to get the localized time zone abbreviation
struct TimeZoneHelper {
    static func getLocalizedTimeZoneAbbreviation() -> String {
        return TimeZone.current.abbreviation() ?? "UTC"
    }
}


struct GooglePlacesAutocomplete: UIViewControllerRepresentable {
    @Binding var street: String
    @Binding var city: String
    @Binding var state: String
    @Binding var stateAbbreviation: String
    @Binding var zipcode: String
    var location: Binding<CLLocationCoordinate2D?>? = nil  // Optional location binding
    //@Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> GMSAutocompleteViewController {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = context.coordinator

        let fields: GMSPlaceField = [.name, .formattedAddress, .addressComponents, .coordinate]
        autocompleteController.placeFields = fields


        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter

        return autocompleteController
    }

    func updateUIViewController(_ uiViewController: GMSAutocompleteViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, GMSAutocompleteViewControllerDelegate {
        var parent: GooglePlacesAutocomplete

        init(_ parent: GooglePlacesAutocomplete) {
            self.parent = parent
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
            viewController.dismiss(animated: true)
            parent.street = place.name ?? ""

            if let addressComponents = place.addressComponents {
                for component in addressComponents {
                    if component.types.contains("administrative_area_level_1") {
                        parent.state = component.name
                        parent.stateAbbreviation = component.shortName ?? "" 
                    }
                    if component.types.contains("locality") {
                        parent.city = component.name
                    }
                    if component.types.contains("postal_code") {
                        parent.zipcode = component.name
                    }
                }
            }
            let lat = place.coordinate.latitude
            let lon = place.coordinate.longitude
            
            parent.location?.wrappedValue = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            print("📍 Selected Address Coordinates: \(lat), \(lon)") // Debugging print
            viewController.dismiss(animated: true)
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
            print("Error: ", error.localizedDescription)
            viewController.dismiss(animated: true)
        }

        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            viewController.dismiss(animated: true)
        }
    }
}
 
