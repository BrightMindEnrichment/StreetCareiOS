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
        
    var size = CGSize(width: 300.0, height: 460.0)
    var question: String
    
    @Binding var textValue: String
    @Binding var location: CLLocationCoordinate2D
    
    @State var locationManager: LocationManager!
    
    @State var isLoading = false
    @State var failedToFindLocation = false
    @State private var street = ""
    @State private var state = ""
    @State private var city = ""
    @State private var zipcode = ""
    @State private var landmark = ""
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
                    Text("Question \(questionNumber)/\(totalQuestions)")
                        .foregroundColor(.black)
                        //.font(.footnote)
                    
                    Spacer()
                    
                    /*Button("Skip") {
                        skipAction()
                    }
                    .foregroundColor(.gray)
                    .padding()*/
                    
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.horizontal)
    
                VStack {
                    Text(question)
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding()
    
                    /*LocationButton {
                        isLoading = true
                        locationManager.requestLocation()
                    }

                    Spacer()*/
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        Text(street.isEmpty ? "Search for address" : street)
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

                VStack {
                    HStack {
                        TextField(NSLocalizedString("city", comment: ""), text: $city)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .layoutPriority(1) // Higher priority
                            .frame(maxWidth: 300)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )

                        TextField(NSLocalizedString("state", comment: ""), text: $stateAbbreviation)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .layoutPriority(0)
                            .frame(maxWidth: 100) // Optional: limit the width
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)

                    TextField(NSLocalizedString("zipcode", comment: ""), text: $zipcode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                .padding(.horizontal)
                        )
                    
                    AutoGrowingTextEditor(text: $landmark, placeholder: NSLocalizedString("landmark", comment: ""))
                    
                    HStack {
                        Button("Previous") {
                            previousAction()
                        }
                        .foregroundColor(Color("SecondaryColor"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white) // Fill with white
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color("SecondaryColor"), lineWidth: 2) // Stroke with dark green
                        )

                        Spacer()

                        Button(" Next  ") {
                            nextAction()
                        }
                        .foregroundColor(Color("PrimaryColor"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color("SecondaryColor"))
                        )
                    }
                    .padding()
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
        SegmentedProgressBar(
            totalSegments: totalQuestions,
            filledSegments: questionNumber
        )

        Text("Progress")
            .font(.caption)
            .padding(.top, 4)
        

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

struct AutoGrowingTextEditor: View {
    @Binding var text: String
    var placeholder: String // ✅ New parameter
    @State private var dynamicHeight: CGFloat = 100

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background height-measuring text
            Text(text.isEmpty ? " " : text)
                .font(.body)
                .padding(EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4))
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                dynamicHeight = geo.size.height
                            }
                            .onChange(of: text) { _ in
                                dynamicHeight = geo.size.height
                            }
                    }
                )
                .hidden()

            // Placeholder
            if text.isEmpty {
                Text(placeholder) // ✅ Use parameter here
                    .foregroundColor(Color.gray.opacity(0.3))
                    .padding(.top, 12)
                    .padding(.leading, 10)
                    .zIndex(1)
            }

            // TextEditor
            TextEditor(text: $text)
                .font(.body)
                .frame(height: max(100, dynamicHeight))
                .padding(4)
                .background(Color.white)
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
        }
        .padding(.horizontal)
        .padding(.top, 4)
        .shadow(radius: 1)
    }
}
