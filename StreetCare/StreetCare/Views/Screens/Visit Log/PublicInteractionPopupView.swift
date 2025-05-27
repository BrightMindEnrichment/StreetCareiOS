//
//  PublicInteractionPopupView.swift
//  StreetCare
//
//  Created by Nilesh Bhoi on 5/23/25.
//

import SwiftUI

struct PublicInteractionPopupView: View {
    var name: String
    var profileImageURL: URL?
    var date: Date
    //    var city: String
    //    var state: String
    var address: String
    var interactionDescription: String

    var peopleHelped: Int
    var joinedPeople: Int
    var itemsDonated: Int

    var helpType: [String]

    var onCancel: () -> Void
    var delegate : EventPopupViewDelegate?
    
    @State private var isFlagged = false
    @State private var isVerified = true


//    var body: some View {
//        VStack(alignment: .leading, spacing: 14) {
//            // Top row: avatar, name, spacer, icons
//            HStack {
//                profileImage
//                    .resizable()
//                    .frame(width: 40, height: 40)
//                    .clipShape(Circle())
//                
//                Text(name)
//                    .font(.system(size: 15, weight: .semibold))
//                
//                Spacer()
//                
//                Image(systemName: "flag.fill")
//                    .foregroundColor(.gray)
//                
//                Image(systemName: "checkmark.circle.fill")
//                    .foregroundColor(.yellow)
//            }
//            
//            // Location & date
//            HStack(spacing: 8) {
//                Image(systemName: "mappin.and.ellipse")
//                    .foregroundColor(.gray)
//                //                    Text("\(city), \(state)")
//                //                        .font(.system(size: 13))
//                Text("\(address)")
//                    .font(.system(size: 13))
//            }
//            
//            HStack(spacing: 8) {
//                Image(systemName: "clock")
//                    .foregroundColor(.gray)
//                //                    Text(date.formatted(date: .long, time: .shortened))
//                //                        .font(.system(size: 13))
//                Text(formattedDateTime(date))
//                    .font(.system(size: 13))
//            }
//            
//            // Description
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Interaction Description")
//                    .font(.system(size: 14, weight: .semibold))
//                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nibh ex, rhoncus ut tincidunt nec, pretium sit amet diam.")
////                Text(interactionDescription)
//                    .font(.system(size: 13))
//                    .fixedSize(horizontal: false, vertical: true)
//            }
//            
//            // Stats
//            VStack(alignment: .leading, spacing: 12) {
//                PublicInfoRow(title: "People Helped", value: "\(peopleHelped)", iconName: "Tab-Profile", iconColor: .yellow)
//                
//                PublicInfoRow(title: "People Who Joined", value: "\(joinedPeople)", iconName: "HelpingHands", iconColor: .yellow)
//                
//                PublicInfoRow(title: "Items Donated", value: "\(itemsDonated)", iconName: "Clothes", iconColor: .yellow)
//                //                    PublicInfoRow(title: "Type of Help Offered", value: helpType.joined(separator: ", "))
//                PublicInfoRow(
//                    title: "Type of Help Offered",
//                    value: helpType.isEmpty ? "N/A" : helpType.joined(separator: ", ")
//                )
//                
//            }
//            
//            
//            // Button
//            NavLinkButton(title: "Close", width: UIScreen.main.bounds.width - 33, secondaryButton: true)
//                .fontWeight(.semibold)
//                .frame(maxWidth: .infinity, alignment: .center)
//                .onTapGesture {
//                    delegate?.close()
//                }
//        }
//        //            .padding()
//        //            .background(Color.white)
//        .cornerRadius(20)
//        //            .shadow(radius: 8)
//        //            .padding(.horizontal)
//        //            .frame(height: UIScreen.main.bounds.height * 0.6) // Or 0.7 for taller sheet
//        .toolbar(.hidden, for: .tabBar) // 👈 this line hides the bottom tab bar
//        
//        
//    }
    
    var body: some View {
            VStack(alignment: .leading, spacing: 14) {
                // Top row
                HStack {
//                    profileImage
//                        .resizable()
//                        .frame(width: 40, height: 40)
//                        .clipShape(Circle())
                    
                    if let url = profileImageURL {
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

                    Text(name)
                        .font(.system(size: 15, weight: .semibold))

                    Spacer()

                    // Flag toggle
                    Image(systemName: "flag.fill")
                        .foregroundColor(isFlagged ? .red : .gray)
                        .onTapGesture {
                            isFlagged.toggle()
                        }

                    // Verified toggle (for demo)
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(isVerified ? .yellow : .gray)
                }

                // Location & date
                HStack(spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.gray)
                    Text(address)
                        .font(.system(size: 13))
                }

                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    Text(formattedDateTime(date))
                        .font(.system(size: 13))
                }

                // Description
                VStack(alignment: .leading, spacing: 4) {
                    Text("Interaction Description")
                        .font(.system(size: 14, weight: .semibold))
                    Text(interactionDescription)
                        .font(.system(size: 13))
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Stats
                VStack(alignment: .leading, spacing: 12) {
                    PublicInfoRow(title: "People Helped", value: "\(peopleHelped)", iconName: "Tab-Profile", iconColor: .yellow)
                    PublicInfoRow(title: "People Who Joined", value: "\(joinedPeople)", iconName: "HelpingHands", iconColor: .yellow)
                    PublicInfoRow(title: "Items Donated", value: "\(itemsDonated)", iconName: "Clothes", iconColor: .yellow)
                    PublicInfoRow(title: "Type of Help Offered", value: helpType.isEmpty ? "N/A" : helpType.joined(separator: ", "))
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
        }

}


//struct InfoRowWithIcon: View {
//    var icon: String
//    var label: String
//    var value: String
//    
//    var body: some View {
//        HStack(alignment: .top, spacing: 8) {
//            Image(systemName: icon)
//                .foregroundColor(.gray)
//                .frame(width: 10)
//            VStack(alignment: .leading, spacing: 2) {
//                Text(label)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                Text(value)
//                    .font(.body)
//            }
//        }
//    }
//}

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


#Preview {
    PublicInteractionPopupView(
        name: "John Doe",
//        profileImageURL: "",
        date: Date(),
        address: "123 Main St, Springfield, IL",
        interactionDescription: "Distributed food and clothes to 5 individuals at the park.",
        peopleHelped: 5,
        joinedPeople:  2,
        itemsDonated: 10,
        helpType: ["Food", "Clothes", "Water"],
        onCancel: {},
        delegate: nil
    )
    .padding()
//    .previewLayout(.sizeThatFits)
}
