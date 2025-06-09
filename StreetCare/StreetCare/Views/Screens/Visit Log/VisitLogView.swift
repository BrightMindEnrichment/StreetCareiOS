//
//  VisitLogView.swift
//  StreetCare
//
//  Created by Michael on 3/27/23.
//

import SwiftUI
import MapKit

struct VisitLogView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.presentationMode) var presentationMode
    @State var log: VisitLog
    @State private var navigateToEditFurtherSupport = false
    @StateObject var editedVisitLog = VisitLog(id: "")
    @State var editedLocationDescription: String = ""

    //@State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(), span: MKCoordinateSpan())
    //@State private var mapLocations = [MapLocation(name: "dummy", latitude: 0.0, longitude: 0.0)]

    @State private var showDeleteDialog = false

    @State private var navigateToEdit = false
    @State private var editedPeopleHelped: Int = 0
    @State var editedPeopleHelpedDescription: String = ""

    @State private var navigateToEditItems = false
    @State private var editedItemQty: Int = 0
    @State var editedItemQtyDescription: String = ""
    
    @State private var editedInteractionDate = Date()
    @State private var navigateToEditInteractionDate = false

    @State private var navigateToEditSupportProvided = false
    @State private var editedSupportProvided = VisitLog(id: "")

    @State private var navigateToEditFollowUpDate = false
    @State private var editedFollowUpDate = Date()

    @State private var navigateToEditPeopleNeedHelp = false
    @State private var editedPeopleNeedHelp: Int = 0
    @State var editedPeopleNeedHelpComment: String = ""

    @StateObject var editedFurtherSupport = VisitLog(id: "")
    @State private var isEditingPeopleHelped = false
    
    @State private var navigateToEditHelpers = false
    @State private var editedHelpers: Int = 0
    @State var editedHelpersComment: String = ""
    
    @State private var navigateToEditFurtherOtherNotes = false
    @State private var editedFurtherOtherNotes: String = ""
    
    @State private var showConfirmationDialog = false
    @State private var hasShared = false
    
    @State private var editedVolunteerAgain: String = ""
    @State private var navigateToEditVolunteerAgain = false
    
    @State private var editedRating: Int = 0
    @State private var editedRatingComment: String = ""
    @State private var navigateToEditRating = false

    @State private var editedFurtherFoodAndDrinks = false
    @State private var editedFurtherClothes = false
    @State private var editedFurtherHygiene = false
    @State private var editedFurtherWellness = false
    @State private var editedFurtherMedical = false
    @State private var editedFurtherSocial = false
    @State private var editedFurtherLegal = false
    @State private var editedFurtherOther = false
    
    @State private var navigateToEditDuration = false
    @State private var navigateToEditLocation = false
    @State private var editedLocationText = ""
    @State private var editedLocationCoord = CLLocationCoordinate2D()
    @State private var lat: Double = 0.0
    @State private var lon: Double = 0.0
    @State private var resolvedAddress: String = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var mapLocations: [MapLocation] = []
    var body: some View {
        ScrollView {
            VStack {
                
                mapSection()
                interactionDateSection()
                locationSection()
                peopleHelpedSection()
                providedhelpSection()
                itemQtySection()
                ratingSection()
                durationSection()
                numberOfHelpersSection()
                peopleNeedFurtherHelpSection()
                furtherSupportNeededSection()
                followUpSection()
                furthernotesSection()
                volunteerAgainSection()
                
                if !hasShared {
                    HStack {
                        Button("Share with Community") {
                            showConfirmationDialog = true
                        }
                        .foregroundColor(Color("PrimaryColor"))
                        .frame(maxWidth: 350)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        //.font(.caption)
                        .fontWeight(.bold)
                        .background(
                            Capsule()
                                .fill(Color("SecondaryColor"))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color("SecondaryColor"), lineWidth: 2)
                        )
                    }
                    .padding()
                }
                NavLinkButton(title: "Delete", width: 350.0, secondaryButton: true, noBorder: false, color: Color.red)
                    .padding()
                    .onTapGesture {
                        showDeleteDialog = true
                    }

                
            }
        }
        .onAppear {
            forwardGeocode(address: log.whereVisit)
        }
        .alert(isPresented: Binding(
            get: { showConfirmationDialog || showDeleteDialog },
            set: { _ in }
        )) {
            if showConfirmationDialog {
                return Alert(
                    title: Text("Confirm Sharing"),
                    message: Text("""
                    The following information will be shared when posted to the community:
                    - Your Name
                    - Your Profile Picture
                    - Your Location
                    - Type of Help Provided
                    """),
                    primaryButton: .default(Text("Confirm")) {
                        let adapter = VisitLogDataAdapter()
                        adapter.addVisitLog_Community(self.log)
                        hasShared = true
                        showConfirmationDialog = false
                    },
                    secondaryButton: .cancel {
                        showConfirmationDialog = false
                    }
                )
            } else {
                return Alert(
                    title: Text("Delete visit log?"),
                    message: Text("This action cannot be undone."),
                    primaryButton: .destructive(Text("OK")) {
                        let adapter = VisitLogDataAdapter()
                        adapter.deleteVisitLog(log.id) {
                            presentation.wrappedValue.dismiss()
                        }
                    },
                    secondaryButton: .cancel {
                        showDeleteDialog = false
                    }
                )
            }
        }
        .navigationTitle("Interaction Details")
    }

    @ViewBuilder
    private func mapSection() -> some View {
        if lat != 0 && lon != 0 {
            Map(coordinateRegion: $region, annotationItems: mapLocations) { location in
                MapMarker(coordinate: location.coordinate)
            }
            .frame(width: 350, height: 300)
            /*.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )*/
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black, lineWidth: 1)
            )
            
        }
    }
    
    func forwardGeocode(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let location = placemarks?.first?.location {
                let coordinate = location.coordinate
                lat = coordinate.latitude
                lon = coordinate.longitude
                
                region.center = coordinate
                mapLocations = [MapLocation(name: "Visit", latitude: lat, longitude: lon)]
                
                reverseGeocode(latitude: lat, longitude: lon) // optional
            }
        }
    }
    private func reverseGeocode(latitude: Double, longitude: Double) {
        let baseUrl = "https://api.geoapify.com/v1/geocode/reverse"
        let latLonParams = "lat=\(latitude)&lon=\(longitude)&apiKey=fd35651164a04eac9266ccfb75aa125d"
        let urlString = "\(baseUrl)?\(latLonParams)"

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }

            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []),
                   let dict = json as? [String: Any],
                   let results = dict["features"] as? [[String: Any]],
                   let properties = results.first?["properties"] as? [String: Any],
                   let address = properties["formatted"] as? String {
                    DispatchQueue.main.async {
                        self.resolvedAddress = address
                        print("📍 Reverse geocoded address: \(address)")
                    }
                } else {
                    print("Unable to parse JSON address")
                }
            } else {
                print("No data received")
            }
        }

        task.resume()
    }
    @ViewBuilder
    private func interactionDateSection() -> some View {
        VisitLogDetailRow(
            title: "When was your Interaction?",
            detail1: log.whenVisit.formatted(date: .abbreviated, time: .omitted),
            onEdit: {
                editedInteractionDate = log.whenVisit
                navigateToEditInteractionDate = true
            }
        )
        
        NavigationLink(
            destination: InputTileDate(
                questionNumber: 1,
                totalQuestions: 1,
                question1: "When was your",
                question2: "Interaction?",
                question3: "",
                showSkip: false,
                showProgressBar: false,
                buttonMode: .update,
                datetimeValue: $editedInteractionDate,
                nextAction: {
                    let adapter = VisitLogDataAdapter()
                    adapter.updateVisitLogField(log.id, field: "whenVisit", value: editedInteractionDate) {
                        log.whenVisit = editedInteractionDate
                        navigateToEditInteractionDate = false
                    }
                    //presentationMode.wrappedValue.dismiss()
                },
                skipAction: { navigateToEditInteractionDate = false },
                previousAction: { navigateToEditInteractionDate = false }
            ),
            isActive: $navigateToEditInteractionDate
        ) {
            EmptyView()
        }
    }

    @ViewBuilder
    private func locationSection() -> some View {
        VisitLogDetailRow(
            title: "Where was your Interaction?",
            detail1: log.whereVisit,
            detail2: log.locationDescription,
            separator: ", ",
            onEdit: {
                editedLocationText = log.whereVisit
                editedLocationCoord = log.location
                editedLocationDescription = log.locationDescription
                navigateToEditLocation = true
            }
        )

        NavigationLink(
            destination: InputTileLocation(
                questionNumber: 1,
                totalQuestions: 1,
                question1: "Where was your",
                question2: "Interaction?",
                textValue: $editedLocationText,
                location: $editedLocationCoord,
                locationDescription: $editedLocationDescription,
                nextAction: {
                    let adapter = VisitLogDataAdapter()
                    adapter.updateVisitLogField(log.id, field: "whereVisit", value: editedLocationText) {
                        adapter.updateVisitLogField(log.id, field: "location", value: [
                            "latitude": editedLocationCoord.latitude,
                            "longitude": editedLocationCoord.longitude
                        ]) {
                            adapter.updateVisitLogField(log.id, field: "locationDescription", value: editedLocationDescription){
                                log.whereVisit = editedLocationText
                                log.location = editedLocationCoord
                                log.locationDescription = editedLocationDescription
                                navigateToEditLocation = false
                            }
                        }
                    }
                },
                previousAction: { navigateToEditLocation = false },
                skipAction: { navigateToEditLocation = false },
                buttonMode: .update
            ),
            isActive: $navigateToEditLocation
        ) {
            EmptyView()
        }
    }

    @ViewBuilder
    private func peopleHelpedSection() -> some View {
        if log.peopleHelped > 0 {
            VisitLogDetailRow(
                title: "Describe who you supported and how many individuals were involved.",
                detail1: "\(log.peopleHelped)",
                detail2: log.peopleHelpedDescription,
                separator: ", ",
                onEdit: {
                    editedPeopleHelped = log.peopleHelped
                    editedPeopleHelpedDescription = log.peopleHelpedDescription
                    navigateToEdit = true
                }
            )
            
            NavigationLink(
                destination: InputTileNumber(
                    questionNumber: 1,
                    totalQuestions: 1,
                    tileWidth: 320,
                    tileHeight: 560,
                    question1: "Describe who you",
                    question2: "supported and how",
                    question3: "many individuals",
                    question4: "were involved.",
                    descriptionLabel: "Description",
                    disclaimerText: NSLocalizedString("disclaimer", comment: ""),
                    placeholderText: NSLocalizedString("peopledescription", comment: ""),
                    number: $editedPeopleHelped,
                    generalDescription: $editedPeopleHelpedDescription,
                    nextAction: {
                        let adapter = VisitLogDataAdapter()
                        adapter.updateVisitLogField(log.id, field: "peopleHelped", value: editedPeopleHelped) {
                            adapter.updateVisitLogField(log.id, field: "peopleHelpedDescription", value: editedPeopleHelpedDescription) {
                                log.peopleHelped = editedPeopleHelped
                                log.peopleHelpedDescription = editedPeopleHelpedDescription
                                isEditingPeopleHelped = false
                            }
                        }
                    },
                    previousAction: {},
                    skipAction: {
                        navigateToEdit = false
                    },
                    showProgressBar: false,
                    buttonMode: .update
                ),
                isActive: $navigateToEdit
            ) {
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    private func providedhelpSection() -> some View {
        if !log.whatGiven.isEmpty {
            HStack {
                Text("What kind of support did you provide?")
                    .screenLeft()
                    .font(.system(size: 16.0)).bold()
                    .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 0.0, trailing: 20.0))
                
                Spacer()
                
                Button(action: {
                    editedSupportProvided = log
                    navigateToEditSupportProvided = true
                }) {
                    Image("Tab-VisitLog-Inactive")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.gray)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.trailing, 20.0)
            }
            
            Text(log.whatGiven.joined(separator: ", "))
                .screenLeft()
                .font(.system(size: 15.0))
                .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0))
            
            Rectangle()
                .frame(width: 350.0, height: 2.0)
                .foregroundColor(.gray)
            
            NavigationLink(
                destination: InputTileList(
                    questionNumber: 1,
                    totalQuestions: 1,
                    optionCount: 8,
                    size: CGSize(width: 350, height: 350),
                    question1: "What kind of support",
                    question2: "did you provide?",
                    visitLog: editedSupportProvided,
                    nextAction: {
                        let updatedFields: [String: Any] = [
                            "foodAndDrinks": editedSupportProvided.foodAndDrinks,
                            "clothes": editedSupportProvided.clothes,
                            "hygiene": editedSupportProvided.hygiene,
                            "wellness": editedSupportProvided.wellness,
                            "medical": editedSupportProvided.medical,
                            "social": editedSupportProvided.social,
                            "legal": editedSupportProvided.legal,
                            "other": editedSupportProvided.other,
                            "otherNotes": editedSupportProvided.otherNotes,
                            "whatGiven": editedSupportProvided.whatGiven
                        ]

                        let adapter = VisitLogDataAdapter()
                        adapter.updateVisitLogFields(log.id, fields: updatedFields) {
                            log.foodAndDrinks = editedSupportProvided.foodAndDrinks
                            log.clothes = editedSupportProvided.clothes
                            log.hygiene = editedSupportProvided.hygiene
                            log.wellness = editedSupportProvided.wellness
                            log.medical = editedSupportProvided.medical
                            log.social = editedSupportProvided.social
                            log.legal = editedSupportProvided.legal
                            log.other = editedSupportProvided.other
                            log.otherNotes = editedSupportProvided.otherNotes
                            log.whatGiven = editedSupportProvided.whatGiven
                            navigateToEditSupportProvided = false
                        }
                    },
                    previousAction: { navigateToEditSupportProvided = false },
                    skipAction: { navigateToEditSupportProvided = false },
                    buttonMode: .update,
                    showProgressBar: false
                ),
                isActive: $navigateToEditSupportProvided
            ) {
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func itemQtySection() -> some View {
        if log.itemQty > 0 {
            VisitLogDetailRow(
                title: "How many items did you donate?",
                detail1: "\(log.itemQty)",
                detail2: log.itemQtyDescription,
                separator: ", ",
                onEdit: {
                    editedItemQty = log.itemQty
                    editedItemQtyDescription = log.itemQtyDescription 
                    navigateToEditItems = true
                }
            )
            
            NavigationLink(
                destination: InputTileNumber(
                    questionNumber: 5,
                    totalQuestions: 6,
                    tileWidth: 300,
                    tileHeight: 420,
                    question1: "How many items",
                    question2: "did you donate?",
                    question3: "",
                    question4: "",
                    descriptionLabel: "",
                    disclaimerText: "",
                    placeholderText: "Enter notes here",
                    number: $editedItemQty,
                    generalDescription: $editedItemQtyDescription,
                    nextAction: {
                        let adapter = VisitLogDataAdapter()
                        adapter.updateVisitLogField(log.id, field: "itemQty", value: editedItemQty) {
                            adapter.updateVisitLogField(log.id, field: "itemQtyDescription", value: editedItemQtyDescription) {
                                log.itemQty = editedItemQty
                                log.itemQtyDescription = editedItemQtyDescription
                                navigateToEditItems = false
                            }
                        }
                    },
                    previousAction: {
                        navigateToEditItems = false
                    },
                    skipAction: {
                        navigateToEditItems = false
                    },
                    showProgressBar: false,
                    buttonMode: .update
                ),
                isActive: $navigateToEditItems
            ) {
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func ratingSection() -> some View {
        if log.rating > 0 {
            HStack {
                Text("How would you rate your outreach experience?")
                    .screenLeft()
                    .font(.system(size: 16.0)).bold()
                    .padding(.leading, 20)
                    .padding(.top, 10)

                Spacer()

                Button(action: {
                    editedRating = log.rating
                    //editedRatingComment = log.ratingComment
                    navigateToEditRating = true
                }) {
                    Image("Tab-VisitLog-Inactive")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.gray)
                }
                .buttonStyle(BorderlessButtonStyle())
                //.padding(.top, 10)
                .padding(.trailing, 20)
            }

            RatingView(rating: $log.rating, readOnly: true)
                .screenLeft()
                .font(.system(size: 15.0))
                .padding(.horizontal, 5)

            Rectangle()
                .frame(width: 350.0, height: 2.0)
                .foregroundColor(.gray)
            NavigationLink(
                destination: InputTileRate(
                    questionNumber: 1,
                    totalQuestions: 1,
                    question1: "How would you rate your",
                    question2: "outreach experience?",
                    textValue: $editedRatingComment,
                    rating: $editedRating,
                    nextAction: {
                        let adapter = VisitLogDataAdapter()
                        adapter.updateVisitLogField(log.id, field: "rating", value: editedRating) {
                            adapter.updateVisitLogField(log.id, field: "ratingComment", value: editedRatingComment) {
                                log.rating = editedRating
                                //log.ratingComment = editedRatingComment
                                navigateToEditRating = false
                            }
                        }
                    },
                    previousAction: { navigateToEditRating = false },
                    skipAction: { navigateToEditRating = false },
                    buttonMode: .update
                ),
                isActive: $navigateToEditRating
            ) {
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func durationSection() -> some View {
        if log.durationHours > 0 || log.durationMinutes > 0 {
            VisitLogDetailRow(
                title: "How much time did you spend on the outreach?",
                detail1: "\(log.durationHours) hours and \(log.durationMinutes) minutes",
                onEdit: {
                    navigateToEditDuration = true
                }
            )
        }
        NavigationLink(
            destination: InputTileDuration(
                questionNumber: 1,
                totalQuestions: 1,
                tileWidth: 350,
                tileHeight: 280,
                questionLine1: "How much time did",
                questionLine2: "you spend on the",
                questionLine3: "outreach?",
                hours: $log.durationHours,
                minutes: $log.durationMinutes,
                nextAction: {
                    let adapter = VisitLogDataAdapter()
                    adapter.updateVisitLogField(log.id, field: "durationHours", value: log.durationHours) {
                        adapter.updateVisitLogField(log.id, field: "durationMinutes", value: log.durationMinutes) {
                            navigateToEditDuration = false
                        }
                    }
                },
                previousAction: { navigateToEditDuration = false },
                skipAction: { navigateToEditDuration = false },
                buttonMode: .update
            ),
            isActive: $navigateToEditDuration
        ) {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func numberOfHelpersSection() -> some View {
        if log.numberOfHelpers > 0 {
            VisitLogDetailRow(
                title: "Who helped you prepare or joined?",
                detail1: "\(log.numberOfHelpers)",
                detail2: log.numberOfHelpersComment,
                separator: ", ",
                onEdit: {
                    editedHelpers = log.numberOfHelpers
                    editedHelpersComment = log.numberOfHelpersComment
                    navigateToEditHelpers = true
                }
            )
            
            NavigationLink(
                destination: InputTileNumber(
                    questionNumber: 4,
                    totalQuestions: 6,
                    tileWidth: 300,
                    tileHeight: 420,
                    question1: "Who helped you",
                    question2: "prepare or joined?",
                    question3: "",
                    question4: "",
                    descriptionLabel: "",
                    disclaimerText: "",
                    placeholderText: "Enter notes here",
                    number: $editedHelpers,
                    generalDescription: $editedHelpersComment,
                    nextAction: {
                        let adapter = VisitLogDataAdapter()
                        adapter.updateVisitLogField(log.id, field: "numberOfHelpers", value: editedHelpers) {
                            adapter.updateVisitLogField(log.id, field: "numberOfHelpersComment", value: editedHelpersComment) {
                                log.numberOfHelpers = editedHelpers
                                log.numberOfHelpersComment = editedHelpersComment
                                navigateToEditHelpers = false
                            }
                        }
                    },
                    previousAction: {
                        navigateToEditHelpers = false
                    },
                    skipAction: {
                        navigateToEditHelpers = false
                    },
                    showProgressBar: false,
                    buttonMode: .update
                ),
                isActive: $navigateToEditHelpers
            ) {
                EmptyView()
            }
        }
    }
    @ViewBuilder
    private func peopleNeedFurtherHelpSection() -> some View {
        if log.peopleNeedFurtherHelp > 0 {
            VisitLogDetailRow(
                title: "How many people still need support?",
                detail1: "\(log.peopleNeedFurtherHelp)",
                detail2: log.peopleNeedFurtherHelpComment,
                separator: ", ",
                onEdit: {
                    editedPeopleNeedHelp = log.peopleNeedFurtherHelp
                    editedPeopleNeedHelpComment = log.peopleNeedFurtherHelpComment
                    navigateToEditPeopleNeedHelp = true
                }
            )
            
            NavigationLink(
                destination: InputTileNumber(
                    questionNumber: 6,
                    totalQuestions: 6,
                    tileWidth: 300,
                    tileHeight: 420,
                    question1: "How many people",
                    question2: "still need support?",
                    question3: "",
                    question4: "",
                    descriptionLabel: "",
                    disclaimerText: "",
                    placeholderText: "Enter notes here",
                    number: $editedPeopleNeedHelp,
                    generalDescription: $editedPeopleNeedHelpComment,
                    nextAction: {
                        let adapter = VisitLogDataAdapter()
                        adapter.updateVisitLogField(log.id, field: "peopleNeedFurtherHelp", value: editedPeopleNeedHelp) {
                            adapter.updateVisitLogField(log.id, field: "peopleNeedFurtherHelpComment", value: editedPeopleNeedHelpComment) {
                                log.peopleNeedFurtherHelp = editedPeopleNeedHelp
                                log.peopleNeedFurtherHelpComment = editedPeopleNeedHelpComment
                                navigateToEditPeopleNeedHelp = false
                            }
                        }
                    },
                    previousAction: {
                        navigateToEditPeopleNeedHelp = false
                    },
                    skipAction: {
                        navigateToEditPeopleNeedHelp = false
                    },
                    showProgressBar: false,
                    buttonMode: .update
                ),
                isActive: $navigateToEditPeopleNeedHelp
            ) {
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func volunteerAgainSection() -> some View {
        if !log.volunteerAgain.isEmpty {
            VisitLogDetailRow(
                title: "Would you like to volunteer again?",
                detail1: log.volunteerAgain,
                onEdit: {
                    editedVolunteerAgain = log.volunteerAgain
                    navigateToEditVolunteerAgain = true
                }
            )

            NavigationLink(
                destination: InputTileVolunteerAgain(
                    questionNumber: 3,
                    totalQuestions: 3,
                    question1: "Would you be willing",
                    question2: "to volunteer again?",
                    volunteerAgain: $editedVolunteerAgain,
                    nextAction: {
                        let adapter = VisitLogDataAdapter()
                        adapter.updateVisitLogField(log.id, field: "volunteerAgain", value: editedVolunteerAgain) {
                            log.volunteerAgain = editedVolunteerAgain
                            navigateToEditVolunteerAgain = false
                        }
                    },
                    previousAction: { navigateToEditVolunteerAgain = false },
                    skipAction: { navigateToEditVolunteerAgain = false },
                    buttonMode: .update
                ),
                isActive: $navigateToEditVolunteerAgain
            ) {
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func followUpSection() -> some View {
        if log.followUpWhenVisit != Date.distantPast {
            VisitLogDetailRow(
                title: "Is there a planned date to interact with them again?",
                detail1: log.followUpWhenVisit.formatted(date: .abbreviated, time: .omitted),
                onEdit: {
                    editedFollowUpDate = log.followUpWhenVisit
                    navigateToEditFollowUpDate = true
            }
        )
            NavigationLink(
                destination: InputTileDate(
                    questionNumber: 1,
                    totalQuestions: 1,
                    question1: "Is there a planned",
                    question2: "date to interact",
                    question3: "with them again?",
                    showSkip: false,
                    showProgressBar: false,
                    buttonMode: .update,
                    datetimeValue: $editedFollowUpDate,
                    nextAction: {
                        let adapter = VisitLogDataAdapter()
                        adapter.updateVisitLogField(log.id, field: "followUpWhenVisit", value: editedFollowUpDate) {
                            log.followUpWhenVisit = editedFollowUpDate
                            navigateToEditFollowUpDate = false
                        }
                    },
                    skipAction: { navigateToEditFollowUpDate = false },
                    previousAction: { navigateToEditFollowUpDate = false }
                ),
                isActive: $navigateToEditFollowUpDate
            ) {
            EmptyView()
        }
        }
    }
    @ViewBuilder
    private func furthernotesSection() -> some View {
        if log.furtherOtherNotes.count > 0 {
            VisitLogDetailRow(
                title: "Is there anything future volunteers should know?",
                detail1: "\(log.furtherOtherNotes)",
                onEdit: {
                    editedFurtherOtherNotes = log.furtherOtherNotes
                    navigateToEditFurtherOtherNotes = true
                }
            )
            NavigationLink(
                destination: InputTileNotes(
                    questionNumber: 6,
                    totalQuestions: 7,
                    tileWidth: 300,
                    tileHeight: 350,
                    question1: "Is there anything future",
                    question2: "volunteers should",
                    question3: "know?",
                    placeholderText: "Enter notes here",
                    otherNotes: $editedFurtherOtherNotes,
                    nextAction: {
                        let adapter = VisitLogDataAdapter()
                        adapter.updateVisitLogField(log.id, field: "furtherOtherNotes", value: editedFurtherOtherNotes) {
                            log.furtherOtherNotes = editedFurtherOtherNotes
                            navigateToEditFurtherOtherNotes = false
                        }
                    },
                    previousAction: { navigateToEditFurtherOtherNotes = false },
                    skipAction: { navigateToEditFurtherOtherNotes = false },
                    buttonMode: .update
                ),
                isActive: $navigateToEditFurtherOtherNotes
            ) {
                EmptyView()
            }
        }
    }
    

    @ViewBuilder
    private func furtherSupportNeededSection() -> some View {
        if log.furtherFoodAndDrinks || log.furtherClothes || log.furtherHygiene || log.furtherWellness || log.furtherMedical || log.furtherSocial || log.furtherLegal || log.furtherOther {
            let needs = [
                log.furtherFoodAndDrinks ? "Food and Drink" : nil,
                log.furtherClothes ? "Clothes" : nil,
                log.furtherHygiene ? "Hygiene Products" : nil,
                log.furtherWellness ? "Wellness/Emotional Support" : nil,
                log.furtherMedical ? "Medical Help" : nil,
                log.furtherSocial ? "Social Worker/Psychiatrist" : nil,
                log.furtherLegal ? "Legal/Lawyer" : nil,
                (log.furtherOther && !log.furtherOtherNotes.isEmpty) ? log.furtherOtherNotes : nil
            ].compactMap { $0 }.joined(separator: ", ")

            VisitLogDetailRow(
                title: "What kind of support do they still need?",
                detail1: needs,
                onEdit: {
                    navigateToEditFurtherSupport = true
                }
            )
        }
        NavigationLink(
            destination: InputTileList(
                questionNumber: 1,
                totalQuestions: 1,
                optionCount: 8,
                size: CGSize(width: 350, height: 450),
                question1: "Edit the support they still need",
                question2: "",
                visitLog: log,
                nextAction: {
                    let adapter = VisitLogDataAdapter()
                    let updates: [(String, Any)] = [
                        ("furtherFoodAndDrinks", log.furtherFoodAndDrinks),
                        ("furtherClothes", log.furtherClothes),
                        ("furtherHygiene", log.furtherHygiene),
                        ("furtherWellness", log.furtherWellness),
                        ("furtherMedical", log.furtherMedical),
                        ("furtherSocial", log.furtherSocial),
                        ("furtherLegal", log.furtherLegal),
                        ("furtherOther", log.furtherOther),
                        ("furtherOtherNotes", log.furtherOtherNotes)
                    ]

                    for (field, value) in updates {
                        adapter.updateVisitLogField(log.id, field: field, value: value) {
                            // No need to reassign, since we're editing `log` directly
                            navigateToEditFurtherSupport = false
                        }
                    }
                },
                previousAction: { navigateToEditFurtherSupport = false },
                skipAction: { navigateToEditFurtherSupport = false },
                buttonMode: .update,
                showProgressBar: false,
                supportMode: .needed
            ),
            isActive: $navigateToEditFurtherSupport
        ) {
            EmptyView()
        }
    }
}

/*struct VisitLogDetailRow: View {
    var title: String
    var detail: String
    var onEdit: (() -> Void)? = nil

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.system(size: 16.0)).bold()
                    .padding(.leading, 20)
                Spacer()
                if let onEdit = onEdit {
                    Button(action: onEdit) {
                        Image("Tab-VisitLog-Inactive")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.trailing, 20)
                }
            }
            Text(detail)
                .font(.system(size: 15.0))
                .padding(.horizontal, 20)
            Rectangle()
                .frame(width: 350.0, height: 2.0)
                .foregroundColor(.gray)
        }
    }
}*/
struct VisitLogDetailRow: View {
    var title: String
    var detail1: String
    var detail2: String? = nil
    var separator: String = " • "
    var onEdit: (() -> Void)? = nil

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .screenLeft()
                    .font(.system(size: 16.0)).bold()
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                if let onEdit = onEdit {
                    Button(action: onEdit) {
                        Image("Tab-VisitLog-Inactive")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.top, 10)
                    .padding(.trailing, 20)
                }
            }

            Text(
                detail2 != nil && !detail2!.isEmpty
                ? "\(detail1)\(separator)\(detail2!)"
                : detail1
            )
            .screenLeft()
            .font(.system(size: 15.0))
            .padding(.vertical, 10)
            .padding(.horizontal, 20)

            Rectangle()
                .frame(width: 350.0, height: 2.0)
                .foregroundColor(.gray)
        }
    }
}
struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
