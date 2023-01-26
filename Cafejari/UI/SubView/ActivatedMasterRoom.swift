//
//  ActivatedMasterRoom.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/06.
//

import SwiftUI

struct ActivatedMasterRoom: View {
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    
    @Binding var selectedCrowded: Int
    
    let onDetailLogClick: (CafeDetailLog) -> Void
    let onExpiredButtonClick: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VerticalSpacer(.moreLarge)
            
            HStack(alignment: .bottom, spacing: .moreLarge) {
                Image("master_activated_person_image")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 76)
                
                VStack(alignment: .leading, spacing: .medium) {
                    Text("\(coreState.user.nickname)님은 현재")
                        .foregroundColor(.primary)
                    Text("\(coreState.masterRoomCafeLog.floor.toFloor())층의 마스터")
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                    +
                    Text("입니다")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .frame(maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 84)
            .padding(.horizontal, .moreLarge)
            .background(Color.moreLightGray)
            .cornerRadius(.medium)
            
            VerticalSpacer(.moreLarge)
            
            Text("혼잡도 설정")
                .font(.headline.bold())
            
            if !coreState.masterRoomCafeLog.cafeDetailLogs.isEmpty {
                VerticalSpacer(.medium)
                Text("최근 업데이트 ")
                    .foregroundColor(.heavyGray)
                    .font(.caption)
                +
                Text("\(cafeViewModel.time.getPassingHourMinuteStringFrom(timeString: coreState.masterRoomCafeLog.cafeDetailLogs[0].update))전")
                    .foregroundColor(.heavyGray)
                    .font(.caption.bold())
            }
            
            VerticalSpacer(.large)
            
            VStack(spacing: .medium) {
                Text(selectedCrowded.toCrowded().detailString)
                    .foregroundColor(.primary)
                
                VerticalSpacer(.small)
                
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        ForEach(Crowded.crowdedListExceptNegative, id: \.value) { crowded in
                            VStack {
                                if selectedCrowded == crowded.value {
                                    Image(crowded.image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24)
                                } else {
                                    Color.white
                                }
                            }
                            .frame(width: geo.size.width / 5)
                            .onTapGesture {
                                selectedCrowded = crowded.value
                            }
                        }
                    }
                    .frame(width: geo.size.width, height: 30)
                }
                .frame(height: 34)
                
                CrowdedColorBar()
            }
            .padding(.horizontal, .large)
            .padding(.vertical, 28)
            .roundBorder(cornerRadius: .moreLarge, lineWidth: 1.5, borderColor: .lightGray)
            .animation(.easeInOut(duration: .short), value: selectedCrowded)
                
            VerticalSpacer(.moreLarge)
            
            FilledCtaButton(text: "혼잡도 업데이트", backgroundColor: .primary, isProgress: cafeViewModel.isMasterRoomCtaProgress) {
                if coreState.isNearBy(latitude: coreState.masterRoomCafeLog.latitude, longitude: coreState.masterRoomCafeLog.longitude) {
                    if !coreState.masterRoomCafeLog.cafeDetailLogs.isEmpty && cafeViewModel.time.getPassingSecondsFrom(timeString: coreState.masterRoomCafeLog.cafeDetailLogs[0].update) > 30 {
                        Task {
                            await cafeViewModel.updateCrowded(coreState: coreState, crowded: selectedCrowded)
                        }
                    } else {
                        coreState.showSnackBar(message: "혼잡도 업데이트는 마지막 업데이트로부터 30초가 지나야 가능합니다")
                    }
                } else {
                    coreState.showSnackBar(message: "현재 위치가 카페와 너무 멀어요. 위치 조정후 다시 시도해주세요!", type: SnackBarType.error)
                }
            }
             
            VerticalSpacer(.large)
        }
        .padding(.moreLarge)
        
        SecondaryDivider()
        
        VerticalSpacer(40)
        
        Text("혼잡도 변경 기록")
            .font(.headline.bold())
            .padding(.horizontal, .moreLarge)
        
        VerticalSpacer(16)
        
        ScrollView(.horizontal) {
            LazyHStack(spacing: .medium) {
                ForEach(coreState.masterRoomCafeLog.cafeDetailLogs, id: \.id) { cafeDetailLog in
                    Button {
                        onDetailLogClick(cafeDetailLog)
                    } label: {
                        HStack {
                            Text(cafeDetailLog.crowded.toCrowded().string)
                                .font(.caption2.bold())
                                .foregroundColor(cafeDetailLog.crowded.toCrowded().textColor)
                                .frame(width: 28, height: 28)
                                .background(cafeDetailLog.crowded.toCrowded().color)
                                .clipShape(Circle())
                                .clipped()
                            
                            Text("\(cafeViewModel.time.getAMPMHourMinuteStringFrom(timeString: cafeDetailLog.update))")
                                .font(.caption.bold())
                                .foregroundColor(.black)
                            Text("(\(cafeViewModel.time.getPassingHourMinuteStringFrom(timeString: cafeDetailLog.update))전)")
                                .font(.caption)
                        }
                        .padding(.leading, 4)
                        .padding(.trailing, 8)
                        .frame(height: 36)
                        .background(.white)
                        .roundBorder(cornerRadius: 18, lineWidth: 1, borderColor: .heavyGray)
                    }
                }
            }
            .padding(.horizontal, .moreLarge)
        }
        .frame(height: 38)
            
        VerticalSpacer(60)
        
        Text("마스터 활동을 종료하시겠어요?")
            .font(.headline.weight(.medium))
            .underline()
            .onTapGesture {
                onExpiredButtonClick()
            }
            .frame(maxWidth: .infinity)
            
        VerticalSpacer(40)
    }
}

