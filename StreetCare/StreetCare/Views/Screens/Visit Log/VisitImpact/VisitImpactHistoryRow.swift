import SwiftUI

struct VisitImpactHistoryRow: View {
    let item: VisitLog
    let index: Int
    let historyCount: Int
    let reviewStatus: VisitImpactReviewStatus?
    @State private var isShowingInteractionLogDetail = false

    var body: some View {
        rowPresentation
    }

    @ViewBuilder
    private var rowPresentation: some View {
        if item.source == "interactionLog" {
            Button(action: {
                isShowingInteractionLogDetail = true
            }) {
                rowContent
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $isShowingInteractionLogDetail) {
                InteractionLogDetailSheet(log: item)
            }
        } else {
            NavigationLink(destination: VisitLogView(log: item)) {
                rowContent
            }
            .buttonStyle(.plain)
        }
    }

    private var rowContent: some View {
        HStack(alignment: .top, spacing: 3) {
            VisitImpactTimelineDecoration(index: index, historyCount: historyCount)
            VisitImpactHistoryIcon()
            VisitImpactHistoryCard(item: item, reviewStatus: reviewStatus)
        }
        .padding(.horizontal, 5)
        .padding(.trailing, 0)
        .contentShape(Rectangle())
    }
}

private struct InteractionLogDetailSheet: View {
    let log: VisitLog
    @State private var measuredHeight: CGFloat = 420

    var body: some View {
        InteractionLogDetailView(log: log)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: InteractionLogDetailHeightKey.self, value: proxy.size.height)
                }
            )
            .onPreferenceChange(InteractionLogDetailHeightKey.self) { newHeight in
                let maxHeight = UIScreen.main.bounds.height * 0.9
                measuredHeight = min(max(newHeight, 1), maxHeight)
            }
            .presentationDetents([.height(measuredHeight)])
            .presentationDragIndicator(.visible)
    }
}

private struct InteractionLogDetailHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct VisitImpactTimelineDecoration: View {
    let index: Int
    let historyCount: Int

    var body: some View {
        ZStack {
            if index != 0 {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 1, height: 70)
                    .offset(x: -5, y: -20)
            }

            if index != historyCount - 1 {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 1, height: 70)
                    .offset(x: -5, y: 50)
            }

            Circle()
                .fill(Color(red: 1.0, green: 0.933, blue: 0.0))
                .frame(width: 13, height: 50)
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 1)
                )
                .offset(x: -5, y: 15)
        }
        .frame(width: 5)
    }
}

private struct VisitImpactHistoryIcon: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 55, height: 55)

                Image("VisitLogIcon")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 55, height: 55)
            }
            .position(x: 40, y: geo.size.height / 2 - 5)
        }
        .frame(width: 0)
        .zIndex(1)
    }
}

private struct VisitImpactHistoryCard: View {
    let item: VisitLog
    let reviewStatus: VisitImpactReviewStatus?

    var body: some View {
        VStack(spacing: 1) {
            VisitImpactLocationRow(item: item)
            VisitImpactDateRow(item: item, reviewStatus: reviewStatus)
        }
        .padding(.top, 10)
        .padding(.bottom, 0)
        .padding(.leading, 55)
        .background(Color.white)
        .clipShape(HalfCapsuleShape())
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}

private struct VisitImpactLocationRow: View {
    let item: VisitLog

    var body: some View {
        let display = locationDisplay

        return HStack(alignment: .top, spacing: 5) {
            Image("MapPin")
                .font(.system(size: 14))
                .foregroundColor(.black)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 2) {
                if let primaryLine = display.primaryLine {
                    Text(primaryLine)
                        .font(.system(size: 13.0))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.4, alignment: .leading)
                }

                Text(display.secondaryLine)
                    .font(.system(size: 13.0))
            }
            .padding(.top, 5)

            Spacer()
        }
        .padding(.leading, 20)
    }

    private var locationDisplay: (primaryLine: String?, secondaryLine: String) {
        let components = item.whereVisit.components(separatedBy: ", ").filter { !$0.isEmpty }

        if components.count >= 3 {
            let street = components.indices.contains(0) ? components[0] : ""
            let city = components.indices.contains(1) ? components[1] : ""
            let state = components.indices.contains(2) ? components[2] : ""
            let stateAbbr = stateAbbreviations[state] ?? state
            return (street, "\(city), \(stateAbbr)")
        }

        if components.count >= 1 {
            let city = components.indices.contains(0) ? components[0] : ""
            let fullState = components.indices.contains(1) ? components[1] : ""
            let stateAbbr = stateAbbreviations[fullState] ?? fullState
            return (nil, "\(city), \(stateAbbr)")
        }

        return (nil, "No location available")
    }
}

private struct VisitImpactDateRow: View {
    let item: VisitLog
    let reviewStatus: VisitImpactReviewStatus?

    var body: some View {
        HStack {
            Image("Clock")
                .font(.system(size: 14))
                .foregroundColor(.black)
                .padding(.trailing, -5)

            Text(
                "\(item.whenVisit.formatted(date: .abbreviated, time: .omitted)) | \(item.whenVisit.formatted(date: .omitted, time: .shortened))"
            )
            .font(.system(size: 13))
            .lineLimit(1)
            .layoutPriority(1)

            VisitImpactStatusArea(reviewStatus: reviewStatus)
        }
        .padding(.top, -8)
        .padding(.leading, 20)
    }
}

private struct VisitImpactStatusArea: View {
    let reviewStatus: VisitImpactReviewStatus?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 3) {
                    if let reviewStatus {
                        VisitImpactStatusBadge(reviewStatus: reviewStatus)
                    }
                }
                .offset(y: 15)
            }
            .position(x: geo.size.width / 2, y: 0)
        }
        .frame(height: 50)
    }
}

private struct VisitImpactStatusBadge: View {
    let reviewStatus: VisitImpactReviewStatus

    var body: some View {
        Text(reviewStatus.title)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.vertical, 2)
            .frame(width: 70)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(reviewStatus.backgroundColor)
            )
    }
}
