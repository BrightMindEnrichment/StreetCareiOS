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
    
    var links: [LinkData] = [
        LinkData(icon: "startNow", title: "startNow", view: AnyView(StartNowView()), iden: 1),
        LinkData(icon: "IconSoap", title: "whatToGive", view: AnyView(WhatToBringView()), iden: 1),
        LinkData(icon: "IconVideo", title: "howToVideos", view: AnyView(PlaylistsView()), iden: 1),
        LinkData(icon: "IconStreetcare", title: "donate", view: AnyView(DonateView()), iden: 1)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if viewModel.shouldShowBanner, let banner = viewModel.bannerData {
                        BannerView(viewModel: viewModel, banner: banner)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LandingScreenView()
    }
}


struct BannerView: View {
    @ObservedObject var viewModel: LandingScreenViewModel
    let banner: BannerData
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                Text(banner.header)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text(banner.subHeader)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text(banner.body)
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .lineSpacing(4)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 1.0, green: 0.9, blue: 0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
            
            // Close button
            Button(action: {
                withAnimation {
                    viewModel.dismissBanner()
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding(8)
            }
        }
    }
}
