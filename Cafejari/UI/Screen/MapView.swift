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
    
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var informationViewModel: InformationViewModel
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    @EnvironmentObject private var adViewModel: AdViewModel
    
    @State private var isMenuButtonOpened = false
    @State private var isAssociatedCafeDescriptionOpened = false
    
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
                        ZStack {
                            if coreState.isLogedIn && coreState.isPermissionChecked {
                                NaverMapView(
                                    markers: $cafeViewModel.markers,
                                    animateToLongDistance: $cafeViewModel.animateToLongDistance,
                                    animateToShortDistance: $cafeViewModel.animateToShortDistance,
                                    startCameraPosition: NMFCameraPosition(
                                        NMGLatLng(
                                            lat: coreState.userLastLocation?.coordinate.latitude ?? Locations.sinchon.cameraPosition.target.lat,
                                            lng: coreState.userLastLocation?.coordinate.longitude ?? Locations.sinchon.cameraPosition.target.lng
                                        ),
                                        zoom: Zoom.medium
                                    ),
                                    closeMenu: { isMenuButtonOpened = false }
                                )
                                .ignoresSafeArea(edges: .top)
                                .task {
                                    if await informationViewModel.isTodayPopUpVisible() && !informationViewModel.isPopUpTriggered {
                                        await informationViewModel.getPopUpNotifications(coreState: coreState)
                                    }
                                }
                            }
                            
                            VStack {
                                HStack {
                                    VStack {
                                        Text("🎉")
                                            .font(.subtitle)
                                        Text("EVENT")
                                            .font(Font.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    if let event = informationViewModel.randomEvent {
                                        Text(event.preview)
                                            .font(.body)
                                            .foregroundColor(.white)
                                    } else {
                                        Text("다양한 이벤트를 확인하고, 포인트를 얻어가세요!")
                                            .font(.body)
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, .large)
                                .frame(height: 52, alignment: .leading)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(.medium)
                                .onTapGesture { coreState.navigate(Screen.Promotion.route) }
                                
                                HStack {
                                    Button {
                                        cafeViewModel.toggleAssociatedCafeMarkersOnlyVisible()
                                        if cafeViewModel.showAssociatedCafeMarkersOnly {
                                            if let associatedCafeDescriptionCloseWork = cafeViewModel.associatedCafeDescriptionCloseWork {
                                                associatedCafeDescriptionCloseWork.cancel()
                                            }
                                            isAssociatedCafeDescriptionOpened = true
                                            cafeViewModel.associatedCafeDescriptionCloseWork = DispatchWorkItem(block: {
                                                isAssociatedCafeDescriptionOpened = false
                                                cafeViewModel.associatedCafeDescriptionCloseWork = nil
                                            })
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: cafeViewModel.associatedCafeDescriptionCloseWork!)
                                        }
                                    } label: {
                                        HStack(spacing: .small) {
                                            Image(cafeViewModel.showAssociatedCafeMarkersOnly ? "reversed_stamp_icon" : "stamp_icon")
                                                .resizable()
                                                .frame(width: 18, height: 18)
                                            Text("제휴카페")
                                                .foregroundColor(cafeViewModel.showAssociatedCafeMarkersOnly ? .white : .black)
                                        }
                                        .padding(.leading, .medium)
                                        .padding(.trailing, .large)
                                        .frame(height: 32)
                                        .background(cafeViewModel.showAssociatedCafeMarkersOnly ? Color.primary : Color.white)
                                        .cornerRadius(16)
                                    }
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(radius: cafeViewModel.showAssociatedCafeMarkersOnly ? 0 : 1)
                                    
                                    Button {
                                        informationViewModel.isOnSaleCafeDialogOpened = true
                                    } label: {
                                        HStack(spacing: .small) {
                                            Image("sale_tag")
                                                .resizable()
                                                .frame(width: 18, height: 18)
                                            Text("할인중인 카페")
                                                .foregroundColor(.black)
                                        }
                                        .padding(.leading, .medium)
                                        .padding(.trailing, .large)
                                        .frame(height: 32)
                                        .background(Color.white)
                                        .cornerRadius(16)
                                    }
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(radius: 1)
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Text("지역")
                                        Image(systemName: "chevron.\(isMenuButtonOpened ? "up" : "down")")
                                            .font(.caption)
                                    }
                                    .padding(.horizontal, .medium)
                                    .frame(height: 32)
                                    .background(Color.white)
                                    .cornerRadius(.medium)
                                    .roundBorder(cornerRadius: .medium, lineWidth: 1, borderColor: isMenuButtonOpened ? .black : .lightGray)
                                    .animation(Animation.easeInOut, value: isMenuButtonOpened)
                                    .onTapGesture { isMenuButtonOpened.toggle() }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                ZStack(alignment: .topLeading) {
                                    VStack {
                                        if isAssociatedCafeDescriptionOpened {
                                            VStack(alignment: .leading, spacing: .medium) {
                                                Text("제휴 카페란?")
                                                    .font(.body.bold())
                                                    .foregroundColor(.primary)
                                                Text("카페자리와 제휴를 맺고\n매장에서 직접 혼잡도 정보를\n제공해주는 카페를 말해요")
                                                    .font(.caption)
                                                    .foregroundColor(.heavyGray)
                                            }
                                            .padding(.large)
                                            .background(Color.white)
                                            .cornerRadius(.medium)
                                            .shadow(radius: 1)
                                        }
                                        
                                        if adViewModel.isInterstitialAdNoticeVisible {
                                            Text("\(adViewModel.interstitialAdNoticeSecond)초 후에 광고가 표시됩니다")
                                                .font(.body.bold())
                                                .foregroundColor(.white)
                                                .padding(.medium)
                                                .background(Color.black.opacity(0.5))
                                                .cornerRadius(.medium)
                                                .offset(x: 0, y: .small)
                                        }
                                    }
                                    .animation(.easeInOut, value: isAssociatedCafeDescriptionOpened)
                                    
                                    HStack(alignment: .top) {
                                        Spacer()
                                        VStack(spacing: 0) {
                                            if isMenuButtonOpened {
                                                ScrollView {
                                                    LazyVStack(spacing: 0) {
                                                        ForEach(Locations.locationList, id: \.name) { location in
                                                            HStack {
                                                                Image("gray_coffee_bean_marker")
                                                                Spacer()
                                                                Text(location.name)
                                                                Spacer()
                                                            }
                                                            .padding(.horizontal, .large)
                                                            .frame(width: 140, height: 48, alignment: .leading)
                                                            .background(Color.white)
                                                            .roundBorder(cornerRadius: 0, lineWidth: 1, borderColor: Color.moreLightGray)
                                                            .onTapGesture {
                                                                isMenuButtonOpened = false
                                                                cafeViewModel.animateToLongDistance = location.cameraPosition
                                                            }
                                                        }
                                                    }
                                                }
                                                .scrollIndicators(.never)
                                                .frame(height: 48 * 4 + 24)
                                                
                                                Divider()
                                                Divider()
                                                
                                                HStack {
                                                    Image(systemName: "plus.circle.fill")
                                                        .foregroundColor(.lightGray)
                                                        .font(.headline)
                                                    Spacer()
                                                    Text("카페 추가하기")
                                                    Spacer()
                                                }
                                                .padding(.horizontal, .large)
                                                .frame(width: 140, height: 48, alignment: .leading)
                                                .background(Color.white)
                                                .roundBorder(cornerRadius: 0, lineWidth: 1, borderColor: Color.moreLightGray)
                                                .onTapGesture {
                                                    isMenuButtonOpened = false
                                                    coreState.navigate(Screen.CafeInquiry.route)
                                                }
                                            }
                                        }
                                        .frame(width: 140, height: isMenuButtonOpened ? 48 * 5 + 24 + 1 : 0, alignment: .top)
                                        .animation(Animation.easeInOut, value: isMenuButtonOpened)
                                        .background(Color.white)
                                        .cornerRadius(.large)
                                        .shadow(radius: 1)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: isMenuButtonOpened ? 48 * 5 + 24 + 1 : 0)
                                    .animation(Animation.easeInOut, value: isMenuButtonOpened)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, .moreLarge)
                            .padding(.vertical, .large)
                            
                            ZStack {
                                VStack(alignment: .trailing) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                            .foregroundColor(.white)
                                            .font(.subtitle.weight(.semibold))
                                    }
                                    .frame(width: 56, height: 56)
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(28)
                                    .onTapGesture {
                                        cafeViewModel.cafeInfoLoading = true
                                        Task {
                                            await cafeViewModel.getCafeInfos(coreState: coreState)
                                        }
                                    }
                                    HStack {
                                        if coreState.isMasterActivated {
                                            Button {
                                                coreState.navigate(Screen.MasterRoom.route)
                                            } label: {
                                                Text("혼잡도 공유 이어서 하기")
                                                    .font(.headline.bold())
                                                    .frame(width: 240, height: 52)
                                                    .foregroundColor(.white)
                                                    .background(Color.primary)
                                                    .cornerRadius(26)
                                            }
                                            .background(Color.white)
                                            .cornerRadius(26)
                                        }
                                        Spacer()
                                        HStack {
                                            Image(systemName: "location.fill")
                                                .foregroundColor(.heavyGray)
                                                .font(.subtitle.weight(.semibold))
                                        }
                                        .frame(width: 56, height: 56)
                                        .background(.white)
                                        .cornerRadius(28)
                                        .shadow(radius: 2)
                                        .onTapGesture {
                                            if let clPosition = coreState.userLastLocation {
                                                cafeViewModel.animateToLongDistance = NMFCameraPosition(
                                                    NMGLatLng(lat: clPosition.coordinate.latitude, lng: clPosition.coordinate.longitude),
                                                    zoom: Zoom.medium
                                                )
                                            } else {
                                                coreState.requestPermissions()
                                            }
                                        }
                                    }
                                }
                                .padding(.moreLarge)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            
                            FullScreenLoadingView(
                                loading: $cafeViewModel.cafeInfoLoading,
                                text: "주변 카페 찾는중.."
                            )
                        }
                        .onChange(of: cafeViewModel.interstitialAdCounter, perform: { newValue in
                            if newValue > 5 {
                                adViewModel.showInterstital(willShowInterstitial: { cafeViewModel.isBottomSheetOpened = false })
                                cafeViewModel.interstitialAdCounter = 0
                            }
                        })
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
                                                MapSheetCafeCrowdedView(isBottomSheetOpened: $cafeViewModel.isBottomSheetOpened)
                                                SecondaryDivider()
                                                MapSheetCafeInfoView(isBottomSheetOpened: $cafeViewModel.isBottomSheetOpened)
                                            }
                                            .padding(.vertical, .large)
                                        } else {
                                            ProgressView()
                                        }
                                    }
                                    .scrollIndicators(.never)
                                    .presentationDetents([.fraction(0.48), .large])
                                }
                                
                                SnackBar(
                                    isSnackBarOpened: $cafeViewModel.isModalSnackBarOpened,
                                    snackBarType: $cafeViewModel.modalSnackBarType,
                                    content: $cafeViewModel.modalSnackBarContent,
                                    onCloseButtonClick: { cafeViewModel.clearModalSnackBar() }
                                )
                                Dialog(
                                    isDialogVisible: $cafeViewModel.isThumbsUpDialogOpened,
                                    positiveButtonText: "빨리 볼게요",
                                    negativeButtonText: "그냥 추천할래요",
                                    onPositivebuttonClick: {
                                        adViewModel.showRewardedInterstitial(
                                            willShowRewardedInterstitial: { cafeViewModel.isBottomSheetOpened = false },
                                            onAdWatched: {
                                                Task {
                                                    await cafeViewModel.thumbsUp (
                                                        coreState: coreState,
                                                        recentLogId: cafeViewModel.thumbsUpRecentLog.id,
                                                        isAdWatched: true,
                                                        onSuccess: {
                                                            cafeViewModel.isBottomSheetOpened = false
                                                            Task {
                                                                await cafeViewModel.getCafeInfos(coreState: coreState)
                                                            }
                                                        }
                                                    )
                                                }
                                            },
                                            onFail: {
                                                cafeViewModel.showModalSnackBar(
                                                    message: "광고가 준비중입니다. 잠시후에 시도하시거나 일반 추천을 활용해주세요", type: .error)
                                            }
                                        )
                                    },
                                    onNegativebuttonClick: {
                                        Task {
                                            await cafeViewModel.thumbsUp (
                                                coreState: coreState,
                                                recentLogId: cafeViewModel.thumbsUpRecentLog.id,
                                                isAdWatched: false,
                                                onSuccess: {
                                                    cafeViewModel.isBottomSheetOpened = false
                                                    Task {
                                                        await cafeViewModel.getCafeInfos(coreState: coreState)
                                                    }
                                                }
                                            )
                                        }
                                    },
                                    onDismiss: {
                                        cafeViewModel.isThumbsUpDialogOpened = false
                                    }
                                ) {
                                    Text("광고 보고 추천시 ")
                                        .font(.headline)
                                    +
                                    Text("최대 4번")
                                        .font(.headline.bold())
                                    +
                                    Text("\n추천이 가능해요!")
                                        .font(.headline)
                                    +
                                    Text("\n\n*추천시 포인트 지급")
                                        .foregroundColor(.moreHeavyGray)
                                }
                            }
                        }
                        .onChange(of: cafeViewModel.isBottomSheetOpened, perform: { _ in
                            cafeViewModel.isThumbsUpDialogOpened = false
                        })
                        .onChange(of: coreState.selectedBottomBarItem, perform: { tapName in
                            if tapName == BottomTab.Map.name {
                                if !cafeViewModel.cafeInfoRefreshDisabled {
                                    Task {
                                        await cafeViewModel.getCafeInfos(coreState: coreState)
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
                Dialog(
                    isDialogVisible: $coreState.isAutoExpiredDialogOpened,
                    positiveButtonText: "확인",
                    negativeButtonText: "아니오",
                    onPositivebuttonClick: {
                        coreState.tapToProfile()
                        coreState.navigateWithClear(Screen.MasterDetail.route)
                        Task {
                            if let autoExpiredCafeLog = coreState.autoExpiredCafeLog {
                                await cafeViewModel.deleteAutoExpiredCafeLog(
                                    coreState: coreState, autoExpiredCafeLogId: autoExpiredCafeLog.id)
                                coreState.autoExpiredCafeLog = nil
                            }
                        }
                    },
                    onNegativebuttonClick: {
                        Task {
                            if let autoExpiredCafeLog = coreState.autoExpiredCafeLog {
                                await cafeViewModel.deleteAutoExpiredCafeLog(
                                    coreState: coreState, autoExpiredCafeLogId: autoExpiredCafeLog.id)
                                coreState.autoExpiredCafeLog = nil
                            }
                        }
                    },
                    onDismiss: {
                        Task {
                            if let autoExpiredCafeLog = coreState.autoExpiredCafeLog {
                                await cafeViewModel.deleteAutoExpiredCafeLog(
                                    coreState: coreState, autoExpiredCafeLogId: autoExpiredCafeLog.id)
                                coreState.autoExpiredCafeLog = nil
                            }
                        }
                    }
                ) {
                    if let autoExpiredCafeLog = coreState.autoExpiredCafeLog {
                        return Text("\(autoExpiredCafeLog.cafeLog.name) \(autoExpiredCafeLog.cafeLog.floor.toFloor())층\n\n")
                            .font(.headline.bold())
                        + Text("마스터 활동이 ")
                        + Text("\(cafeViewModel.time.parseYearFrom(timeString: autoExpiredCafeLog.time)).\(cafeViewModel.time.parseMonthFrom(timeString: autoExpiredCafeLog.time)).\(cafeViewModel.time.parseDayFrom(timeString: autoExpiredCafeLog.time)) \(cafeViewModel.time.getAMPMHourMinuteStringFrom(timeString: autoExpiredCafeLog.time))")
                            .font(.body.bold())
                        + Text("에\n")
                        + Text("자동 종료되었습니다. 확인하시겠습니까?")
                            .baselineOffset(-.small)
                    } else {
                        return Text("")
                    }
                }
                
                // 세일중인 카페
                OnSaleCafeDialog(moveToConnectedCafe: { cafeInfoId in
                    cafeViewModel.cameraMoveToCafe(cafeInfoId: cafeInfoId)
                })
                
                // 팝업
                PopUpDialog(
                    moveToConnectedCafe: { cafeInfoId in
                        cafeViewModel.cameraMoveToCafe(cafeInfoId: cafeInfoId)
                    },
                    setTodayPopUpDisabled: {
                        informationViewModel.informationRepository.savePopUpDisabledDate()
                    }
                )
                
                // 온보딩
                OnboardingDialog(isDialogVisible: $coreState.isOnboardingDialogOpened)
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
