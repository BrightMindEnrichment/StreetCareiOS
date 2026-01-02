//
//  PublicLogViewCard.swift
//  StreetCare
//
//  Created by Aishwarya S on 21/05/25.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseFirestore

struct PublicLogViewCard: View {
    @ObservedObject var log: VisitLog
    @ObservedObject var user: UserDetails
    @ObservedObject var loggedInUser: UserDetails
    var onDetailsClick: () -> Void
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack(alignment: .trailing) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    HStack(alignment: .center) {
                        // profile picture
                        Group {
                            if let image = user.image {
                                Image(uiImage: image)
                                    .resizable()

                                    .scaledToFill()

                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                            } else {
                                Image("PublicLogDefaultProfile")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                            }
                        }
                        Text(log.user.userName).font(.headline)
                    }
                    Spacer()
                    HStack(spacing: 5) {
                        Image(systemName: "flag.fill")
                            .foregroundColor(log.isFlagged ? .red : .gray)
                            .onTapGesture {
                                guard let currentUser = Auth.auth().currentUser else { return }
                                
                                // If the public log is flagged, only users that flagged the event or internal users can unflag it
                                if log.isFlagged {
                                    if log.flaggedByUser == loggedInUser.uid || loggedInUser.userType == "Street Care Hub Leader" {
                                        // unflag
                                        updateFlagStatus(log: log, isFlagged: false, flaggedByUser: nil)
                                        log.isFlagged = false
                                        log.flaggedByUser = ""
                                    } else {
                                        alertMessage = "Only the user who flagged this event or a Street Care Hub Leader can unflag it."
                                        showAlert = true
                                    }
                                } else {
                                    updateFlagStatus(log: log, isFlagged: true, flaggedByUser: loggedInUser.uid)
                                    log.isFlagged = true
                                    log.flaggedByUser = loggedInUser.uid
                                }
                            }
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(getVerificationColor(for: log.user.userType))
                            .font(.system(size: 18))
                            .padding(1)
                    }
                }.padding([.bottom], 5)
                // location
                if !log.city.isEmpty || !log.state.isEmpty || !log.stateAbbv.isEmpty {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text("\(log.city)\(log.city.isEmpty || (log.state.isEmpty && log.stateAbbv.isEmpty) ? "" : ", ")\(log.state.isEmpty ? log.stateAbbv : log.state)")
                            .font(.system(size: 13))
                    }
                } else {
                    HStack {
                        Spacer()
                    }
                }

                
                // time
                HStack {
                    Image(systemName: "clock")
                    Text("\(formatTime(log.whenVisit))")
                        .font(.system(size: 13))
                }
                if log.whatGiven.count != 0 {
                    HStack {
                        Image("HelpType")
                            .resizable()
                            .frame(width: 20.0, height: 20.0)
                        
                        Text(log.whatGiven.joined(separator: ", "))
                            .font(.system(size: 13))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color("Color87CEEB").opacity(0.4))
                            .cornerRadius(5)
                    }
                }
            }
            VStack() {
                Spacer()
                Button("Details") {
                    onDetailsClick()
                }
                .frame(width: 60, height: 15)
                .foregroundColor(Color("PrimaryColor"))
                .font(.footnote)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color("SecondaryColor"))
                )
                .buttonStyle(BorderlessButtonStyle())
                Spacer()
            }            
        }
        .padding(4)
        .padding(.horizontal, 8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .clipShape(RoundedCorner(radius: 35, corners: [.topLeft]))
        .shadow(radius: 2)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Unflag Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

func getDateAndDay(date: Date) -> (String, String) {
    let dayFormatter = DateFormatter()
    dayFormatter.dateFormat = "dd"
    let day = dayFormatter.string(from: date)
    
    let weekdayFormatter = DateFormatter()
    weekdayFormatter.dateFormat = "EEE"
    let weekday = weekdayFormatter.string(from: date).uppercased()
    
    return (day, weekday)
}

func formatTime(_ date: Date) -> String {
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "h:mm a"
    let timeString = timeFormatter.string(from: date)
    return "\(timeString)"
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 15
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

func updateFlagStatus(log: VisitLog, isFlagged: Bool, flaggedByUser: String?) {
    Task {
        let db = Firestore.firestore()
        let collectionName = log.source == "webProd" ? "VisitLogBook_New" : "VisitLogBook_New"
        let ref = db.collection(collectionName).document(log.id)
        
        let updates: [String: Any] = [
            "isFlagged": isFlagged,
            "flaggedByUser": flaggedByUser ?? NSNull()
        ]
        do {
            try await ref.updateData(updates)
            print("Successfully updated flag status")
        } catch {
            print("Error updating flag status: \(error)")
        }
    }
}
