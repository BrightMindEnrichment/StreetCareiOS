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
        
    var size = CGSize(width: 320.0, height: 460.0)
    var question1: String
    var question2: String
    
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
    @State private var didPrefillFields = false
    @State private var showSuccessAlert = false
    @Environment(\.presentationMode) var presentationMode
    var nextAction: () -> ()
    var previousAction: () -> ()
    var skipAction: () -> ()
    
    var buttonMode: ButtonMode
    private func handleLocationSubmit() {
        if city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            stateAbbreviation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            failedToFindLocation = true
            return
        }

        let manualAddress = [
            street.isEmpty ? nil : street,
            city.isEmpty ? nil : city,
            (stateAbbreviation.isEmpty ? state : stateAbbreviation).isEmpty ? nil : (stateAbbreviation.isEmpty ? state : stateAbbreviation),
            zipcode.isEmpty ? nil : zipcode
        ].compactMap { $0 }.joined(separator: ", ")

        if !manualAddress.isEmpty {
            textValue = manualAddress
            print("📍 Updated textValue manually: \(textValue)")
        }

        nextAction()
    }
    var body: some View {

        ZStack {
            BasicTile(size: CGSize(width: size.width, height: size.height))

            VStack {
                if buttonMode == .navigation {
                    HStack {
                        Text("Question \(questionNumber)/\(totalQuestions)")
                            .foregroundColor(.black)
                        Spacer()

                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
                
                if buttonMode == .navigation {
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal)
                }
    
                VStack{
                    Text(question1)
                        .font(.title2)
                        .padding(.top, 6)
                        .fontWeight(.bold)
                    Text(question2)
                        .font(.title2)
                        .padding(.bottom, 12)
                        .fontWeight(.bold)
                }

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        Text(street.isEmpty ? "Search for address" : street)
                            .foregroundColor(street.isEmpty ? .gray : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        /*Text(textValue.isEmpty ? "Search for address" : textValue)
                            .foregroundColor(textValue.isEmpty ? .gray : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)*/
                                                                               
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
                    
                    switch buttonMode {
                    case .navigation:
                        HStack {
                            Button("Previous") {
                                previousAction()
                            }
                            .foregroundColor(Color("SecondaryColor"))
                            .font(.footnote)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.white))
                            .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))

                            Spacer()

                            Button("Next") {
                                handleLocationSubmit()
                            }
                            .foregroundColor(Color("PrimaryColor"))
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color("SecondaryColor")))
                        }
                        .padding()

                    case .update:
                        HStack {
                            Button("Cancel") {
                                previousAction()
                            }
                            .foregroundColor(Color("SecondaryColor"))
                            .font(.footnote)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.white))
                            .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))

                            Spacer()

                            Button("Update") {
                                handleLocationSubmit()
                                showSuccessAlert = true
                            }
                            .foregroundColor(Color("PrimaryColor"))
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color("SecondaryColor")))
                        }
                        .padding()
                    }
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Updated"),
                message: Text("Interaction location was successfully updated."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .alert("Missing Required Fields", isPresented: $failedToFindLocation, actions: {
            Button("OK") {}
        }, message: {
            Text("Please enter both city and state before continuing.")
        })
        .loadingAnimation(isLoading: isLoading)
        .onAppear {
            locationManager = LocationManager {
                isLoading = false
                newLocation()
                if !failedToFindLocation {
                    nextAction()
                }
            }
            if !didPrefillFields {
                let components = textValue.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                if components.indices.contains(0) { street = components[0] }
                if components.indices.contains(1) { city = components[1] }
                if components.indices.contains(2) { stateAbbreviation = components[2] }
                if components.indices.contains(3) { zipcode = components[3] }
                didPrefillFields = true
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
                                self.textValue = [
                                    self.street,
                                    self.city,
                                    self.stateAbbreviation,
                                    self.zipcode
                                ].filter { !$0.isEmpty }.joined(separator: ", ") // ✅ Updates whereVisit
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
        if buttonMode == .navigation {
            SegmentedProgressBar(
                totalSegments: totalQuestions,
                filledSegments: questionNumber,
                tileWidth: 320
            )
            Text("Progress")
                .font(.footnote)
                .padding(.top, 4)
                .fontWeight(.bold)
        }
        

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
