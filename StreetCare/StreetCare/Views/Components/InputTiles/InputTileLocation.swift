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
                    
                    /*TextField("optional", text: $textValue)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200.0)
                    
                    HStack {
                        Rectangle()
                            .frame(height: 2.0).foregroundColor(.gray).padding()
                        Text("and/or").foregroundColor(.gray)
                        Rectangle()
                            .frame(height: 2.0).foregroundColor(.gray).padding()
                    }*/
                    
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
                    .onTapGesture {
                        showAddressSearch = true
                    }
                }
                
                TextField(NSLocalizedString("state", comment: ""), text: $state)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField(NSLocalizedString("city", comment: ""), text: $city)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField(NSLocalizedString("zipcode", comment: ""), text: $zipcode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                ProgressView(value: Double(questionNumber) / Double(totalQuestions))
                    .tint(.yellow)
                    .background(Color("TextColor"))
                    .padding()


                Spacer()
                
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
            }
        }
        .frame(width: size.width, height: size.height)
        .loadingAnimation(isLoading: isLoading)
        .sheet(isPresented: $showAddressSearch) {
            GooglePlacesAutocomplete(
                street: $street,
                city: $city,
                state: $state,
                stateAbbreviation: $stateAbbreviation,
                zipcode: $zipcode,
                location: Binding<CLLocationCoordinate2D?>(
                    get: { Optional(location) },
                    set: { newValue in
                        if let newLocation = newValue {
                            location = newLocation
                            print("📍 Updated Location in InputTileLocation: \(location.latitude), \(location.longitude)")
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
    
}


struct InputTileString_Previews: PreviewProvider {

    @State static var inputText = ""
    @State static var location = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)

    static var previews: some View {

        InputTileLocation(questionNumber: 2, totalQuestions: 5, question: "Shall we play a game?", textValue: $inputText, location: $location) {
            //
        } previousAction: {
            //
        } skipAction: {
            //
        }
    }
}

