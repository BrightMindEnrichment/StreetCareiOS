//
//  InputTileLocation.swift
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

    var question1: String
    var question2: String

    @Binding var textValue: String
    @Binding var location: CLLocationCoordinate2D
    @Binding var locationDescription: String

    @State var locationManager: LocationManager!
    @State var isLoading = false

    @State private var street = ""
    @State private var state = ""
    @State private var city = ""
    @State private var zipcode = ""
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
        let manualAddress = [
            street.isEmpty ? nil : street,
            city.isEmpty ? nil : city,
            (stateAbbreviation.isEmpty ? state : stateAbbreviation).isEmpty ? nil : (stateAbbreviation.isEmpty ? state : stateAbbreviation),
            zipcode.isEmpty ? nil : zipcode
        ]
        .compactMap { $0 }
        .joined(separator: ", ")

        if !manualAddress.isEmpty {
            textValue = manualAddress
        }

        nextAction()
    }

    private func roundedInput(_ title: String, text: Binding<String>) -> some View {
        TextField(title, text: text)
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.35), lineWidth: 1)
            )
    }

    var body: some View {
        VStack(spacing: 0) {

            // Progress bar (spacing matches reference)
            if buttonMode == .navigation {
                SegmentedProgressBar(
                    totalSegments: totalQuestions,
                    filledSegments: questionNumber,
                    tileWidth: 320
                )
                .padding(.top, 24)
                .padding(.bottom, 24)
            }

            // CARD
            VStack {

                // Question header + Skip
                if buttonMode == .navigation {
                    HStack {
                        Text("Question \(questionNumber)/\(totalQuestions)")
                        Spacer()
                        Button("Skip") { skipAction() }
                            .font(.footnote)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .overlay(
                                Capsule().stroke(Color.gray.opacity(0.6))
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }

                // Question text
                VStack(spacing: 4) {
                    Text(question1)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(question2)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    Text(street.isEmpty ? "Search for address" : street)
                        .foregroundColor(street.isEmpty ? .gray.opacity(0.7) : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .frame(height: 45)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .onTapGesture {
                    showAddressSearch = true
                }

                // Inputs
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        roundedInput("City", text: $city)
                        roundedInput("State", text: $stateAbbreviation)
                            .frame(width: 110)
                    }

                    roundedInput("Zip Code", text: $zipcode)

                    AutoGrowingTextEditor(
                        text: $locationDescription,
                        placeholder: "Describe the location/landmark"
                    )
                    .frame(height: 120)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // Buttons
                HStack {
                    Button("Previous") {
                        previousAction()
                    }
                    .foregroundColor(Color("SecondaryColor"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .overlay(
                        Capsule().stroke(Color("SecondaryColor"), lineWidth: 2)
                    )

                    Spacer()

                    Button("Next") {
                        handleLocationSubmit()
                    }
                    .foregroundColor(Color("PrimaryColor"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule().fill(Color("SecondaryColor"))
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
            )
            .frame(width: 320)
        }
        .navigationTitle("Interaction Log")
        .navigationBarTitleDisplayMode(.inline)
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
                        if let newLocation = newValue {
                            self.location = newLocation
                            self.textValue = [
                                self.street,
                                self.city,
                                self.stateAbbreviation,
                                self.zipcode
                            ]
                            .filter { !$0.isEmpty }
                            .joined(separator: ", ")
                        }
                    }
                )
            )
        }

    }
}

// MARK: - AutoGrowingTextEditor
struct AutoGrowingTextEditor: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        ZStack(alignment: .topLeading) {

            TextEditor(text: $text)
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                )
                .scrollContentBackground(.hidden)

            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(placeholder)
                    .foregroundColor(Color.gray.opacity(0.6))
                    .padding(.top, 16)
                    .padding(.leading, 14)
                    .allowsHitTesting(false)
            }
        }
    }
}

