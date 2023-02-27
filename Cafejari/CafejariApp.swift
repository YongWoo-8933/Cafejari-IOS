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
import GoogleMobileAds

@main
struct CafejariApp: App {
    let dependencies = Dependencies()
    
    @StateObject var coreState = CoreState()
    @StateObject var loginViewModel = LoginViewModel()
    @StateObject var userViewModel = UserViewModel()
    @StateObject var cafeViewModel = CafeViewModel()
    @StateObject var shopViewModel = ShopViewModel()
    @StateObject var informationViewModel = InformationViewModel()
    @StateObject var adViewModel = AdViewModel()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        
    var body: some Scene {
        WindowGroup {
            GeometryReader { geo in
                ZStack {
                    AdRewardedInterstitialView()
                    
                    AdInterstitialView()
                    
                    MapView()
                        .font(.body)
                        .animation(.easeInOut, value: coreState.isSplashFinished)
                        .animation(.easeInOut, value: coreState.isAppInitiated)
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
                    
                    Dialog(
                        isDialogVisible: $informationViewModel.isMinorUpdateDialogOpened,
                        positiveButtonText: "업데이트",
                        negativeButtonText: "오늘하루보지않기",
                        onPositivebuttonClick: { informationViewModel.navigateToAppstore() },
                        onNegativebuttonClick: { informationViewModel.informationRepository.saveUpdateDisabledDate() },
                        onDismiss: {  }
                    ) {
                        Text("새 업데이트가 있습니다\n")
                            .font(.headline.bold())
                            .foregroundColor(.black)
                        +
                        Text("*업데이트하지 않아도 앱을\n")
                            .font(.body)
                            .foregroundColor(.heavyGray)
                            .baselineOffset(-.medium)
                        +
                        Text("사용하실 수 있습니다")
                            .font(.body)
                            .foregroundColor(.heavyGray)
                    }
                    
                    
                    let width = geo.size.width * 0.75
                    ZStack {
                        ZStack {
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.black.opacity(0.5))
                        .opacity(informationViewModel.isMajorUpdateDialogOpened ? 1 : 0)
                        .onTapGesture {}
                        
                        VStack {
                            VStack(spacing: 0) {
                                Text("앱을 업데이트해주세요")
                                    .font(.headline.bold())
                                    .foregroundColor(.black)
                                VerticalSpacer(.medium)
                                Text("*필수 업데이트가 있습니다")
                                    .font(.caption)
                                    .foregroundColor(.heavyGray)
                                VerticalSpacer(.moreLarge)
                                Text("\(informationViewModel.majorUpdateDialogSecond)초후 자동으로 이동")
                                    .font(.body)
                                    .foregroundColor(.heavyGray)
                            }
                            .padding(.vertical, 25)
                            .padding(.horizontal, .large)
                            
                            HStack(spacing: 0) {
                                Button {
                                    informationViewModel.navigateToAppstore()
                                } label: {
                                    Text("업데이트")
                                        .font(.headline.bold())
                                        .foregroundColor(.white)
                                        .frame(width: width, height: 52)
                                }
                                
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.primary)
                        }
                        .frame(width: width)
                        .background(.white)
                        .cornerRadius(.moreLarge)
                        .shadow(radius: 3)
                        .opacity(informationViewModel.isMajorUpdateDialogOpened ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(.easeInOut, value: informationViewModel.isMajorUpdateDialogOpened)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .environmentObject(adViewModel)
                .environmentObject(coreState)
                .task {
                    await informationViewModel.checkAppVersion()
                    adViewModel.loadInterstitial()
                    adViewModel.loadRewardedInterstitial()
                    adViewModel.loadBanner()
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
