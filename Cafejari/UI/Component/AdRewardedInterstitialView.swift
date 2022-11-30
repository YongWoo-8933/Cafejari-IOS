//
//  AdRewardView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/29.
//

import Foundation
import SwiftUI
import GoogleMobileAds


struct AdRewardedInterstitialView: UIViewControllerRepresentable {
    
    @EnvironmentObject private var adViewModel: AdViewModel
    @EnvironmentObject private var coreState: CoreState
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(
            onDismissAd: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    if adViewModel.isAdWatched {
                        adViewModel.onRewardReceive()
                    } else {
                        coreState.showSnackBar(message: "광고 시청을 중단하였습니다", type: .info)
                    }
                    adViewModel.isRewardedInterstitialAdVisible = false
                    adViewModel.isAdWatched = false
                    adViewModel.isRewardedInterstitialReady = false
                    adViewModel.loadRewardedInterstitial()
                }
            }
        )
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        adViewModel.rewardedInterstitial?.fullScreenContentDelegate = context.coordinator
        adViewModel.rewardedInterstitial?.present(
            fromRootViewController: viewController,
            userDidEarnRewardHandler: { adViewModel.isAdWatched = true }
        )
        return viewController
    }

    func updateUIViewController(_ viewController: UIViewController, context: Context) {
        if adViewModel.isRewardedInterstitialAdVisible {
            adViewModel.rewardedInterstitial?.fullScreenContentDelegate = context.coordinator
            adViewModel.rewardedInterstitial?.present(
                fromRootViewController: viewController,
                userDidEarnRewardHandler: { adViewModel.isAdWatched = true }
            )
        }
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, GADFullScreenContentDelegate {
        
        let onDismissAd: () -> Void
        
        init(onDismissAd: @escaping () -> Void) {
            self.onDismissAd = onDismissAd
        }
        
        func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
            onDismissAd()
        }
    }
}
