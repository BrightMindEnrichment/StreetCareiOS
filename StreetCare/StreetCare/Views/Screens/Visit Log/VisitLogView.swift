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
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 16.0, weight: .semibold))
            Text(detail)
                .font(.system(size: 15.0))
                .foregroundColor(.secondary)
            Divider()
        }
        .padding(.horizontal)
        .padding(.top, 12)
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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                headerSection
                coreDetailsSection
                supportSection
                feedbackSection
                actionButtonsSection
            }
        }
        .onAppear {
            if log.location.latitude != 0 {
                region = MKCoordinateRegion(center: log.location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                mapLocations = [MapLocation(name: "Help", latitude: log.location.latitude, longitude: log.location.longitude)]
            }
        }
        .alert("Delete visit log?", isPresented: $showDeleteDialog) {
            Button("OK", role: .destructive) {
                let adapter = VisitLogDataAdapter()
                adapter.deleteVisitLog(self.log.id) {
                    presentation.wrappedValue.dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .navigationTitle("Visit Log")
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Interaction Details")
                .font(.title3).bold()
                .padding(.horizontal)
            
            if log.location.latitude != 0 {
                Map(coordinateRegion: $region, annotationItems: mapLocations) { location in
                    MapMarker(coordinate: location.coordinate)
                }
                .frame(height: 250)
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
    
    private var coreDetailsSection: some View {
        Group {
            VisitLogDetailRow(title: "When was your Interaction?", detail: "\(log.whenVisit.formatted(date: .abbreviated, time: .shortened))")
            VisitLogDetailRow(title: "Where was your Interaction?", detail: log.whereVisit)
            VisitLogDetailRow(title: "Describe who you supported and how many individuals were involved.", detail: "\(log.peopleHelped)")
            
            if !log.peopleHelpedDescription.isEmpty {
                VisitLogDetailRow(title: "Description", detail: log.peopleHelpedDescription)
            }
        }
    }
    
    private var supportSection: some View {
        Group {
            if log.didProvideSpecificHelp {
                VisitLogDetailRow(
                    title: "What kind of support did you provide?",
                    detail: [
                        log.foodAndDrinks ? "Food & Drinks" : nil,
                        log.clothes ? "Clothes" : nil,
                        log.hygine ? "Hygiene Products" : nil,
                        log.wellness ? "Wellness / Emotional Support" : nil,
                        log.medical ? "Medical Help / Doctor" : nil,
                        log.socialworker ? "Social Worker / Psychiatrist" : nil,
                        log.legal ? "Lawyer / Legal" : nil,
                        log.other ? log.otherNotes : nil
                    ].compactMap { $0 }.joined(separator: ", ")
                )
            }
            
            VisitLogDetailRow(title: "How many items did you donate?", detail: "\(log.itemQty)")
            
            if !log.otherNotes.isEmpty {
                VisitLogDetailRow(title: "Notes", detail: log.otherNotes)
            }
        }
    }
    
    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
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
            
            if log.durationHours > 0 || log.durationMinutes > 0 {
                VisitLogDetailRow(
                    title: "How much time did you spend?",
                    detail: "\(log.durationHours) hrs \(log.durationMinutes) min"
                )
            }
            
            if log.numberOfHelpers > 0 {
                VisitLogDetailRow(
                    title: "Who helped you prepare or join?",
                    detail: "\(log.numberOfHelpers) people"
                )
            }
            
            if log.peopleNeedFurtherHelp > 0 {
                VisitLogDetailRow(
                    title: "How many people still need support?",
                    detail: "\(log.peopleNeedFurtherHelp)"
                )
            }
            
            if !log.stillNeedHelpDescription.isEmpty {
                VisitLogDetailRow(
                    title: "Describe their needs",
                    detail: log.stillNeedHelpDescription
                )
            }
            
            if log.furtherfoodAndDrinks || log.furtherClothes || log.furtherHygine || log.furtherWellness || log.furtherOther {
                VisitLogDetailRow(
                    title: "What kind of support do they still need?",
                    detail: [
                        log.furtherfoodAndDrinks ? "Food & Drinks" : nil,
                        log.furtherClothes ? "Clothes" : nil,
                        log.furtherHygine ? "Hygiene Products" : nil,
                        log.furtherWellness ? "Wellness / Emotional Support" : nil,
                        log.furtherOther ? log.furtherOtherNotes : nil
                    ].compactMap { $0 }.joined(separator: ", ")
                )
            }
            
            if !log.futureNotes.isEmpty {
                VisitLogDetailRow(
                    title: "Is there anything future volunteers should know?",
                    detail: log.futureNotes
                )
            }
            
            if log.followUpWhenVisit != Date.distantPast {
                VisitLogDetailRow(
                    title: "Planned date to interact again",
                    detail: log.followUpWhenVisit.formatted(date: .abbreviated, time: .shortened)
                )
            }
            
            VisitLogDetailRow(
                title: "Would you like to volunteer again?",
                detail: log.volunteerAgainText
            )
        }
    }
    private var actionButtonsSection: some View {
        Group {
            HStack(spacing: 12) {
                Button("Edit") {
                    // TODO: Handle Edit Action
                }
                .foregroundColor(Color("PrimaryColor"))
                .frame(maxWidth: .infinity, minHeight: 44)
                .font(.caption)
                .fontWeight(.bold)
                .background(
                    Capsule().fill(Color("SecondaryColor"))
                )
                .padding(.horizontal, 6)
                
                Button("Delete") {
                    showDeleteDialog = true
                }
                .foregroundColor(Color("PrimaryColor"))
                .frame(maxWidth: .infinity, minHeight: 44)
                .font(.caption)
                .fontWeight(.bold)
                .background(
                    Capsule().fill(Color("SecondaryColor"))
                )
                .padding(.horizontal, 6)
            }
            .padding(.horizontal)
            
            Button("Share with Community") {
                // TODO: Handle Share Action
            }
            .foregroundColor(Color.black)
            .frame(maxWidth: .infinity, minHeight: 44)
            .font(.caption)
            .fontWeight(.bold)
            .background(
                Capsule().fill(Color.white)
            )
            .overlay(
                Capsule().stroke(Color("SecondaryColor"), lineWidth: 2)
            )
            .padding(.horizontal)
            .padding(.top, 4)
        }
    }
}
struct VisitLogView_Previews: PreviewProvider {
    static var log = VisitLog(id: "123456")

    static var previews: some View {
        VisitLogView(log: log)
    }
}
