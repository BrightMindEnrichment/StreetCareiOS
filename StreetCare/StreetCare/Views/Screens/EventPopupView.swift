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
    
    @State private var isFlagged: Bool = false
    @State private var showFlagAlert: Bool = false
    
    private func flagEventInFirestore(eventID: String?) {
        guard let eventID = eventID else {
            print("Missing event ID. Cannot flag event.")
            return
        }

        let db = Firestore.firestore()
        db.collection("outreachEventsDev").document(eventID).updateData([
            "isFlagged": true
        ]) { error in
            if let error = error {
                print("❌ Error flagging event: \(error.localizedDescription)")
            } else {
                print("✅ Event flagged successfully in Firestore.")
            }
        }
    }

    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
           // Spacer()
            HStack{
                Text(event.event.title.capitalized)
                    .font(.headline)
                Spacer()
                Button {
                    print("🚨 Flag button tapped")
                    showFlagAlert = true
                } label: {
                    Image(systemName: "flag.fill")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(isFlagged ? .red : .black.opacity(0.7))
                        .padding(6)
                        .background(Color.white.opacity(0.01)) // makes whole area tappable
                        .clipShape(Circle())
                }
                .contentShape(Rectangle())
                
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
                if let date = event.date.2{
                    Text("\(date)")
                        .font(.system(size: 13))
                }
            }
            if let description = event.event.description, !description.isEmpty {
                Text("Event Description").font(.system(size: 14)).fontWeight(.semibold)
                Text(description).font(.system(size: 13))
            }
            
            if let helpType = event.event.helpType, !helpType.isEmpty {
                HStack {
                    Image("HelpType").resizable().frame(width: 20.0,height: 20.0)
                    Text(helpType.capitalized)
                        .font(.system(size: 13))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color("Color87CEEB").opacity(0.4))
                        .cornerRadius(5)
                }
            }
            
            HStack {
                if let skills = event.event.skills{
                    ForEach(0..<skills.count, id: \.self) { index in
                    HStack {
                        Text("  \(skills[index])  ")
                            .font(.system(size: 10))
                    }.frame(height: 30.0).overlay(
                        RoundedRectangle(cornerRadius: 15.0)
                            .stroke(Color.gray.opacity(0.8), lineWidth: 0.7))
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
        .alert(isPresented: $showFlagAlert) {
            Alert(
                title: Text("Flag this event?"),
                message: Text("Do you want to report this event as inappropriate or incorrect?"),
                primaryButton: .destructive(Text("Flag")) {
                    isFlagged = true
                    flagEventInFirestore(eventID: event.event.eventId)
                },
                secondaryButton: .cancel()
            )
        }
        .onChange(of: showFlagAlert) { value in
            print("👀 showFlagAlert changed to: \(value)")
        }
        .onAppear {
            isFlagged = event.event.isFlagged ?? false
        }
    }
}

#Preview {
    EventPopupView(event: EventData(), eventType: .future)
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
