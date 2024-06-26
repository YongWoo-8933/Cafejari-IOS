//
//  PromotionView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI
import CachedAsyncImage
import GoogleMobileAds

struct PromotionView: View {
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var informationViewModel: InformationViewModel
    @EnvironmentObject private var adViewModel: AdViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                NavigationTitle(
                    title: "공지 및 이벤트",
                    leadingIconSystemName: "chevron.backward",
                    onLeadingIconClick: {
                        coreState.popUp()
                    }
                )
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(informationViewModel.unExpiredEvents, id: \.id) { event in
                            Button {
                                coreState.navigateToWebView("이벤트 상세", event.url)
                            } label: {
                                ZStack {
                                    VStack(alignment: .leading, spacing: .medium) {
                                        CachedAsyncImage(
                                            url: URL(string: event.image),
                                            content: { image in
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(maxWidth: .infinity)
                                                    .cornerRadius(.medium)
                                            },
                                            placeholder: {
                                                ProgressView()
                                            }
                                        )
                                        VerticalSpacer(.medium)
                                        Text(event.name)
                                            .font(.headline.bold())
                                        Text(event.preview)
                                        Text("\(informationViewModel.time.parseYearFrom(timeString: event.start)).\(informationViewModel.time.parseMonthFrom(timeString: event.start)).\(informationViewModel.time.parseDayFrom(timeString: event.start)) ~ \(informationViewModel.time.parseYearFrom(timeString: event.finish)).\(informationViewModel.time.parseMonthFrom(timeString: event.finish)).\(informationViewModel.time.parseDayFrom(timeString: event.finish))")
                                            .font(.caption)
                                            .foregroundColor(.heavyGray)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.moreLarge)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 240)
                            }
                            Divider()
                        }
                        ForEach(informationViewModel.expiredEvents, id: \.id) { event in
                            Button {
                                coreState.navigateToWebView("이벤트 상세", event.url)
                            } label: {
                                ZStack {
                                    VStack(alignment: .leading, spacing: .medium) {
                                        CachedAsyncImage(
                                            url: URL(string: event.image),
                                            content: { image in
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(maxWidth: .infinity)
                                                    .cornerRadius(.medium)
                                            },
                                            placeholder: {
                                                ProgressView()
                                            }
                                        )
                                        VerticalSpacer(.medium)
                                        Text(event.name)
                                            .font(.headline.bold())
                                        Text(event.preview)
                                        Text("\(informationViewModel.time.parseYearFrom(timeString: event.start)).\(informationViewModel.time.parseMonthFrom(timeString: event.start)).\(informationViewModel.time.parseDayFrom(timeString: event.start)) ~ \(informationViewModel.time.parseYearFrom(timeString: event.finish)).\(informationViewModel.time.parseMonthFrom(timeString: event.finish)).\(informationViewModel.time.parseDayFrom(timeString: event.finish))")
                                            .font(.caption)
                                            .foregroundColor(.heavyGray)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.moreLarge)
                                    
                                    HStack {
                                        Color.black.opacity(0.5)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    Text("종료된 이벤트입니다")
                                        .font(.headline.bold())
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 240)
                            }
                            Divider()
                        }
                        VerticalSpacer(60)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarBackButtonHidden()
            .task {
                if informationViewModel.expiredEvents.isEmpty && informationViewModel.unExpiredEvents.isEmpty {
                    await informationViewModel.getEvents(coreState: coreState)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            AdBannerView()
                .frame(width: UIScreen.main.bounds.width, height: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width).size.height)
                .offset(x: 0, y: .moreLarge)
        }
        .task {
            adViewModel.loadBanner()
        }
    }
}
