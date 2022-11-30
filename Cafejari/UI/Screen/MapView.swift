//
//  MapView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/04.
//

import SwiftUI
import UIKit
import GoogleMaps
import CachedAsyncImage
import UserNotifications

struct MapView: View {
    
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var informationViewModel: InformationViewModel
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    @EnvironmentObject private var adViewModel: AdViewModel
    
    @State private var isBottomSheetOpened = false
    @State private var animateTo: GMSCameraPosition? = nil
    @State private var isMenuButtonOpened = false
    @State private var interstitialAdCounter = 0
    
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
            ZStack { GeometryReader { geo in
                NavigationStack(path: $coreState.navigationPath) {
                    TabView(selection: $coreState.selectedBottomBarItem) {
                        // Map tap
                        ZStack {
                            if coreState.isLogedIn && coreState.isPermissionChecked {
                                GoogleMapView(
                                    markerRefreshTrigger: $cafeViewModel.markerRefeshTrigger,
                                    animateTo: $animateTo,
                                    mapType: $coreState.mapType,
                                    startCameraPosition: GMSCameraPosition.camera(
                                        withLatitude: coreState.userLastLocation?.coordinate.latitude ?? GMSCameraPosition.sinchon.target.latitude,
                                        longitude: coreState.userLastLocation?.coordinate.longitude ?? GMSCameraPosition.sinchon.target.longitude,
                                        zoom: Float.zoom.Default.rawValue
                                    ),
                                    onMarkerTap: { cafeInfo in
                                        if cafeInfo.id != cafeViewModel.modalCafeInfo.id {
                                            interstitialAdCounter += 1
                                        }
                                        cafeViewModel.clearModal()
                                        cafeViewModel.getModalCafePlaceInfo(googlePlaceId: cafeInfo.googlePlaceId)
                                        cafeViewModel.modalCafeInfo = cafeInfo
                                        isBottomSheetOpened = true
                                    },
                                    onMarkerInfoWindowTap: {
                                        isBottomSheetOpened = true
                                    },
                                    onCameraChanged: {
                                        isMenuButtonOpened = false
                                    },
                                    onMapTap: {
                                        isMenuButtonOpened = false
                                    }
                                )
                                .ignoresSafeArea(edges: .top)
                            }
                            
                            VStack {
                                HStack {
                                    VStack {
                                        Text("🎉")
                                            .font(.subtitle)
                                        Text("EVENT")
                                            .font(Font.system(size: 10, weight: .bold))
                                            .foregroundColor(.crowdedBlue)
                                    }
                                    if let event = informationViewModel.randomEvent {
                                        Text(event.preview)
                                            .font(.body)
                                    } else {
                                        Text("다양한 이벤트를 확인하고, 포인트를 얻어가세요!")
                                            .font(.body)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, .moreLarge)
                                .frame(height: 52, alignment: .leading)
                                .background(.white)
                                .cornerRadius(.medium)
                                .roundBorder(cornerRadius: .medium, lineWidth: 1.5, borderColor: .lightGray)
                                .onTapGesture { coreState.navigate(Screen.Promotion.route) }
                                
                                HStack {
                                    MapTypeButton(
                                        isSelected: coreState.mapType == .crowded,
                                        text: "👀 혼잡도 확인"
                                    ) {
                                        coreState.mapType = MapType.crowded
                                        cafeViewModel.markerRefeshTrigger = true
                                    }
                                    MapTypeButton(
                                        isSelected: coreState.mapType == .master,
                                        text: "✏️ 혼잡도 공유"
                                    ) {
                                        if coreState.isMasterActivated {
                                            coreState.showSnackBar(message: "마스터 활동중에는 다른 카페의 혼잡도를 공유할 수 없습니다", type: .info)
                                        } else {
                                            coreState.mapType = MapType.master
                                            cafeViewModel.markerRefeshTrigger = true
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Text("지역")
                                        Image(systemName: "chevron.\(isMenuButtonOpened ? "up" : "down")")
                                    }
                                    .padding(.horizontal, .medium)
                                    .frame(height: 32)
                                    .background(Color.white)
                                    .cornerRadius(.medium)
                                    .roundBorder(cornerRadius: .medium, lineWidth: 1.5, borderColor: isMenuButtonOpened ? .black : .lightGray)
                                    .animation(Animation.easeInOut, value: isMenuButtonOpened)
                                    .onTapGesture { isMenuButtonOpened.toggle() }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(alignment: .top) {
                                    if adViewModel.isInterstitialAdNoticeVisible {
                                        Text("\(adViewModel.interstitialAdNoticeSecond)초 후에 광고가 표시됩니다")
                                            .font(.body.bold())
                                            .foregroundColor(.white)
                                            .padding(.medium)
                                            .background(Color.black.opacity(0.5))
                                            .cornerRadius(.medium)
                                            .offset(x: 0, y: .moreLarge)
                                    }
                                    Spacer()
                                    VStack(spacing: 0) {
                                        if isMenuButtonOpened {
                                            ScrollView {
                                                VStack(spacing: 0) {
                                                    MenuItem(text: "신촌역", iconSystemName: "flag.circle.fill") {
                                                        isMenuButtonOpened = false
                                                        animateTo = GMSCameraPosition.sinchon
                                                    }
                                                    MenuItem(text: "홍대입구역", iconSystemName: "flag.circle.fill") {
                                                        isMenuButtonOpened = false
                                                        animateTo = GMSCameraPosition.hongik
                                                    }
                                                    MenuItem(text: "이대역", iconSystemName: "flag.circle.fill") {
                                                        isMenuButtonOpened = false
                                                        animateTo = GMSCameraPosition.ewha
                                                    }
                                                    MenuItem(text: "노량진역", iconSystemName: "flag.circle.fill") {
                                                        isMenuButtonOpened = false
                                                        animateTo = GMSCameraPosition.noryangjin
                                                    }
                                                    MenuItem(text: "광운대역", iconSystemName: "flag.circle.fill") {
                                                        isMenuButtonOpened = false
                                                        animateTo = GMSCameraPosition.kwangWoon
                                                    }
                                                }
                                            }
                                            .scrollIndicators(.never)
                                            .frame(height: 168)
                                            
                                            Divider()
                                            MenuItem(text: "카페 추가하기", iconSystemName: "plus.circle") {
                                                isMenuButtonOpened = false
                                                coreState.navigate(Screen.CafeInquiry.route)
                                            }
                                        }
                                    }
                                    .frame(width: 140, height: isMenuButtonOpened ? 216 : 0, alignment: .top)
                                    .animation(Animation.easeInOut, value: isMenuButtonOpened)
                                    .background(Color.white)
                                    .cornerRadius(.large)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: isMenuButtonOpened ? 216 : 0)
                                .animation(Animation.easeInOut, value: isMenuButtonOpened)
                                
                                Spacer()
                                    
                                if coreState.isMasterActivated {
                                    Button {
                                        coreState.navigate(Screen.MasterRoom.route)
                                    } label: {
                                        Text("혼잡도 공유 이어서 하기")
                                            .font(.headline.bold())
                                            .frame(width: 240, height: 50)
                                            .foregroundColor(.white)
                                            .background(Color.secondary)
                                            .cornerRadius(25)
                                    }
                                    .background(Color.white)
                                    .cornerRadius(25)
                                    .padding(.trailing, 50)
                                }
                            }
                            .padding(.horizontal, .moreLarge)
                            .padding(.vertical, .large)
                            
                            ZStack {
                                HStack {
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
                                }
                                .padding(.vertical, 72)
                                .padding(.horizontal, .large)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            
                            FullScreenLoadingView(
                                loading: $cafeViewModel.cafeInfoLoading,
                                text: "주변 카페 찾는중.."
                            )
                        }
                        .onChange(of: interstitialAdCounter, perform: { newValue in
                            if newValue > 4 {
                                adViewModel.showInterstital(willShowInterstitial: { isBottomSheetOpened = false })
                                interstitialAdCounter = 0
                            }
                        })
                        .sheet(isPresented: $isBottomSheetOpened) {
                            ZStack(alignment: .bottom) {
                                ScrollView {
                                    if !cafeViewModel.modalCafeInfo.cafes.isEmpty {
                                        LazyVStack(alignment: .leading, spacing: 0) {
                                            MapSheetCafeCrowdedView(isBottomSheetOpened: $isBottomSheetOpened)
                                            SecondaryDivider()
                                            MapSheetCafeInfoView(isBottomSheetOpened: $isBottomSheetOpened)
                                        }
                                        .padding(.vertical, .large)
                                    } else {
                                        ProgressView()
                                    }
                                }
                                .padding(.top, .large)
                                .scrollIndicators(.never)
                                .presentationDetents([.fraction(coreState.mapType == MapType.crowded ? 0.48 : 0.25), .large])
                                
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
                                            willShowRewardedInterstitial: { isBottomSheetOpened = false },
                                            onAdWatched: {
                                                Task {
                                                    await cafeViewModel.thumbsUp (
                                                        coreState: coreState,
                                                        recentLogId: cafeViewModel.thumbsUpRecentLog.id,
                                                        isAdWatched: true,
                                                        onSuccess: { isBottomSheetOpened = false }
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
                                                onSuccess: { isBottomSheetOpened = false }
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
                        .onChange(of: isBottomSheetOpened, perform: { _ in
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
                            if informationViewModel.events.isEmpty {
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
                        case Screen.ShoppingBag.route:
                            ShoppingBagView()
                        case Screen.PointResult.route:
                            PointResultView()
                        case Screen.PermissionRequest.route:
                            PermissionRequestView()
                        default:
                            EmptyView()
                        }
                    }
                }
                SnackBar(
                    isSnackBarOpened: $coreState.isSnackBarOpened,
                    snackBarType: $coreState.snackBarType,
                    content: $coreState.snackBarContent,
                    onCloseButtonClick: { coreState.clearSnackBar() }
                )
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
                Dialog(
                    isDialogVisible: $coreState.isWelcomeDialogOpened,
                    positiveButtonText: "가이드 보기",
                    negativeButtonText: "바로 시작",
                    onPositivebuttonClick: { coreState.navigate(Screen.GuideGrid.route) },
                    onNegativebuttonClick: {
                        coreState.showSnackBar(message: "가이드북은 프로필 > 사용가이드북 보기에서 언제든지 확인할 수 있어요!", type: .info) },
                    onDismiss: { coreState.showSnackBar(message: "가이드북은 프로필 > 사용가이드북 보기에서 언제든지 확인할 수 있어요!", type: .info) }
                ) {
                    Text("카페자리")
                        .font(.headline.bold())
                    +
                    Text("에 오신것을 환영합니다!!\n")
                        .font(.headline)
                    +
                    Text("가이드를 통해 카페자리를\n")
                        .baselineOffset(-.medium)
                        .font(.body)
                    +
                    Text("200%")
                        .baselineOffset(-.small)
                        .font(.body.bold())
                    +
                    Text(" 활용해보세요!")
                        .baselineOffset(-.small)
                        .font(.body)
                }
            }}
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
