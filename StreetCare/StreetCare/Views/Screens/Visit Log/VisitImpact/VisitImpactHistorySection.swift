import SwiftUI

struct VisitImpactHistorySection: View {
    let history: [VisitLog]
    let publishedLogIDs: Set<String>
    let pendingLogIDs: Set<String>
    let rejectedLogIDs: Set<String>

    var body: some View {
        VStack {
            Text(NSLocalizedString("history", comment: "").uppercased())
                .font(.custom("Poppins-Regular", size: 20))
                .fontWeight(.bold)
                .padding(.top, 8)

            if history.isEmpty {
                Text(NSLocalizedString("noLoggedHistory", comment: ""))
                    .font(.custom("Poppins-Light", size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            } else {
                List(Array(history.enumerated()), id: \.element.id) { index, item in
                    VisitImpactHistoryRow(
                        item: item,
                        index: index,
                        historyCount: history.count,
                        reviewStatus: reviewStatus(for: item.id)
                    )
                    .listRowSeparatorTint(.clear, edges: .all)
                    .listSectionSeparatorTint(.clear, edges: .all)
                }
            }
        }
    }

    private func reviewStatus(for logID: String) -> VisitImpactReviewStatus? {
        if publishedLogIDs.contains(logID) {
            return .published
        }
        if pendingLogIDs.contains(logID) {
            return .pending
        }
        if rejectedLogIDs.contains(logID) {
            return .rejected
        }
        return nil
    }
}
