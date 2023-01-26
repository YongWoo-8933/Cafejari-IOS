//
//  AdViewModel.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/28.
//

import Foundation
import GoogleMobileAds

@MainActor
final class AdViewModel: ObservableObject {
    @Published var banner: GADBannerView = GADBannerView(adSize: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width))
    
    @Published var interstitial: GADInterstitial = GADInterstitial(adUnitID: AdUnit.interstitial.id)
    @Published var interstitialAdNoticeSecond: Int = 4
    @Published var isInterstitialAdNoticeVisible: Bool = false
    @Published var isInterstitialAdVisible: Bool = false
    
    @Published var rewardedInterstitial: GADRewardedInterstitialAd? = nil
    @Published var isRewardedInterstitialReady: Bool = false
    @Published var isRewardedInterstitialAdVisible: Bool = false
    @Published var isAdWatched: Bool = false
    @Published var onRewardReceive: () -> Void = {}
    
    func loadBanner() {
        self.banner.adUnitID = AdUnit.banner.id
        self.banner.load(GADRequest())
    }
    
    func loadInterstitial() {
        self.interstitial = GADInterstitial(adUnitID: AdUnit.interstitial.id)
        self.interstitial.load(GADRequest())
    }
    
    func showInterstital(willShowInterstitial: @escaping () -> Void) {
        if interstitial.isReady {
            isInterstitialAdNoticeVisible = true
            let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                DispatchQueue.main.async {
                    self.interstitialAdNoticeSecond -= 1
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                willShowInterstitial()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                timer.invalidate()
                self.isInterstitialAdNoticeVisible = false
                self.interstitialAdNoticeSecond = 3
                self.isInterstitialAdVisible = true
            }
        }
    }
    
    func loadRewardedInterstitial() {
        self.isRewardedInterstitialReady = false
        GADRewardedInterstitialAd.load(
            withAdUnitID: AdUnit.reward.id,
            request: GADRequest(),
            completionHandler: { ad, error in
                if let error = error {
                    print(error)
                } else {
                    self.rewardedInterstitial = ad
                    self.isRewardedInterstitialReady = true
                }
            }
        )
    }
    
    func showRewardedInterstitial(
        willShowRewardedInterstitial: @escaping () -> Void,
        onAdWatched: @escaping () -> Void,
        onFail: @escaping () -> Void
    ) {
        if isRewardedInterstitialReady && rewardedInterstitial != nil {
            self.onRewardReceive = onAdWatched
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                willShowRewardedInterstitial()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.isRewardedInterstitialAdVisible = true
            }
        } else {
            onFail()
            self.loadRewardedInterstitial()
        }
    }
}
