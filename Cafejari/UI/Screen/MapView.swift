//
//  MapView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/04.
//

import SwiftUI
import UIKit
import NMapsMap
import CachedAsyncImage
import UserNotifications
import GooglePlaces

struct MapView: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var informationViewModel: InformationViewModel
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    @EnvironmentObject private var adViewModel: AdViewModel
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.selectionIndicatorTintColor = UIColor(Color.blue)
        appearance.backgroundColor = UIColor(Color.white)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primary)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(Color.primary)]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        if !coreState.isSplashFinished || !coreState.isAppInitiated {
            SplachView()
        } else {
            ZStack {
                NavigationStack(path: $coreState.navigationPath) {
                    TabView(selection: $coreState.selectedBottomBarItem) {
                        // Map tap
                        MapFrameView()
                            .sheet(isPresented: $cafeViewModel.isBottomSheetOpened) {
                                ZStack(alignment: .bottom) {
                                    VStack(spacing: 0) {
                                        VerticalSpacer(.moreLarge)
                                        
                                        // 마커, 카페 이름
                                        HStack(spacing: .large) {
                                            if let place = cafeViewModel.modalCafePlace {
                                                if place.isOpen() == .closed {
                                                    Image("gray_coffee_bean_marker")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 24)
                                                    
                                                    Text(cafeViewModel.modalCafeInfo.name + " (영업종료)")
                                                        .font(.headline.bold())
                                                        .foregroundColor(.lightGray)
                                                } else {
                                                    Image("coffee_bean_marker")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 24)
                                                    
                                                    Text(cafeViewModel.modalCafeInfo.name)
                                                        .font(.headline.bold())
                                                        .foregroundColor(.primary)
                                                }
                                            } else {
                                                Image("coffee_bean_marker")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 24)
                                                
                                                Text(cafeViewModel.modalCafeInfo.name)
                                                    .font(.headline.bold())
                                                    .foregroundColor(.primary)
                                            }
                                            Spacer()
                                        }
                                        .padding(.moreLarge)
                                        
                                        // 내용
                                        ScrollView {
                                            if !cafeViewModel.modalCafeInfo.cafes.isEmpty {
                                                LazyVStack(alignment: .leading, spacing: 0) {
                                                    MapSheetCafeCrowdedView()
                                                    SecondaryDivider()
                                                    MapSheetCafeInfoView()
                                                }
                                                .padding(.vertical, .large)
                                            } else {
                                                ProgressView()
                                            }
                                        }
                                        .scrollIndicators(.never)
                                        .presentationDetents([.fraction(0.48), .large])
                                    }
                                    // sheet에서 동작하는 스낵바
                                    SnackBar(
                                        isSnackBarOpened: $cafeViewModel.isModalSnackBarOpened,
                                        snackBarType: $cafeViewModel.modalSnackBarType,
                                        content: $cafeViewModel.modalSnackBarContent,
                                        onCloseButtonClick: { cafeViewModel.clearModalSnackBar() }
                                    )
                                    // 마스터 추천 다이얼로그
                                    ThumbsUpDialog()
                                }
                            }
                            .onChange(of: cafeViewModel.interstitialAdCounter, perform: { newValue in
                                if newValue > 5 {
                                    print("trigger")
                                    adViewModel.showInterstital(willShowInterstitial: { cafeViewModel.isBottomSheetOpened = false })
                                    cafeViewModel.interstitialAdCounter = 0
                                }
                            })
                            .onChange(of: cafeViewModel.isBottomSheetOpened, perform: { _ in
                                cafeViewModel.isThumbsUpDialogOpened = false
                            })
                            .onChange(of: coreState.selectedBottomBarItem, perform: { tapName in
                                if tapName == BottomTab.Map.name {
                                    if !cafeViewModel.cafeInfoRefreshDisabled {
                                        Task {
                                            await cafeViewModel.getNearbyCafeInfos(coreState: coreState)
                                        }
                                    }
                                }
                            })
                            .task {
                                if informationViewModel.unExpiredEvents.isEmpty && informationViewModel.expiredEvents.isEmpty {
                                    await informationViewModel.getEvents(coreState: coreState)
                                }
                            }
                            .tabItem {
                                Label(
                                    BottomTab.Map.name,
                                    systemImage: BottomTab.Map.SFImage
                                )
                            }
                            .tag(BottomTab.Map.name)
                        
                        
                        // Leaderboard tap
                        LeaderBoardView()
                            .tabItem{
                                Label(
                                    BottomTab.LeaderBoard.name,
                                    systemImage: BottomTab.LeaderBoard.SFImage
                                )
                            }
                            .tag(BottomTab.LeaderBoard.name)
                        
                        
                        // Shop tap
                        ShopView()
                            .tabItem{
                                Label(
                                    BottomTab.Shop.name,
                                    systemImage: BottomTab.Shop.SFImage
                                )
                            }
                            .tag(BottomTab.Shop.name)
                        
                        
                        // Shop tap
                        ProfileView()
                            .tabItem{
                                Label(
                                    BottomTab.Profile.name,
                                    systemImage: BottomTab.Profile.SFImage
                                )
                            }
                            .tag(BottomTab.Profile.name)
                    }
                    .navigationDestination(for: String.self) { value in
                        switch value {
                        case Screen.Login.route:
                            LoginView()
                        case Screen.Auth.route:
                            AuthView()
                        case Screen.MasterRoom.route:
                            MasterRoomView()
                        case Screen.Promotion.route:
                            PromotionView()
                        case Screen.CafeInquiry.route:
                            CafeInquiryView()
                        case Screen.CafeInquiryResult.route:
                            CafeInquiryResultView()
                        case Screen.ProfileEdit.route:
                            ProfileEditView()
                        case Screen.MasterDetail.route:
                            MasterDetailView()
                        case Screen.GuideGrid.route:
                            GuideGridView()
                        case Screen.PatchNote.route:
                            PatchNoteView()
                        case Screen.FAQ.route:
                            FAQView()
                        case Screen.Inquiry.route:
                            InquiryView()
                        case Screen.InquiryAnswer.route:
                            InquiryAnswerView()
                        case Screen.ShoppingBag.route:
                            ShoppingBagView()
                        case Screen.PointResult.route:
                            PointResultView()
                        case Screen.PermissionRequest.route:
                            PermissionRequestView()
                        case Screen.WebView.route:
                            WebView()
                        case Screen.PointHistory.route:
                            PointHistoryView()
                        case Screen.CafeCorrection.route:
                            CafeCorrectionView()
                        default:
                            EmptyView()
                        }
                    }
                }
                // 스낵바
                SnackBar(
                    isSnackBarOpened: $coreState.isSnackBarOpened,
                    snackBarType: $coreState.snackBarType,
                    content: $coreState.snackBarContent,
                    onCloseButtonClick: { coreState.clearSnackBar() }
                )
                
                // 자동종료 다이얼로그
                AutoExpiredLogDialog()
                
                // 세일중인 카페
                OnSaleCafeDialog()
                
                // 팝업
                PopUpDialog()
                
                // 온보딩
                OnboardingDialog()
            }
            .task {
                // 스플래쉬가 끝난 시점에서,
                if !coreState.isLogedIn {
                    // 로그인 안된상태(자동 로그인 실패)라면 로그인 뷰로
                    coreState.navigate(Screen.Login.route)
                } else {
                    // 로그인 된상태라면 권한 체크가 됐는지 확인
                    if !coreState.isPermissionCheckFinished() {
                        coreState.navigate(Screen.PermissionRequest.route)
                    } else {
                        coreState.isPermissionChecked = true
                        coreState.clearStack()
                        await informationViewModel.getOnSaleCafes(coreState: coreState)
                    }
                    await cafeViewModel.checkMasterActivated(coreState: coreState)
                }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active && coreState.isLogedIn && !coreState.accessToken.isEmpty {
                    Task {
                        UIApplication.shared.applicationIconBadgeNumber = 0
                        await cafeViewModel.checkMasterActivated(coreState: coreState)
                    }
                }
            }
        }
    }
}
