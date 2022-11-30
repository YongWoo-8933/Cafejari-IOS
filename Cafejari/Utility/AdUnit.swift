//
//  AdUnit.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/12.
//

import Foundation

enum AdUnit {
    case banner
    case interstitial
    case reward
    
    var id: String {
        switch self {
//        case .banner: return "ca-app-pub-3940256099942544/2934735716" // test
//        case .interstitial: return "ca-app-pub-3940256099942544/4411468910" // test
//        case .reward: return "ca-app-pub-3940256099942544/6978759866" // test
            
        case .banner: return "ca-app-pub-6775038074316382/2516836833"
        case .interstitial: return "ca-app-pub-6775038074316382/4223972074"
        case .reward: return "ca-app-pub-6775038074316382/4775065018"
        }
    }
}
