//
//  EventPopupView.swift
//  StreetCare
//
//  Created by SID on 6/27/24.
//

import SwiftUI
import FirebaseAuth

protocol EventPopupViewDelegate{
    func close()
}

struct EventPopupView: View {
    var event: EventData
    var eventType : EventType
    var delegate : EventPopupViewDelegate?
    let adapter = EventDataAdapter()

    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
           // Spacer()
            Text(event.event.title.capitalized)
                .font(.headline)
            
            HStack {
                Image(systemName: "mappin.and.ellipse")
                Text(event.event.location!)
                    .font(.system(size: 13))
            }
            
            HStack {
                Image(systemName: "clock")
                if let date = event.date.2{
                    Text("\(date)")
                        .font(.system(size: 13))
                }
            }
            Text("Event Description").font(.system(size: 14)).fontWeight(.semibold)
            Text(event.event.description == "" ? "No date available" : event.event.description!).font(.system(size: 13))
           
            
            HStack {
                Image("HelpType").resizable().frame(width: 20.0,height: 20.0)
                Text(event.event.helpType!.capitalized).font(.system(size: 13))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color("Color87CEEB").opacity(0.4))
                    .cornerRadius(5)
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
            
            if let interest = event.event.participants?.count{
                if let slots = event.event.totalSlots{
                    Text("Participants: \(interest) / \(slots)")
                        .font(.system(size: 13))
                }
            }
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
                        NavLinkButton(title: likeStatus ?  "Deregister" : "Sign up for the Event", width: UIScreen.main.bounds.width - 30.0).fontWeight(.semibold)
                        .onTapGesture {
                            DispatchQueue.global().async {
                                adapter.setLikeEvent(event.event, setTo: likeStatus ? false : true)
                            }
                            DispatchQueue.main.async {
                                self.delegate?.close()
                            }
                        }
                        
                        NavLinkButton(title: "Close", width: UIScreen.main.bounds.width - 30.0,secondaryButton: true).fontWeight(.semibold)
                        .onTapGesture {
                            DispatchQueue.main.async {
                                self.delegate?.close()
                            }
                        }
                }

                }
            }
        } .toolbar(.hidden, for: .tabBar)
        .background(Color.white)
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
