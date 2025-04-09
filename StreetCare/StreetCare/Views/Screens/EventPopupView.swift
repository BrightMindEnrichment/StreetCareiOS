//
//  EventPopupView.swift
//  StreetCare
//
//  Created by SID on 6/27/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

protocol EventPopupViewDelegate {
    func close()
}

struct EventPopupView: View {
    var event: EventData
    @ObservedObject var flagStatus: FlagStatus
    var eventType: EventType
    var delegate: EventPopupViewDelegate?
    
    @Binding var isFlagged: Bool
    @State private var showFlagAlert: Bool = false
    @State private var showPermissionAlert: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(event.event.title.capitalized)
                    .font(.headline)
                Spacer()
                
                // Flag Button
                Button {
                    handleFlagButtonTap()
                } label: {
                    Image(systemName: "flag.fill")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(isFlagged ? .red : .black.opacity(0.7))
                        .padding(6)
                        .background(Color.white.opacity(0.01))
                        .clipShape(Circle())
                }
                .contentShape(Rectangle())
                
                // Verified Icon
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(getVerificationColor(for: event.event.userType))
                    .font(.system(size: 20))
                    .padding(8)
            }

            if let description = event.event.description, !description.isEmpty {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text(description).font(.system(size: 13))
                }
            }

            HStack {
                Image(systemName: "clock")
                if let date = event.date.2 {
                    Text("\(date)")
                        .font(.system(size: 13))
                }
            }

            if let description = event.event.description, !description.isEmpty {
                Text("Event Description")
                    .font(.system(size: 14))
                    .fontWeight(.semibold)
                Text(description)
                    .font(.system(size: 13))
            }

            if let helpType = event.event.helpType, !helpType.isEmpty {
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
                if let skills = event.event.skills {
                    ForEach(skills, id: \.self) { skill in
                        Text("  \(skill)  ")
                            .font(.system(size: 10))
                            .frame(height: 30.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15.0)
                                    .stroke(Color.gray.opacity(0.8), lineWidth: 0.7)
                            )
                    }
                }
            }

            if eventType == .past {
                VStack(alignment: .center, spacing: 10) {
                    Text("Completed")
                        .font(.system(size: 13))
                        .frame(width: UIScreen.main.bounds.width - 30.0)
                    
                    NavLinkButton(title: "Close", width: UIScreen.main.bounds.width - 30.0, secondaryButton: true)
                        .fontWeight(.semibold)
                        .onTapGesture {
                            self.delegate?.close()
                        }
                }
            } else {
                VStack(alignment: .center, spacing: 10) {
                    NavLinkButton(title: "Close", width: UIScreen.main.bounds.width - 30.0, secondaryButton: true)
                        .fontWeight(.semibold)
                        .onTapGesture {
                            self.delegate?.close()
                        }
                }
            }
        }
        .padding()
        .background(Color.white)
        .onAppear {
            if !flagStatus.isFlagged {
                flagStatus.isFlagged = event.event.isFlagged ?? false
            }
        }
    }

    private func handleFlagButtonTap() {
        if let currentUserID = Auth.auth().currentUser?.uid {
            if currentUserID == event.event.uid && !isFlagged {
                isFlagged = true
                flagStatus.isFlagged = true
                event.event.isFlagged = true
                flagEventInFirestore(eventID: event.event.eventId)
            }
        }
    }

    private func flagEventInFirestore(eventID: String?) {
        guard let eventID = eventID else {
            print("❌ Missing event ID. Cannot flag event.")
            return
        }

        guard let userID = Auth.auth().currentUser?.uid else {
            print("❌ User not logged in. Cannot flag.")
            return
        }

        let db = Firestore.firestore()
        let eventRef = db.collection("outreachEventsDev").document(eventID)

        eventRef.updateData([
            "isFlagged": true,
            "flaggedByUsers": FieldValue.arrayUnion([userID])
        ]) { error in
            if let error = error {
                print("❌ Error flagging event: \(error.localizedDescription)")
            } else {
                print("✅ Event flagged by user: \(userID)")
            }
        }
    }
}



struct BottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                BottomSheetView(isPresented: $isPresented, content: sheetContent)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

extension View {
    func bottomSheet<SheetContent: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> SheetContent) -> some View {
        self.modifier(BottomSheetModifier(isPresented: isPresented, sheetContent: content))
    }
}

struct BottomSheetView<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content

    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack {
                    self.content
                }
                .frame(width: geometry.size.width, height: UIScreen.main.bounds.height / 2) // Adjust height as needed
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
