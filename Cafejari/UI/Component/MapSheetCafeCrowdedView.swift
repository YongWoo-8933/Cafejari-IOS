//
//  MapSheetCafeCrowdedView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/04.
//

import SwiftUI

struct MapSheetCafeCrowdedView: View {
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    
    @Binding var isBottomSheetOpened: Bool
    
    @State private var thumbsUpErrorMessage: String = ""
    @State private var isThumbsUpErrorTrigger: Bool = false
    
    var body: some View {
        FloorTap()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 15)
        
        TabView(selection: $cafeViewModel.modalCafeIndex.animation(Animation.easeInOut(duration: 0.1))) {
            ForEach(Array(cafeViewModel.modalCafeInfo.cafes.enumerated()), id: \.offset){ index, cafe in
                VStack(alignment: .leading, spacing: 0) {
                    VerticalSpacer(15)
                    Group {
                        Text("현재 카페 혼잡도를 알려드려요")
                            .font(.headline)
                        VerticalSpacer(15)
                        if cafe.isMasterAvailable() {
                            Text("현재 \(cafe.floor.toFloor())층에서 활동중인 마스터가 없어요!")
                                .font(.caption)
                                .foregroundColor(.gray)
                            VerticalSpacer(5)
                            if !coreState.isMasterActivated {
                                Text("내가 혼잡도 체크하고 포인트 받기 >")
                                    .font(.caption)
                                    .underline()
                                    .onTapGesture {
                                        if !coreState.isMasterActivated {
                                            cafeViewModel.setCafeLogInfo(coreState: coreState)
                                        }
                                        isBottomSheetOpened = false
                                        coreState.navigate(Screen.MasterRoom.route)
                                    }
                            }
                        } else {
                            Text("현재 \(cafe.floor.toFloor())층은 \(cafe.master.nickname)님이 활동 중입니다.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        VerticalSpacer(10)
                    }
                    .padding(.leading, 10)
                    
                    VStack {
                        if cafe.hasRecentLog() {
                            let recentLog = cafe.recentUpdatedLogs[0]
                            HStack(spacing: 0) {
                                ForEach(Crowded.crowdedListExceptNegative, id: \.value) { crowded in
                                    if recentLog.crowded == crowded.value {
                                        VStack {
                                            Text(crowded.string)
                                                .font(.headline)
                                            Text("(\(cafeViewModel.time.getPassingHourMinuteStringFrom(timeString: recentLog.update))전)")
                                                .font(.system(size: 9, weight: .regular))
                                            Image(crowded.image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24)
                                        }
                                        .frame(width: 64)
                                    } else {
                                        VStack {
                                            Color.gray
                                        }
                                        .frame(width: 64, height: 30)
                                    }
                                }
                            }
                            .frame(width: 320)
                        } else {
                            Text("최근 3시간 혼잡도 정보가 없어요")
                            Text("직접 혼잡도를 체크해보세요!")
                        }
                        
                        HStack(spacing: 0){
                            ForEach(Crowded.crowdedListExceptNegative, id: \.value) { crowded in
                                HStack{

                                }
                                .frame(width: 64, height: 6)
                                .background(crowded.color)
                            }
                        }
                        .frame(width: 320, height: 6)
                        .background(.gray)
                        .cornerRadius(3)
                        .padding(.vertical, 5)
                        
                        HStack {
                            Text(Crowded.crowdedZero.string)
                                .font(.subheadline.bold())
                            Spacer()
                            Text(Crowded.crowdedFour.string)
                                .font(.subheadline.bold())
                        }
                        .padding(.horizontal, 10)
                    }
                    .padding()
                    .background(.gray)
                    .cornerRadius(20)
                    
                    if !cafe.isMasterAvailable() && cafe.master.userId != coreState.user.userId {
                        HStack {
                            Text("정보가 도움이 되었다면 꾹 눌러주기!!")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                            Button {
                                Task {
                                    await cafeViewModel.thumbsUp(
                                        coreState: coreState,
                                        recentLogId: cafe.recentUpdatedLogs[0].id,
                                        isAdWatched: true,
                                        onSuccess: { isBottomSheetOpened = false },
                                        onFail: { errorMessage in
                                            thumbsUpErrorMessage = errorMessage
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                isThumbsUpErrorTrigger = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                                    withAnimation(.easeInOut(duration: 0.1)) {
                                                        isThumbsUpErrorTrigger = false
                                                    }
                                                }
                                            }
                                        }
                                    )
                                }
                            } label: {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 18)
                                Text("도움이 됐어요!")
                                    .font(.footnote)
                            }
                            .padding(6)
                            .background(.gray)
                            .cornerRadius(15)
                        }
                        .padding(10)
                        
                        if isThumbsUpErrorTrigger {
                            HStack {
                                Image(systemName: "exclamationmark.circle")
                                    .font(.title2.bold())
                                    .foregroundColor(.red)
                                Text(thumbsUpErrorMessage)
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(15)
                .tag(index)
            }
        }
        .frame(height: 300)
        .tabViewStyle(.page(indexDisplayMode: .never))
        
        if !cafeViewModel.modalCafeInfo.cafes.isEmpty {
            let recentLogs = cafeViewModel.modalCafeInfo.cafes[cafeViewModel.modalCafeIndex].recentUpdatedLogs
            if !recentLogs.isEmpty {
                VStack(alignment: .leading, spacing: 3) {
                    Text("최근 3시간 카페 혼잡도 정보를 알려드려요")
                        .font(.headline)
                    VerticalSpacer(15)
                    ForEach(recentLogs, id: \.id) { recentUpdatedLog in
                        HStack {
                            RoundClockFrame(timeString: recentUpdatedLog.update)
                            Text(recentUpdatedLog.crowded.toCrowded().string)
                                .foregroundColor(recentUpdatedLog.crowded.toCrowded().color)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(10)
            }
        }
    }
}
