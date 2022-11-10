//
//  MasterDetailView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/04.
//

import SwiftUI

struct MasterDetailView: View {
    
    @EnvironmentObject var coreState: CoreState
    @EnvironmentObject var userViewModel: UserViewModel

    @State private var isBottomSheetOpened = false
    @State private var bottomModalDateCafeLog: DateCafeLog? = nil
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    VerticalSpacer(20)
                    Text("지금까지")
                    Text("총 ")
                    +
                    Text(userViewModel.time.getPassingHourMinuteStringFromSeconds(seconds: coreState.user.activity))
                        .font(.title3.bold())
                    +
                    Text("동안 활동했어요!")
                    VerticalSpacer(30)

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
                        .frame(height: 480)
                        .padding(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.never)

            FullScreenLoadingView(loading: $userViewModel.isDateCafeLogsLoading, text: "마스터 활동 정보 로드중..")
        }
        .navigationTitle("내 마스터 활동")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isBottomSheetOpened) {
            SheetHandle()
            VStack(alignment: .leading) {
                if let bottomModalDateCafeLog = bottomModalDateCafeLog {
                    HStack {
                        Image("stamp_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24)
                        Text("\(userViewModel.time.parseYearFrom(timeString: bottomModalDateCafeLog.cafeLogs[0].start))년  \(userViewModel.time.parseMonthFrom(timeString: bottomModalDateCafeLog.cafeLogs[0].start))월  \(userViewModel.time.parseDayFrom(timeString: bottomModalDateCafeLog.cafeLogs[0].start))일")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()

                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            ForEach(bottomModalDateCafeLog.cafeLogs, id: \.id) { cafeLog in
                                ZStack {
                                    VStack(alignment: .leading) {
                                        Text(cafeLog.name)
                                        +
                                        Text("  \(cafeLog.floor.toFloor())층")

                                        HStack {
                                            HStack {
                                                Text("\(userViewModel.time.getAMPMHourMinuteStringFrom(timeString: cafeLog.start)) ~ \(userViewModel.time.getAMPMHourMinuteStringFrom(timeString: cafeLog.finish))")
                                                    .font(.caption.bold())
                                                    .foregroundColor(.white)
                                            }
                                            .padding(8)
                                            .frame(height: 32)
                                            .background(.gray)
                                            .cornerRadius(16)
                                            Text("총 \(userViewModel.time.getPassingHourMinuteStringFromTo(timeStringFrom: cafeLog.start, timeStringTo: cafeLog.finish)) 활동")
                                                .font(.body)
                                        }
                                    }
                                    .padding(15)
                                    .frame(height: 110)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                    VStack {
                                        Text("+\(cafeLog.point)P")
                                            .font(.title3.bold())
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                    .padding(25)
                                }
                            }
                        }
                        .padding()
                    }
                    .scrollIndicators(.never)
                } else {
                    ProgressView()
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .presentationDetents([.fraction(0.65)])
        }
        .onChange(of: isBottomSheetOpened, perform: { newValue in
            if !newValue {
                bottomModalDateCafeLog = nil
            }
        })
        .task {
            userViewModel.isDateCafeLogsLoading = true
            await userViewModel.getDateCafeLogs(coreState: coreState)
        }
    }
}
