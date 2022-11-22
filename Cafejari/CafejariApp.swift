//
//  CafejariApp.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import GoogleSignIn

@main
struct CafejariApp: App {
    let dependencies = Dependencies()
    
    @StateObject var coreState = CoreState()
    @StateObject var loginViewModel = LoginViewModel()
    @StateObject var userViewModel = UserViewModel()
    @StateObject var cafeViewModel = CafeViewModel()
    @StateObject var shopViewModel = ShopViewModel()
    @StateObject var informationViewModel = InformationViewModel()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        
    var body: some Scene {
        WindowGroup {
            MapView()
                .font(.body)
                .animation(.easeInOut, value: coreState.isSplashFinished)
                .animation(.easeInOut, value: coreState.isAppInitiated)
                .environmentObject(coreState)
                .environmentObject(loginViewModel)
                .environmentObject(userViewModel)
                .environmentObject(cafeViewModel)
                .environmentObject(shopViewModel)
                .environmentObject(informationViewModel)
                .accentColor(.black)
                .onOpenURL { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        _ = AuthController.handleOpenUrl(url: url)
                    } else {
                        _ = GIDSignIn.sharedInstance.handle(url)
                    }
                }
        }
    }
}
