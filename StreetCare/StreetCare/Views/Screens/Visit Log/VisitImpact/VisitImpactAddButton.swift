import SwiftUI

struct VisitImpactAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                NavLinkButton(
                    title: NSLocalizedString("addNew", comment: "") + "+",
                    width: 197.0,
                    height: 40.0
                )
                .clipShape(Capsule())
            }
        }
    }
}
