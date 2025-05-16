//
//  VisitLogView.swift
//  StreetCare
//
//  Created by Michael on 3/27/23.
//

import SwiftUI
import MapKit


struct VisitLogDetailRow: View {
    
    var title: String
    var detail: String
    var onEdit: (() -> Void)? = nil

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .screenLeft()
                    .font(.system(size: 16.0)).bold()
                    .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 0.0, trailing: 20.0))
                
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

            Text(detail)
                .screenLeft()
                .font(.system(size: 15.0))
                .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0))

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


struct VisitLogView: View {
    
    @Environment(\.presentationMode) var presentation
    
    @State var log: VisitLog
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(), span: MKCoordinateSpan())
    @State private var mapLocations = [MapLocation(name: "dummy", latitude: 0.0, longitude: 0.0)]
    
    @State private var showDeleteDialog = false
    @State private var isEditingPeopleHelped = false
    @State private var editedPeopleHelped: Int = 0
    @State private var navigateToEdit = false
    @State private var navigateToEditItems = false
    @State private var editedItemQty: Int = 0
    @State private var navigateToEditHelpers = false
    @State private var editedHelpers: Int = 0
    @State private var navigateToEditPeopleNeedHelp = false
    @State private var editedPeopleNeedHelp: Int = 0
    @State private var navigateToEditInteractionDate = false
    @State private var editedInteractionDate = Date()
    @State private var navigateToEditFollowUpDate = false
    @State private var editedFollowUpDate = Date()
    
    var body: some View {
        ScrollView {
            VStack {
                
                if log.location.latitude != 0 {
                    Map(coordinateRegion: $region, annotationItems: mapLocations) { location in
                        MapMarker(coordinate: location.coordinate)
                    }
                        .frame(width: 350, height: 300)
                }
                Spacer(minLength: 20.0)
                
                VisitLogDetailRow(
                    title: "When was your Interaction?",
                    detail: log.whenVisit.formatted(date: .abbreviated, time: .omitted),
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
                        },
                        skipAction: { navigateToEditInteractionDate = false },
                        previousAction: { navigateToEditInteractionDate = false }
                    ),
                    isActive: $navigateToEditInteractionDate
                ) {
                    EmptyView()
                }
                
                /*let location = log.whenVisit.formatted(date: .abbreviated, time: .omitted) + ", " + log.whereVisit
                Text(location).font(.system(size: 17.0)).bold()*/
                
                VisitLogDetailRow(
                    title: "Where was your Interaction?",
                    detail: "\(log.whereVisit)")
                
                if log.peopleHelped > 0 {
                    VisitLogDetailRow(
                        title: "Describe who you supported and how many individuals were involved.",
                        detail: "\(log.peopleHelped)",
                        onEdit: {
                            editedPeopleHelped = log.peopleHelped
                            navigateToEdit = true
                        }
                    )

                    NavigationLink(
                        destination: InputTileNumber(
                            questionNumber: 1,
                            totalQuestions: 1,
                            tileWidth: 320,
                            tileHeight: 330,
                            question1: "Edit the number of",
                            question2: "people you helped",
                            question3: "",
                            question4: "",
                            descriptionLabel: nil,
                            disclaimerText: nil,
                            placeholderText: nil,
                            number: $editedPeopleHelped,
                            nextAction: {
                                let adapter = VisitLogDataAdapter()
                                adapter.updateVisitLogField(log.id, field: "peopleHelped", value: editedPeopleHelped) {
                                    log.peopleHelped = editedPeopleHelped
                                    isEditingPeopleHelped = false
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

                
                if log.didProvideSpecificHelp {
                    VStack {
                        Text("What kind of support did you provide?")
                            .screenLeft()
                            .font(.system(size: 16.0)).bold()
                            .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 0.0, trailing: 20.0)) 
                        
                        VStack {
                            if log.foodAndDrinks {
                                Text("Food & Drinks").screenLeft().padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)).font(.system(size: 15.0))
                            }
                            
                            if log.clothes {
                                Text("Clothes").screenLeft().padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)).font(.system(size: 15.0))
                            }
                            
                            if log.hygine {
                                Text("Hygiene Products").screenLeft().padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)).font(.system(size: 15.0))
                            }
                            
                            if log.wellness {
                                Text("Wellness/Emotional Support").screenLeft().padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)).font(.system(size: 15.0))
                            }
                            
                            if log.other && log.otherNotes.count > 0 {
                                Text(log.otherNotes).screenLeft().padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)).font(.system(size: 15.0))
                            }
                        }
                        Rectangle()
                            .frame(width: 350.0, height: 2.0)
                            .foregroundColor(.gray)
                    }
                }
                // Items donated
                if log.itemQty > 0 {
                    VisitLogDetailRow(
                        title: "How many items did you donate?",
                        detail: "\(log.itemQty)",
                        onEdit: {
                            editedItemQty = log.itemQty
                            navigateToEditItems = true
                        }
                    )

                    NavigationLink(
                        destination: InputTileNumber(
                            questionNumber: 5,
                            totalQuestions: 6,
                            tileWidth: 300,
                            tileHeight: 460,
                            question1: "How many items",
                            question2: "did you donate?",
                            question3: "",
                            question4: "",
                            descriptionLabel: "",
                            disclaimerText: "",
                            placeholderText: "Enter notes here",
                            number: $editedItemQty,
                            nextAction: {
                                let adapter = VisitLogDataAdapter()
                                adapter.updateVisitLogField(log.id, field: "itemQty", value: editedItemQty) {
                                    log.itemQty = editedItemQty
                                    navigateToEditItems = false
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
                
                if log.rating > 0 {
                    Text("How would you rate your outreach experience?")
                        .screenLeft()
                        .font(.headline)
                        .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 0.0, trailing: 20.0))
                    
                    RatingView(rating: $log.rating, readOnly: true)
                        .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0))
                    
                    Rectangle()
                        .frame(width: 350.0, height: 2.0)
                        .foregroundColor(.gray)
                }
                if log.durationHours > 0 || log.durationMinutes > 0 {
                    VisitLogDetailRow(title: "How much time did you spend on the outreach?", detail: "\(log.durationHours) hours and \(log.durationMinutes) minutes")
                }
                
                if log.numberOfHelpers > 0 {
                    VisitLogDetailRow(
                        title: "Who helped you prepare or joined?",
                        detail: "\(log.numberOfHelpers)",
                        onEdit: {
                            editedHelpers = log.numberOfHelpers
                            navigateToEditHelpers = true
                        }
                    )

                    NavigationLink(
                        destination: InputTileNumber(
                            questionNumber: 1,
                            totalQuestions: 1,
                            tileWidth: 320,
                            tileHeight: 330,
                            question1: "Who helped you",
                            question2: "prepare or joined?",
                            question3: "",
                            question4: "",
                            descriptionLabel: nil,
                            disclaimerText: nil,
                            placeholderText: nil,
                            number: $editedHelpers,
                            nextAction: {
                                let adapter = VisitLogDataAdapter()
                                adapter.updateVisitLogField(log.id, field: "numberOfHelpers", value: editedHelpers) {
                                    log.numberOfHelpers = editedHelpers
                                    navigateToEditHelpers = false
                                }
                            },
                            previousAction: { navigateToEditHelpers = false },
                            skipAction: { navigateToEditHelpers = false },
                            showProgressBar: false,
                            buttonMode: .update
                        ),
                        isActive: $navigateToEditHelpers
                    ) {
                        EmptyView()
                    }
                }

                // VisitLogDetailRow(title: "Would you like to volunteer again?", detail: "\(log.volunteerAgainText)")
                

                // People who still need support
                if log.peopleNeedFurtherHelp > 0 {
                    VisitLogDetailRow(
                        title: "How many people still need support?",
                        detail: "\(log.peopleNeedFurtherHelp)",
                        onEdit: {
                            editedPeopleNeedHelp = log.peopleNeedFurtherHelp
                            navigateToEditPeopleNeedHelp = true
                        }
                    )

                    NavigationLink(
                        destination: InputTileNumber(
                            questionNumber: 1,
                            totalQuestions: 1,
                            tileWidth: 320,
                            tileHeight: 330,
                            question1: "How many people",
                            question2: "still need support?",
                            question3: "",
                            question4: "",
                            descriptionLabel: nil,
                            disclaimerText: nil,
                            placeholderText: nil,
                            number: $editedPeopleNeedHelp,
                            nextAction: {
                                let adapter = VisitLogDataAdapter()
                                adapter.updateVisitLogField(log.id, field: "peopleNeedFurtherHelp", value: editedPeopleNeedHelp) {
                                    log.peopleNeedFurtherHelp = editedPeopleNeedHelp
                                    navigateToEditPeopleNeedHelp = false
                                }
                            },
                            previousAction: { navigateToEditPeopleNeedHelp = false },
                            skipAction: { navigateToEditPeopleNeedHelp = false },
                            showProgressBar: false,
                            buttonMode: .update
                        ),
                        isActive: $navigateToEditPeopleNeedHelp
                    ) {
                        EmptyView()
                    }
                }

                // Support they still need
                if log.furtherfoodAndDrinks || log.furtherClothes || log.furtherHygine || log.furtherWellness || log.furthermedical || log.furthersocialworker || log.furtherlegal || log.furtherOther {
                    VStack {
                        Text("What kind of support do they still need?")
                            .screenLeft()
                            .font(.system(size: 16.0)).bold()
                            .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 0.0, trailing: 20.0))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            if log.furtherfoodAndDrinks {
                                Text("Food & Drinks")
                                    .screenLeft()
                                    .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)).font(.system(size: 15.0))
                                    .font(.system(size: 15.0))
                            }
                            if log.furtherClothes {
                                Text("Clothes")
                                    .screenLeft()
                                    .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)).font(.system(size: 15.0))
                                    .font(.system(size: 15.0))
                            }
                            if log.furtherHygine {
                                Text("Hygiene Products")
                                    .screenLeft()
                                    .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)).font(.system(size: 15.0))
                                    .font(.system(size: 15.0))
                            }
                            if log.furtherWellness {
                                Text("Wellness/Emotional Support")
                                    .screenLeft()
                                    .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)).font(.system(size: 15.0))
                                    .font(.system(size: 15.0))
                            }
                            if log.furthermedical {
                                Text("Medical Help")
                                    .screenLeft()
                                    .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)).font(.system(size: 15.0))
                                    .font(.system(size: 15.0))
                            }
                            if log.furthersocialworker {
                                Text("Social Worker")
                                    .screenLeft()
                                    .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)).font(.system(size: 15.0))
                                    .font(.system(size: 15.0))
                            }
                            if log.furtherlegal {
                                Text("Legal Assistance")
                                    .screenLeft()
                                    .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)).font(.system(size: 15.0))
                                    .font(.system(size: 15.0))
                            }
                            if log.furtherOther && !log.furtherOtherNotes.isEmpty {
                                Text(log.furtherOtherNotes)
                                    .screenLeft()
                                    .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0)).font(.system(size: 15.0))
                                    .font(.system(size: 15.0))
                            }
                        }

                        Rectangle()
                            .frame(width: 350.0, height: 2.0)
                            .foregroundColor(.gray)
                    }
                }

                // Planned follow-up date
                if log.followUpWhenVisit != Date.distantPast {
                    VisitLogDetailRow(
                        title: "Is there a planned date to interact with them again?",
                        detail: log.followUpWhenVisit.formatted(date: .abbreviated, time: .omitted),
                        onEdit: {
                            editedFollowUpDate = log.followUpWhenVisit
                            navigateToEditFollowUpDate = true
                        }
                    )

                    NavigationLink(
                        destination: InputTileDate(
                            questionNumber: 1,
                            totalQuestions: 1,
                            question1: "Is there anything future",
                            question2: "volunteers should",
                            question3: "know?",
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

                // Volunteer again
                if log.volunteerAgain >= 0 {
                    VisitLogDetailRow(
                        title: "Would you like to volunteer again?",
                        detail: log.volunteerAgain == 1 ? "Yes" :
                                log.volunteerAgain == 2 ? "Maybe" : "No"
                    )
                }
                
                NavLinkButton(title: "Delete Log", width: 190.0, secondaryButton: true, noBorder: false, color: Color.red)
                    .padding()
                    .onTapGesture {
                        showDeleteDialog = true
                    }
            }
        }
        .onAppear {
            if log.location.latitude != 0 {
                print("📍 Updated Location in view is: \(log.location.latitude), \(log.location.longitude)")
                region = MKCoordinateRegion(center: log.location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                mapLocations = [MapLocation(name: "Help", latitude: log.location.latitude, longitude: log.location.longitude)]
            }
            print("ItemQty: \(log.itemQty)")
        }
        .alert("Delete visit log?", isPresented: $showDeleteDialog) {
            Button("OK", role: .destructive)
            {
                let adapter = VisitLogDataAdapter()
                adapter.deleteVisitLog(self.log.id) {
                    presentation.wrappedValue.dismiss()
                }
            }
            
            Button("Cancel", role: .cancel) {
                showDeleteDialog = false
            }
        }
        .navigationTitle("Visit Log")
    } // end body
    
    
} // end struct

struct VisitLogView_Previews: PreviewProvider {
    
    static var log = VisitLog(id: "123456")
    
    static var previews: some View {
        VisitLogView(log: log)
            .onAppear {
                log.whereVisit = "under a bridge"
            }
    }
}
