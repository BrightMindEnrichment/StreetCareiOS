//
//  ContentView.swift
//  StreetCare
//
//  Created by Michael on 3/26/23.
//
import SwiftUI

struct LandingScreenView: View {
    @StateObject private var viewModel = LandingScreenViewModel()
    @State private var isBannerVisible = true
    @Binding var shouldDismissAll: Bool
    @State private var showChapterMembershipForm = false

    
    var links: [LinkData] = [
        LinkData(icon: "startNow", title: "startNow", view: AnyView(StartNowView()), iden: 1),
        LinkData(icon: "IconSoap", title: "whatToGive", view: AnyView(WhatToBringView()), iden: 1),
        LinkData(icon: "IconVideo", title: "How-to Videos", view: AnyView(PlaylistsView()), iden: 1),
        LinkData(icon: "IconStreetcare", title: "Donate", view: AnyView(DonateView()), iden: 1)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if viewModel.shouldShowBanner, let banner = viewModel.bannerData {
                        BannerView(
                                viewModel: viewModel,
                                banner: banner,
                                shouldDismissAll: $shouldDismissAll,
                                showChapterMembershipForm: $showChapterMembershipForm
                            )
                    }
                    
                    ScrollView {
                        ImageSliderView()
                        Spacer().frame(height: 30)
                        AppDescriptionView()
                        
                        // Links Section
                        ForEach(links, id: \.id) { link in
                            NavigationLink {
                                link.view
                            } label: {
                                NavigationRowLinkView(link: link)
                                    .padding(EdgeInsets(top: 5.0, leading: 5.0, bottom: 5.0, trailing: 5.0))
                            }
                        }
                    }
                }.onAppear{
                    viewModel.fetchBannerData()
                }
            }
            .padding()
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        LandingScreenView()
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LandingScreenView(shouldDismissAll: .constant(false))
    }
}


struct BannerView: View {
    @ObservedObject var viewModel: LandingScreenViewModel
    let banner: BannerData
    @Binding var shouldDismissAll: Bool
    @Binding var showChapterMembershipForm: Bool

    var body: some View {
        // ─────────────────── Card ───────────────────
        ZStack(alignment: .topTrailing) {

            // MARK: – Text + Button stack
            VStack(alignment: .leading, spacing: 8) {

                // headers & body
                Text(banner.header)
                    .font(.caption).bold()
                    .foregroundColor(.blue)

                Text(banner.subHeader)
                    .font(.title3).bold()

                Text(banner.body)
                    .font(.subheadline)
                    .lineSpacing(4)

                // button pinned to trailing edge, below the body
                HStack {
                    Spacer()      // pushes button to the right
                    Button {
                        showChapterMembershipForm = true
                    } label: {
                        Text("Become a Member")
                            .font(.custom("Poppins-SemiBold", size: 12))
                            .foregroundColor(.yellow)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 28)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0, green: 0.16, blue: 0.145))
                            )
                    }
                }
                .padding(.top, 12)   // gap above button
            }
            .padding()               // inner content padding
            .frame(maxWidth: .infinity, alignment: .leading)

            // MARK: – Close (✕) button
            Button {
                withAnimation { viewModel.dismissBanner() }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding(8)
            }
        }
        // MARK: – Card styling
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 1.0, green: 0.9, blue: 0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)

        // MARK: – Hidden NavigationLink
        .background(
            NavigationLink(
                destination: ChapterMembershipForm(
                    isPresented: $showChapterMembershipForm,
                    shouldDismissAll: $shouldDismissAll
                ),
                isActive: $showChapterMembershipForm
            ) { EmptyView() }
        )
    }
}





//struct BannerView: View {
//    @ObservedObject var viewModel: LandingScreenViewModel
//    let banner: BannerData
//    @Binding var shouldDismissAll: Bool
//    @Binding var showChapterMembershipForm: Bool
//
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            // Banner content + bottom-right button overlay
//            ZStack(alignment: .bottomTrailing) {
//                VStack(alignment: .leading, spacing: 8) {
//                    Text(banner.header)
//                        .font(.caption)
//                        .fontWeight(.bold)
//                        .foregroundColor(.blue)
//                    
//                    Text(banner.subHeader)
//                        .font(.title3)
//                        .fontWeight(.bold)
//                        .foregroundColor(.black)
//                    
//                    Text(banner.body)
//                        .font(.subheadline)
//                        .foregroundColor(.black)
//                        .lineSpacing(4)
//                }
//                .padding(.bottom, 44) // Give room for the button at the bottom
//                
//                // Button at bottom right
//                Button(action: {
//                    showChapterMembershipForm = true
//                }) {
//                    Text("->")
//                        .font(.custom("Poppins-SemiBold", size: 8))
//                        .foregroundColor(.yellow)
//                        .padding(.vertical, 10)
//                        .padding(.horizontal, 28)
//                        .background(
//                            Capsule()
//                                .fill(Color(red: 0, green: 0.16, blue: 0.145))
//                        )
//                }
//                .padding([.bottom, .trailing], 0) //18
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(Color(red: 1.0, green: 0.9, blue: 0.2))
//            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
//            )
//            .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
//
//            // Close button (top right)
//            Button(action: {
//                withAnimation {
//                    viewModel.dismissBanner()
//                }
//            }) {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.gray)
//                    .padding(8)
//            }
//        }
//        // NavigationLink is invisible, for navigation
//        NavigationLink(
//            destination: ChapterMembershipForm(
//                isPresented: $showChapterMembershipForm,
//                shouldDismissAll: $shouldDismissAll
//            ),
//            isActive: $showChapterMembershipForm
//        ) {
//            EmptyView()
//        }
//    }
//}
//





//  --------- working code -------------------

//struct BannerView: View {
//    @ObservedObject var viewModel: LandingScreenViewModel
//    let banner: BannerData
//    @Binding var shouldDismissAll: Bool
//    @Binding var showChapterMembershipForm: Bool
//
//
//    
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            VStack(alignment: .leading, spacing: 8) {
//                Text(banner.header)
//                    .font(.caption)
//                    .fontWeight(.bold)
//                    .foregroundColor(.blue)
//                
//                Text(banner.subHeader)
//                    .font(.title3)
//                    .fontWeight(.bold)
//                    .foregroundColor(.black)
//                
//                Text(banner.body)
//                    .font(.subheadline)
//                    .foregroundColor(.black)
//                    .lineSpacing(4)
//
//                
//                Button(action: {
//                    showChapterMembershipForm = true
//                    print("Become a Member tapped")
//                }) {
//                    Text("Become a Member") // or "Details"
////                        .font(.custom("Poppins-SemiBold", size: 8))
//                        .font(.caption)
//                        .fontWeight(.bold)
//                        .foregroundColor(.yellow)
//                        .padding(.horizontal, 28)
//                        .padding(.vertical, 10)
//                        .background(
//                            Capsule()
//                                .fill(Color(red: 0, green: 0.16, blue: 0.145))
//                        )
//                        .frame(width: 230) // Adjust width as needed for your text
//                }
//                .padding(.top, 6)
//                NavigationLink(
//                    //destination: ChapterMembershipForm(isPresented: $showChapterMembershipForm),
//                    destination: ChapterMembershipForm(
//                                    isPresented: $showChapterMembershipForm,
//                                    shouldDismissAll: $shouldDismissAll
//                                ),
//                    isActive: $showChapterMembershipForm
//                ) {
//                    EmptyView()
//                }
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(Color(red: 1.0, green: 0.9, blue: 0.2))
//            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
//            )
//            .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
//            
//            // Close button
//            Button(action: {
//                withAnimation {
//                    viewModel.dismissBanner()
//                }
//            }) {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.gray)
//                    .padding(8)
//            }
//        }
//    }
//}






//  --------- original code -------------------

//struct BannerView: View {
//    @ObservedObject var viewModel: LandingScreenViewModel
//    let banner: BannerData
//    
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            VStack(alignment: .leading, spacing: 8) {
//                Text(banner.header)
//                    .font(.caption)
//                    .fontWeight(.bold)
//                    .foregroundColor(.blue)
//                
//                Text(banner.subHeader)
//                    .font(.title3)
//                    .fontWeight(.bold)
//                    .foregroundColor(.black)
//                
//                Text(banner.body)
//                    .font(.subheadline)
//                    .foregroundColor(.black)
//                    .lineSpacing(4)
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(Color(red: 1.0, green: 0.9, blue: 0.2))
//            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
//            )
//            .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
//            
//            // Close button
//            Button(action: {
//                withAnimation {
//                    viewModel.dismissBanner()
//                }
//            }) {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.gray)
//                    .padding(8)
//            }
//        }
//    }
//}
