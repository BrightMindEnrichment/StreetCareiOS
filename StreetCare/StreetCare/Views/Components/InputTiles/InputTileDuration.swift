import SwiftUI

struct InputTileDuration: View {
    var questionNumber: Int
    var totalQuestions: Int
    
    //var size = CGSize(width: 350.0, height: 320.0)
    var tileWidth: CGFloat
    var tileHeight: CGFloat
    var questionLine1: String
    var questionLine2: String
    var questionLine3: String
    
    
    @Binding var hours: Int
    @Binding var minutes: Int

    
    var nextAction: () -> ()
    var previousAction: () -> ()
    var skipAction: () -> ()
    var buttonMode: ButtonMode = .navigation
    @Environment(\.presentationMode) var presentationMode
    @State private var showSuccessAlert = false
    
    var body: some View {
        ZStack {
            BasicTile(size: CGSize(width: tileWidth, height: tileHeight))
            
            VStack {
                if buttonMode == .navigation {
                    HStack {
                        Text("Question \(questionNumber)/\(totalQuestions)")
                            .foregroundColor(.black)
                        Spacer()
                        Button("Skip") {
                            skipAction()
                        }
                        .foregroundColor(Color("SecondaryColor"))
                        .font(.footnote)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.white))
                        .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
                    }
                    .padding(.horizontal)

                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal)
                }
                
                VStack {
                        Text(questionLine1)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 6)
                        Text(questionLine2)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(questionLine3)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.bottom, 12)
                    }

                HStack(spacing: 16) {
                    CustomDropdown(title: "Hours", selection: $hours, options: Array(0..<13).reversed())
                    CustomDropdown(title: "Minutes", selection: $minutes, options: Array(0..<61).reversed())
                }
                .padding(.horizontal)
                .padding()

                if buttonMode == .navigation {
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

                        Button(" Next  ") {
                            nextAction()
                        }
                        .foregroundColor(Color("PrimaryColor"))
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color("SecondaryColor")))
                    }
                    .padding()
                } else if buttonMode == .update {
                    HStack {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(Color("SecondaryColor"))
                        .font(.footnote)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.white))
                        .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))

                        Spacer()

                        Button("Update") {
                            showSuccessAlert = true
                            nextAction()
                        }
                        .foregroundColor(Color("PrimaryColor"))
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color("SecondaryColor")))
                    }
                    .padding()
                }
            }
        }
        .frame(width: tileWidth, height: tileHeight)
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Updated"),
                message: Text("Time spent on outreach was successfully updated."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }

        if buttonMode == .navigation {
            SegmentedProgressBar(
                totalSegments: totalQuestions,
                filledSegments: questionNumber,
                tileWidth: 350
            )

            Text("Progress")
                .font(.footnote)
                .fontWeight(.bold)
                .padding(.top, 4)
        }
    }
}
struct CustomDropdown: View {
    var title: String
    @Binding var selection: Int
    var options: [Int]

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selection = option // Correct binding to ensure selection updates
                }) {
                    Text("\(option)")
                }
            }
        } label: {
            HStack {
                Text(selection == -1 ? title : "\(selection)")
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.black)
            }
            .padding(.horizontal)
            .frame(width: 139, height: 43)
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
            .cornerRadius(8)
        }
    }
}


struct InputTileDuration_Previews: PreviewProvider {
    @State static var hours = -1
    @State static var minutes = -1

    static var previews: some View {
        InputTileDuration(
            questionNumber: 1,
            totalQuestions: 7,
            tileWidth: 360,
            tileHeight: 361,
            questionLine1: "How much time did",
            questionLine2: "you spend on the",
            questionLine3: "outreach?",
            hours: $hours,
            minutes: $minutes
        ) {
            // next
        } previousAction: {
            // previous
        } skipAction: {
            // skip
        }
    }
}
