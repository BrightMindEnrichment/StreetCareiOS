//
//  VisitLogFormView.swift
//  StreetCare
//
//  Created by Shaik Saheer on 06/05/25.
//

import SwiftUI
import MapKit    // if you need maps later

struct VisitLogFormView: View {
    // MARK: – State for each form field
    @State private var interactionDate = Date()
    @State private var interactionTimeZone = "GMT-4 (York)"
    
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var landmark = ""
    
    @State private var peopleHelped = 0
    @State private var peopleHelpedDescription = ""
    
    @State private var supportFood = false
    @State private var supportClothes = false
    @State private var supportHygiene = false
    @State private var supportWellness = false
    @State private var supportMedical = false
    @State private var supportSocial = false
    @State private var supportLawyer = false
    @State private var supportOther = false
    @State private var supportOtherNotes = ""
    
    @State private var itemsDonated = 0
    @State private var itemsDonatedNotes = ""
    
    @State private var rating = 0
    
    @State private var durationHours = 0
    @State private var durationMinutes = 0
    
    @State private var helpers = 0
    
    @State private var stillNeedHelpCount = 0
    @State private var stillNeedHelpDescription = ""
    @State private var stillNeedWellness = false
    @State private var stillNeedMedical = false
    @State private var stillNeedOther = false
    
    @State private var nextInteractionDate = Date()
    @State private var nextInteractionTimeZone = "GMT-4 (York)"
    @State private var futureNotes = ""
    
    @State private var volunteerAgainSelection = 0 // 0=Yes,1=No,2=Maybe
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // FORM FIELDS GO HERE…
                    // — Section 1: When was your interaction?
                    Text("When was your interaction?")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 0)
                    
                    VStack(spacing: 12) {
                        // Date + Time Row
                        HStack(spacing: 12) {
                            // DATE
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                                DatePicker("", selection: $interactionDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .font(.system(size: 15))
                            }
                            .padding(.vertical, 7)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                            
                            // TIME
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.gray)
                                DatePicker("", selection: $interactionDate, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .font(.system(size: 15))
                            }
                            .padding(.vertical, 7)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                        }
                        
                        // Timezone
                        ZStack(alignment: .trailing) {
                            Menu {
                                Picker(selection: $interactionTimeZone, label: EmptyView()) {
                                    Text("Colorado (MDT)").tag("Colorado (MDT)")
                                    Text("New York (EST)").tag("New York (EST)")
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "globe")
                                        .foregroundColor(.gray)
                                    Text(interactionTimeZone)
                                        .foregroundColor(.black)
                                        .font(.system(size: 15))
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.4))
                                )
                            }

                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                                .padding(.trailing, 16)
                        }
                        Divider()
                        // — Section 2: Where was your interaction?
                        Text("Where was your Interaction?")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                            .padding(.leading, 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                           
                        HStack(spacing: 12) {
                            TextField("City*", text: $city)
                                .padding()
                                .frame(height: 44)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                            
                            TextField("State*", text: $state)
                                .padding()
                                .frame(height: 44)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                        }
                        
                        TextField("ZIP Code", text: $zipCode)
                            .padding()
                            .frame(height: 44)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                        
                        TextField("Describe the location/landmark.", text: $landmark, axis: .vertical)
                            .lineLimit(3...4)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                        
                        Divider()
                        // — Section 3: How many people did you support?
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Describe who you supported and how many individuals were involved.")
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.top, 8)
                                .padding(.bottom, 4)
                                .padding(.leading, 3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        HStack(spacing: 24) {
                            Button {
                                if peopleHelped > 0 { peopleHelped -= 1 }
                            } label: {
                                Image(systemName: "minus")
                                    .foregroundColor(.yellow)
                                    .frame(width: 32, height: 32)
                                    .background(Circle().fill(Color(red: 0.09, green: 0.25, blue: 0.21))) // Dark green
                            }

                            Text("\(peopleHelped)")
                                .font(.system(size: 20, weight: .semibold))

                            Button {
                                peopleHelped += 1
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundColor(.yellow)
                                    .frame(width: 32, height: 32)
                                    .background(Circle().fill(Color(red: 0.09, green: 0.25, blue: 0.21))) // Dark green
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Description")
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.top, 8)
                                .padding(.bottom, 4)
                                .padding(.leading, 3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextField("Example: Tom, a senior citizen in a wheelchair, wearing a navy blue shirt and brown shoes.", text: $peopleHelpedDescription, axis: .vertical)
                                .lineLimit(2...3)
                                .padding(.top, 8)
                                .padding(.bottom, 4)
                                .padding(.leading, 3)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                        }
                        Text("Disclaimer: Completing one interaction log per person helps us serve you better. Optional, any information helps.")
                            .font(.footnote)
                            .foregroundColor(Color.gray)
                            .padding(.horizontal)
                            .padding(.top, 4)

                        Divider()
                        // — Section 5: What support did you provide?
                        Text("What kind of support did you provide?")
                            .font(.headline)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                            .padding(.leading, 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 16) {
                            HStack {
                                Text("Food & Drinks")
                                    .font(.body)
                                Spacer()
                                Toggle("", isOn: $supportFood)
                                    .toggleStyle(YellowGreenToggleStyle())
                            }
                            
                            HStack {
                                Text("Clothes")
                                    .font(.body)
                                Spacer()
                                Toggle("", isOn: $supportClothes)
                                    .toggleStyle(YellowGreenToggleStyle())
                            }
                            
                            HStack {
                                Text("Hygiene Products")
                                    .font(.body)
                                Spacer()
                                Toggle("", isOn: $supportHygiene)
                                    .toggleStyle(YellowGreenToggleStyle())
                            }
                            
                            HStack {
                                Text("Wellness / Emotional Support")
                                    .font(.body)
                                Spacer()
                                Toggle("", isOn: $supportWellness)
                                    .toggleStyle(YellowGreenToggleStyle())
                            }
                            
                            HStack {
                                Text("Medical Help / Doctor")
                                    .font(.body)
                                Spacer()
                                Toggle("", isOn: $supportMedical)
                                    .toggleStyle(YellowGreenToggleStyle())
                            }
                            
                            HStack {
                                Text("Social Worker / Psychiatrist")
                                    .font(.body)
                                Spacer()
                                Toggle("", isOn: $supportSocial)
                                    .toggleStyle(YellowGreenToggleStyle())
                            }
                            
                            HStack {
                                Text("Lawyer / Legal")
                                    .font(.body)
                                Spacer()
                                Toggle("", isOn: $supportLawyer)
                                    .toggleStyle(YellowGreenToggleStyle())
                            }
                            
                            HStack {
                                Text("Other")
                                    .font(.body)
                                Spacer()
                                Toggle("", isOn: $supportOther)
                                    .toggleStyle(YellowGreenToggleStyle())
                            }
                            
                            if supportOther {
                                TextField("(Optional)", text: $supportOtherNotes)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                        Divider()
                        // — Section 6: Items Donated
                        Text("How many items did you donate?")
                            .font(.headline)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                            .padding(.leading, 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Button { if itemsDonated>0 { itemsDonated -= 1 } } label: {
                                Image(systemName: "minus.circle.fill")
                            }
                            Text("\(itemsDonated)")
                                .frame(minWidth: 40)
                            Button { itemsDonated += 1 } label: {
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                        .font(.title2)
                        
                        TextField("Optional notes", text: $itemsDonatedNotes)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Divider()
                        // — Section 7: Rate your experience
                        Text("Rate your outreach experience")
                            .font(.headline)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                            .padding(.leading, 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Use your existing RatingView
                        RatingView(rating: $rating, readOnly: false)
                        
                        Divider()
                        // — Section 8: Time spent
                        Text("How much time did you spend?")
                            .font(.headline)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                            .padding(.leading, 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Picker("Hours", selection: $durationHours) {
                                ForEach(0..<24) { Text("\($0) h") }
                            }.pickerStyle(.menu)
                            Picker("Minutes", selection: $durationMinutes) {
                                ForEach(0..<60) { Text("\($0) m") }
                            }.pickerStyle(.menu)
                        }
                        
                        Divider()
                        // — Section 9: Helpers
                        Text("Who helped you prepare or join?")
                            .font(.headline)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                            .padding(.leading, 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Button { if helpers>0 { helpers -= 1 } } label: {
                                Image(systemName: "minus.circle.fill")
                            }
                            Text("\(helpers)")
                                .frame(minWidth: 40)
                            Button { helpers += 1 } label: {
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                        .font(.title2)
                        
                        Divider()
                        // — Section 10: Still need support?
                        Text("How many still need support?")
                            .font(.headline)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                            .padding(.leading, 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Button { if stillNeedHelpCount>0 { stillNeedHelpCount -= 1 } } label: {
                                Image(systemName: "minus.circle.fill")
                            }
                            Text("\(stillNeedHelpCount)")
                                .frame(minWidth: 40)
                            Button { stillNeedHelpCount += 1 } label: {
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                        .font(.title2)
                        
                        TextField("Describe their needs", text: $stillNeedHelpDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Toggle("Wellness / Emotional", isOn: $stillNeedWellness)
                        Toggle("Medical Help / Doctor", isOn: $stillNeedMedical)
                        Toggle("Other", isOn: $stillNeedOther)
                        
                        Divider()
                        // — Section 11: Next planned interaction
                        Text("Planned date to interact again")
                            .font(.headline)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                            .padding(.leading, 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        DatePicker("Date", selection: $nextInteractionDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                        
                        DatePicker("Time", selection: $nextInteractionDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                        
                        Picker("Time Zone", selection: $nextInteractionTimeZone) {
                            Text("GMT-4 (York)").tag("GMT-4 (York)")
                            Text("MDT (Colorado)").tag("MDT (Colorado)")
                        }
                        .pickerStyle(.menu)
                        
                        TextField("Anything future volunteers should know", text: $futureNotes)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Divider()
                        // — Section 12: Volunteer again?
                        Text("Would you like to volunteer again?")
                            .font(.headline)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.top, 8)
                            .padding(.bottom, 4)
                            .padding(.leading, 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            ForEach(0..<3) { idx in
                                let titles = ["Yes","No","Maybe"]
                                Button(titles[idx]) {
                                    volunteerAgainSelection = idx
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(volunteerAgainSelection == idx ? Color.green : Color.clear)
                                .foregroundColor(volunteerAgainSelection == idx ? .white : .primary)
                                .cornerRadius(8)
                            }
                        }
                        
                        // Submit Button
                        Button("Submit Interaction") {
                            // TODO: save all @State values to Firebase
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.vertical, 16)
                        
                    }
                    .padding(.horizontal)
                }
                .navigationTitle("Interaction Log")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
