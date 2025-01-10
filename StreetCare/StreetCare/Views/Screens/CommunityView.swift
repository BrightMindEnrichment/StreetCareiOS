//
//  CommunityView.swift
//  StreetCare
//
//  Created by Michael on 3/27/23.
//

import SwiftUI
import FirebaseAuth

struct CommunityView: View {
    
    @State var user: User?
    @StateObject var mapViewModel = MapViewModel()
    //@StateObject var googleViewModel = GoogleMapView()
    
    let adapter = EventDataAdapter()
    @State var events = [Event]()
    
    let formatter = DateFormatter()
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Community")
                    .font(.title)
                
                if let _ = self.user {
                    ScrollView{
                        VStack{
                            Spacer().frame(height: 10)
                            //                        Text("City: Unavailable").bold()
                            Spacer().frame(height: 35)
                            HStack{
                                NavigationLink {
                                    CommunityEventView(eventType: .future)
                                } label: {
                                    VStack{
                                        ZStack {
                                            Circle()
                                                .fill(Color("BackgroundColor"))
                                                .frame(width: 66.0)
                                            Circle()
                                                .strokeBorder(lineWidth: 1.2)
                                                .foregroundColor(Color("SecondaryColor"))
                                                .frame(width: 66.0)
                                            Image("community").frame(width: 15.0, height: 15.0)
                                        }
                                        Text(NSLocalizedString("futureEvents", comment: "")).fontWeight(.regular).foregroundColor(Color("TextColor"))
                                    }
                                }
                                Spacer().frame(width: (UIScreen.main.bounds.width / 2) / 2)
                                
                                NavigationLink {
                                    CommunityEventView(eventType: .past)
                                } label: {
                                    VStack{
                                        ZStack {
                                            Circle()
                                                .fill(Color("BackgroundColor"))
                                                .frame(width: 66.0)
                                            Circle()
                                                .strokeBorder(lineWidth: 1.2)
                                                .foregroundColor(Color("SecondaryColor"))
                                                .frame(width: 66.0)
                                            Image("community").frame(width: 15.0, height: 15.0)
                                        }
                                        Text(NSLocalizedString("pastEvents", comment: "")).fontWeight(.regular).foregroundColor(Color("TextColor"))
                                    }
                                }
                            }
                            
                            Spacer().frame(height: 10)
                            
                            NavigationLink {
                                HelpRequestView()
                            } label:{
                                VStack{
                                    ZStack {
                                        Circle()
                                            .fill(Color("BackgroundColor"))
                                            .frame(width: 66.0)
                                        Circle()
                                            .strokeBorder(lineWidth: 1.2)
                                            .foregroundColor(Color("SecondaryColor"))
                                            .frame(width: 66.0)
                                        Image("HelpingHands").frame(width: 15.0, height: 15.0)
                                    }
                                    Text(NSLocalizedString("helpRequests", comment: "")).fontWeight(.regular).foregroundColor(Color("TextColor"))
                                }
                            }
                            
                            VStack{
                                Spacer().frame(height: 30)
                                
                                Text("Map (Coming Soon)").bold()
                                    .frame(maxWidth: .infinity, alignment: .leading).padding()
                                ZStack {
                                    GoogleMapView(viewModel: mapViewModel)
                                        .edgesIgnoringSafeArea(.all)
                                        .task {
                                            print("GoogleMapView appeared, calling fetchMarkers()")
                                            await mapViewModel.fetchMarkers()
                                        }
                                    
                                    if mapViewModel.isLoading {
                                        ProgressView()
                                            .scaleEffect(1.5)
                                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    }
                                }
                                
                                .frame(height: 300)
                                
                                //                            Image("Map").resizable().aspectRatio(contentMode: .fit).frame(width: (UIScreen.main.bounds.width - 20),height: (UIScreen.main.bounds.width - 0)).padding(EdgeInsets(top: -50, leading: 0.0, bottom: 0.0, trailing: 0.0))
                            }
                        }
                        
                    }
                }
                else {
                    Image("CommunityOfThree").padding()
                    Text("Log in to connect with your local community.")
                }
            }
            .onAppear {
                if let user = Auth.auth().currentUser {
                    self.user = user
                    
                    adapter.delegate = self
                    adapter.refresh()
                }
            }
        }
    }
}



extension CommunityView: EventDataAdapterProtocol {
    func helpRequestDataRefreshed(_ events: [HelpRequest]) {
    }
    
    func eventDataRefreshed(_ events: [Event]) {
        self.events = events.filter({ event in
            return event.eventDate != nil
        })
    }
}


struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}

struct CardView: View {
    var height: CGFloat = 200 // default height
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.gray, lineWidth: 2)
            .frame(height: height)
            .padding()
            .overlay(
                VStack {
                    Image("Map")
                        .resizable()
                        .frame(width: 200, height: 200)
                }
            ).frame(width: 250,height: 250)
    }
}
