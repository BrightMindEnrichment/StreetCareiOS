import SwiftUI

enum VisitImpactReviewStatus {
    case published
    case pending
    case rejected

    var title: String {
        switch self {
        case .published:
            return "PUBLISHED"
        case .pending:
            return "PENDING"
        case .rejected:
            return "REJECTED"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .published:
            return Color("PublishedGreen")
        case .pending:
            return Color("Pending")
        case .rejected:
            return Color("RejectedRed")
        }
    }
}

let stateAbbreviations: [String: String] = [
    "Alabama": "AL", "Alaska": "AK", "Arizona": "AZ", "Arkansas": "AR",
    "California": "CA", "Colorado": "CO", "Connecticut": "CT", "Delaware": "DE",
    "Florida": "FL", "Georgia": "GA", "Hawaii": "HI", "Idaho": "ID",
    "Illinois": "IL", "Indiana": "IN", "Iowa": "IA", "Kansas": "KS",
    "Kentucky": "KY", "Louisiana": "LA", "Maine": "ME", "Maryland": "MD",
    "Massachusetts": "MA", "Michigan": "MI", "Minnesota": "MN", "Mississippi": "MS",
    "Missouri": "MO", "Montana": "MT", "Nebraska": "NE", "Nevada": "NV",
    "New Hampshire": "NH", "New Jersey": "NJ", "New Mexico": "NM", "New York": "NY",
    "North Carolina": "NC", "North Dakota": "ND", "Ohio": "OH", "Oklahoma": "OK",
    "Oregon": "OR", "Pennsylvania": "PA", "Rhode Island": "RI", "South Carolina": "SC",
    "South Dakota": "SD", "Tennessee": "TN", "Texas": "TX", "Utah": "UT",
    "Vermont": "VT", "Virginia": "VA", "Washington": "WA", "West Virginia": "WV",
    "Wisconsin": "WI", "Wyoming": "WY"
]

struct HalfCapsuleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let leftRadius = rect.height / 2
        let rightRadius: CGFloat = 16

        path.move(to: CGPoint(x: leftRadius, y: 0))
        path.addLine(to: CGPoint(x: rect.width - rightRadius, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: rightRadius),
            control: CGPoint(x: rect.width, y: 0)
        )
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - rightRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.width - rightRadius, y: rect.height),
            control: CGPoint(x: rect.width, y: rect.height)
        )
        path.addLine(to: CGPoint(x: leftRadius, y: rect.height))
        path.addArc(
            center: CGPoint(x: leftRadius, y: rect.midY),
            radius: leftRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(270),
            clockwise: false
        )

        path.closeSubpath()
        return path
    }
}
