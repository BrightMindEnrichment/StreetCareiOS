import SwiftUI

struct YellowGreenToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? Color(red: 0.09, green: 0.25, blue: 0.21) : Color(UIColor.systemGray5))
                    .frame(width: 51, height: 31)

                Circle()
                    .fill(configuration.isOn ? Color.yellow : Color.white)
                    .frame(width: 27, height: 27)
                    .offset(x: configuration.isOn ? 10 : -10)
                    .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                    .shadow(radius: 1)
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}
