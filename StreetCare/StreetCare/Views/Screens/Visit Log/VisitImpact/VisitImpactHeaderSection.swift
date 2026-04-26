import SwiftUI

struct VisitImpactHeaderSection: View {
    let peopleHelped: Int
    let outreaches: Int
    let itemsDonated: Int

    var body: some View {
        VStack {
            Text(NSLocalizedString("interactionLog", comment: "").uppercased())
                .font(.system(size: 18, weight: .bold))
                .padding()
            ImpactView(
                peopleHelped: peopleHelped,
                outreaches: outreaches,
                itemsDonated: itemsDonated
            )
        }
    }
}
