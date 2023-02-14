//
//  MasterDetailView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/04.
//

import SwiftUI
import GoogleMobileAds

struct MasterDetailView: View {
    
    @EnvironmentObject var coreState: CoreState
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject private var adViewModel: AdViewModel

    @State private var isBottomSheetOpened = false
    @State private var bottomModalDateCafeLog: DateCafeLog? = nil
    
    @Inject private var time: Time
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                NavigationTitle(
                    title: "내 마스터 활동",
                    leadingIconSystemName: "chevron.backward",
                    onLeadingIconClick: {
                        coreState.popUp()
                    }
                )
                ScrollView {
                    LazyVStack(spacing: 0) {
                        VerticalSpacer(.moreLarge)
                        
                        VStack(spacing: .small) {
                            Text("지금까지")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("총 ")
                                .font(.headline)
                                .foregroundColor(.primary)
                            +
                            Text(time.getPassingHourMinuteStringFromSeconds(seconds: coreState.user.activity))
                                .font(.headline.bold())
                                .foregroundColor(.primary)
                            +
                            Text(" 동안 카페를 지켰어요!")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        VerticalSpacer(.moreLarge)
                        
                        if !userViewModel.isDateCafeLogsLoading {
                            CalendarView(
                                selectedDate: $userViewModel.selectedDate,
                                dateCafeLogs: $userViewModel.dateCafeLogs,
                                onDateSelected: { date in
                                    let imageDateFormatter = DateFormatter()
                                    imageDateFormatter.dateFormat = "yyyyMMdd"
                                    let dateStr = imageDateFormatter.string(from: date)
                                    let selectedDateCafeLogs = userViewModel.dateCafeLogs.filter({ dateCafeLog in
                                        imageDateFormatter.string(from: dateCafeLog.date) == dateStr
                                    })
                                    if !selectedDateCafeLogs.isEmpty {
                                        bottomModalDateCafeLog = selectedDateCafeLogs[0]
                                        isBottomSheetOpened = true
                                    }
                                }
                            )
                            .frame(height: 420)
                            .padding(.moreLarge)
                            .roundBorder(cornerRadius: .moreLarge, lineWidth: 1.5, borderColor: .primary)
                        }
                    }
                    .padding(.moreLarge)
                }
                .scrollIndicators(.never)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            AdBannerView()
                .frame(width: UIScreen.main.bounds.width, height: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width).size.height)
                .offset(x: 0, y: .moreLarge)
            
            FullScreenLoadingView(loading: $userViewModel.isDateCafeLogsLoading, text: "마스터 활동 정보 로드중..")
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $isBottomSheetOpened) {
            SheetHandle()
            
            VStack(alignment: .leading, spacing: 0) {
                if let bottomModalDateCafeLog = bottomModalDateCafeLog {
                    HStack(spacing: .large) {
                        Image("stamp_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16)
                        Text("\(time.parseYearFrom(timeString: bottomModalDateCafeLog.cafeLogs[0].start))년  \(time.parseMonthFrom(timeString: bottomModalDateCafeLog.cafeLogs[0].start))월  \(time.parseDayFrom(timeString: bottomModalDateCafeLog.cafeLogs[0].start))일")
                            .font(.headline.bold())
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.moreLarge)

                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: .large) {
                            ForEach(bottomModalDateCafeLog.cafeLogs, id: \.id) { cafeLog in
                                ZStack {
                                    VStack(alignment: .leading) {
                                        Text(cafeLog.name + " \(cafeLog.floor.toFloor())층")
                                            .font(.body.bold())

                                        HStack {
                                            RoundTimeFrame(timeStringFrom: cafeLog.start, timeStringTo: cafeLog.finish)
                                            Text("총 \(time.getPassingHourMinuteStringFromTo(timeStringFrom: cafeLog.start, timeStringTo: cafeLog.finish)) 활동")
                                                .font(.caption)
                                        }
                                    }
                                    .padding(.moreLarge)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .roundBorder(cornerRadius: .moreLarge, lineWidth: 1, borderColor: .black)
                                    
                                    VStack {
                                        Text("+\(cafeLog.point)P")
                                            .font(.headline.bold())
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                    .padding(.large)
                                }
                            }
                        }
                        .padding(.moreLarge)
                    }
                    .scrollIndicators(.never)
                } else {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .presentationDetents([.fraction(0.7)])
        }
        .onChange(of: isBottomSheetOpened, perform: { newValue in
            if !newValue {
                bottomModalDateCafeLog = nil
            }
        })
        .task {
            adViewModel.loadBanner()
            userViewModel.isDateCafeLogsLoading = true
            await userViewModel.getDateCafeLogs(coreState: coreState)
        }
    }
}
