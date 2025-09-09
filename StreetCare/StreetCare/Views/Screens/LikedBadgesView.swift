//
//  LikedBadgesView.swift
//  StreetCare
//
//  Created by Gayathri Jayachander on 9/7/25.
//
import SwiftUI
import FirebaseAuth

struct LikedBadgesView: View {
    @State private var user: User?
    @State var userDetails: UserDetails? = UserDetails()
    @State var isPresented: Bool = false

    var body: some View {
        VStack {
            if user != nil {
                List {
                    NavigationLink(destination: LikedEventView(isPresented: $isPresented, loggedInUserDetails: userDetails ?? UserDetails(), eventType: .all)) {
                        HStack {
                            Image("community")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .cornerRadius(8.0)
                            Text("Outreach Events")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .center) // centers text horizontally
                                    .padding(.vertical, 8)
                                
                                
                        }
                    }
                    .padding().cornerRadius(10.0).border(.black).listRowSeparator(.hidden)

                   /* NavigationLink(destination: LikedEventView(isPresented: $isPresented, loggedInUserDetails: userDetails ?? UserDetails(), eventType: .future)) {
                        HStack {
                            Image("benevolent_donor_badge")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                            Text("Interaction Log")
                                .font(.headline)
                                .padding(.leading, 8)
                        }
                    }
                    .listRowSeparator(.hidden)*/
                }
                .navigationTitle("Liked Posts")
                .scrollContentBackground(.hidden)
                .background(.clear)
                .listStyle(.plain)
            } else {
                Image("CommunityOfThree").padding()
                Text("Log in to connect with your local community.")
            }
        }
        .onAppear {
            user = Auth.auth().currentUser
        }
    }
}

struct LikedBadgesView_Previews: PreviewProvider {
    static var previews: some View {
        LikedBadgesView()
    }
}

