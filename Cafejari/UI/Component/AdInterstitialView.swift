//
//  AdFullScreenView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/11.
//

import Foundation
import SwiftUI
import GoogleMobileAds


struct AdInterstitialView: UIViewControllerRepresentable {
    
    @EnvironmentObject private var adViewModel: AdViewModel
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(
            onDismissAd: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    adViewModel.isInterstitialAdVisible = false
                    adViewModel.loadInterstitial()
                }
            }
        )
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        adViewModel.interstitial.present(fromRootViewController: viewController)
        adViewModel.interstitial.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ viewController: UIViewController, context: Context) {
        if adViewModel.isInterstitialAdVisible {
            adViewModel.interstitial.present(fromRootViewController: viewController)
            adViewModel.interstitial.delegate = context.coordinator
        }
    }
    
    

    class Coordinator: NSObject, UINavigationControllerDelegate, GADInterstitialDelegate {
        
        let onDismissAd: () -> Void
        
        init(onDismissAd: @escaping () -> Void) {
            self.onDismissAd = onDismissAd
        }
        
        func interstitialDidDismissScreen(_ ad: GADInterstitial) {
            onDismissAd()
        }
    }
}
