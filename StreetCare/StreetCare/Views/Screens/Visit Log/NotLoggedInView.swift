import SwiftUI

struct NotLoggedInView: View {
    @State private var showGuestWarning = false
    @State private var navigateToImpact = false
    @Binding var loginRequested: Bool
    @Binding var selection: Int
    var body: some View {
        NavigationStack {
            VStack(spacing: 46) {
                
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                
                Text(LocalizedStringKey("notLoggedInPrompt"))
                    .multilineTextAlignment(.center)
                    .frame(width: 323, height: 140)
                    .font(.custom("Poppins-Light", size: 16))
                
                VStack(spacing: 16) {
                    Button {
                        loginRequested = true
                        selection = 3
                    }
                    label: {
                        Text("Log in")
                            .foregroundColor(Color("PrimaryColor"))
                            .frame(width: 189, height: 40)
                            .background(Color("SecondaryColor"))
                            .clipShape(Capsule())
                    }
                    
                    
                    Button {
                        showGuestWarning = true
                    } label: {
                        Text("Guest")
                            .fontWeight(.bold)              
                            .foregroundColor(.black)
                            .frame(width: 189, height: 40)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }

                  
                    .alert(NSLocalizedString("guestWarningTitle", comment: ""), isPresented: $showGuestWarning) {
                        Button("Cancel") {
                          }
                          Button("OK", role: .cancel) {
                            navigateToImpact = true
                          }
                        
                    } message: {
                        Text(NSLocalizedString("guestWarningMessage", comment: ""))
                    }
                }
                
                // Hidden NavigationLink triggered by the flag
                NavigationLink(
                    destination: VisitImpactView(selection: $selection),
                    isActive: $navigateToImpact
                ) {
                    EmptyView()
                }
            }
            .padding(.top, 10)
            .frame(maxWidth: .infinity)
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct NotLoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        NotLoggedInView(loginRequested: .constant(false), selection: .constant(1))
    }
}
