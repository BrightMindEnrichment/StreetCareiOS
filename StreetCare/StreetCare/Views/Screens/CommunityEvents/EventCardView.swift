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
import UIKit

struct EventCardView: View {
    @ObservedObject var event: EventData
    var eventType: EventType
    var onCardTap: () -> Void
    @State private var showAlert = false
    @State private var isLiked = false
    @State private var didShare = false
    @State private var showLogin = false
    @State private var showShareSheet = false
    @State private var isProcessing = false
    @State private var suppressCardTap = false
    @State private var loginSelection = 0
    @State private var alertMessage = ""
    @Binding var popupRefresh: Bool
    @ObservedObject var loggedInUser: UserDetails
    // Share sheet
    @State private var shareItems: [Any] = []

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

                        // Right: like + share (assets) — likes count on the left
                        //Temporarily disable like and share
                        /*
                        HStack(spacing: 12) {
                            HStack(spacing: 6) {
                                // Likes count first (left)
                                Text("\(event.event.interest ?? 0)")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.black)
                                    .accessibilityLabel("Likes count: \(event.event.interest ?? 0)")

                                // Like image using a high-priority gesture so it wins over the parent .onTapGesture
                                Image(isLiked ? "like_clicked" : "like_un_clicked")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                    .scaleEffect(isLiked ? 1.15 : 1.0)
                                    .highPriorityGesture(
                                        TapGesture().onEnded {
                                            Task {
                                                // set suppression & processing immediately on main actor
                                                await MainActor.run {
                                                    suppressCardTap = true
                                                    isProcessing = true
                                                }

                                                // 1) Require login
                                                guard let user = Auth.auth().currentUser else {
                                                    await MainActor.run {
                                                        alertMessage = "Please sign in to like events."
                                                        showAlert = true
                                                        isProcessing = false
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { suppressCardTap = false }
                                                    }
                                                    return
                                                }

                                                // 2) Need a valid event id
                                                guard let eventId = event.event.eventId, !eventId.isEmpty else {
                                                    await MainActor.run {
                                                        isProcessing = false
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { suppressCardTap = false }
                                                    }
                                                    return
                                                }

                                                // 3) Firestore transaction
                                                let db = Firestore.firestore()
                                                let eventRef = db.collection("outreachEventsDev").document(eventId)
                                                let usersQuery = try await db.collection("users")
                                                    .whereField("uid", isEqualTo: user.uid)
                                                    .getDocuments()

                                                guard let existingUserDoc = usersQuery.documents.first else {
                                                    print("⚠️ No matching user doc found for \(user.uid)")
                                                    return
                                                }

                                                let userRef = db.collection("users").document(existingUserDoc.documentID)

                                                let resultAny = try? await db.runTransaction({ (txn, errorPointer) -> Any? in
                                                    do {
                                                        // Read current event likes
                                                        let snap = try txn.getDocument(eventRef)
                                                        let current = (snap.data()?["interests"] as? Int) ?? 0

                                                        // 1) ensure user doc exists (important if it's not there yet)
                                                        //    merge:true means we won't overwrite anything
                                                        txn.setData(["uid": user.uid], forDocument: userRef, merge: true)

                                                        // 2) compute next like count
                                                        let next = isLiked ? max(0, current - 1) : (current + 1)

                                                        // 3) update event like count
                                                        txn.updateData(["interests": next], forDocument: eventRef)

                                                        // 4) update user's likedOutreachEvents array
                                                        let op: [String: Any] = isLiked
                                                            ? ["likedOutreachEvents": FieldValue.arrayRemove([eventId])]
                                                            : ["likedOutreachEvents": FieldValue.arrayUnion([eventId])]

                                                        txn.updateData(op, forDocument: userRef)

                                                        return next
                                                    } catch let err as NSError {
                                                        errorPointer?.pointee = err
                                                        return nil
                                                    }
                                                })


                                                // 4) Update UI/model or show error
                                                if let newCount = resultAny as? Int {
                                                    await MainActor.run {
                                                        withAnimation {
                                                            isLiked.toggle()
                                                            event.event.liked = isLiked
                                                            event.event.interest = newCount
                                                        }
                                                        popupRefresh.toggle()
                                                        // release suppression after a short delay
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                                            suppressCardTap = false
                                                        }
                                                        isProcessing = false
                                                    }
                                                } else {
                                                    await MainActor.run {
                                                        alertMessage = "Failed to update like. Please try again."
                                                        showAlert = true
                                                        isProcessing = false
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { suppressCardTap = false }
                                                    }
                                                }
                                            }
                                        }
                                    )
                                    .disabled(isProcessing)
                            }
                            Image(didShare ? "share_clicked" : "share_un_clicked")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .onTapGesture {
                                    let id = event.event.eventId ?? ""
                                    let urlString = "https://streetcarenow.org/outreachsignup/\(id)"

                                    // Copy to clipboard
                                    UIPasteboard.general.string = urlString

                                    // Present native share sheet
                                    if let url = URL(string: urlString) {
                                        shareItems = [url]
                                        showShareSheet = true
                                    }

                                    // little pulse
                                    didShare.toggle()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { didShare = false }
                                }
                        }
                        .padding(.trailing, -6) // align with top-right flag/check
                         */

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
            if !suppressCardTap {
                onCardTap()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    suppressCardTap = false
                }
            }
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
        // Native share sheet
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: shareItems)
        }
        .fullScreenCover(isPresented: $showLogin) {
                    NavigationStack {
                        LoginView(selection: $loginSelection)
                    }
                }
    }
}
// Tiny helper to present UIActivityViewController in SwiftUI
struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: applicationActivities)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
