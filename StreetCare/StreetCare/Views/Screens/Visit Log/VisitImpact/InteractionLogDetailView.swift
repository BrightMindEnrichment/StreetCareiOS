import SwiftUI

struct InteractionLogDetailView: View {
    let log: VisitLog

    var body: some View {
        detailCard
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(Color.white.ignoresSafeArea())
    }

    private var detailCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            infoList
            metricsSection

            if !supportTags.isEmpty {
                InteractionLogTagFlowLayout(horizontalSpacing: 6, verticalSpacing: 6) {
                    ForEach(supportTags, id: \.self) { tag in
                        InteractionLogTagChip(title: tag)
                    }
                }
            }
        }
        .padding(.top, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
    }

    private var header: some View {
        HStack(spacing: 6) {
            Image(systemName: "person.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(InteractionLogDetailStyle.headerIcon)
                .frame(width: 28)

            Text(displayName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.black)

            ZStack {
                Circle()
                    .fill(InteractionLogDetailStyle.verificationBadge)
                    .frame(width: 24, height: 24)

                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }

            Spacer()
        }
    }

    private var infoList: some View {
        VStack(alignment: .leading, spacing: 10) {
            InteractionLogInfoItem(
                iconName: "calendar",
                text: formattedDate
            )
            InteractionLogInfoItem(
                iconName: "mappin.and.ellipse",
                text: cityStateDisplayText
            )
            InteractionLogInfoItem(
                iconName: "phone",
                text: phoneDisplayText
            )
            InteractionLogInfoItem(
                iconName: "clock",
                text: timeRangeDisplayText
            )
            InteractionLogInfoItem(
                iconName: "mappin.and.ellipse",
                text: fullAddressDisplayText
            )
            InteractionLogInfoItem(
                iconName: "envelope",
                text: emailDisplayText
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            InteractionLogMetricRow(title: "People Joined", value: "\(log.numPeopleJoined)")
            InteractionLogMetricRow(title: "Help Request Count", value: "\(log.helpRequestDocIds.count)")
            InteractionLogMetricRow(title: "People Helped", value: "\(peopleHelpedCount)")
            InteractionLogMetricRow(title: "Care Packages Distributed", value: "\(log.carePackagesDistributed)")
        }
    }

    private var displayName: String {
        let fullName = [log.firstname, log.lastname]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        if !fullName.isEmpty {
            return fullName
        }
        if !log.username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return log.username
        }
        return "Interaction Log"
    }

    private var formattedDate: String {
        InteractionLogDetailFormatters.dateFormatter.string(from: log.whenVisit)
    }

    private var timeRangeDisplayText: String {
        let start = InteractionLogDetailFormatters.timeFormatter.string(from: log.whenVisit)
        guard log.whenVisitEnd.timeIntervalSince1970 > 0, log.whenVisitEnd > log.whenVisit else {
            return start
        }

        let end = InteractionLogDetailFormatters.timeFormatter.string(from: log.whenVisitEnd)
        return "\(start) - \(end)"
    }

    private var phoneDisplayText: String {
        let value = log.contactphone.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? "Not provided" : value
    }

    private var emailDisplayText: String {
        let value = log.contactemail.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? "Not provided" : value
    }

    private var peopleHelpedCount: Int {
        if log.peopleHelped > 0 {
            return log.peopleHelped
        }
        return log.numPeopleHelped
    }

    private var supportTags: [String] {
        let directTags = log.listOfSupportsProvided
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if !directTags.isEmpty {
            return directTags
        }

        return log.carePackageContents
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private var addressParts: (street: String, city: String, state: String, zip: String) {
        let fallback = log.whereVisit
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let street = !log.street.isEmpty ? log.street : (fallback.indices.contains(0) ? fallback[0] : "")
        let city = !log.city.isEmpty ? log.city : (fallback.indices.contains(1) ? fallback[1] : "")
        let state = !log.state.isEmpty ? log.state : (fallback.indices.contains(2) ? fallback[2] : "")
        let zip = !log.zipcode.isEmpty ? log.zipcode : (fallback.indices.contains(3) ? fallback[3] : "")

        return (street, city, state, zip)
    }

    private var cityStateDisplayText: String {
        let parts = addressParts
        let city = parts.city
        let state = fullStateName(for: parts.state)
        let values = [city, state].filter { !$0.isEmpty }
        return values.isEmpty ? "Location unavailable" : values.joined(separator: ", ")
    }

    private var fullAddressDisplayText: String {
        let parts = addressParts
        let cityStateZip = [parts.city, abbreviatedState(for: parts.state), parts.zip]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        let addressParts = [parts.street, cityStateZip, "USA"].filter { !$0.isEmpty }
        return addressParts.joined(separator: ", ")
    }

    private func fullStateName(for stateValue: String) -> String {
        guard !stateValue.isEmpty else { return "" }

        let normalized = stateValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if stateAbbreviations[normalized] != nil {
            return normalized
        }

        return stateAbbreviations.first(where: { $0.value.caseInsensitiveCompare(normalized) == .orderedSame })?.key
            ?? normalized
    }

    private func abbreviatedState(for stateValue: String) -> String {
        guard !stateValue.isEmpty else { return "" }

        let normalized = stateValue.trimmingCharacters(in: .whitespacesAndNewlines)
        return stateAbbreviations[normalized] ?? normalized
    }
}

private struct InteractionLogInfoItem: View {
    let iconName: String
    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(InteractionLogDetailStyle.headerIcon)
                .frame(width: 18)

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .lineSpacing(1)
                .multilineTextAlignment(.leading)
                .layoutPriority(1)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct InteractionLogMetricRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black)
        }
    }
}

private struct InteractionLogTagChip: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(InteractionLogDetailStyle.chipText)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.clear)
            .overlay(
                Capsule()
                    .stroke(InteractionLogDetailStyle.chipBorder, lineWidth: 1.2)
            )
    }
}

private struct InteractionLogTagFlowLayout: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let rows = arrangedRows(for: subviews, availableWidth: proposal.width ?? 320)
        let width = proposal.width ?? rows.map(\.width).max() ?? 0
        let height = rows.last.map { $0.originY + $0.height } ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let rows = arrangedRows(for: subviews, availableWidth: bounds.width)

        for row in rows {
            for element in row.elements {
                subviews[element.index].place(
                    at: CGPoint(x: bounds.minX + element.originX, y: bounds.minY + row.originY),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(width: element.size.width, height: element.size.height)
                )
            }
        }
    }

    private func arrangedRows(for subviews: Subviews, availableWidth: CGFloat) -> [InteractionLogTagRow] {
        guard availableWidth > 0 else { return [] }

        var rows: [InteractionLogTagRow] = []
        var currentRow = InteractionLogTagRow()

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let proposedWidth = currentRow.elements.isEmpty
                ? size.width
                : currentRow.width + horizontalSpacing + size.width

            if proposedWidth > availableWidth, !currentRow.elements.isEmpty {
                rows.append(currentRow)
                currentRow = InteractionLogTagRow()
            }

            let originX = currentRow.elements.isEmpty ? 0 : currentRow.width + horizontalSpacing
            currentRow.elements.append(
                InteractionLogTagElement(index: index, size: size, originX: originX)
            )
            currentRow.width = originX + size.width
            currentRow.height = max(currentRow.height, size.height)
        }

        if !currentRow.elements.isEmpty {
            rows.append(currentRow)
        }

        var currentY: CGFloat = 0
        for rowIndex in rows.indices {
            rows[rowIndex].originY = currentY
            currentY += rows[rowIndex].height + verticalSpacing
        }

        return rows
    }
}

private struct InteractionLogTagRow {
    var elements: [InteractionLogTagElement] = []
    var width: CGFloat = 0
    var height: CGFloat = 0
    var originY: CGFloat = 0
}

private struct InteractionLogTagElement {
    let index: Int
    let size: CGSize
    let originX: CGFloat
}

private enum InteractionLogDetailFormatters {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()

    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }()
}

private enum InteractionLogDetailStyle {
    static let headerIcon = Color(red: 0.55, green: 0.55, blue: 0.57)
    static let verificationBadge = Color(red: 1.0, green: 0.72, blue: 0.20)
    static let chipText = Color(red: 0.30, green: 0.34, blue: 0.42)
    static let chipBorder = Color(red: 0.62, green: 0.64, blue: 0.70)
}

struct InteractionLogDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let log = VisitLog(id: "preview")
        log.firstname = "Monica"
        log.contactphone = "3477191134"
        log.contactemail = "californiachapter@brightmindenrichment.org"
        log.street = "888 C St"
        log.city = "Hayward"
        log.state = "California"
        log.zipcode = "94541"
        log.whereVisit = "888 C St, Hayward, California, 94541"
        log.whenVisit = Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 15, hour: 11, minute: 30)) ?? Date()
        log.whenVisitEnd = Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: log.whenVisit) ?? Date()
        log.numPeopleJoined = 15
        log.peopleHelped = 4
        log.carePackagesDistributed = 15
        log.helpRequestDocIds = ["1", "2", "3"]
        log.listOfSupportsProvided = ["Food and Drink", "Wellness / Emotional Support", "Hygiene Products"]
        log.source = "interactionLog"

        return NavigationStack {
            InteractionLogDetailView(log: log)
        }
    }
}
