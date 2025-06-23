//
//  EventCardView.swift
//  StreetCare
//
//  Created by Kevin Phillips on 10/24/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore

struct EventCardView: View {
    @ObservedObject var event: EventData
    var eventType: EventType
    var onCardTap: () -> Void
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var popupRefresh: Bool
    @ObservedObject var loggedInUser: UserDetails

    var body: some View {
        //let _ = refresh
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(event.event.title.capitalized)
                        .font(.headline)
                }
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text("\(event.event.city ?? ""), \(event.event.stateAbbv ?? "")")
                        .font(.system(size: 13))
                }
                HStack {
                    Image(systemName: "clock")
                    if let date = event.date.2 {
                        Text("\(date)")
                            .font(.system(size: 13))
                    }
                }
                if let helpType = event.event.helpType {
                    HStack {
                        Image("HelpType")
                            .resizable()
                            .frame(width: 20.0, height: 20.0)
                        
                        Text(helpType.capitalized)
                            .font(.system(size: 13))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color("Color87CEEB").opacity(0.4))
                            .cornerRadius(5)
                    }
                }
                HStack {
                    // TODO: hide participant count until feature is completed
    //                if let slots = event.event.totalSlots {
    //                    let minimumInterest = Int(Double(slots) * 0.65)
    //                    let interest = Int.random(in: minimumInterest...slots)
    //
    //                    Text(String(format: NSLocalizedString("participantsCount", comment: "Number of participants out of total slots"), interest, slots))
    //                        .font(.system(size: 13))
    //                }
                    Spacer()
                    if eventType == .past {
                        Text(NSLocalizedString("completedText", comment: "Label for completed events"))
                            .font(.system(size: 13))
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            HStack(spacing: 8) {
                
                Image(systemName: "flag.fill")
                    .foregroundColor(event.event.isFlagged ? .red : .gray)
                    .id(popupRefresh)
                    .onTapGesture {
                        Task {
                            guard let currentUser = Auth.auth().currentUser else { return }
                            let db = Firestore.firestore()
                            
                            let eventRef = db.collection("outreachEventsDev").document(event.event.eventId ?? "")
                            let currentUserId = currentUser.uid
                            
                            if event.event.isFlagged {
                                if event.event.flaggedByUser == currentUserId || loggedInUser.userType == "Street Care Hub Leader" {
                                    event.event.updateFlagStatus(newFlagState: false, userId: nil)
                                    
                                    let updates: [String: Any] = [
                                        "isFlagged": false,
                                        "flaggedByUser": NSNull()
                                    ]
                                    
                                    do {
                                        try await eventRef.updateData(updates)
                                        print("Successfully unflagged event by user \(currentUser.email ?? "")")
                                        popupRefresh.toggle()
                                    } catch {
                                        print("Error updating flag status: \(error)")
                                    }
                                } else {
                                    alertMessage = "Only the user who flagged this event or a Street Care Hub Leader can unflag it."
                                    showAlert = true
                                }
                            } else {
                                event.event.updateFlagStatus(newFlagState: true, userId: currentUserId)
                                
                                let updates: [String: Any] = [
                                    "isFlagged": true,
                                    "flaggedByUser": currentUserId
                                ]
                                
                                do {
                                    try await eventRef.updateData(updates)
                                    print("Successfully flagged event by user \(currentUser.email ?? "")")
                                    popupRefresh.toggle()
                                } catch {
                                    print("Error updating flag status: \(error)")
                                }
                            }
                        }
                    }
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(getVerificationColor(for: event.event.userType))
                    .font(.system(size: 20))
                    .padding(8)
            }
            .padding([.top, .trailing], 8)
        }
        .onTapGesture {
            onCardTap()
            
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Unflag Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }

    }
}

