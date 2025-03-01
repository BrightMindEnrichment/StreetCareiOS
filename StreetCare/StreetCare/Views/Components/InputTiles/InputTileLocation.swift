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
                    
                    TextField("optional", text: $textValue)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200.0)
                    
                    HStack {
                        Rectangle()
                            .frame(height: 2.0).foregroundColor(.gray).padding()
                        Text("and/or").foregroundColor(.gray)
                        Rectangle()
                            .frame(height: 2.0).foregroundColor(.gray).padding()
                    }
    
                    LocationButton {
                        isLoading = true
                        locationManager.requestLocation()
                    }
    
                    Spacer()
                }
                
                ProgressView(value: Double(questionNumber) / Double(totalQuestions))
                    .tint(.yellow)
                    .background(Color("TextColor"))
                    .padding()


                Spacer()
                
                HStack {
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
        .onAppear {
            locationManager = LocationManager {
                isLoading = false
                newLocation()
                if !failedToFindLocation {
                    nextAction()
                }
            }
        }
        .alert("Error...", isPresented: $failedToFindLocation, actions: {
            Button("OK") {
                // nothing to do
            }
        }, message: {
            Text("Sorry, having a problem finding your current location.")
        })
        

    } // end body
    
    
    /*func newLocation() {
        if let loc = locationManager.location {
            self.location = loc
            failedToFindLocation = false
            print("got a location")
        }
        else {
            failedToFindLocation = true
            print("missing location!")
        }
    }*/
    func newLocation() {
        if let loc = locationManager.location {
            self.location = loc
            failedToFindLocation = false
            print("Successfully got location: \(loc.latitude), \(loc.longitude)")
        } else {
            failedToFindLocation = true
            print("Location not found! Check permissions.")
        }
    }
} // end struct


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

