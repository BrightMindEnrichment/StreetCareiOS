//
//  EventPopupView.swift
//  StreetCare
//
//  Created by SID on 6/27/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

protocol EventPopupViewDelegate{
    func close()
}

struct EventPopupView: View {
    var event: EventData
    var eventType : EventType
    var delegate : EventPopupViewDelegate?
    let adapter = EventDataAdapter()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var refresh: Bool
    @State private var showCustomAlert = false

    var body: some View {
        
        let _ = refresh
        Group{
            VStack(alignment: .leading, spacing: 10) {
                // Spacer()
                HStack(spacing: 8) {
                    
                    Text(event.event.title.capitalized)
                        .font(.headline)
                    Spacer()
                    Image(systemName: "flag.fill")
                        .foregroundColor(event.event.isFlagged ? .red : .gray)
                        .onTapGesture {
                            Task {
                                guard let currentUser = Auth.auth().currentUser else { return }
                                let db = Firestore.firestore()
                                
                                let eventRef = db.collection("outreachEventsDev").document(event.event.eventId ?? "")
                                let currentUserId = currentUser.uid
                                
                                if event.event.isFlagged {
                                    if event.event.flaggedByUser == currentUserId {
                                        event.event.updateFlagStatus(newFlagState: false, userId: nil)
                                        
                                        let updates: [String: Any] = [
                                            "isFlagged": false,
                                            "flaggedByUser": NSNull()
                                        ]
                                        
                                        do {
                                            try await eventRef.updateData(updates)
                                            print("Successfully unflagged event by user \(currentUser.email ?? "")")
                                            refresh.toggle()
                                        } catch {
                                            print("Error updating flag status: \(error)")
                                        }
                                    } else {
                                        await MainActor.run {
                                            alertMessage = "Only the user who flagged this event or a Street Care Hub Leader can unflag it."
                                            showCustomAlert = true
                                        }
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
                                        refresh.toggle()
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
                
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundColor(.black)

                    VStack(alignment: .leading, spacing: 2) {
                        let date = event.date.0 ?? ""
                        let day = event.date.1 ?? ""
                        let time = event.date.2 ?? ""
                        let monthyear = event.monthYear
                        let timeZone = event.event.timeZone ?? ""

                        Text("\(monthyear), \(day) \(date), \(time) \(timeZone)")
                            .font(.system(size: 13))
                        
                         
                    }
                }


                
                if event.event.consentStatus {
                    if let contact = event.event.contactNumber, !contact.isEmpty {
                        HStack(spacing: 6){
                            Image(systemName: "phone")
                            Text(contact).font(.system(size: 13))
                        }
                    }
                    
                    if let emailAddress = event.event.emailAddress, !emailAddress.isEmpty {
                        HStack(spacing: 6){
                            Image(systemName: "envelope")
                            Text(emailAddress).font(.system(size: 13))
                        }
                    }
                    
                    
                }
                
                if event.event.consentStatus {
                    if let street = event.event.street,
                       let city = event.event.city,
                       let state = event.event.stateAbbv,
                       let zip = event.event.zipcode,
                       !street.isEmpty, !city.isEmpty, !state.isEmpty {
                        HStack(spacing: 6){
                            Image(systemName: "mappin.and.ellipse")
                            Text("\(street), \(city), \(state) \(zip)")
                                .font(.system(size: 13))
                        }
                    }
                } else {
                    if let city = event.event.city,
                       let state = event.event.stateAbbv,
                       !city.isEmpty, !state.isEmpty {
                        HStack(spacing: 6){
                            Image(systemName: "mappin.and.ellipse")
                            Text("\(city), \(state)").font(.system(size: 13))
                        }
                    }
                }
                
                
                if let description = event.event.description, !description.isEmpty {
                    Text(NSLocalizedString("eventDescription", comment: "")).font(.system(size: 14)).fontWeight(.semibold)
                    Text(description).font(.system(size: 13))
                }
                
                

                
                if let helpType = event.event.helpType, !helpType.isEmpty {
                    HStack {
                        Image("HelpType").resizable().frame(width: 20.0,height: 20.0)
                        let help = helpType.split(separator: ",").map({ NSLocalizedString($0.lowercased().replacingOccurrences(of: ".", with: "").replacingOccurrences(of: " ", with: ""), comment: "")
                        }).joined(separator: ", ")
                        Text(help.capitalized)
                            .font(.system(size: 13))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color("Color87CEEB").opacity(0.4))
                            .cornerRadius(5)
                    }
                }
                
                HStack {
                    if let skills = event.event.skills {
                        let maxVisibleSkills = 4 // adjust this based on how many fit in one line
                        let displaySkills = skills.prefix(maxVisibleSkills)
                        let shouldShowEllipsis = skills.count > maxVisibleSkills
                        
                        ForEach(Array(displaySkills.enumerated()), id: \.offset) { index, skill in
                            HStack {
                                Text("  \(NSLocalizedString(skill.lowercased().replacingOccurrences(of: " ", with: ""), comment: "").capitalized)  ")
                                    .font(.system(size: 10))
                            }
                            .frame(height: 30.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15.0)
                                    .stroke(Color.gray.opacity(0.8), lineWidth: 0.7)
                            )
                        }
                        
                        if shouldShowEllipsis {
                            Text("  ...  ")
                                .font(.system(size: 10))
                                .frame(height: 30.0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15.0)
                                        .stroke(Color.gray.opacity(0.8), lineWidth: 0.7)
                                )
                        }
                    }
                }
                // TODO: need to persist data from previous screens
                //            if let interest = event.event.participants?.count{
                //                if let slots = event.event.totalSlots{
                //                    Text("Participants: \(interest) / \(slots)")
                //                        .font(.system(size: 13))
                //                }
                //            }
                if eventType == .past{
                    VStack(alignment: .center, spacing: 10){
                        Text("Completed").font(.system(size: 13)).frame(width: UIScreen.main.bounds.width - 30.0)
                        NavLinkButton(title: "Close", width: UIScreen.main.bounds.width - 30.0,secondaryButton: true).fontWeight(.semibold)
                            .onTapGesture {
                                self.delegate?.close()
                            }
                    }
                }else{
                    if let user = Auth.auth().currentUser  {
                        let likeStatus =  self.event.event.liked//event.event.uid == user.uid ? false : true
                        VStack(alignment: .center, spacing: 10){
                            // TODO: hide RSVP visibility until functionality complete
                            //                        NavLinkButton(title: likeStatus ?  "Deregister" : "Sign up for the Event", width: UIScreen.main.bounds.width - 30.0).fontWeight(.semibold)
                            //                        .onTapGesture {
                            //                            adapter.setLikeEvent(event.event, setTo: likeStatus ? false :true)
                            //                            self.delegate?.close()
                            //                        }
                            
                            NavLinkButton(title: "Close", width: UIScreen.main.bounds.width - 30.0,secondaryButton: true).fontWeight(.semibold)
                                .onTapGesture {
                                    self.delegate?.close()
                                }
                        }
                        
                    }
                }
            } .toolbar(.hidden, for: .tabBar)
                .background(Color.white)
                .onAppear {
                    print("EventPopupView appeared")
                }
        }
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
                .onAppear {
                    print("EventPopupView appeared")
                    print("Consent Box: \(event.event.consentStatus)")
                    print("Email: \(event.event.emailAddress ?? "nil")")
                    print("Contact Number: \(event.event.contactNumber ?? "nil")")
                    print("title: \(event.event.title)")
                    print("description: \(String(describing: event.event.description))")
                    
                }

        )
    }
}

func formattedYear(_ date: Date?) -> String {
    guard let date = date else { return "" }
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    return formatter.string(from: date)
}

func formattedTime(_ date: Date?) -> String {
    guard let date = date else { return "" }
    let formatter = DateFormatter()
    formatter.timeStyle = .short // e.g., 3:00 PM
    return formatter.string(from: date)
}


struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let heightRatio: CGFloat
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                BottomSheetView(isPresented: $isPresented, heightRatio: heightRatio, content: sheetContent)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

extension View {
    func bottomSheet<SheetContent: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> SheetContent,  heightRatio: CGFloat = 0.5) -> some View {
        self.modifier(BottomSheetModifier(isPresented: isPresented, heightRatio: heightRatio, sheetContent: content))
    }
}

struct BottomSheetView<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content
    var heightRatio: CGFloat = 0.5 // ✅ default 50%

    init(isPresented: Binding<Bool>, heightRatio: CGFloat = 0.5, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.heightRatio = heightRatio
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack {
                    self.content
                }
                .frame(width: geometry.size.width, height: geometry.size.height * heightRatio) // Adjust height as needed
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .transition(.move(edge: .bottom))
                .animation(.easeInOut)
            }
            .background(
                Color.black.opacity(isPresented ? 0.3 : 0)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        self.isPresented = false
                    }
            )
        }
    }
}



//struct BottomSheetView<Content: View>: View {
//    @Binding var isPresented: Bool
//    let content: Content
//    var heightRatio: CGFloat = 0.5
//
//    init(isPresented: Binding<Bool>, heightRatio: CGFloat = 0.5, @ViewBuilder content: () -> Content) {
//        self._isPresented = isPresented
//        self.heightRatio = heightRatio
//        self.content = content()
//    }
//
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .bottom) {
//                // Dimmed background
//                if isPresented {
//                    Color.black.opacity(0.3)
//                        .edgesIgnoringSafeArea(.all)
//                        .onTapGesture {
//                            self.isPresented = false
//                        }
//                }
//
//                // Bottom Sheet
//                content
//                    .frame(width: geometry.size.width, height: geometry.size.height * heightRatio)
//                    .background(Color.white)
//                    .cornerRadius(20)
//                    .shadow(radius: 10)
//                    .transition(.move(edge: .bottom))
//                    .animation(.easeInOut, value: isPresented)
//            }
//        }
//    }
//}
