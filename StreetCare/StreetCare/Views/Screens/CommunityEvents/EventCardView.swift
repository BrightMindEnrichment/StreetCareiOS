//
//  EventCardView.swift
//  StreetCare
//
//  Created by Kevin Phillips on 10/24/24.
//

import Foundation
import SwiftUI

struct EventCardView: View {
    var event: EventData
    var eventType: EventType
    var onCardTap: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(event.event.title.capitalized)
                        .font(.headline)
                }
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text(event.event.location!)
                        .font(.system(size: 13))
                }
                HStack {
                    Image(systemName: "clock")
                    if let date = event.date.2 {
                        Text("\(date)")
                            .font(.system(size: 13))
                    }
                }
                HStack {
                    Image("HelpType")
                        .resizable()
                        .frame(width: 20.0, height: 20.0)
                    Text(event.event.helpType!.capitalized)
                        .font(.system(size: 13))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color("Color87CEEB").opacity(0.4))
                        .cornerRadius(5)
                }
                HStack {
                    // TODO: hide participant count until feature is completed
    //                if let slots = event.event.totalSlots {
    //                    let minimumInterest = Int(Double(slots) * 0.65)
    //                    let interest = Int.random(in: minimumInterest...slots)
    //
    //                    Text(String(format: NSLocalizedString("participantsCount", comment: "Number of participants out of total slots"), interest, slots))
    //                        .font(.system(size: 13))
    //                }
                    Spacer()
                    if eventType == .past {
                        Text(NSLocalizedString("completedText", comment: "Label for completed events"))
                            .font(.system(size: 13))
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(getVerificationColor(for: event.event.userType))
                .font(.system(size: 20))
                .padding(8)
        }
        .onTapGesture {
            onCardTap()
        }
    }
}

