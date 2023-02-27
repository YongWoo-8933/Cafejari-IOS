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
    @EnvironmentObject private var informationViewModel: InformationViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if let onSaleCafe = informationViewModel.getOnSaleCafeFromId(cafeInfoId: cafeViewModel.modalCafeInfo.id) {
                ZStack {
                    HStack {
                        Text(onSaleCafe.content)
                            .foregroundColor(.white)
                            .font(.body.bold())
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    .padding(.leading, .large)
                    .padding(.trailing, 56)
                    .frame(maxWidth: .infinity)
                    .background(Color(hexString: "FF3E00"))
                    .cornerRadius(.small)
                    HStack {
                        Spacer()
                        Image("paper_coffee_cup")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 56)
                            .offset(x: 0, y: -.large)
                    }
                    .padding(.horizontal, .large)
                }
                .frame(maxWidth: .infinity)
            } else {
                if !coreState.isMasterActivated && cafeViewModel.modalCafeInfo.isMasterAvailable() {
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: .small) {
                            HStack(spacing: 0) {
                                Text("지금은 ")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                ForEach(Array(cafeViewModel.modalCafeInfo.masterAvailableFloors().enumerated()), id: \.offset) { index, floor in
                                    if index == cafeViewModel.modalCafeInfo.masterAvailableFloors().count - 1 {
                                        Text("\(floor.toFloor())층에서 활동 가능해요!")
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    } else {
                                        Text("\(floor.toFloor()), ")
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            Text("혼잡도 3초만에 공유하고 포인트 얻기")
                                .font(.body.bold())
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Image("yellow_armchair")
                            .resizable()
                            .frame(width: 84)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, .moreLarge)
                    .padding(.vertical, 17)
                    .background(Color.background)
                    .cornerRadius(.medium)
                    .onTapGesture {
                        if cafeViewModel.modalCafeInfo.isMasterAvailable() {
                            cafeViewModel.setCafeLogInfo(coreState: coreState)
                            cafeViewModel.collapseBottomSheet {
                                coreState.navigate(Screen.MasterRoom.route)
                            }
                        }
                    }
                }
            }
            
            VerticalSpacer(16)
            
            // 층 탭
            FloorTap(useDisabledFloorButton: false)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VerticalSpacer(.small)
            
            // 혼잡도 안내 파트
            VStack(alignment: .leading, spacing: .large) {
                VStack(alignment: .leading, spacing: .small) {
                    Text("\(cafeViewModel.modalCafe.floor.toFloor())층 카페 혼잡도")
                        .font(.body.bold())
                    Text(cafeViewModel.modalCafe.isMasterAvailable() ? "현재 \(cafeViewModel.modalCafe.floor.toFloor())층에서 활동중인 마스터가 없어요!" : "(현재 \(cafeViewModel.modalCafe.floor.toFloor())층은 \(cafeViewModel.modalCafe.master.nickname)님이 활동 중이에요")
                        .font(.caption2)
                        .foregroundColor(.heavyGray)
                }
                
                VStack(spacing: .small) {
                    if cafeViewModel.modalCafe.hasRecentLog() {
                        GeometryReader { geo in
                            HStack(spacing: 0) {
                                ForEach(Crowded.crowdedListExceptNegative, id: \.value) { crowded in
                                    if cafeViewModel.modalCafe.recentUpdatedLogs[0].crowded == crowded.value {
                                        VStack {
                                            Text(crowded.string)
                                                .font(.body.bold())
                                                .foregroundColor(.primary)
                                            Text("(\(cafeViewModel.time.getPassingHourMinuteStringFrom(timeString: cafeViewModel.modalCafe.recentUpdatedLogs[0].update))전)")
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
                        
                        CrowdedColorBar()
                    } else {
                        Text("최근 3시간 내 혼잡도 정보없음")
                            .font(.caption)
                            .foregroundColor(.primary)
                        
                        VerticalSpacer(.large)
                        
                        CrowdedGrayBar()
                    }
                }
                .padding(.horizontal, .large)
                .padding(.vertical, .moreLarge)
                .roundBorder(cornerRadius: .moreLarge, lineWidth: 1.5, borderColor: .lightGray)
                
                Button {
                    if cafeViewModel.modalCafe.master.userId == coreState.user.userId {
                        // 혼잡도 공유 이어하기
                        cafeViewModel.collapseBottomSheet {
                            coreState.navigate(Screen.MasterRoom.route)
                        }
                    } else if (!cafeViewModel.modalCafe.isMasterAvailable()) {
                        // 마스터 추천
                        if coreState.isNearBy(latitude: cafeViewModel.modalCafeInfo.latitude, longitude: cafeViewModel.modalCafeInfo.longitude) {
                            cafeViewModel.thumbsUpRecentLog = cafeViewModel.modalCafe.recentUpdatedLogs[0]
                            cafeViewModel.isThumbsUpDialogOpened = true
                        } else {
                            cafeViewModel.showModalSnackBar(
                                message: "현위치가 카페위치와 너무 멀어요. 마스터를 추천하려면 해당 카페에 위치해야해요", type: SnackBarType.info)
                        }
                        
                    } else if (coreState.isMasterActivated) {
                        // 활동중이라 못함
                        
                    } else {
                        // 마스터 하러가기
                        cafeViewModel.setCafeLogInfo(coreState: coreState)
                        cafeViewModel.collapseBottomSheet {
                            coreState.navigate(Screen.MasterRoom.route)
                        }
                    }
                } label: {
                    HStack {
                        if cafeViewModel.modalCafe.master.userId == coreState.user.userId {
                            // 혼잡도 이어하기
                            Text("혼잡도 공유 이어서 하기")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        } else if (!cafeViewModel.modalCafe.isMasterAvailable()) {
                            // 마스터 추천
                            Image(systemName: "hand.thumbsup.fill")
                                .font(.title)
                                .foregroundColor(.white)
                            Text("도움이 되었다면 꾹 누르기!")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        } else if (coreState.isMasterActivated) {
                            // 활동중이라 못함
                            Text("이미 다른 카페에서 마스터 활동중")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        } else {
                            // 마스터 하러가기
                            Image(systemName: "pencil")
                                .font(.title)
                                .foregroundColor(.white)
                            Text("혼잡도 공유하고 포인트 받기")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        }
                    }
                }
                .disabled(cafeViewModel.modalCafe.master.userId != coreState.user.userId && cafeViewModel.modalCafe.isMasterAvailable() && coreState.isMasterActivated)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.primary)
                .cornerRadius(20)
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.vertical, .moreLarge)
            .animation(.easeInOut(duration: .short), value: cafeViewModel.modalCafe.id)
        }
        .padding(.horizontal, .moreLarge)
        
        if !cafeViewModel.modalCafeInfo.cafes.isEmpty {
            if !cafeViewModel.modalCafe.recentUpdatedLogs.isEmpty {
                VStack(alignment: .leading, spacing: .large) {
                    Text("최근 3시간 카페 혼잡도")
                        .font(.body.bold())
                        .padding(.horizontal, .moreLarge)
                    
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: .medium) {
                            ForEach(
                                cafeViewModel.modalCafe.recentUpdatedLogs, id: \.id) { recentLog in
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
                                    .roundBorder(cornerRadius: 18, lineWidth: 1, borderColor: .lightGray)
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
