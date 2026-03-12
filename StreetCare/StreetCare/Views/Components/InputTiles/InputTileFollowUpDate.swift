
import SwiftUI

struct InputTileFollowUpDate: View {

    var questionNumber: Int
    var totalQuestions: Int

    var size = CGSize(width: 360.0, height: 500.0)

    var question1: String
    var question2: String

    var showSkip: Bool = true
    var showProgressBar: Bool = true
    var buttonMode: ButtonMode = .navigation
    var isFollowUpDate: Bool = false
    var initialDateValue: Date = Date()

    @Binding var datetimeValue: Date
    @Binding var convertedDate: Date
    @Binding var additionalDetails: String
    
    var selectedTimeZone: String = TimeZone.current.identifier

    var nextAction: () -> ()
    var skipAction: () -> ()
    var previousAction: () -> ()

    @Environment(\.presentationMode) var presentationMode
    @State private var showSuccessAlert = false
    let placeholderDate = Date(timeIntervalSince1970: 0)

    //  Picker state
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()
    // Computed property to turn the passed string into a TimeZone object
        private var timeZoneObject: TimeZone {
            TimeZone(identifier: selectedTimeZone) ?? .current
        }

    @State private var showDatePicker = false
    @State private var showTimePicker = false

    //  Formatters
    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yyyy"
        return f
    }

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "h:mma"
        f.timeZone = timeZoneObject
        return f
    }

    //  Combine date + time + timezone
    private func syncDateTime() {
        var calendar = Calendar.current
        calendar.timeZone = timeZoneObject
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)

        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        combined.timeZone = timeZoneObject

        if let finalDate = calendar.date(from: combined) {
            datetimeValue = finalDate
        }
    }
    
    private func gmtOffsetString(for tz: TimeZone) -> String {
        let hours = tz.secondsFromGMT() / 3600
        return hours >= 0 ? "GMT+\(hours)" : "GMT\(hours)"
    }

    private var allTimeZones: [(id: String, tz: TimeZone)] {
        TimeZone.knownTimeZoneIdentifiers
            .compactMap { id in
                TimeZone(identifier: id).map { (id, $0) }
            }
            .sorted { $0.id < $1.id }
    }

    var body: some View {
        VStack(spacing: 0) {
            if buttonMode == .update {
                Text("Edit Your Interaction")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 50)
            }

            ZStack(alignment: .top) {
                VStack {
                    if buttonMode == .navigation {
                        HStack {
                            Text(NSLocalizedString("question", comment: "") + " \(questionNumber)/\(totalQuestions)")
                                .foregroundColor(.black)

                            Spacer()

                            if showSkip {
                                Button(NSLocalizedString("skip", comment: "")) {
                                    convertedDate = placeholderDate
                                    skipAction()
                                }
                                .foregroundColor(Color("SecondaryColor"))
                                .font(.footnote)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color.white))
                                .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)

                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.horizontal)
                    }

                    // Title
                    Text(question1)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 6)
                        .padding(.bottom, 6)

                    // Date + Time pills
                    HStack(spacing: 12) {

                        Button {
                            showDatePicker = true
                        } label: {
                            dateTile(
                                icon: "calendar",
                                text: dateFormatter.string(from: selectedDate),
                                width: 157
                            )
                        }
                        .sheet(isPresented: $showDatePicker) {
                            VStack {
                                DatePicker(
                                    "",
                                    selection: $selectedDate,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.wheel)
                                .labelsHidden()

                                Button("Done") {
                                    syncDateTime()
                                    showDatePicker = false
                                }
                                .padding()
                            }
                            .presentationDetents([.medium])
                        }

                        Button {
                            showTimePicker = true
                        } label: {
                            // Custom label to support two lines (Time + GMT)
                            HStack(spacing: 8) {
                                Image(systemName: "clock").foregroundColor(.black)
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(timeFormatter.string(from: selectedTime))
                                        .foregroundColor(.black)
                                    
                                    // Static GMT Offset Label
                                    Text(gmtOffsetString(for: timeZoneObject))
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.black)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .frame(width: 157, height: 42, alignment: .leading) // Height increased for 2 lines
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                        }
                        .sheet(isPresented: $showTimePicker) {
                            VStack(spacing: 16) {
                                Text("Select Time")
                                    .font(.headline)
                                    .padding(.top, 30) // Increased padding here
                                
                                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    // Force the wheel to respect the visit's timezone
                                    .environment(\.timeZone, timeZoneObject)

                                Button("Done") {
                                    syncDateTime()
                                    showTimePicker = false
                                }
                                .padding()
                                .buttonStyle(.borderedProminent)
                            }
                            .presentationDetents([.fraction(0.4)]) // Smaller height since Picker is gone
                        }
                    }
                    .frame(width: 335)
                    .padding(.horizontal)

                    Text(question2)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 12)
                        .padding(.top, 10)

                    // TextEditor
                    TextEditor(text: $additionalDetails)
                        .frame(height: 120)
                        .padding(8)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .cornerRadius(10)
                        .frame(width: 335)
                        .padding(.horizontal)
                        .padding(.top, 12)

                    // Navigation buttons (unchanged)
                    if buttonMode == .navigation {
                        HStack {
                            Button(NSLocalizedString("previous", comment: "")) {
                                previousAction()
                            }
                            .foregroundColor(Color("SecondaryColor"))
                            .font(.footnote)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.white))
                            .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))

                            Spacer()

                            Button(" " + NSLocalizedString("SAVE", comment: "") + " ") {
                                convertedDate = datetimeValue
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
                                convertedDate = datetimeValue
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
                .frame(width: size.width, alignment: .top)
                .background(Color("BackgroundColor"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 0)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 6)
            }
            .frame(width: size.width, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            selectedDate = datetimeValue
            selectedTime = datetimeValue
            // No longer resetting selectedTimeZone to .current
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Interaction Log")
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Updated"),
                message: Text("Interaction log was successfully updated."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }

      /*  if showProgressBar {
            SegmentedProgressBar(
                totalSegments: totalQuestions,
                filledSegments: questionNumber,
                tileWidth: 350
            )
            Text(NSLocalizedString("progress", comment: ""))
                .font(.footnote)
                .padding(.top, 4)
                .fontWeight(.bold)
        }*/
    }

    //  Pill UI
    private func dateTile(icon: String, text: String, width: CGFloat) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.black)

            Text(text)
                .foregroundColor(.black)

            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(width: width, height: 38, alignment: .leading)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 1)
        )
    }
}
