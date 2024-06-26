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
    @EnvironmentObject var adViewModel: AdViewModel
    
    @State private var selectedCrowded = 1
    @State private var selectedDetailLog: CafeDetailLog? = nil
    
    @State private var isDeleteDetailLogDialogOpened = false
    @State private var isExpireDialogOpened = false
    
    var body: some View {
        ZStack {
            AdRewardedInterstitialView()
            
            VStack(spacing: 0) {
                NavigationTitle(
                    title: coreState.masterRoomCafeLog.name,
                    leadingIconSystemName: "xmark",
                    onLeadingIconClick:  {
                        coreState.popUp()
                    }
                )
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        if coreState.isMasterActivated {
                            ActivatedMasterRoom(
                                selectedCrowded: $selectedCrowded,
                                onDetailLogClick: { cafeDetailLog in
                                    selectedDetailLog = cafeDetailLog
                                    isDeleteDetailLogDialogOpened = true
                                },
                                onExpiredButtonClick: {
                                    isExpireDialogOpened = true
                                }
                            )
                            .task {
                                if coreState.isMasterActivated && !coreState.masterRoomCafeLog.cafeDetailLogs.isEmpty {
                                    selectedCrowded = coreState.masterRoomCafeLog.cafeDetailLogs[0].crowded
                                }
                            }
                        } else {
                            InactivatedMasterRoom(selectedCrowded: $selectedCrowded)
                        }
                    }
                    .animation(.easeInOut, value: coreState.isMasterActivated)
                }
                .scrollIndicators(.never)
            }
            
            Dialog(
                isDialogVisible: $isExpireDialogOpened,
                positiveButtonText: "광고보고 종료",
                negativeButtonText: "그냥 종료",
                onPositivebuttonClick: {
                    adViewModel.showRewardedInterstitial(
                        willShowRewardedInterstitial: {},
                        onAdWatched: {
                            Task {
                                await cafeViewModel.expireMaster(coreState: coreState, adWatched: true)
                            }
                        },
                        onFail: { coreState.showSnackBar(message: "광고 로드에 실패했습니다. 다시 시도하시거나 일반 종료를 실행해주세요", type: .error) }
                    )
                },
                onNegativebuttonClick: {
                    Task {
                        await cafeViewModel.expireMaster(coreState: coreState, adWatched: false)
                    }
                },
                onDismiss: {}
            ) {
                Text("마스터를 종료하시겠어요?\n")
                    .font(.headline.weight(.medium))
                    .baselineOffset(.medium)
                +
                Text("광고 시청시 ")
                    .font(.headline.weight(.medium))
                    .baselineOffset(.medium)
                +
                Text("포인트를 1.5배로 드려요\n")
                    .font(.headline.bold())
                    .baselineOffset(.medium)
                +
                Text("*커피 기프티콘 구매 가능")
                    .font(.body.weight(.medium))
                    .foregroundColor(.moreHeavyGray)
            }
            
            Dialog(
                isDialogVisible: $isDeleteDetailLogDialogOpened,
                positiveButtonText: "삭제",
                negativeButtonText: "취소",
                onPositivebuttonClick: {
                    guard let cafeDetailLog = selectedDetailLog else { return }
                    Task {
                        await cafeViewModel.deleteCafeDetailLog(coreState: coreState, cafeDetailLogId: cafeDetailLog.id)
                    }
                },
                onNegativebuttonClick: { selectedDetailLog = nil },
                onDismiss: { selectedDetailLog = nil }
            ) {
                Text("해당 로그를 삭제하시겠어요?")
                    .font(.headline)
            }
        }
        .navigationBarBackButtonHidden()
    }
}
