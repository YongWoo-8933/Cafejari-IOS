//
//  AutoExpiredLogDialog.swift
//  Cafejari
//
//  Created by 안용우 on 2023/02/25.
//

import SwiftUI

struct AutoExpiredLogDialog: View {
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    @EnvironmentObject private var adViewModel: AdViewModel
    
    @State private var isAddAdPointCompleteDialogOpened = false
    
    var body: some View {
        Dialog(
            isDialogVisible: $coreState.isAutoExpiredDialogOpened,
            positiveButtonText: "받을게요",
            negativeButtonText: "괜찮아요",
            onPositivebuttonClick: {
                if let autoExpiredCafeLog = coreState.autoExpiredCafeLog {
                    let cafeLogId = autoExpiredCafeLog.cafeLog.id
                    Task {
                        adViewModel.showRewardedInterstitial(
                            willShowRewardedInterstitial: { cafeViewModel.isBottomSheetOpened = false },
                            onAdWatched: {
                                Task {
                                    await cafeViewModel.addAdPoint(coreState: coreState, cafeLogId: cafeLogId)
                                    isAddAdPointCompleteDialogOpened = true
                                }
                            },
                            onFail: {
                                coreState.showSnackBar(
                                    message: "불러올 수 있는 광고가 없습니다. 다음부터는 '광고보고 종료하기'를 활용해주세요!", type: .error)
                            }
                        )
                        await cafeViewModel.deleteAutoExpiredCafeLog(
                            coreState: coreState, autoExpiredCafeLogId: autoExpiredCafeLog.id)
                        coreState.autoExpiredCafeLog = nil
                    }
                }
            },
            onNegativebuttonClick: {
                Task {
                    if let autoExpiredCafeLog = coreState.autoExpiredCafeLog {
                        await cafeViewModel.deleteAutoExpiredCafeLog(
                            coreState: coreState, autoExpiredCafeLogId: autoExpiredCafeLog.id)
                        coreState.autoExpiredCafeLog = nil
                    }
                }
            },
            onDismiss: {
                Task {
                    if let autoExpiredCafeLog = coreState.autoExpiredCafeLog {
                        await cafeViewModel.deleteAutoExpiredCafeLog(
                            coreState: coreState, autoExpiredCafeLogId: autoExpiredCafeLog.id)
                        coreState.autoExpiredCafeLog = nil
                    }
                }
            }
        ) {
            if let autoExpiredCafeLog = coreState.autoExpiredCafeLog {
                return Text("\(autoExpiredCafeLog.cafeLog.name) \(autoExpiredCafeLog.cafeLog.floor.toFloor())층\n\n")
                    .font(.headline.bold())
                + Text("마스터 활동이 ")
                + Text("\(cafeViewModel.time.parseYearFrom(timeString: autoExpiredCafeLog.time)).\(cafeViewModel.time.parseMonthFrom(timeString: autoExpiredCafeLog.time)).\(cafeViewModel.time.parseDayFrom(timeString: autoExpiredCafeLog.time)) \(cafeViewModel.time.getAMPMHourMinuteStringFrom(timeString: autoExpiredCafeLog.time))")
                    .font(.body.bold())
                + Text("에\n")
                + Text("자동 종료되었습니다. (\(autoExpiredCafeLog.cafeLog.point)P 획득)\n")
                    .baselineOffset(-.small)
                + Text("광고보고 ")
                    .baselineOffset(-.small)
                + Text("\(autoExpiredCafeLog.cafeLog.point/2)P ")
                    .font(.body.bold())
                    .baselineOffset(-.small)
                + Text("더 받아보세요!")
                    .baselineOffset(-.small)
            } else {
                return Text("")
            }
        }
        
        // 광고보고 추가포인트 완료 다이얼로그
        Dialog(
            isDialogVisible: $isAddAdPointCompleteDialogOpened,
            positiveButtonText: "확인",
            negativeButtonText: "",
            onPositivebuttonClick: {},
            onNegativebuttonClick: {},
            onDismiss: {}
        ) {
            Text("광고를 보고 추가 포인트를\n")
                .font(.headline)
            + Text("지급받았습니다!")
                .font(.headline)
                .baselineOffset(-.small)
        }
    }
}
