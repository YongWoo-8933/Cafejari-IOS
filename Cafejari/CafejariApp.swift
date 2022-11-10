//
//  CafejariApp.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import GoogleMaps
import CoreData
import GoogleSignIn

@main
struct CafejariApp: App {
    let kakaoNativeAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
    let dependencies = Dependencies()
    
    @StateObject var coreState = CoreState()
    
    @StateObject var userViewModel = UserViewModel()
    @StateObject var cafeViewModel = CafeViewModel()
    @StateObject var shopViewModel = ShopViewModel()
    @StateObject var informationViewModel = InformationViewModel()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: kakaoNativeAppKey as! String)
    }
        
    var body: some Scene {
        
        WindowGroup {
            MapView()
                .environmentObject(coreState)
                .environmentObject(userViewModel)
                .environmentObject(cafeViewModel)
                .environmentObject(shopViewModel)
                .environmentObject(informationViewModel)
                .accentColor(.black)
                .onOpenURL { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    } else {
                        GIDSignIn.sharedInstance.handle(url)
                    }
                }
        }
    }
}
