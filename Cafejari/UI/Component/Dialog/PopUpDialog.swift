//
//  PopUpDialog.swift
//  Cafejari
//
//  Created by 안용우 on 2023/01/23.
//

import SwiftUI
import CachedAsyncImage

struct PopUpDialog: View {
    
    @EnvironmentObject private var informationViewModel: InformationViewModel
    @EnvironmentObject private var coreState: CoreState
    
    @State private var currentPageIndex = 0
    
    let moveToConnectedCafe: (Int) -> Void
    let setTodayPopUpDisabled: () -> Void
    
    var body: some View {
        let width = UIScreen.main.bounds.size.width * 0.7
        ZStack {
            ZStack {
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black.opacity(0.5))
            .opacity(informationViewModel.popUpNotifications.isEmpty ? 0 : 1)
            .onTapGesture {
                informationViewModel.popUpNotifications.removeAll()
            }
            
            VStack(spacing: 0) {
                if !informationViewModel.popUpNotifications.isEmpty {
                    ZStack(alignment: .top) {
                        VStack(spacing: 0) {
                            TabView(selection: $currentPageIndex) {
                                ForEach(Array(informationViewModel.popUpNotifications.enumerated()), id: \.offset) { index, popUpNotification in
                                    CachedAsyncImage(
                                        url: URL(string: popUpNotification.image),
                                        content: { image in
                                            image
                                                .resizable()
                                                .frame(width: width, height: width)
                                        },
                                        placeholder: {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .heavyGray))
                                                .frame(width: 44, height: 44)
                                        }
                                    )
                                    .tag(index)
                                    .onTapGesture {
                                        if popUpNotification.hasConnectedCafeInfo() {
                                            moveToConnectedCafe(popUpNotification.cafeInfoId)
                                        } else {
                                            coreState.navigateToWebView("자세히 보기", popUpNotification.url)
                                        }
                                        informationViewModel.popUpNotifications.removeAll()
                                    }
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .indexViewStyle(.page(backgroundDisplayMode: .never))
                            .frame(width: width, height: width)
                            
                            HStack(spacing: 0) {
                                Button {
                                    setTodayPopUpDisabled()
                                    informationViewModel.popUpNotifications.removeAll()
                                } label: {
                                    Text("오늘하루보지않기")
                                        .font(.headline.bold())
                                        .foregroundColor(.onPrimary)
                                        .frame(width: width / 2, height: 54)
                                }
                                
                                Button {
                                    informationViewModel.popUpNotifications.removeAll()
                                } label: {
                                    Text("닫기")
                                        .font(.headline.bold())
                                        .foregroundColor(.white)
                                        .frame(width: width / 2, height: 54)
                                }
                            }
                            .background(Color.primary)
                        }
                        
                        HStack(spacing: .small) {
                            ForEach(Array(informationViewModel.popUpNotifications.enumerated()), id: \.offset) { index, popUpNotification in
                                if currentPageIndex == index {
                                    Image("stamp_icon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: .moreLarge)
                                } else {
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: .medium)
                                        .foregroundColor(.gray.opacity(0.75))
                                }
                            }
                        }
                        .animation(.easeInOut, value: currentPageIndex)
                        .padding(.small)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(16)
                        .padding(.top, .medium)
                    }
                }
            }
            .frame(width: width, height: width + 54)
            .background(.white)
            .cornerRadius(.moreLarge)
            .shadow(radius: 3)
            .opacity(informationViewModel.popUpNotifications.isEmpty ? 0 : 1)
        }
        .edgesIgnoringSafeArea(.all)
        .animation(.easeInOut, value: !informationViewModel.popUpNotifications.isEmpty)
    }
    
}

