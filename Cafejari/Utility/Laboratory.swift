//
//  Laboratory.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/04.
//

import Foundation
import SwiftUI
import UIKit
import GooglePlaces

struct Laboratory: View {
    
    @State private var isGooglePlaceSearchOpened = false
    @State private var googlePlaceSearchAddress = ""
    
    var body: some View {
        GooglePlacePicker(
            address: $googlePlaceSearchAddress,
            onSearchResult: { place in
//                if let searchCafeInfo = cafeViewModel.getCafeInfoFromPlace(place: place) {
//                    cafeViewModel.clearUserMapModal()
//                    cafeViewModel.getModalCafePlaceInfo(googlePlaceId: searchCafeInfo.googlePlaceId)
//                    cafeViewModel.userMapModalCafeIndex = 0
//                    cafeViewModel.userMapModalCafeInfo = searchCafeInfo
//
//                    animateTo = GMSCameraPosition.camera(
//                        withLatitude: place.coordinate.latitude,
//                        longitude: place.coordinate.longitude,
//                        zoom: GlobalZoom.Large.rawValue
//                    )
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
//                        isBottomSheetOpened = true
//                    }
//                } else {
//
//                }
            }
        )
    }
}

struct GooglePlacePicker: UIViewControllerRepresentable {

    @Environment(\.presentationMode) var presentationMode
    @Binding var address: String
    let onSearchResult: (GMSPlace) -> Void
    
    func makeCoordinator() -> GooglePlacesCoordinator {
        GooglePlacesCoordinator(parent: self, onSearchResult: onSearchResult)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<GooglePlacePicker>) -> GMSAutocompleteViewController {

        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = context.coordinator
        

        let fields: GMSPlaceField = GMSPlaceField(
            rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue)
        )
        
        autocompleteController.placeFields = fields

        let filter = GMSAutocompleteFilter()
        filter.locationBias = GMSPlaceRectangularLocationOption (
            CLLocationCoordinate2D(latitude: 37.748887, longitude: 127.418066),
            CLLocationCoordinate2D(latitude: 37.338261, longitude: 126.549068)
        )
        autocompleteController.autocompleteFilter = filter
        return autocompleteController
    }

    func updateUIViewController(_ uiViewController: GMSAutocompleteViewController, context: UIViewControllerRepresentableContext<GooglePlacePicker>) {
    }
    
    

    class GooglePlacesCoordinator: NSObject, UINavigationControllerDelegate, GMSAutocompleteViewControllerDelegate {

        var parent: GooglePlacePicker
        var onSearchResult: (GMSPlace) -> Void

        init(parent: GooglePlacePicker, onSearchResult: @escaping (GMSPlace) -> Void) {
            self.parent = parent
            self.onSearchResult = onSearchResult
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
            DispatchQueue.main.async {
                self.parent.address =  place.name!
                self.parent.presentationMode.wrappedValue.dismiss()
                self.onSearchResult(place)
            }
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
            print("Error: ", error.localizedDescription)
        }

        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }

    }
}

//struct HomeMapView: View {
//
//    @Environment(\.openURL) private var openURL
//    @Environment(\.scenePhase) var scenePhase
//
//    @EnvironmentObject private var coreState: CoreState
//    @EnvironmentObject private var informationViewModel: InformationViewModel
//    @EnvironmentObject private var cafeViewModel: CafeViewModel
//    @EnvironmentObject private var shopViewModel: ShopViewModel
//
//    @State private var isMenuOpened = false
//    @State private var selectedEventTabIndex = 0
//
//    init() {
//        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: "Georgia-Bold", size: 25)!]
//
//        let appearance = UITabBarAppearance()
//        appearance.backgroundColor = UIColor(Color.red)
//
//        UITabBar.appearance().standardAppearance = appearance
//        UITabBar.appearance().scrollEdgeAppearance = appearance
//    }
//
//    var body: some View {
//        if coreState.isSplashFinished && coreState.isAppInitiated {
//            ZStack{ GeometryReader { geo in
//                NavigationStack(path: $coreState.navigationPath) {
//                    TabView(selection: $coreState.selectedBottomBarItem){
//                        UserMapView()
//                            .tabItem{
//                                Label(
//                                    BottomTab.UserMap.name,
//                                    systemImage: BottomTab.UserMap.SFImage
//                                )
//                                .disabled(true)
//                            }
//                            .tag(BottomTab.UserMap.name)
//
//                        ScrollView{
//                            ZStack {
//                                TabView(selection: $selectedEventTabIndex) {
//                                    Image("banner_default")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .tag(0)
//                                        .onTapGesture {
//                                            coreState.navigate(Screen.GuideGrid.route)
//                                        }
//                                    ForEach(
//                                        Array(informationViewModel.events.enumerated()), id: \.offset
//                                    ) { index, event in
//                                        CachedAsyncImage(
//                                            url: URL(string: event.image),
//                                            content: { image in
//                                                image
//                                                    .resizable()
//                                                    .scaledToFit()
//                                                    .onTapGesture {
//                                                        openURL(URL(string: event.url)!)
//                                                    }
//                                            },
//                                            placeholder: {
//                                                ProgressView()
//                                            }
//                                        )
//                                        .tag(index + 1)
//                                    }
//                                }
//                                .tabViewStyle(.page)
//                                .indexViewStyle(.page(backgroundDisplayMode: .never))
//                                .frame(height: 135)
//
//                                VStack {
//                                    NavigationLink{
//                                        PromotionView()
//                                    } label: {
//                                        Text("\(selectedEventTabIndex + 1) / \(informationViewModel.events.count + 1) 모두보기")
//                                            .foregroundColor(.white)
//                                            .padding(9)
//                                            .background(.black.opacity(0.5))
//                                            .cornerRadius(15)
//                                            .frame(height: 30)
//                                    }
//                                    .padding(15)
//                                }
//                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
//                            }
//
//                            LazyVStack(alignment: .leading){
//                                HStack {
//                                    Image("stamp_icon")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 20)
//                                    Text("오늘의 TIP")
//                                        .font(.system(.title3, design: .rounded))
//                                        .fontWeight(.semibold)
//                                    Spacer()
//                                }
//                                .padding([.horizontal, .top], 15)
//
//                                if !informationViewModel.isRandomTipLoading {
//                                    Text(informationViewModel.randomTip.saying.useNonBreakingSpace())
//                                        .font(.custom("나눔손글씨 다행체", size: 21))
//                                        .padding([.horizontal, .bottom], 15)
//                                }
//
//                                LazyVGrid(
//                                    columns: GridItem(.flexible()).setGridColumn(columns: 2),
//                                    spacing: 10
//                                ) {
//                                    Button{
//                                        coreState.tapToUserMap()
//                                    }label: {
//                                        VStack{
//                                            Image("user_map_btn")
//                                                .resizable()
//                                                .scaledToFit()
//                                                .padding(10)
//                                                .frame(height: 120)
//                                            Text("내 주변 카페")
//                                        }
//                                        .frame(height: 160)
//                                    }
//                                    Button{
//                                        coreState.tapToMasterMap()
//                                    } label: {
//                                        VStack{
//                                            Image("master_map_btn")
//                                                .resizable()
//                                                .scaledToFit()
//                                                .frame(height: 120)
//                                            Text("카페 마스터 하러가기")
//                                        }
//                                        .frame(height: 200)
//                                    }
//                                }
//                                .frame(maxHeight: 250)
//
//                                VStack(alignment: .leading) {
//                                    Text("서비스 지역 안내")
//                                        .font(.system(.title3, design: .rounded))
//                                        .fontWeight(.semibold)
//                                    Divider()
//                                    HStack{
//                                        Text("신촌")
//                                        Text("광운대")
//                                    }
//                                    Text("현재 카페자리는 뭐시기 뭐시기")
//                                }
//                                .padding(15)
//
//                                VStack {
//                                    HStack(alignment: .bottom) {
//                                        Text("포인트 상점")
//                                            .font(.system(.title3, design: .rounded))
//                                            .fontWeight(.semibold)
//                                        Spacer()
//                                        Button {
//                                            shopViewModel.selectedShopCategoty = ""
//                                            coreState.navigate(Screen.Shop.route)
//                                        } label: {
//                                            Text("전체보기 >")
//                                                .foregroundColor(.gray)
//                                                .font(.system(.caption, design: .rounded))
//                                        }
//                                    }
//                                    Divider()
//
//                                    LazyVGrid(
//                                        columns: GridItem(.flexible()).setGridColumn(columns: 3),
//                                        spacing: 10
//                                    ) {
//                                        ForEach(ItemCategory.categories, id: \.name) { itemCategory in
//                                            Button {
//                                                shopViewModel.selectedShopCategoty = itemCategory.name
//                                                coreState.navigate(Screen.Shop.route)
//                                            } label: {
//                                                VStack{
//                                                    Image(itemCategory.image)
//                                                        .resizable()
//                                                        .scaledToFit()
//                                                        .frame(height: 60)
//                                                        .padding(20)
//                                                    Text(itemCategory.name)
//                                                }
//                                            }
//                                            .frame(height: 120)
//                                        }
//                                    }
//
//                                    LazyVGrid(
//                                        columns: GridItem(.flexible()).setGridColumn(columns: 4),
//                                        spacing: 10
//                                    ) {
//                                        ForEach(InformationCategory.categories, id: \.name){ informationCategory in
//                                            Button{
//                                                if(informationCategory.name == "가이드"){
//                                                    coreState.navigate(Screen.GuideGrid.route)
//                                                }else{
//                                                    informationViewModel.selectedInformationCategoty = informationCategory.name
//                                                    coreState.navigate(Screen.Information.route)
//                                                }
//                                            } label:{
//                                                VStack{
//                                                    Image(informationCategory.image)
//                                                        .resizable()
//                                                        .scaledToFit()
//                                                        .padding(20)
//                                                    Text(informationCategory.name)
//                                                }
//                                                .frame(height: geo.size.width / 3)
//                                            }
//                                            .frame(height: 120)
//                                        }
//                                    }
//                                }
//                                .padding(15)
//                            }
//                        }
//                        .scrollIndicators(.never)
//                        .tabItem{
//                            Label(
//                                BottomTab.Home.name,
//                                systemImage: BottomTab.Home.SFImage
//                            )
//                        }
//                        .tag(BottomTab.Home.name)
//
//                        MasterMapView()
//                            .tabItem{
//                                if(cafeViewModel.isMasterActivated){
//                                    Label(
//                                        "마스터룸",
//                                        systemImage: BottomTab.MasterMap.SFImage
//                                    )
//                                }else{
//                                    Label(
//                                        BottomTab.MasterMap.name,
//                                        systemImage: BottomTab.MasterMap.SFImage
//                                    )
//                                }
//                            }
//                            .tag(BottomTab.MasterMap.name)
//                    }
//                    .onChange(of: coreState.selectedBottomBarItem) { newTap in
//                        if(newTap == BottomTab.MasterMap.name && cafeViewModel.isMasterActivated){
//                            coreState.navigate(Screen.MasterRoom.route)
//                        }
//                    }
//                    .navigationBarTitleDisplayMode(.inline)
//                    .navigationTitle("홈")
//                    .toolbar {
//                        ToolbarItem(placement: .navigationBarTrailing) {
//                            Button {
//                                coreState.navigate(Screen.Profile.route)
//                            } label: {
//                                Image(systemName: "person.crop.circle")
//                                    .font(.callout.weight(.bold))
//                            }
//                        }
//                        ToolbarItem(placement: .principal) {
//                            Image("home_logo")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 120)
//                                .padding(10)
//                        }
//                        ToolbarItem(placement: .navigationBarLeading){
//                            Button{
//                                isMenuOpened = true
//                                informationViewModel.deleteSavedRefreshToken()
//                            }label: {
//                                Image(systemName: "line.3.horizontal")
//                                    .font(.callout.weight(.bold))
//                            }
//                        }
//                    }
//                    .navigationBarHidden(coreState.selectedBottomBarItem != BottomTab.Home.name)
//                    .navigationDestination(for: String.self) { value in
//                        switch value {
//                        case Screen.Profile.route:
//                            ProfileView()
//                        case Screen.ProfileEdit.route:
//                            ProfileEditView()
//                        case Screen.Shop.route:
//                            ShopView()
//                        case Screen.ShoppingBag.route:
//                            ShoppingBagView()
//                        case Screen.GuideGrid.route:
//                            GuideGridView()
//                        case Screen.Information.route:
//                            InformationView()
//                        case Screen.Login.route:
//                            LoginView()
//                        case Screen.Auth.route:
//                            AuthView()
//                        case Screen.MasterRoom.route:
//                            MasterRoomView()
//                        default:
//                            EmptyView()
//                        }
//                    }
//                    .accentColor(.black)
//                }
//                EmptyView()
//                    .background(.black.opacity(0.4))
//                    .opacity(isMenuOpened ? 1 : 0)
//                    .animation(.easeInOut, value: isMenuOpened)
//                    .onTapGesture {
//                        isMenuOpened.toggle()
//                    }
//                SnackBar(
//                    isSnackBarOpened: $coreState.isSnackBarOpened,
//                    snackBarType: $coreState.snackBarType,
//                    content: $coreState.snackBarContent,
//                    onCloseButtonClick: { coreState.clearSnackBar() }
//                )
//                CustomDialog(
//                    isDialogVisible: $coreState.isAutoExpiredDialogOpened,
//                    content: getAutoExpiredDialogContent(log: coreState.autoExpiredCafeLog),
//                    positiveButtonText: "확인",
//                    negativeButtonText: "아니오",
//                    onPositivebuttonClick: {
//                        coreState.navigateWithClear(Screen.Profile.route)
//                        coreState.tapToHome()
//                        Task {
//                            do {
//                                if let autoExpiredCafeLog = coreState.autoExpiredCafeLog {
//                                    try await cafeViewModel.deleteAutoExpiredCafeLog(
//                                        coreState: coreState, autoExpiredCafeLogId: autoExpiredCafeLog.id)
//                                    coreState.autoExpiredCafeLog = nil
//                                }
//                            } catch {
//                                print(error.localizedDescription)
//                            }
//                        }
//                    },
//                    onNegativebuttonClick: {
//                        Task {
//                            do {
//                                if let autoExpiredCafeLog = coreState.autoExpiredCafeLog {
//                                    try await cafeViewModel.deleteAutoExpiredCafeLog(
//                                        coreState: coreState, autoExpiredCafeLogId: autoExpiredCafeLog.id)
//                                    coreState.autoExpiredCafeLog = nil
//                                }
//                            } catch {
//                                print(error.localizedDescription)
//                            }
//                        }
//                    },
//                    onDismiss: {
//                        Task {
//                            do {
//                                if let autoExpiredCafeLog = coreState.autoExpiredCafeLog {
//                                    try await cafeViewModel.deleteAutoExpiredCafeLog(
//                                        coreState: coreState, autoExpiredCafeLogId: autoExpiredCafeLog.id)
//                                    coreState.autoExpiredCafeLog = nil
//                                }
//                            } catch {
//                                print(error.localizedDescription)
//                            }
//                        }
//                    }
//                )
//            }}
//            .task {
//                if coreState.isAppInitiated {
//                    if !coreState.isLogedIn || !coreState.user.authorization {
//                        coreState.navigate(Screen.Login.route)
//                    } else {
//                        switch coreState.locationAuthorizationStatus {
//                        case .notDetermined:
//                            print("요청해야지")
//                            coreState.requestLocationPermission()
//                        case .restricted:
//                            print("제한되면 안되는데")
//                            coreState.requestLocationPermission()
//                        case .denied:
//                            print("거절이라닛")
//                            coreState.requestLocationPermission()
//                        case .authorizedAlways, .authorizedWhenInUse:
//                            print("이게 맞지")
//                            coreState.startLocationTracking()
//                        default:
//                            print("이건 무슨 상황이지")
//                        }
//                        do {
//                            try await cafeViewModel.checkMasterActivated(coreState: coreState)
//                        } catch {
//
//                        }
//                    }
//                }
//            }
//            .task {
//                await informationViewModel.getEvents()
//                await informationViewModel.getRandomTip()
//            }
//            .onChange(of: scenePhase) { newPhase in
//                if newPhase == .active && coreState.isLogedIn && !coreState.accessToken.isEmpty && coreState.user.authorization {
//                    Task {
//                        do {
//                            try await cafeViewModel.checkMasterActivated(coreState: coreState)
//                        } catch {
//                            print(error.localizedDescription)
//                        }
//                    }
//                }
//            }
//        } else {
//            SplachView()
//        }
//    }
