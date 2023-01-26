//
//  WebView.swift
//  Cafejari
//
//  Created by 안용우 on 2023/01/14.
//

import SwiftUI
import WebKit
import GoogleMobileAds

struct WebView: View {
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var adViewModel: AdViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                NavigationTitle(
                    title: coreState.webViewTitle,
                    leadingIconSystemName: "chevron.backward",
                    onLeadingIconClick: {
                        coreState.popUp()
                    }
                )
                MainWebView(webViewUrl: $coreState.webViewUrl)
            }
            AdBannerView()
                .frame(width: UIScreen.main.bounds.width, height: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width).size.height)
                .offset(x: 0, y: .moreLarge)
        }
        .navigationBarBackButtonHidden()
        .task {
            adViewModel.loadBanner()
        }
    }
}


struct MainWebView: UIViewRepresentable {
    
    @Binding var webViewUrl: String
    
    func makeUIView(context: Context) -> WKWebView {
        
        guard let url = URL(string: webViewUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            return WKWebView()
        }
        
        let webview = WKWebView()
        webview.load(URLRequest(url: url))
        
        return webview
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<MainWebView>) {
        
    }
}
