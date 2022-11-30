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
    
    @EnvironmentObject private var adViewModel: AdViewModel
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        adViewModel.banner.rootViewController = viewController
        viewController.view.addSubview(adViewModel.banner)
        viewController.view.frame = CGRect(origin: .zero, size: adViewModel.banner.adSize.size)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        uiViewController.view.addSubview(adViewModel.banner)
        uiViewController.view.frame = CGRect(origin: .zero, size: adViewModel.banner.adSize.size)
    }
}


