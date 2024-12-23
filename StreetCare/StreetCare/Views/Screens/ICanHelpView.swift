//
//  ICanHelpView.swift
//  StreetCare
//
//  Created by Amey Kanunje on 9/27/24.
//

/*import SwiftUI

struct ICanHelpView: View {
    
    @Binding var isPresented: Bool
    @State private var isOutreachCreated = false
    @State private var isSupportRequestViewPresented = false
    @State private var helpRequests: [HelpRequest] = []
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }
                
                Text(NSLocalizedString("iCanHelpText1", comment: ""))
                    .font(.headline)
                
                Text(NSLocalizedString("iCanHelpText2", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(NSLocalizedString("iCanHelpText3", comment: ""))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(NSLocalizedString("iCanHelpText4", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                NavigationLink(destination: EventListView()) {
                                Text(NSLocalizedString("rsvpExistingOutreach", comment: ""))
                                    .padding(EdgeInsets(top: 8.0, leading: 20.0, bottom: 8.0, trailing: 20.0))
                                    .foregroundColor(Color("PrimaryColor"))
                            }
                            .background(Color("SecondaryColor"))
                            .clipShape(Capsule())

                Button(action: {
                    isPresented = false // Close this view
                }) {
                    Text(NSLocalizedString("cancel", comment: ""))
                        .padding(EdgeInsets(top: 8.0, leading: 20.0, bottom: 8.0, trailing: 20.0))
                        .foregroundColor(Color("PrimaryColor"))
                }
                .background(Color("SecondaryColor"))
                .clipShape(Capsule())
                
                Button(action: {
                    isOutreachCreated = true // Open OutreachFormView
                }) {
                    Text(NSLocalizedString("createAnOutreach", comment: ""))
                        .padding(EdgeInsets(top: 8.0, leading: 20.0, bottom: 8.0, trailing: 20.0))
                        .foregroundColor(Color("PrimaryColor"))
                }
                .background(Color("SecondaryColor"))
                .clipShape(Capsule())
                .sheet(isPresented: $isOutreachCreated) {
                    NavigationStack {
                        OutreachFormView(isPresented: $isPresented) 
                    }
                }
            }
            .padding()
            .frame(maxWidth: 300)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
        }
    }
}

//#Preview {
//    ICanHelpView(isPresented: )
//}
*/
import SwiftUI

struct ICanHelpView: View {
    
    @Binding var isPresented: Bool // Binding to control dismissal of this view
    @State private var isOutreachCreated = false
    @State private var isSupportRequestViewPresented = false // State to present SupportRequestView
    @State private var helpRequests: [HelpRequest] = []
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) { // Close this view
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }
                
                Text(NSLocalizedString("iCanHelpText1", comment: ""))
                    .font(.headline)
                
                Text(NSLocalizedString("iCanHelpText2", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(NSLocalizedString("iCanHelpText3", comment: ""))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(NSLocalizedString("iCanHelpText4", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Navigation Link to RSVP Existing Outreach
                NavigationLink(destination: EventListView()) {
                    Text(NSLocalizedString("rsvpExistingOutreach", comment: ""))
                        .padding(EdgeInsets(top: 8.0, leading: 20.0, bottom: 8.0, trailing: 20.0))
                        .foregroundColor(Color("PrimaryColor"))
                }
                .background(Color("SecondaryColor"))
                .clipShape(Capsule())

                // Button to Create an Outreach
                Button(action: {
                    isOutreachCreated = true // Open OutreachFormView
                }) {
                    Text(NSLocalizedString("createAnOutreach", comment: ""))
                        .padding(EdgeInsets(top: 8.0, leading: 20.0, bottom: 8.0, trailing: 20.0))
                        .foregroundColor(Color("PrimaryColor"))
                }
                .background(Color("SecondaryColor"))
                .clipShape(Capsule())
                .sheet(isPresented: $isOutreachCreated) {
                    NavigationStack {
                        OutreachFormView(isPresented: $isPresented) // Pass binding
                    }
                }
                
                // Cancel Button
                Button(action: {
                    isPresented = false // Close this view
                }) {
                    Text(NSLocalizedString("cancel", comment: ""))
                        .padding(EdgeInsets(top: 8.0, leading: 20.0, bottom: 8.0, trailing: 20.0))
                        .foregroundColor(Color("PrimaryColor"))
                }
                .background(Color("SecondaryColor"))
                .clipShape(Capsule())
                
            }
            .padding()
            .frame(maxWidth: 300)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
        }
    }
}

//#Preview {
//    ICanHelpView(isPresented: )
//}
