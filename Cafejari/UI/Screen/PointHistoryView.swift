//
//  PointHistoryView.swift
//  Cafejari
//
//  Created by 안용우 on 2023/02/13.
//

import SwiftUI
import GoogleMobileAds

struct PointHistoryView: View {
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var adViewModel: AdViewModel
    
    @State private var selectedTapIndex: Int = 0
    
    @Inject private var time: Time
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                NavigationTitle(
                    title: "포인트 지급내역",
                    leadingIconSystemName: "chevron.backward",
                    onLeadingIconClick: {
                        coreState.popUp()
                    }
                )
                
                HStack(spacing: 0) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            selectedTapIndex = 0
                        }
                    } label: {
                        Text("이벤트")
                            .font(.caption.bold())
                            .foregroundColor(selectedTapIndex == 0 ? .primary : .heavyGray)
                            .frame(width: geo.size.width / 2, height: 48)
                    }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            selectedTapIndex = 1
                        }
                    } label: {
                        Text("혼잡도 공유")
                            .font(.caption.bold())
                            .foregroundColor(selectedTapIndex == 1 ? .primary : .heavyGray)
                            .frame(width: geo.size.width / 2, height: 48)
                    }
                }
                .frame(maxWidth: .infinity)
                
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Color.primary
                    }
                    .cornerRadius(1.5)
                    .padding(.horizontal, .medium)
                    .frame(width: geo.size.width / 2, height: 3)
                }
                .frame(width: geo.size.width, alignment: selectedTapIndex == 0 ? .leading : .trailing)
                
                if selectedTapIndex == 0 {
                    ZStack {
                        if userViewModel.isEventHistoriesLoading {
                            EmptyView()
                        }
                        else if userViewModel.eventPointHistorys.isEmpty {
                            VStack {
                                EmptyImageView("이벤트로 받은 포인트가 없어요")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.vertical, .moreLarge)
                        }
                        else {
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(userViewModel.eventPointHistorys, id: \.id) { eventPointHistory in
                                        HStack(spacing: 0) {
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(eventPointHistory.content)
                                                    .font(.body.bold())
                                                    .padding(.leading, 16)
                                                
                                                HStack(spacing: 6) {
                                                    Text("\(time.parseYearFrom(timeString: eventPointHistory.time)).\(time.parseMonthFrom(timeString: eventPointHistory.time)).\(time.parseDayFrom(timeString: eventPointHistory.time))")
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                    Text("지급완료")
                                                        .padding(.horizontal, .small)
                                                        .padding(.vertical, 2)
                                                        .background(Color.secondary)
                                                        .cornerRadius(.small)
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 10, weight: .regular))
                                                }
                                                .padding(.leading, 16)
                                            }
                                            .padding(.vertical, 16)
                                            .frame(width: geo.size.width * 0.75, alignment: .leading)
                                            
                                            VStack {
                                                Text("+\(eventPointHistory.point)P")
                                                    .font(.body.bold())
                                                    .foregroundColor(.primary)
                                            }
                                            .padding(.bottom, .moreLarge)
                                            .padding(.trailing, 16)
                                            .frame(width: geo.size.width * 0.25, alignment: .trailing)
                                        }
                                        .frame(maxWidth: .infinity)
                                        
                                        Divider()
                                    }
                                    VerticalSpacer(60)
                                }
                            }
                        }
                        FullScreenLoadingView(loading: $userViewModel.isDateCafeLogsLoading, text: "이벤트 포인트 지급정보 로드중..")
                            .frame(maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if selectedTapIndex == 1 {
                    ZStack {
                        if userViewModel.isDateCafeLogsLoading {
                            EmptyView()
                        }
                        else if userViewModel.dateCafeLogs.isEmpty {
                            VStack {
                                EmptyImageView("혼잡도 공유로 받은 포인트가 없어요")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.vertical, .moreLarge)
                        }
                        else {
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(userViewModel.dateCafeLogs, id: \.cafeLogs[0].id) { dateCafeLog in
                                        ForEach(dateCafeLog.cafeLogs, id: \.id) { cafeLog in
                                            HStack(spacing: 0) {
                                                VStack(alignment: .leading, spacing: 6) {
                                                    Text(cafeLog.name + " \(cafeLog.floor.toFloor())층")
                                                        .font(.body.bold())
                                                        .padding(.leading, 16)

                                                    HStack(spacing: 6) {
                                                        Text("\(time.parseYearFrom(timeString: cafeLog.start)).\(time.parseMonthFrom(timeString: cafeLog.start)).\(time.parseDayFrom(timeString: cafeLog.start))")
                                                            .font(.caption)
                                                            .foregroundColor(.gray)
                                                        Text("\(time.getAMPMHourMinuteStringFrom(timeString: cafeLog.start)) ~ \(time.getAMPMHourMinuteStringFrom(timeString: cafeLog.finish))")
                                                            .padding(.horizontal, .small)
                                                            .padding(.vertical, 2)
                                                            .background(Color.secondary)
                                                            .cornerRadius(.small)
                                                            .foregroundColor(.white)
                                                            .font(.system(size: 10, weight: .regular))
                                                    }
                                                    .padding(.leading, 16)
                                                }
                                                .padding(.vertical, 16)
                                                .frame(width: geo.size.width * 0.75, alignment: .leading)

                                                VStack {
                                                    Text("+\(cafeLog.point)P")
                                                        .font(.body.bold())
                                                        .foregroundColor(.primary)
                                                }
                                                .padding(.bottom, .moreLarge)
                                                .padding(.trailing, 16)
                                                .frame(width: geo.size.width * 0.25, alignment: .trailing)
                                            }
                                            .frame(maxWidth: .infinity)

                                            Divider()
                                        }
                                    }
                                    VerticalSpacer(60)
                                }
                            }
                        }
                        FullScreenLoadingView(loading: $userViewModel.isDateCafeLogsLoading, text: "혼잡도 공유활동 정보 로드중..")
                            .frame(height: geo.size.height * 0.8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationBarBackButtonHidden()
            
            VStack {
                Spacer()
                AdBannerView()
                    .frame(width: UIScreen.main.bounds.width, height: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width).size.height)
                    .offset(x: 0, y: .moreLarge)
            }
        }
        .animation(.easeInOut(duration: .short), value: selectedTapIndex)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .task {
            adViewModel.loadBanner()
            userViewModel.isDateCafeLogsLoading = true
            userViewModel.isEventHistoriesLoading = true
            await userViewModel.getDateCafeLogs(coreState: coreState)
            await userViewModel.getMyEventPointHistories(coreState: coreState)
        }
    }
}
