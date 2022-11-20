//
//  AdFullScreenView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/11.
//

import Foundation
import SwiftUI
import GoogleMobileAds


struct AdFullScreenView: UIViewControllerRepresentable {
    
    @Binding var interstitial: GADInterstitial?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {

        let viewController = UIViewController()
        if let interstitial = self.interstitial {
            interstitial.present(fromRootViewController: viewController)
        }
        return viewController
    }

    func updateUIViewController(_ viewController: UIViewController, context: Context) {
        if let interstitial = self.interstitial {
            interstitial.present(fromRootViewController: viewController)
        }
    }
    
    

    class Coordinator: NSObject, UINavigationControllerDelegate, GADInterstitialDelegate {
        
        let parent: AdFullScreenView
        
        init(parent: AdFullScreenView) {
            self.parent = parent
        }

        func interstitialDidReceiveAd(_ ad: GADInterstitial) {
            
        }
        
        func interstitialDidDismissScreen(_ ad: GADInterstitial) {
            
        }
        
        func interstitialWillDismissScreen(_ ad: GADInterstitial) {
            
        }
        
        func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        }
        
        func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
            
        }
        
        func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
            
        }
        
        func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
            
        }
    }
}
