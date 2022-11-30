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
    
    var body: some View {
        VStack(spacing: 0) {
            if coreState.mapType == MapType.master {
                // 마스터 모드
                VerticalSpacer(.large)
                VStack(alignment: .leading, spacing: .small) {
                    if !cafeViewModel.modalCafeInfo.isMasterAvailable() {
                        Text("이 카페는 모든 층에서 마스터들이 활동중입니다. 잠시 후에 다시 시도해주세요!")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                    } else {
                        HStack(spacing: 0) {
                            Text("지금은 ")
                                .foregroundColor(.onPrimary)
                            ForEach(Array(cafeViewModel.modalCafeInfo.masterAvailableFloors().enumerated()), id: \.offset) { index, floor in
                                if index == cafeViewModel.modalCafeInfo.masterAvailableFloors().count - 1 {
                                    Text("\(floor.toFloor())층에서 활동 가능해요!")
                                        .foregroundColor(.onPrimary)
                                } else {
                                    Text("\(floor.toFloor()), ")
                                        .foregroundColor(.onPrimary)
                                }
                            }
                        }
                        Text("혼잡도 3초만에 공유하고 포인트 얻기")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 72)
                .padding(.horizontal, .moreLarge)
                .background(Color.primary)
                .cornerRadius(.medium)
                .onTapGesture {
                    if cafeViewModel.modalCafeInfo.isMasterAvailable() {
                        cafeViewModel.setCafeLogInfo(coreState: coreState)
                        isBottomSheetOpened = false
                        coreState.navigate(Screen.MasterRoom.route)
                    }
                }
            }
            
            // 마커, 카페 이름
            HStack(spacing: .large) {
                let cafe = cafeViewModel.modalCafeInfo.cafes.isEmpty ? Cafe.empty : cafeViewModel.modalCafeInfo.cafes[cafeViewModel.modalCafeIndex]
                
                Image(cafe.crowded.toCrowded().image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
                
                Text(cafeViewModel.modalCafeInfo.name)
                    .font(.body.bold())
                
                Spacer()
            }
            .padding(.vertical, .moreLarge)
            
            // 층 탭
            FloorTap(useDisabledFloorButton: false)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 혼잡도 안내 파트
            VStack(alignment: .leading, spacing: .large) {
                let cafe = cafeViewModel.modalCafeInfo.cafes[cafeViewModel.modalCafeIndex]
                VStack(alignment: .leading, spacing: .small) {
                    Text("\(cafe.floor.toFloor())층 카페 혼잡도")
                        .font(.body.bold())
                    +
                    Text("를 알려드려요")
                    Text(cafe.isMasterAvailable() ? "(현재 \(cafe.floor.toFloor())층에서 활동중인 마스터가 없어요)" : "(현재 \(cafe.floor.toFloor())층은 \(cafe.master.nickname)님이 활동 중이에요)")
                        .font(.caption2)
                        .foregroundColor(.heavyGray)
                }
                
                VStack(spacing: .small) {
                    if cafe.hasRecentLog() {
                        GeometryReader { geo in
                            HStack(spacing: 0) {
                                ForEach(Crowded.crowdedListExceptNegative, id: \.value) { crowded in
                                    if cafe.recentUpdatedLogs[0].crowded == crowded.value {
                                        VStack {
                                            Text(crowded.string)
                                                .font(.body.bold())
                                                .foregroundColor(.primary)
                                            Text("(\(cafeViewModel.time.getPassingHourMinuteStringFrom(timeString: cafe.recentUpdatedLogs[0].update))전)")
                                                .font(.system(size: 9, weight: .regular))
                                                .foregroundColor(.moreHeavyGray)
                                            Image(crowded.image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 24)
                                        }
                                        .frame(width: geo.size.width / 5)
                                    } else {
                                        VStack {
                                            Color.white
                                        }
                                        .frame(width: geo.size.width / 5, height: 30)
                                    }
                                }
                            }
                            .frame(width: geo.size.width, height: 70)
                        }
                        .frame(height: 70)
                    } else {
                        Text("(최근 3시간 내 정보없음)")
                            .font(.caption)
                        Text("3초 안에 혼잡도 공유하고 포인트 받아가세요")
                            .foregroundColor(.primary)
                            .font(.body.bold())
                        VerticalSpacer(.large)
                    }
                    CrowdedColorBar()
                }
                .padding(.horizontal, .large)
                .padding(.vertical, .moreLarge)
                .roundBorder(cornerRadius: .moreLarge, lineWidth: 1.5, borderColor: .primary)
                
                HStack(spacing: .large) {
                    if coreState.isMasterActivated {
                        if !cafe.isMasterAvailable() {
                            RoundButton(
                                iconSystemName: "hand.thumbsup.fill",
                                text: "도움이 됐어요!",
                                foregroundColor: .white,
                                backgroundColor: .primary
                            ) {
                                if coreState.isNearBy(latitude: cafeViewModel.modalCafeInfo.latitude, longitude: cafeViewModel.modalCafeInfo.longitude) {
                                    cafeViewModel.thumbsUpRecentLog = cafe.recentUpdatedLogs[0]
                                    cafeViewModel.isThumbsUpDialogOpened = true
                                } else {
                                    cafeViewModel.showModalSnackBar(
                                        message: "현위치가 카페위치와 너무 멀어요. 마스터를 추천하려면 해당 카페에 위치해야해요", type: SnackBarType.info)
                                }
                            }
                            Text("정보가 도움이 되었다면 꾹 눌러주기!!")
                                .font(.caption)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    } else {
                        RoundButton(
                            iconSystemName: cafe.isMasterAvailable() ? "pencil" : "hand.thumbsup.fill",
                            text: cafe.isMasterAvailable() ? "혼잡도 공유" : "도움이 됐어요!",
                            foregroundColor: .white,
                            backgroundColor: .primary
                        ) {
                            if cafe.isMasterAvailable() {
                                cafeViewModel.setCafeLogInfo(coreState: coreState)
                                isBottomSheetOpened = false
                                coreState.navigate(Screen.MasterRoom.route)
                            } else {
                                if coreState.isNearBy(latitude: cafeViewModel.modalCafeInfo.latitude, longitude: cafeViewModel.modalCafeInfo.longitude) {
                                    cafeViewModel.thumbsUpRecentLog = cafe.recentUpdatedLogs[0]
                                    cafeViewModel.isThumbsUpDialogOpened = true
                                } else {
                                    cafeViewModel.showModalSnackBar(
                                        message: "현위치가 카페위치와 너무 멀어요. 마스터를 추천하려면 해당 카페에 위치해야해요", type: SnackBarType.info)
                                }
                            }
                        }
                        Text(cafe.isMasterAvailable() ? "내가 혼잡도 체크하고 포인트 받기" : "정보가 도움이 되었다면 꾹 눌러주기!!")
                            .font(.caption)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.vertical, .moreLarge)
            .animation(.easeInOut(duration: .short), value: cafeViewModel.modalCafeIndex)
        }
        .padding(.horizontal, .moreLarge)
        
        if !cafeViewModel.modalCafeInfo.cafes.isEmpty {
            if !cafeViewModel.modalCafeInfo.cafes[cafeViewModel.modalCafeIndex].recentUpdatedLogs.isEmpty {
                VStack(alignment: .leading, spacing: .medium) {
                    HStack(spacing: .small) {
                        Text("최근 3시간")
                            .font(.body.bold())
                        Text(" 카페 혼잡도를 알려드려요")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, .moreLarge)
                    
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: .medium) {
                            ForEach(
                                cafeViewModel.modalCafeInfo.cafes[cafeViewModel.modalCafeIndex].recentUpdatedLogs, id: \.id) { recentLog in
                                    HStack {
                                        Text(recentLog.crowded.toCrowded().string)
                                            .font(.caption2.bold())
                                            .foregroundColor(recentLog.crowded.toCrowded().textColor)
                                            .frame(width: 28, height: 28)
                                            .background(recentLog.crowded.toCrowded().color)
                                            .clipShape(Circle())
                                            .clipped()
                                        
                                        Text("\(cafeViewModel.time.getAMPMHourMinuteStringFrom(timeString: recentLog.update))")
                                            .font(.caption.bold())
                                            .foregroundColor(.black)
                                        Text("(\(cafeViewModel.time.getPassingHourMinuteStringFrom(timeString: recentLog.update))전)")
                                            .font(.caption)
                                    }
                                    .padding(.leading, 4)
                                    .padding(.trailing, 8)
                                    .frame(height: 36)
                                    .background(.white)
                                    .roundBorder(cornerRadius: 18, lineWidth: 1, borderColor: .heavyGray)
                            }
                        }
                        .padding(.horizontal, .moreLarge)
                    }
                    .frame(height: 38)
                }
                .padding(.vertical, .moreLarge)
            }
        }
        
        VerticalSpacer(.large)
    }
}
