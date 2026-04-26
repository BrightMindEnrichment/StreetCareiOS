import SwiftUI

struct VisitImpactProvidedHelpAlert: View {
    @Binding var doNotShowAgain: Bool
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text(NSLocalizedString("providedHelpTitle", comment: ""))
                    .font(.headline)

                Text(NSLocalizedString("providedHelpMessage", comment: ""))
                    .font(.subheadline)
                    .multilineTextAlignment(.center)

                HStack {
                    Button(action: {
                        doNotShowAgain.toggle()
                    }) {
                        Image(systemName: doNotShowAgain ? "checkmark.square" : "square")
                            .foregroundColor(.primary)
                            .font(.system(size: 20))
                    }

                    Text(NSLocalizedString("donotShowAgain", comment: ""))
                        .font(.body)

                    Spacer()
                }
                .padding(.horizontal)

                Divider()
                    .padding(.top, 20)
                    .padding(.horizontal)

                Button("OK", action: onConfirm)
                    .font(.headline)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 10)
                    .foregroundColor(.blue)
                    .clipShape(Capsule())
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            .frame(maxWidth: 300)
        }
    }
}
