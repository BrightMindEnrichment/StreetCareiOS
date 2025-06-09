//
//  PublicInteractionPopupView.swift
//  StreetCare
//
//  Created by Nilesh Bhoi on 5/23/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct PublicInteractionPopupView: View {
    @ObservedObject var visit: VisitLog
    var user: User?
    var userType: String
    var onCancel: () -> Void
    var delegate : EventPopupViewDelegate?
    
    @Binding var refresh: Bool
    @State private var showCustomAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Top row
            HStack {
                if let url = user?.photoURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .opacity(0.5)
                    }
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
                
                Text(user?.displayName ?? "Firstname Lastname")
                    .font(.system(size: 15, weight: .semibold))
                
                Spacer()
                
                // Flag toggle
                Image(systemName: "flag.fill")
                    .foregroundColor(visit.isFlagged ? .red : .gray)
                    .onTapGesture {
                        Task {
                            let db = Firestore.firestore()
//                            print(visit.id)
                            let ref = db.collection("visitLogWebProd").document(visit.id)
//                            print(ref.documentID)
                            let updates: [String: Any] = [
                                "isFlagged": false,
                                "flaggedByUser": NSNull()
                            ]
                            if visit.isFlagged {
                                // UNFLAGGING
                                // Allow to unflag if flagged by same user (==currentUser)
//                                print("Checking if user \(user?.uid ?? "") is flagged by user \(visit.flaggedByUser ?? "")")
                                if visit.flaggedByUser == user?.uid || userType == "Street Care Hub Leader" {
                                    // Allow unflagging
                                    do {
                                        try await ref.updateData(updates)
                                        
                                        visit.isFlagged = false
                                        visit.flaggedByUser = ""
                                        refresh.toggle()
//                                        print("Successfully unflagged event by user \(user?.uid ?? "")")
                                    } catch {
//                                        print("Error updating flag status: \(error)")
                                    }

                                } else {
                                    // Not allowed, show alert
                                    await MainActor.run {
                                        alertMessage = "Only the user who flagged this event or a Street Care Hub Leader can unflag it."
                                        showCustomAlert = true
                                    }
                                }
                            } else {
                                // FLAGGING
                                let updates: [String: Any] = [
                                    "isFlagged": true,
                                    "flaggedByUser": user?.uid
                                ]

                                do {
                                    try await ref.updateData(updates)

                                    visit.isFlagged = true
                                    visit.flaggedByUser = user?.uid ?? ""
                                    refresh.toggle()
//                                    print("Successfully flagged event by user \(user?.uid ?? "")")
                                } catch {
//                                    print("Error updating flag status: \(error)")
                                }
                            }
                            
                        }
                    }
                
                // checkmark
                UserRoleBadge(userType: userType)
            }
            
            // Location & date
            HStack(spacing: 8) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.gray)
                Text(visit.whereVisit)
                    .font(.system(size: 13))
            }
            
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .foregroundColor(.gray)
                Text(formattedDateTime(visit.whenVisit))
                    .font(.system(size: 13))
            }
            
            // Description
            VStack(alignment: .leading, spacing: 4) {
                Text("Interaction Description")
                    .font(.system(size: 14, weight: .semibold))
                Text(visit.peopleHelpedDescription)
                    .font(.system(size: 13))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Stats
            VStack(alignment: .leading, spacing: 12) {
                PublicInfoRow(title: "People Helped", value: "\(visit.peopleHelped)", iconName: "Tab-Profile", iconColor: .yellow)
                PublicInfoRow(title: "People Who Joined", value: "\(visit.numberOfHelpers)", iconName: "HelpingHands", iconColor: .yellow)
                PublicInfoRow(title: "Items Donated", value: "\(visit.itemQty)", iconName: "Clothes", iconColor: .yellow)
                PublicInfoRow(title: "Type of Help Offered", value: visit.whatGiven.isEmpty ? "N/A" : visit.whatGiven.joined(separator: ", "))
            }
            
            // Close Button
            NavLinkButton(title: "Close", width: UIScreen.main.bounds.width - 30, secondaryButton: true)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
                .onTapGesture {
                    delegate?.close()
                    onCancel()
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
        default:
            return (.yellow, "Chapter Member")
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
