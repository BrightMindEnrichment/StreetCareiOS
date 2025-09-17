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
    @State private var isLiked = false
    @State private var didShare = false
    @State private var showLogin = false
    @State private var showShareSheet = false
    @State private var loginSelection = 0
    @State private var alertMessage = ""
    @Binding var popupRefresh: Bool
    @ObservedObject var loggedInUser: UserDetails

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 10) {

                HStack(spacing: 8) {
                    Text(event.event.title.capitalized)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "flag.fill")
                            .foregroundColor(event.event.isFlagged ? .red : .gray)
                            .font(.system(size: 16))
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
                                            popupRefresh.toggle()
                                        } catch {
                                            print("Error updating flag status: \(error)")
                                        }
                                    }
                                }
                            }

                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(getVerificationColor(for: event.event.userType))
                            .font(.system(size: 16))
                            .padding(.leading, 6)
                    }
                    .padding(.trailing, -6)
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
                    let rawItems = helpType
                        .split(separator: ",")
                        .map {
                            $0.trimmingCharacters(in: .whitespacesAndNewlines)
                                .lowercased()
                                .replacingOccurrences(of: ".", with: "")
                                .replacingOccurrences(of: " ", with: "")
                        }

                    let localized = rawItems.map { NSLocalizedString($0, comment: "") }
                    let capped = Array(localized.prefix(2))
                    let pillText: String = {
                        var text = capped.joined(separator: ", ")
                        if localized.count > 2 {
                            text += "…"
                        }
                        return text
                    }()

                    HStack(alignment: .top, spacing: 8) {
                        // Left: help icon + blue pill
                        Image("HelpType")
                            .resizable()
                            .frame(width: 20, height: 20)

                        Text(pillText.capitalized)
                            .font(.system(size: 13))
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color("Color87CEEB").opacity(0.4))
                            .cornerRadius(5)

                        Spacer(minLength: 0)

                        // Right: like + share (assets)
                        HStack(spacing: 12) {
                            Image(isLiked ? "like_clicked" : "like_un_clicked")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .onTapGesture {
                                        Task {
                                            // 1) Require login
                                            guard let user = Auth.auth().currentUser else {
                                                alertMessage = "Please sign in to like events."
                                                showAlert = true
                                                return
                                            }
                                            // 2) Need a valid event id
                                            guard let eventId = event.event.eventId, !eventId.isEmpty else { return }

                                            // 3) Firestore transaction: update interests + per-user mapping
                                            let db = Firestore.firestore()
                                            let eventRef = db.collection("outreachEventsDev").document(eventId)
                                            let likedDocId = "\(user.uid)_\(eventId)"
                                            let likedRef = db.collection("likedEvents").document(likedDocId)

                                            let resultAny = try? await db.runTransaction({ (txn, errorPointer) -> Any? in
                                                do {
                                                    let snap = try txn.getDocument(eventRef)
                                                    let current = (snap.data()?["interests"] as? Int) ?? 0

                                                    if isLiked {
                                                        // UNLIKE: decrement & remove mapping
                                                        let next = max(0, current - 1)
                                                        txn.updateData(["interests": next], forDocument: eventRef)
                                                        txn.deleteDocument(likedRef)
                                                        return next
                                                    } else {
                                                        // LIKE: increment & add mapping
                                                        let next = current + 1
                                                        txn.updateData(["interests": next], forDocument: eventRef)
                                                        txn.setData([
                                                            "uid": user.uid,
                                                            "eventId": eventId,
                                                            "createdAt": FieldValue.serverTimestamp()
                                                        ], forDocument: likedRef, merge: true)
                                                        return next
                                                    }
                                                } catch let err as NSError {
                                                    errorPointer?.pointee = err
                                                    return nil
                                                }
                                            })

                                            // 4) Update UI/model or show error
                                            if let newCount = resultAny as? Int {
                                                withAnimation {
                                                    isLiked.toggle()
                                                    event.event.liked = isLiked
                                                    event.event.interest = newCount // if you show a count
                                                }
                                                // notify popup (if shown) to sync its UI
                                                popupRefresh.toggle()
                                            } else {
                                                alertMessage = "Failed to update like. Please try again."
                                                showAlert = true
                                            }
                                        }
                                    }

                            Image(didShare ? "share_clicked" : "share_un_clicked")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .onTapGesture {
                                    didShare.toggle()
                                    // TODO: present share sheet
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { didShare = false }
                                }
                        }
                        .padding(.trailing, -6) // align with top-right flag/check
                    }
                }

                HStack {
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
        }   // <-- end of ZStack { ... } (the main content)
        .onTapGesture {
            onCardTap()
        }
        .onAppear {
            // initialize local UI from model when the card first appears
            isLiked = event.event.liked
        }
        .onChange(of: popupRefresh) { _ in
            // popup or other components changed the model — refresh local UI
            isLiked = event.event.liked
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Please Login"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")){
                    showLogin = true
                }
            )
        }
        .sheet(isPresented: $showLogin) {
            NavigationStack {
                LoginView(selection: $loginSelection)
            }
        }
    }
}
