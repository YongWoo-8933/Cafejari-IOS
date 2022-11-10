//
//  MasterRoomView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI
import CachedAsyncImage

struct MasterRoomView: View {
    
    @EnvironmentObject var coreState: CoreState
    @EnvironmentObject var cafeViewModel: CafeViewModel
    
    @State private var selectedCrowded = 1
    
    @State private var isCafeDetailLogLoading = false
    @State private var isExpireDialogOpened = false
    @State private var isAdWatchDialogOpened = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    HStack {
                        Text("\(coreState.masterRoomCafeLog.name)")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(.gray)
                    
                    Button {
                        cafeViewModel.cafeInfoLoading = true
                        Task {
                            await cafeViewModel.getCafeInfos(coreState: coreState)
                        }
                        coreState.popUp()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline.bold())
                            .padding()
                    }
                }
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        if coreState.isMasterActivated {
                            ActivatedMasterRoom(
                                selectedCrowded: $selectedCrowded,
                                isCafeDetailLogLoading: $isCafeDetailLogLoading,
                                isExpireDialogOpened: $isExpireDialogOpened
                            )
                        } else {
                            InactivatedMasterRoom(selectedCrowded: $selectedCrowded)
                        }
                    }
                    .padding()
                }
                .scrollIndicators(.never)
            }
            
            FullScreenLoadingView(loading: $isCafeDetailLogLoading, text: "로그 삭제중..")
            CustomDialog(
                isDialogVisible: $isExpireDialogOpened,
                content: "마스터를 종료하시겠습니까?",
                positiveButtonText: "종료",
                negativeButtonText: "취소",
                onPositivebuttonClick: { isAdWatchDialogOpened = true },
                onNegativebuttonClick: {},
                onDismiss: {}
            )
            CustomDialog(
                isDialogVisible: $isAdWatchDialogOpened,
                content: "광고를 보고 종료하시면 포인트가 1.5배로 지급됩니다. 광고 보고 종료하시겠습니까?",
                positiveButtonText: "광고시청",
                negativeButtonText: "종료",
                onPositivebuttonClick: {
                    Task {
                        await cafeViewModel.expireMaster(coreState: coreState, adWatched: true)
                    }
                },
                onNegativebuttonClick: {
                    Task {
                        await cafeViewModel.expireMaster(coreState: coreState, adWatched: false)
                    }
                },
                onDismiss: {}
            )
        }
        .navigationBarBackButtonHidden()
    }
}


// 랜덤 이미지 받아오던 코드

//                        ZStack {
//                            CachedAsyncImage(url: URL(string: cafeViewModel.masterRoomImageSaying.image )) { image in
//                                image
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(maxWidth: .infinity)
//                            } placeholder: {
//                                Image("cafe_picture_default")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(maxWidth: .infinity)
//                                    .frame(height: 250)
//                            }
//
//                            VStack{
//                                Text(cafeViewModel.masterRoomImageSaying.saying.useNonBreakingSpace() + "\n")
//                                    .frame(maxWidth: .infinity, alignment: .topLeading)
//                                Text("- " + cafeViewModel.masterRoomImageSaying.person)
//                                    .frame(maxWidth: .infinity, alignment: .bottomTrailing)
//                            }
//                            .foregroundColor(.white)
//                            .padding(30)
//                            .background(.black.opacity(0.6))
//                            .cornerRadius(10)
//                            .padding(30)
//
//                            if isImageLoading {
//                                HStack {
//                                    ProgressView()
//                                }
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                .background(.white)
//                            }
//                        }
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 250)
//                        .onTapGesture {
//                            if !isImageLoading {
//                                withAnimation(.easeInOut(duration: 0.15)) {
//                                    isImageLoading = true
//                                }
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                                    isImageLoading = false
//                                }
//                            }
//                            Task {
//                                try await cafeViewModel.getRandomImageSaying(coreState: coreState)
//                            }
//                        }


// 슬라이더 코드
//                        HStack {
//                            ForEach(Array(Crowded.crowdedListExceptNegative.enumerated()), id: \.offset) { index, crowded in
//                                if index != 0 { Spacer() }
//                                Image(crowded.image)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 30)
//                                    .onTapGesture {
//                                        crowdedSliderValue = Double(crowded.value) * 100.0
//                                    }
//                            }
//                        }
                        
//                        Slider(value: $crowdedSliderValue, in: 0...400, step: 1){
//
//                        } onEditingChanged: { editing in
//                            if !editing {
//                                let crowdedDouble = round(crowdedSliderValue / 100.0)
//                                sliderColor = Int(crowdedDouble).toCrowded().color
//                                crowdedSliderValue = crowdedDouble * 100
//                            }
//                        }
//                        .onChange(of: crowdedSliderValue){ newValue in
//                            let crowdedDouble = floor(newValue / 100.0)
//                            sliderColor = Int(crowdedDouble).toCrowded().color
//                        }
//                        .accentColor(sliderColor)
//                        .padding(.horizontal, 8)
