//  Created by Saheer on 01/15/26.

import SwiftUI

// MARK: - Model (lightweight UI model)
struct IndividualInteractionItem: Identifiable {
    let id = UUID()
    var title: String

    // person fields
    var firstName: String
    var lastName: String

    // categories/details
    var helpProvidedCategory: [String]
    var furtherHelpCategory: [String]
    var additionalDetails: String

    // optional follow up
    var followUpTimestamp: Date
}

// MARK: - Tile

struct InputTileIndividualInteractionsSummary: View {

    // Progress header
    var questionNumber: Int
    var totalQuestions: Int

    // Size similar to your other tiles
    var size: CGSize = CGSize(width: 360, height: 500)

    // Header text
    var headerTitle: String = "Individual Interaction"
    var bigTitle: String = "Individual Interactions"

    // List data
    @Binding var interactions: [IndividualInteractionItem]

    // Actions
    var previousAction: () -> Void
    var nextAction: () -> Void

    /// Called when user taps "+ Add More"
    var addMoreAction: () -> Void

    /// Called when user taps edit pencil on a row
    var editAction: (_ item: IndividualInteractionItem, _ index: Int) -> Void

    /// Called when user taps red X on a row
    var deleteAction: (_ item: IndividualInteractionItem, _ index: Int) -> Void

    // UI toggles
    var showProgressBar: Bool = true
    var showQuestionHeader: Bool = false   // screenshot 3 doesn’t show “Question x/y” inside tile
    var showTopClose: Bool = true          // the red close in header area

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(spacing: 0) {

            ZStack {
                BasicTile(size: size)

                VStack(spacing: 0) {

                    // Top bar (matches your screenshot style: title centered, close on left)
                    HStack {
                        if showTopClose {
                            Button {
                                // Close the whole flow
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.red)
                            }
                        } else {
                            Spacer().frame(width: 24)
                        }

                        Spacer()

                        Text(headerTitle)
                            .font(.headline)
                            .foregroundColor(.black)

                        Spacer()

                        // symmetry spacer so title stays centered
                        Spacer().frame(width: 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal, 12)
                        .padding(.top, 6)

                    // Optional question header (off by default to match screenshot 3)
                    if showQuestionHeader {
                        HStack {
                            Text("Question \(questionNumber)/\(totalQuestions)")
                                .foregroundColor(.black)
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }

                    // Big Title
                    Text(bigTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 14)
                        .padding(.bottom, 8)

                    // List area
                    VStack(spacing: 10) {

                        if interactions.isEmpty {
                            // Empty state
                            VStack(spacing: 10) {
                                Text("Click “Add More”\nto add Individual Interaction logs")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 20)

                                Button {
                                    addMoreAction()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "plus")
                                        Text("Add More")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(Color.black.opacity(0.75))
                                    .cornerRadius(10)
                                }
                                .padding(.top, 6)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)

                        } else {
                            // Interactions list (scrollable if many)
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 10) {
                                    ForEach(Array(interactions.enumerated()), id: \.element.id) { index, item in
                                        interactionRow(
                                            title: item.title.isEmpty ? "Individual Interaction \(index + 1)" : item.title,
                                            onEdit: { editAction(item, index) },
                                            onDelete: { deleteAction(item, index) }
                                        )
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.top, 4)
                                .padding(.bottom, 8)
                            }
                            .frame(width: 350, height: 205)

                            // Helper text
                            Text("Click “Add More”\nto add Individual Interaction logs")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.top, 2)

                            // Add More
                            Button {
                                addMoreAction()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                    Text("Add More")
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(Color.black.opacity(0.75))
                                .cornerRadius(10)
                            }
                            .padding(.top, 6)

                            // NEXT
                            Button {
                                nextAction()
                            } label: {
                                Text("NEXT")
                                    .font(.headline)
                                    .foregroundColor(Color("PrimaryColor"))
                                    .padding(.horizontal, 26)
                                    .padding(.vertical, 12)
                                    .background(Color("SecondaryColor"))
                                    .clipShape(Capsule())
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal, 8)

                    Spacer(minLength: 0)

                    // Bottom nav buttons (optional; screenshot shows only NEXT, but you can keep Previous)
                    HStack {
                        Button("Previous") {
                            previousAction()
                        }
                        .foregroundColor(Color("SecondaryColor"))
                        .font(.footnote)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.white))
                        .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))

                        Spacer()

                        // If you want “NEXT” only (like screenshot), comment this out
                        // and rely on the big NEXT button above.
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 14)
                }
            }
        }
        .frame(width: size.width, height: size.height)

        // Progress bar (optional)
        if showProgressBar {
            SegmentedProgressBar(
                totalSegments: totalQuestions,
                filledSegments: questionNumber,
                tileWidth: 350
            )
            Text(NSLocalizedString("progress", comment: ""))
                .font(.footnote)
                .padding(.top, 4)
                .fontWeight(.bold)
        }
    }

    // MARK: - Row UI (matches screenshot: dark card, yellow title, pencil + red X)

    private func interactionRow(
        title: String,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) -> some View {

        HStack(spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.yellow)

            Spacer()

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .foregroundColor(.white)
                    .font(.subheadline)
            }

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.subheadline)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color("SecondaryColor"))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black.opacity(0.15), lineWidth: 1)
        )
    }
}
