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
    
    var body: some View {
        VStack {
            Text(title)
                .screenLeft()
                .font(.system(size: 16.0)).bold()
                .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 0.0, trailing: 20.0))
            
            Text(detail)
                .screenLeft().font(.system(size: 15.0))
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
    
    func updatePeopleHelpedInFirestore(newValue: Int) {
        let adapter = VisitLogDataAdapter()
        adapter.updatePeopleHelped(log.id, newValue: newValue) {
            log.peopleHelped = newValue
            isEditingPeopleHelped = false
        }
    }
    var body: some View {
        ScrollView {
            VStack {
                let location = log.whenVisit.formatted(date: .abbreviated, time: .omitted) + ", " + log.whereVisit
                Text(location).font(.system(size: 17.0)).bold()
                
                if log.location.latitude != 0 {
                    Map(coordinateRegion: $region, annotationItems: mapLocations) { location in
                        MapMarker(coordinate: location.coordinate)
                    }
                        .frame(width: 350, height: 300)
                }
                Spacer(minLength: 20.0)
                if log.peopleHelped > 0 {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("People helped")
                                .font(.system(size: 16.0)).bold()
                                .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 0.0, trailing: 20.0))
                            
                            Button(action: {
                                editedPeopleHelped = log.peopleHelped
                                navigateToEdit = true
                            }) {
                                Image("Tab-VisitLog-Inactive")
                                    .resizable()
                                    .frame(width: 16, height: 16) 
                                    .foregroundColor(.gray)
                                    //.padding(6)
                                    //.background(Circle().stroke(Color.gray, lineWidth: 1))
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        //.padding(.horizontal, 10)
                        //.padding(.top, 10)

                        Text("\(log.peopleHelped)")
                            .font(.system(size: 15.0))
                            .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 0.0, trailing: 20.0))
                            //.padding(.horizontal, 20)
                            //.padding(.bottom, 10)
                        
                        Rectangle()
                            .frame(width: 350.0, height: 2.0)
                            .foregroundColor(.gray)
                    }

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
                                updatePeopleHelpedInFirestore(newValue: editedPeopleHelped)
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
                        Text("Type of help provided")
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
                
                if log.rating > 0 {
                    Text("Rate your outreach experience")
                        .screenLeft()
                        .font(.headline)
                        .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 0.0, trailing: 20.0))
                    
                    RatingView(rating: $log.rating, readOnly: true)
                        .padding(EdgeInsets(top: 10.0, leading: 20.0, bottom: 10.0, trailing: 20.0))
                    
                    Rectangle()
                        .frame(width: 350.0, height: 2.0)
                        .foregroundColor(.gray)
                }
                

//                if log.durationHours > 0 || log.durationMinutes > 0 {
//                    VisitLogDetailRow(title: "Approximate time spent on outreach?", detail: "\(log.durationHours) hours and \(log.durationMinutes) minutes")
//                }
                
                
                if log.numberOfHelpers > 0 {
                    VisitLogDetailRow(title: "How many people joined or helped you prepare?", detail: "\(log.numberOfHelpers)")
                }

                // VisitLogDetailRow(title: "Would you like to volunteer again?", detail: "\(log.volunteerAgainText)")
                
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
