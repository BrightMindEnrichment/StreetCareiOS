//
//  PublicInteractionPopupView.swift
//  StreetCare
//
//  Created by Shaik Saheer on 24/06/25.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

struct PublicInteractionPopupView: View {
    @ObservedObject var visit: VisitLog
    var user: User?
    var userType: String
    var onCancel: () -> Void
    var delegate : EventPopupViewDelegate?
    
    @Binding var refresh: Bool
    @State private var showCustomAlert = false
    @State private var alertMessage = ""
    @State private var username: String = "Firstname Lastname"
    @EnvironmentObject var imageLoader: StorageManager
    //@State private var userRoleType: String = "Account Holder"
    
    var body: some View {
        //ScrollView {
        VStack(alignment: .leading, spacing: 8) {
            // Top row
            HStack {
                if let image = visit.image {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else if let img = imageLoader.image {
                    Image(uiImage: img)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: imageLoader.image)
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .opacity(0.5)
                }
                
                Text(username)
                    .font(.system(size: 15, weight: .semibold))
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: username)
                
                Spacer()
                
                // Flag toggle
                Image(systemName: "flag.fill")
                    .foregroundColor(visit.isFlagged ? .red : .gray)
                    .onTapGesture {
                        Task {
                            guard let currentUser = Auth.auth().currentUser else { return }
                            let db = Firestore.firestore()
                            let collectionName = visit.source == "webProd" ? "visitLogWebProd" : "VisitLogBook_New"
                            let ref = db.collection(collectionName).document(visit.id)
                            
                            if visit.isFlagged {
                                // Try to unflag
                                if visit.flaggedByUser == currentUser.uid || userType == "Street Care Hub Leader" {
                                    let updates: [String: Any] = [
                                        "isFlagged": false,
                                        "flaggedByUser": ""  //Reset to empty string
                                    ]
                                    do {
                                        try await ref.updateData(updates)
                                        visit.isFlagged = false
                                        visit.flaggedByUser = ""
                                        refresh.toggle()
                                    } catch {
                                        print("Unflagging error: \(error.localizedDescription)")
                                    }
                                } else {
                                    await MainActor.run {
                                        alertMessage = "Only the user who flagged this event or a Street Care Hub Leader can unflag it."
                                        showCustomAlert = true
                                    }
                                }
                            } else {
                                // ✅ Flag it
                                let updates: [String: Any] = [
                                    "isFlagged": true,
                                    "flaggedByUser": currentUser.uid
                                ]
                                do {
                                    try await ref.updateData(updates)
                                    visit.isFlagged = true
                                    visit.flaggedByUser = currentUser.uid
                                    refresh.toggle()
                                } catch {
                                    print("Flagging error: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                
                // checkmark
                UserRoleBadge(userType: visit.userType)
            }
            
            // Location & date
            HStack(spacing: 8) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.gray)
                Text(
                    !visit.whereVisit.isEmpty
                    ? visit.whereVisit
                    : [visit.street, visit.city, visit.state, visit.stateAbbv, visit.zipcode]
                        .filter { !$0.isEmpty }
                        .joined(separator: ", ")
                )

                    .font(.system(size: 13))
            }
            
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .foregroundColor(.gray)
                Text(formattedDateTime(visit.whenVisit))
                    .font(.system(size: 13))
            }
            
           /* // Description
            //if !visit.peopleHelpedDescription.isEmpty && visit.peopleHelpedDescription != "N/A" {
            VStack(alignment: .leading, spacing: 4) {
                Text("Interaction Description")
                    .font(.system(size: 14, weight: .semibold))
                Text(visit.peopleHelpedDescription)
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
            }
            //}
            
            // Stats
            VStack(alignment: .leading, spacing: 12) {
                PublicInfoRow(title: "People Helped", value: "\(visit.peopleHelped)", iconName: "Tab-Profile", iconColor: .yellow)
                PublicInfoRow(title: "People Who Joined", value: "\(visit.numberOfHelpers)", iconName: "HelpingHands", iconColor: .yellow)
                PublicInfoRow(title: "Items Donated", value: "\(visit.itemQty)", iconName: "Clothes", iconColor: .yellow)
                PublicInfoRow(
                    title: "Type of Help Offered",
                    value: visit.whatGiven.isEmpty ? "N/A" : visit.whatGiven.joined(separator: ", ")
                )
            }*/
            // Description
            if !(visit.peopleHelpedDescription.isEmpty && visit.description.isEmpty) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Interaction Description")
                        .font(.system(size: 14, weight: .semibold))
                    Text(visit.peopleHelpedDescription.isEmpty || visit.peopleHelpedDescription == "N/A"
                          ? visit.description
                          : visit.peopleHelpedDescription
                    )
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
                }
            }

            // Stats
            VStack(alignment: .leading, spacing: 12) {
                PublicInfoRow(
                    title: "People Helped",
                    value: visit.peopleHelped > 0
                        ? "\(visit.peopleHelped)"
                        : (Int(visit.numberPeopleHelped) ?? 0 > 0 ? visit.numberPeopleHelped : "0"),
                    iconName: "Tab-Profile",
                    iconColor: .yellow
                )

                PublicInfoRow(
                    title: "People Who Joined",
                    value: "\(visit.numberOfHelpers)",
                    iconName: "HelpingHands",
                    iconColor: .yellow
                )

                PublicInfoRow(
                    title: "Items Donated",
                    value: visit.itemQty > 0
                        ? "\(visit.itemQty)"
                        : (Int(visit.itemQtyWeb) ?? 0 > 0 ? visit.itemQtyWeb : "0"),
                    iconName: "Clothes",
                    iconColor: .yellow
                )

                PublicInfoRow(
                    title: "Type of Help Offered",
                    value: visit.whatGiven.isEmpty ? "N/A" : visit.whatGiven.joined(separator: ", ")
                )
            }
            
            // Close Button
            NavLinkButton(title: "Close", width: UIScreen.main.bounds.width - 30, secondaryButton: true)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 20)
                .onTapGesture {
                    delegate?.close()
                    onCancel()
                }
        }
        .padding(.top, 30)
        .padding(.horizontal, 10)
        .frame(minHeight: 500, alignment: .top)
    //}
        //with Caching
        /*.onAppear {
            imageLoader.uid = visit.uid

            // If image already preloaded, use it
            if let img = visit.image {
                imageLoader.image = img
            } else {
                imageLoader.getImage()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if let loaded = imageLoader.image {
                        visit.image = loaded // fallback cache
                    }
                }
            }

            // Use preloaded values
            self.username = visit.username
            //self.userRoleType = visit.userType
            
            //fetch the latest userType from Firestore
                let db = Firestore.firestore()
                db.collection("users")
                    .whereField("uid", isEqualTo: visit.uid)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("Error fetching user type: \(error.localizedDescription)")
                            return
                        }

                        if let document = snapshot?.documents.first {
                            let data = document.data()
                            if let fetchedType = data["type"] as? String {
                                visit.userType = fetchedType
                            }
                        }
                    }
        }*/
        //Without Caching
        .onAppear {
                    imageLoader.uid = visit.uid
                    imageLoader.getImage()
                    let db = Firestore.firestore()
                    db.collection("users")
                        .whereField("uid", isEqualTo: visit.uid)
                        .getDocuments { snapshot, error in
                            if let error = error {
                                print("Error fetching user info: \(error.localizedDescription)")
                                return
                            }
                            
                            if let document = snapshot?.documents.first {
                                let data = document.data()
                                
                                // Username
                                if let fetchedUsername = data["username"] as? String {
                                    self.username = fetchedUsername
                                }
                            }
                        }
                }
        .cornerRadius(20)
        .toolbar(.hidden, for: .tabBar)
        .overlay(
            Group {
                if showCustomAlert {
                    ZStack {
                        // Softened dimmed background with subtle blur and corners
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.clear)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .edgesIgnoringSafeArea(.all)
                        
                        // Alert Box
                        VStack(spacing: 0) {
                            VStack(spacing: 16) {
                                Text("Unflag Error")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Text(alertMessage)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true) // ✅ Enables line wrapping
                                    .frame(maxWidth: .infinity)
                            }
                            .padding()
                            
                            Divider()
                            
                            Button(action: {
                                withAnimation {
                                    showCustomAlert = false
                                }
                            }) {
                                Text("OK")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(width: 300)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white)
                                .shadow(radius: 20)
                        )
                        .transition(.scale)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        )
    }
}

func formattedDateTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM d, yyyy | h:mma"
    formatter.amSymbol = "AM"
    formatter.pmSymbol = "PM"
    return formatter.string(from: date)
}

struct InfoValueRow: View {
    var value: String
    var iconName: String?
    var iconColor: Color = .yellow
    
    var body: some View {
        HStack(spacing: 8) {
            if let icon = iconName, !icon.isEmpty {
                Image(icon)
                    .resizable()
                    .interpolation(.none)
                    .frame(width: 20, height: 20)
                    .foregroundColor(iconColor)
            }
            Text(value)
                .font(.system(size: 13))
        }
    }
}

struct PublicInfoRow: View {
    var title: String
    var value: String
    var iconName: String? = nil
    var iconColor: Color = .yellow
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
            
            InfoValueRow(value: value, iconName: iconName, iconColor: iconColor)
        }
    }
}

struct UserRoleBadge: View {
    var userType: String
    
    func userTypeBadge(for userType: String) -> (Color, String) {
        switch userType {
        case "Chapter Leader":
            return (.green, "Chapter Leader")
        case "Street Care Hub Leader":
            return (Color.blue.opacity(0.7), "Street Care Hub Leader")
        case "Chapter Member":
            return (.purple, "Chapter Member")
        case "Account Holder":
                    return (.yellow, "Account Holder")
                default:
                    return (.yellow, "Account Holder")
        }
    }
    
    var body: some View {
        let (badgeColor, badgeText) = userTypeBadge(for: userType)
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(badgeColor)
        }
    }
}
