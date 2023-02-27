//
//  MapFrameView.swift
//  Cafejari
//
//  Created by 안용우 on 2023/02/25.
//

import SwiftUI
import NMapsMap

struct MapFrameView: View {
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var informationViewModel: InformationViewModel
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    @EnvironmentObject private var adViewModel: AdViewModel
    
    @State private var isMenuButtonOpened = false
    @State private var isRefreshButtonVisible = false
    @State private var isSearchModalOpened = false
    
    var body: some View {
        ZStack {
            if coreState.isLogedIn && coreState.isPermissionChecked {
                NaverMapView(
                    markers: $cafeViewModel.markers,
                    isMarkerUpdateTriggered: $cafeViewModel.isMarkerUpdateTriggered,
                    cameraPosition: $cafeViewModel.cameraPosition,
                    isLongDCameraUpdateTriggered: $cafeViewModel.isLongDCameraUpdateTriggered,
                    isShortDCameraUpdateTriggered: $cafeViewModel.isShortDCameraUpdateTriggered,
                    startCameraPosition: NMFCameraPosition(
                        NMGLatLng(
                            lat: coreState.userLastLocation?.coordinate.latitude ?? Locations.sinchon.cameraPosition.target.lat,
                            lng: coreState.userLastLocation?.coordinate.longitude ?? Locations.sinchon.cameraPosition.target.lng
                        ), zoom: Zoom.medium
                    ),
                    closeMenu: { isMenuButtonOpened = false },
                    onCameraPositionChanged: { cameraPosition in
                        cafeViewModel.lastCameraPosition = cameraPosition
                        if let work = cafeViewModel.hideRefreshCafeInfoWork {
                            work.cancel()
                        }
                        isRefreshButtonVisible = true
                        cafeViewModel.hideRefreshCafeInfoWork = DispatchWorkItem(block: {
                            isRefreshButtonVisible = false
                            cafeViewModel.hideRefreshCafeInfoWork = nil
                        })
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: cafeViewModel.hideRefreshCafeInfoWork!)
                    }
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
                        isSearchModalOpened = true
                    } label: {
                        HStack(spacing: .small) {
                            Image(systemName: "magnifyingglass")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .frame(width: 32, height: 32)
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 1)
                    
                    Button {
                        informationViewModel.sortOnSaleCafesByDistance(coreState: coreState)
                        informationViewModel.isOnSaleCafeDialogOpened = true
                    } label: {
                        HStack(spacing: .small) {
                            Image("discount_tag")
                                .resizable()
                                .frame(width: 16, height: 18)
                            Text("할인중")
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, .large)
                        .frame(height: 32)
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 1)
                    
                    Button {
                        isMenuButtonOpened = false
                        coreState.navigate(Screen.CafeInquiry.route)
                    } label: {
                        HStack(spacing: .small) {
                            Image("stamp_icon")
                                .resizable()
                                .frame(width: 18, height: 18)
                            Text("카페추가")
                        }
                        .padding(.leading, .medium)
                        .padding(.trailing, .large)
                        .frame(height: 32)
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
                    .onTapGesture {
                        isMenuButtonOpened.toggle()
                        isRefreshButtonVisible = false
                        if let work = cafeViewModel.hideRefreshCafeInfoWork {
                            work.cancel()
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                ZStack(alignment: .topLeading) {
                    VStack {
                        if isRefreshButtonVisible {
                            Button {
                                if !cafeViewModel.cafeInfoLoading {
                                    Task {
                                        await cafeViewModel.getNearbyCafeInfos(coreState: coreState)
                                    }
                                }
                            } label: {
                                HStack(spacing: .small) {
                                    Image(systemName: "arrow.clockwise")
                                        .foregroundColor(.primary)
                                        .font(.caption2.bold())
                                    Text(cafeViewModel.cafeInfoLoading ? "카페 정보 로드중.." : "현 지도에서 검색")
                                        .foregroundColor(.primary)
                                        .font(.caption.bold())
                                }
                                .padding(.horizontal, .large)
                                .frame(height: 32)
                                .background(Color.white)
                                .roundBorder(cornerRadius: 16, lineWidth: 2, borderColor: .primary)
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(radius: 1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .animation(.easeInOut, value: isRefreshButtonVisible)
                    .padding(.top, .moreLarge)
                    
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
                                                cafeViewModel.updateCameraPosition(location.cameraPosition) {
                                                    Task {
                                                        await cafeViewModel.getNearbyCafeInfos(
                                                            coreState: coreState,
                                                            cameraPosition: location.cameraPosition
                                                        )
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                .scrollIndicators(.never)
                                .frame(height: 48 * 6 + 24)
                            }
                        }
                        .frame(width: 140, height: isMenuButtonOpened ? 48 * 6 + 24 + 1 : 0, alignment: .top)
                        .animation(Animation.easeInOut, value: isMenuButtonOpened)
                        .background(Color.white)
                        .cornerRadius(.large)
                        .shadow(radius: 1)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: isMenuButtonOpened ? 48 * 6 + 24 + 1 : 0)
                    .animation(Animation.easeInOut, value: isMenuButtonOpened)
                    
                    HStack {
                        if adViewModel.isInterstitialAdNoticeVisible {
                            Text("\(adViewModel.interstitialAdNoticeSecond)초 후 광고가 표시됩니다")
                                .foregroundColor(.white)
                                .padding(.large)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(.medium)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .animation(.easeInOut, value: adViewModel.isInterstitialAdNoticeVisible)
                }
                Spacer()
            }
            .padding(.horizontal, .moreLarge)
            .padding(.vertical, .large)
            
            ZStack {
                VStack(alignment: .trailing) {
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
                                cafeViewModel.updateCameraPosition( NMFCameraPosition(
                                    NMGLatLng(lat: clPosition.coordinate.latitude, lng: clPosition.coordinate.longitude),
                                    zoom: Zoom.medium
                                )) {
                                    Task {
                                        await cafeViewModel.getNearbyCafeInfos(
                                            coreState: coreState,
                                            cameraPosition: NMFCameraPosition(
                                                NMGLatLng(lat: clPosition.coordinate.latitude, lng: clPosition.coordinate.longitude),
                                                zoom: Zoom.small
                                            )
                                        )
                                    }
                                }
                            } else {
                                coreState.requestPermissions()
                            }
                        }
                    }
                }
                .padding(.moreLarge)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                
                SearchModal(isSeachModalOpened: $isSearchModalOpened)
            }
        }
    }
}
