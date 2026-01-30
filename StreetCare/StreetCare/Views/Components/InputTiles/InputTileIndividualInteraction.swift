import SwiftUI

struct InputTileIndividualInteraction: View {

    @ObservedObject var log: VisitLog
    
    var questionTitle: String
    var questionNumber: Int
    var totalQuestions: Int
    
    var skipAction: (() -> Void)?
    var previousAction: (() -> Void)?
    var nextAction: (() -> Void)?
    
    var tileWidth: CGFloat = 360
    var tileHeight: CGFloat = 520

    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()
    @State private var selectedTimeZone: TimeZone = .current // Added TimeZone State
    
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    
    let states = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
    
    // List of common US Time Zones for easier selection
    let timeZones: [TimeZone] = [
        TimeZone(identifier: "America/New_York")!,
        TimeZone(identifier: "America/Chicago")!,
        TimeZone(identifier: "America/Denver")!,
        TimeZone(identifier: "America/Phoenix")!,
        TimeZone(identifier: "America/Los_Angeles")!,
        TimeZone(identifier: "America/Anchorage")!,
        TimeZone(identifier: "Pacific/Honolulu")!
    ].sorted { $0.identifier < $1.identifier }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.timeZone = selectedTimeZone // Respect the selected timezone
        return formatter
    }
    
    private func syncDateTimeToLog() {
        var calendar = Calendar.current
        calendar.timeZone = selectedTimeZone // Set calendar to selected timezone
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        
        var combined = DateComponents()
        combined.timeZone = selectedTimeZone
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        
        if let finalDate = calendar.date(from: combined) {
            log.whenVisit = finalDate
        }
    }
    
    private func borderedTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .foregroundColor(.black)
            .padding(.horizontal, 10)
            .frame(height: 38)
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 0.5))
    }
    
    private func dateTile<Content: View>(iconName: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Image(systemName: iconName).foregroundColor(.black)
            content().foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal, 10)
        .frame(height: 38)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 0.5))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("question", comment: "") + " \(questionNumber)/\(totalQuestions)")
                        .foregroundColor(.black)
                   
                }
                Spacer()
                if let skipAction = skipAction {
                    Button("Skip", action: skipAction)
                        .font(.subheadline)
                        .foregroundColor(Color("SecondaryColor"))
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 1))
                }
            }
            Divider()
            
            Group {
                borderedTextField("First Name*", text: $log.recipientFirstName)
                borderedTextField("Last Name", text: $log.recipientLastName)
                borderedTextField("Location or Landmark", text: $log.locationDescription)
            }
            
            HStack(spacing: 12) {
                Menu {
                    ForEach(states, id: \.self) { state in
                        Button(state) { log.state = state }
                    }
                } label: {
                    HStack {
                        Text(log.state.isEmpty ? "State" : log.state)
                            .foregroundColor(log.state.isEmpty ? .gray : .black)
                        Spacer()
                        Image(systemName: "chevron.down").foregroundColor(.black)
                    }
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, minHeight: 38, maxHeight: 38)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 0.5))
                }
                borderedTextField("Zip Code", text: $log.zipcode).keyboardType(.numberPad)
            }
            
            HStack(spacing: 12) {
                // Date Button
                Button(action: { showDatePicker.toggle() }) {
                    dateTile(iconName: "calendar") { Text(dateFormatter.string(from: selectedDate)) }
                }
                .sheet(isPresented: $showDatePicker) {
                    VStack {
                        DatePicker("", selection: $selectedDate, displayedComponents: .date).datePickerStyle(.wheel).labelsHidden()
                        Button("Done") { syncDateTimeToLog(); showDatePicker = false }.padding()
                    }.presentationDetents([.medium])
                }
                
                // Time Button (Now includes Time Zone selection in sheet)
                Button(action: { showTimePicker.toggle() }) {
                    dateTile(iconName: "clock") {
                        Text("\(timeFormatter.string(from: selectedTime)) (\(selectedTimeZone.abbreviation() ?? ""))")
                    }
                }
                .sheet(isPresented: $showTimePicker) {
                    VStack(spacing: 20) {
                        Text("Select Time & Zone").font(.headline).padding(.top)
                        
                        DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                        
                        // Time Zone Picker
                        Picker("Time Zone", selection: $selectedTimeZone) {
                            ForEach(timeZones, id: \.identifier) { zone in
                                Text(zone.identifier.replacingOccurrences(of: "_", with: " ")).tag(zone)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal)
                        
                        Button("Done") { syncDateTimeToLog(); showTimePicker = false }
                            .padding()
                            .buttonStyle(.borderedProminent)
                    }
                    .presentationDetents([.medium])
                }
            }

            
            HStack {
                if let previousAction = previousAction {
                    Button("Previous", action: previousAction)
                        .foregroundColor(Color("SecondaryColor"))
                        .font(.footnote)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.white))
                        .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
                }
                Spacer()
                if let nextAction = nextAction {
                    Button(action: {
                        syncDateTimeToLog()
                        nextAction()
                    }) {
                        Text("Next").fontWeight(.bold)
                            .foregroundColor(Color("PrimaryColor"))
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color("SecondaryColor")))
                    }
                }
            }
        }
        .padding()
        .frame(width: tileWidth, height: tileHeight)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
