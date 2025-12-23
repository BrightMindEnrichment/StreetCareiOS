//
// InputTileIndividualInteraction.swift
// StreetCare
//
// Created by Gayathri Jayachander on 11/7/25.
//

import SwiftUI
import Combine

struct InputTileIndividualInteraction: View {
    var questionTitle: String
    var skipAction: (() -> Void)?
    var previousAction: (() -> Void)?
    var nextAction: (() -> Void)?
    
    // NEW — tile sizing
    var tileWidth: CGFloat = 360
    var tileHeight: CGFloat = 500

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var location: String = ""
    @State private var selectedState: String = ""
    @State private var zipCode: String = ""
    @State private var date: Date = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 30)) ?? Date()
    @State private var time: Date = Calendar.current.date(bySettingHour: 11, minute: 35, second: 0, of: Date()) ?? Date()
    
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    
    let states = [
        "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
        "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
        "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
        "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
        "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"
    ]
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
    // Helper function to apply the black border style (linewidth 0.5) to a TextField
    private func borderedTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .foregroundColor(.black)
            .padding(.horizontal, 10)
            .frame(height: 38)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black, lineWidth: 0.5)
            )
    }
    
    // Date/Time tile function with black icon/text and thinner border
    private func dateTile<Content: View>(iconName: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.black)
            content()
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal, 10)
        .frame(height: 38)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 0.5)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            HStack {
                Text(questionTitle)
                    .font(.headline)
                
                Spacer()
                
                if let skipAction = skipAction {
                    Button(action: skipAction) {
                        Text("Skip")
                            .font(.subheadline)
                            .foregroundColor(Color("SecondaryColor"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color("SecondaryColor"), lineWidth: 1)
                            )
                    }
                }
            }
            
            Divider()
            
            Group {
                borderedTextField("First Name (Person You Interacted)*", text: $firstName)
                borderedTextField("Last Name", text: $lastName)
                borderedTextField("Location or Landmark", text: $location)
            }
            
            HStack(spacing: 12) {
                Menu {
                    ForEach(states, id: \.self) { state in
                        Button(state) { selectedState = state }
                    }
                } label: {
                    HStack {
                        Text(selectedState.isEmpty ? "State" : selectedState)
                            .foregroundColor(selectedState.isEmpty ? .gray : .black)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, minHeight: 38, maxHeight: 38)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 0.5)
                    )
                }
                
                // ZIP CODE FIELD
                borderedTextField("Zip Code", text: $zipCode)
                    .keyboardType(.numberPad)
                    .onChange(of: zipCode) { newValue in
                        // Filter out any non-numeric characters
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        // Limit to 5 characters (Standard US Zip)
                        if filtered.count > 5 {
                            zipCode = String(filtered.prefix(5))
                        } else {
                            zipCode = filtered
                        }
                    }
            }
            
            HStack(spacing: 12) {
                Button(action: { showDatePicker.toggle() }) {
                    dateTile(iconName: "calendar") {
                        Text(dateFormatter.string(from: date))
                    }
                }
                .sheet(isPresented: $showDatePicker) {
                    VStack {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                        Divider()
                        Button("Done") { showDatePicker = false }
                            .padding()
                    }
                    .presentationDetents([.medium])
                }
                
                Button(action: { showTimePicker.toggle() }) {
                    dateTile(iconName: "clock") {
                        Text(timeFormatter.string(from: time))
                    }
                }
                .sheet(isPresented: $showTimePicker) {
                    VStack {
                        DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                        Divider()
                        Button("Done") { showTimePicker = false }
                            .padding()
                    }
                    .presentationDetents([.medium])
                }
            }
            
            HStack {
                if let previousAction = previousAction {
                    Button(action: previousAction) {
                        Text("Previous")
                            .font(.body)
                            .foregroundColor(Color("SecondaryColor"))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color("SecondaryColor"), lineWidth: 1)
                            )
                    }
                }
                
                Spacer()
                
                if let nextAction = nextAction {
                    Button(action: nextAction) {
                        Text("Next")
                            .foregroundColor(Color("PrimaryColor"))
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color("SecondaryColor")))
                    }
                }
            }
            .padding(.top, 10)
            
        }
        .padding()
        .frame(width: tileWidth, height: tileHeight)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}
