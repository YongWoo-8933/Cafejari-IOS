//
//  AdBannerView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/11.
//

import Foundation
import SwiftUI
import GoogleMobileAds


struct AdBannerView: UIViewControllerRepresentable {
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        
        let viewController = UIViewController()
        let bannerSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width)
        let banner = GADBannerView(adSize: bannerSize)
        banner.rootViewController = viewController
        viewController.view.addSubview(banner)
        viewController.view.frame = CGRect(origin: .zero, size: bannerSize.size)
        banner.adUnitID = AdUnit.banner.id
        banner.load(GADRequest())
        return viewController
    }
    
    func updateUIViewController(_ viewController: UIViewController, context: Context) {
        
    }
    
    
    
    class Coordinator: NSObject, UINavigationControllerDelegate, GADBannerViewDelegate {
        
        var parent: AdBannerView
        
        init(parent: AdBannerView) {
            self.parent = parent
        }
        
        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("bannerViewDidReceiveAd")
        }
    }
}


