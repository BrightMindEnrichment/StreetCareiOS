//
//  PublicPopupSheetModifier.swift
//  StreetCare
//
//  Created by Shaik Saheer on 24/06/25.
//
import SwiftUI

struct PublicPopupSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let heightRatio: CGFloat
    let sheetContent: () -> SheetContent

    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        sheetContent()
                            .background(Color.white)
                            .cornerRadius(20)
                            .frame(height: geometry.size.height * heightRatio)
                            .shadow(radius: 10)
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: isPresented)
                }
                .background(Color.black.opacity(0.3)
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    isPresented = false
                                })
            }
        }
    }
}

extension View {
    func publicPopupSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        heightRatio: CGFloat = 0.5,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        self.modifier(PublicPopupSheetModifier(isPresented: isPresented, heightRatio: heightRatio, sheetContent: content))
    }
}
