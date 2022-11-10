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
    @Binding var isCafeDetailLogLoading: Bool
    @Binding var isExpireDialogOpened: Bool
    
    var body: some View {
        Group {
            VerticalSpacer(10)
            Text("현재 \(coreState.user.nickname)님이 마스터로 계신 층은 \(coreState.masterRoomCafeLog.floor.toFloor())층입니다.")
                .font(.headline)
            
            VerticalSpacer(40)
        }
        
        Group {
            Text("혼잡도를 주기적으로 업데이트해주세요")
                .font(.headline)
            if !coreState.masterRoomCafeLog.cafeDetailLogs.isEmpty {
                Text("최근 업데이트 : \(cafeViewModel.time.getPassingHourMinuteStringFrom(timeString: coreState.masterRoomCafeLog.cafeDetailLogs[0].update))전")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            VerticalSpacer(10)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(Crowded.crowdedListExceptNegative, id: \.value) { crowded in
                        Button {
                            selectedCrowded = crowded.value
                        } label: {
                            if selectedCrowded == crowded.value {
                                VStack {
                                    Text(crowded.string)
                                        .font(.headline)
                                    
                                    Image(crowded.image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24)
                                }
                                .frame(width: 60, height: 80)
                            } else {
                                VStack {
                                    Color.gray
                                }
                                .frame(width: 60, height: 80)
                            }
                        }
                    }
                }
                .frame(width: 300)
                
                HStack(spacing: 0){
                    ForEach(Crowded.crowdedListExceptNegative, id: \.value) { crowded in
                        HStack{
                            
                        }
                        .frame(width: 60, height: 6)
                        .background(crowded.color)
                    }
                }
                .frame(width: 300, height: 6)
                .cornerRadius(3)
                .padding(.vertical, 5)
                
                HStack(spacing: 0) {
                    ForEach(Crowded.crowdedListExceptNegative, id: \.value) { crowded in
                        Text(crowded.string)
                            .frame(width: 60)
                    }
                }
                .frame(width: 300)
            }
            .frame(maxWidth: .infinity)
            .padding(15)
            .background(.gray)
            .cornerRadius(20)
            
            VerticalSpacer(40)
        }
         
        Group {
//            Text("현재 위치를 확인하고 혼잡도를 변경해주세요")
//                .font(.headline)
//            VerticalSpacer(10)
//
//            Text("*현재 위치가 카페 위치와 다르면 혼잡도 변경을 할 수 없어요!")
//                .font(.caption)
//                .foregroundColor(.gray)
//            VerticalSpacer(10)
//
//            HStack {
//                Button {
//
//                } label: {
//                    Circle()
//                        .fill(.white)
//                        .frame(width: 18)
//                    Text("위치 조정하기")
//                        .font(.footnote)
//                }
//                .padding(6)
//                .background(.gray)
//                .cornerRadius(15)
//
//                Text("현위치와 카페 위치가 동일해요!")
//                    .font(.headline)
//            }
            
            VerticalSpacer(10)
            HStack {
                Button {
                    Task {
                        await cafeViewModel.updateCrowded(coreState: coreState, crowded: selectedCrowded)
                    }
                } label: {
                    HStack {
                        Text("혼잡도 업데이트")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.black)
                }
            }
            VerticalSpacer(40)
        }
            
        VStack(spacing: 5) {
            HStack {
                Color.black
            }
            .frame(maxWidth: .infinity)
            .frame(height: 3)
            .cornerRadius(2)
            
            VerticalSpacer(10)
            Text("내 활동 기록")
                .font(.headline)
            
            VerticalSpacer(10)
            
            ForEach(Array(coreState.masterRoomCafeLog.cafeDetailLogs.enumerated()), id: \.offset) { index, cafeDetailLog in
                if index == coreState.masterRoomCafeLog.cafeDetailLogs.count - 1 {
                    Button {
                        withAnimation {
                            isCafeDetailLogLoading = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isCafeDetailLogLoading = false
                        }
                        Task {
                            await cafeViewModel.deleteCafeDetailLog(coreState: coreState, cafeDetailLogId: cafeDetailLog.id)
                        }
                    } label: {
                        RoundClockFrame(timeString: cafeDetailLog.update)
                        Text("\(cafeDetailLog.crowded.toCrowded().string)")
                            .foregroundColor(cafeDetailLog.crowded.toCrowded().color)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Button {
                        withAnimation {
                            isCafeDetailLogLoading = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isCafeDetailLogLoading = false
                        }
                        Task {
                            await cafeViewModel.deleteCafeDetailLog(coreState: coreState, cafeDetailLogId: cafeDetailLog.id)
                        }
                    } label: {
                        RoundClockFrame(timeString: cafeDetailLog.update)
                        Text("\(coreState.masterRoomCafeLog.cafeDetailLogs[index + 1].crowded.toCrowded().string)")
                            .foregroundColor(coreState.masterRoomCafeLog.cafeDetailLogs[index + 1].crowded.toCrowded().color)
                        +
                        Text(" > ")
                        +
                        Text("\(cafeDetailLog.crowded.toCrowded().string)")
                            .foregroundColor(cafeDetailLog.crowded.toCrowded().color)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            VerticalSpacer(10)
            
            HStack {
                Color.black
            }
            .frame(maxWidth: .infinity)
            .frame(height: 3)
            .cornerRadius(2)
            VerticalSpacer(40)
        }
        
        Group {
            HStack {
                Text("마스터 활동을 종료하고 싶다면")
                    .font(.headline)
                Spacer()
                Text("클릭")
                    .font(.headline)
                    .underline()
                    .onTapGesture {
                        isExpireDialogOpened = true
                    }
            }
        }
    }
}

