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
            case .banner: return "ca-app-pub-3940256099942544/2934735716"
            case .interstitial: return "ca-app-pub-3940256099942544/4411468910"
            case .reward: return "ca-app-pub-3940256099942544/1712485313"
            }
        }
}
