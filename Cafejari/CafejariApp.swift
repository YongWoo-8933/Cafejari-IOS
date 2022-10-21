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

@main
struct CafejariApp: App {
    let kakaoNativeAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
    let dependencies = Dependencies()
    
    @StateObject var coreState = CoreState()
    @StateObject var master = Master()
    
    @StateObject var userViewModel = UserViewModel()
    @StateObject var shopViewModel = ShopViewModel()
    @StateObject var informationViewModel = InformationViewModel()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: kakaoNativeAppKey as! String)
    }
        
    var body: some Scene {
        
        WindowGroup {
            if coreState.isSplashFinished {
                HomeView()
                    .environmentObject(coreState)
                    .environmentObject(master)
                    .environmentObject(userViewModel)
                    .environmentObject(shopViewModel)
                    .environmentObject(informationViewModel)
                    .accentColor(.black)
                    .onOpenURL(perform: { url in
                        if (AuthApi.isKakaoTalkLoginUrl(url)) {
                            AuthController.handleOpenUrl(url: url)
                        }
                    })
            }else{
                SplachView()
                    .onAppear{
                        Task {
                            try await userViewModel.appInit(coreState: coreState)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                            coreState.isSplashFinished.toggle()
                        }
                    }
            }
        }
    }
}
