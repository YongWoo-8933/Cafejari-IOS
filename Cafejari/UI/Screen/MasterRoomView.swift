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
    @State private var selectedDetailLog: CafeDetailLog? = nil
    
    @State private var isDeleteDetailLogDialogOpened = false
    @State private var isExpireDialogOpened = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationTitle(title: coreState.masterRoomCafeLog.name, leadingIconSystemName: "xmark") {
                    cafeViewModel.cafeInfoLoading = true
                    Task {
                        await cafeViewModel.getCafeInfos(coreState: coreState)
                    }
                    coreState.popUp()
                }
                
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
            ) {
                Text("마스터를 종료하시겠어요?\n")
                    .font(.headline.weight(.medium))
                    .baselineOffset(.medium)
                +
                Text("광고 시청시 ")
                    .font(.headline.weight(.medium))
                    .baselineOffset(.medium)
                +
                Text("포인트를 더 얻을 수 있어요\n")
                    .font(.headline.bold())
                    .baselineOffset(.medium)
                +
                Text("*카페 기프티콘 구매 가능")
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
                    .font(.headline.bold())
            }
        }
        .navigationBarBackButtonHidden()
    }
}
