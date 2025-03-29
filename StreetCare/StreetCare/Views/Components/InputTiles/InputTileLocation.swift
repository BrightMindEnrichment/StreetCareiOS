//
//  InputTileString.swift
//  StreetCare
//
//  Created by Michael on 4/19/23.
//
import SwiftUI
import CoreLocation
import CoreLocationUI

struct InputTileLocation: View { 

    var questionNumber: Int
    var totalQuestions: Int
        
    var size = CGSize(width: 300.0, height: 450.0)
    var question: String
    
    @Binding var textValue: String
    @Binding var location: CLLocationCoordinate2D
    @ObservedObject var visitLog: VisitLog
    
    @State var locationManager: LocationManager!
    
    @State var isLoading = false
    @State var failedToFindLocation = false
    @State private var street = ""
    @State private var state = ""
    @State private var city = ""
    @State private var zipcode = ""
    @State private var stateAbbreviation = ""
    @State private var showAddressSearch = false
        
    var nextAction: () -> ()
    var previousAction: () -> ()
    var skipAction: () -> ()
    
    var body: some View {

        ZStack {
            BasicTile(size: CGSize(width: size.width, height: size.height))

            VStack {
                HStack {
                    Spacer()
                    Button("Skip") {
                        skipAction()
                    }
                    .foregroundColor(.gray)
                    .padding()
                }

                Spacer()

                Text("Question \(questionNumber)/\(totalQuestions)")
                    .foregroundColor(.gray)
                    .font(.footnote)
    
                VStack {
                    Text(question)
                        .font(.headline)
                        .padding()
    
                    /*LocationButton {
                        isLoading = true
                        locationManager.requestLocation()
                    }

                    Spacer()*/
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
                    .padding(.horizontal, 20)
                    .onTapGesture {
                        showAddressSearch = true
                    }
                }
                Spacer()
                VStack {
                    TextField(NSLocalizedString("state", comment: ""), text: $state)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)

                    TextField(NSLocalizedString("city", comment: ""), text: $city)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)

                    TextField(NSLocalizedString("zipcode", comment: ""), text: $zipcode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)

                    HStack {
                        Button("Previous") {
                            previousAction()
                        }
                        .foregroundColor(Color("TextColor"))
                        Spacer()
                        Button("Next") {
                            nextAction()
                        }
                        .foregroundColor(Color("TextColor"))
                    }
                    .padding()
                    
                    SegmentedProgressBar(
                        totalSegments: totalQuestions,
                        filledSegments: questionNumber
                    )
                    
                    Text("Progress")
                        .font(.caption)
                        .padding(.top, 4)
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .loadingAnimation(isLoading: isLoading)
        .onAppear {
            locationManager = LocationManager {
                isLoading = false
                newLocation()
                if !failedToFindLocation {
                    nextAction()
                }
            }
        }
        .sheet(isPresented: $showAddressSearch) {
            GooglePlacesAutocomplete(
                street: $street,
                city: $city,
                state: $state,
                stateAbbreviation: $stateAbbreviation,
                zipcode: $zipcode,
                location: Binding<CLLocationCoordinate2D?>(
                    get: { Optional(self.location) },
                    set: { newValue in
                        DispatchQueue.main.async {
                            if let newLocation = newValue {
                                self.location = newLocation // ✅ Updates location
                                self.textValue = "\(self.street), \(self.city), \(self.state) \(self.zipcode)" // ✅ Updates whereVisit
                                // ✅ Update VisitLog properties
                                visitLog.street = self.street
                                visitLog.city = self.city
                                visitLog.state = self.state
                                visitLog.stateAbbv = self.stateAbbreviation
                                visitLog.zipcode = self.zipcode

                                print("📍 Updated whereVisit: \(self.textValue)")
                                print("📍 Updated location: \(self.location.latitude), \(self.location.longitude)")
                            }
                        }
                    }
                )
            )
        }
        .alert("Error...", isPresented: $failedToFindLocation, actions: {
            Button("OK") {
                // nothing to do
            }
        }, message: {
            Text("Sorry, having a problem finding your current location.")
        })
        

    }
    
    func newLocation() {
        if let loc = locationManager.location {
            self.location = loc
            failedToFindLocation = false
            print("got a location")
        }
        else {
            failedToFindLocation = true
            print("missing location!")
        }
    }
}
