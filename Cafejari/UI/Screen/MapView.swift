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

struct MapView: View {
    
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var informationViewModel: InformationViewModel
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    
    @State private var isBottomSheetOpened = false
    @State private var animateTo: GMSCameraPosition? = nil
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: ".SFProText-Regular", size: 24)!]

        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(Color.white)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        let thumbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
    
    var body: some View {
        if coreState.isSplashFinished && coreState.isAppInitiated {
            ZStack{ GeometryReader { geo in
                NavigationStack(path: $coreState.navigationPath) {
                    TabView(selection: $coreState.selectedBottomBarItem){
                            
                        // Map tap
                        ZStack {
                            GoogleMapView(
                                markerRefreshTrigger: $cafeViewModel.markerRefeshTrigger,
                                animateTo: $animateTo,
                                mapType: $coreState.mapType,
                                startCameraPosition: GMSCameraPosition.camera(
                                    withLatitude: coreState.userLastLocation?.coordinate.latitude ?? GMSCameraPosition.sinchon.target.latitude,
                                    longitude: coreState.userLastLocation?.coordinate.longitude ?? GMSCameraPosition.sinchon.target.longitude,
                                    zoom: GlobalZoom.Default.rawValue
                                ),
                                onMarkerTap: { cafeInfo in
                                    cafeViewModel.clearModal()
                                    cafeViewModel.getModalCafePlaceInfo(googlePlaceId: cafeInfo.googlePlaceId)
                                    cafeViewModel.modalCafeInfo = cafeInfo
                                },
                                onMarkerInfoWindowTap: {
                                    isBottomSheetOpened = true
                                }
                            )
                            .ignoresSafeArea(edges: .top)
                            
                            VStack {
                                HStack(spacing: 8) {
                                    HStack {
                                        VStack {
                                            Image(systemName: "party.popper.fill")
                                            Text("EVENT")
                                                .font(.caption2.bold())
                                        }
                                        Text("이벤트 내용에 대한거")
                                            .font(.body)
                                        Spacer()
                                    }
                                    .padding(8)
                                    .frame(maxHeight: .infinity, alignment: .leading)
                                    .background(.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 1)
                                    .onTapGesture {
                                        coreState.navigate(Screen.Promotion.route)
                                    }
                                    
                                    VStack {
                                        Image(systemName: "plus")
                                        Text("카페추가")
                                            .font(.caption2.bold())
                                    }
                                    .padding(8)
                                    .frame(width: 56, height: 52)
                                    .background(.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 1)
                                    .onTapGesture {
                                        coreState.navigate(Screen.CafeInquiry.route)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .padding(.horizontal, 10)
                                
                                HStack {
                                    if !coreState.isMasterActivated {
                                        Button {
                                            coreState.mapType = MapType.crowded
                                            cafeViewModel.markerRefeshTrigger = true
                                        } label: {
                                            Text("혼잡도확인 MODE")
                                                .font(.subheadline.bold())
                                        }
                                        .padding(8)
                                        .background(.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(coreState.mapType == .crowded ? .black : .clear, lineWidth: 1)
                                        )
                                        .shadow(radius: coreState.mapType == .crowded ? 0 : 1)
                                    }
                                    
                                    Button {
                                        if coreState.isMasterActivated {
                                            coreState.navigate(Screen.MasterRoom.route)
                                        } else {
                                            coreState.mapType = MapType.master
                                            cafeViewModel.markerRefeshTrigger = true
                                        }
                                    } label: {
                                        if coreState.isMasterActivated {
                                            Text("혼잡도 체크 이어하기 >")
                                                .font(.subheadline.bold())
                                        } else {
                                            Text("직접체크 MODE")
                                                .font(.subheadline.bold())
                                        }
                                    }
                                    .padding(8)
                                    .background(.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(coreState.mapType == .master ? .black : .clear, lineWidth: 1)
                                    )
                                    .shadow(radius: coreState.mapType == .master ? 0 : 1)
                                    
                                    Spacer()
                                    
                                    Menu {
                                        Button {
                                            animateTo = GMSCameraPosition.sinchon
                                        } label: {
                                            Image(systemName: "flag.circle.fill")
                                            Text("신촌역")
                                        }
                                        .frame(width: 120)
                                        Button {
                                            animateTo = GMSCameraPosition.kwangWoon
                                        } label: {
                                            Image(systemName: "flag.circle.fill")
                                            Text("광운대역")
                                        }
                                        .frame(width: 120)
                                    } label: {
                                         Text("이동")
                                         Image(systemName: "chevron.down")
                                    }
                                    .padding(8)
                                    .background(.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 10)
                                
                                Spacer()
                                
                                HStack {
                                    RoundButton(
                                        buttonHeight: 48.0,
                                        iconSystemName: "arrow.clockwise",
                                        iconColor: Color.white,
                                        backgroundColor: Color.black.opacity(0.5)
                                    ) {
                                        withAnimation {
                                            cafeViewModel.cafeInfoLoading = true
                                        }
                                        Task {
                                            await cafeViewModel.getCafeInfos(coreState: coreState)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(30)
                            }
                            
                            FullScreenLoadingView(
                                loading: $cafeViewModel.cafeInfoLoading,
                                text: "카페 정보 로드중.."
                            )
                        }
                        .sheet(isPresented: $isBottomSheetOpened){
                            SheetHandle()
                            
                            ScrollView {
                                if !cafeViewModel.modalCafeInfo.cafes.isEmpty {
                                    LazyVStack(spacing: 0) {
                                        MapSheetCafeInfoView(isBottomSheetOpened: $isBottomSheetOpened)
                                        MapSheetCafeCrowdedView(isBottomSheetOpened: $isBottomSheetOpened)
                                        VerticalSpacer(40)
                                        if !cafeViewModel.modalImageMetaData.isEmpty {
                                            Text("위 사진은 google place api에서 제공되며, google map 닉네임 \(cafeViewModel.modalAttributions)에게 저작권이 있습니다. 무단으로 사용 및 배포할 경우 google maps platform 서비스 정책에 따라 책임을 물을 수 있습니다.")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(10)
                                } else {
                                    ProgressView()
                                }
                            }
                            .scrollIndicators(.never)
                        }
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
                CustomDialog(
                    isDialogVisible: $coreState.isAutoExpiredDialogOpened,
                    content: getAutoExpiredDialogContent(log: coreState.autoExpiredCafeLog),
                    positiveButtonText: "확인",
                    negativeButtonText: "아니오",
                    onPositivebuttonClick: {
                        coreState.tapToProfile()
                        coreState.clearStack()
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
                )
            }}
            .task {
                if !coreState.isLogedIn || !coreState.user.authorization {
                    coreState.navigate(Screen.Login.route)
                } else {
                    switch coreState.locationAuthorizationStatus {
                    case .notDetermined:
                        print("요청해야지")
                        coreState.requestLocationPermission()
                    case .restricted:
                        print("제한되면 안되는데")
                        coreState.requestLocationPermission()
                    case .denied:
                        print("거절이라닛")
                        coreState.requestLocationPermission()
                    case .authorizedAlways, .authorizedWhenInUse:
                        print("이게 맞지")
                        coreState.startLocationTracking()
                    default:
                        print("이건 무슨 상황이지")
                    }
                    await cafeViewModel.checkMasterActivated(coreState: coreState)
                }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active && coreState.isLogedIn && !coreState.accessToken.isEmpty && coreState.user.authorization {
                    Task {
                        await cafeViewModel.checkMasterActivated(coreState: coreState)
                    }
                }
            }
        } else {
            SplachView()
        }
    }
    
    private func getAutoExpiredDialogContent(log: AutoExpiredCafeLog?) -> String {
        if let autoExpiredCafeLog = log {
            return "\(autoExpiredCafeLog.cafeLog.name) \(autoExpiredCafeLog.cafeLog.floor.toFloor())층에서의 마스터 활동이 \(cafeViewModel.time.parseYearFrom(timeString: autoExpiredCafeLog.time))년 \(cafeViewModel.time.parseMonthFrom(timeString: autoExpiredCafeLog.time))월 \(cafeViewModel.time.parseDayFrom(timeString: autoExpiredCafeLog.time))일 \(cafeViewModel.time.parseHourFrom(timeString: autoExpiredCafeLog.time)):\(cafeViewModel.time.parseMinuteFrom(timeString: autoExpiredCafeLog.time))에 자동종료되었습니다. 확인하시겠습니까?"
        } else {
            return ""
        }
    }
}
