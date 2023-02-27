//
//  ThumbsUpDialog.swift
//  Cafejari
//
//  Created by 안용우 on 2023/02/25.
//

import SwiftUI

struct ThumbsUpDialog: View {
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    @EnvironmentObject private var adViewModel: AdViewModel
    
    var body: some View {
        
        Dialog(
            isDialogVisible: $cafeViewModel.isThumbsUpDialogOpened,
            positiveButtonText: "빨리 볼게요",
            negativeButtonText: "그냥 추천할래요",
            onPositivebuttonClick: {
                adViewModel.showRewardedInterstitial(
                    willShowRewardedInterstitial: {  },
                    onAdWatched: {
                        Task {
                            await cafeViewModel.thumbsUp (
                                coreState: coreState,
                                recentLogId: cafeViewModel.thumbsUpRecentLog.id,
                                isAdWatched: true,
                                onSuccess: {
                                    cafeViewModel.isBottomSheetOpened = false
                                    Task {
                                        await cafeViewModel.getNearbyCafeInfos(coreState: coreState)
                                    }
                                }
                            )
                        }
                    },
                    onFail: {
                        cafeViewModel.showModalSnackBar(
                            message: "광고가 준비중입니다. 잠시후에 시도하시거나 일반 추천을 활용해주세요", type: .error)
                    }
                )
            },
            onNegativebuttonClick: {
                Task {
                    await cafeViewModel.thumbsUp (
                        coreState: coreState,
                        recentLogId: cafeViewModel.thumbsUpRecentLog.id,
                        isAdWatched: false,
                        onSuccess: {
                            cafeViewModel.isBottomSheetOpened = false
                            Task {
                                await cafeViewModel.getNearbyCafeInfos(coreState: coreState)
                            }
                        }
                    )
                }
            },
            onDismiss: {
                cafeViewModel.isThumbsUpDialogOpened = false
            }
        ) {
            Text("광고 보고 추천시 ")
                .font(.headline)
            +
            Text("최대 4번")
                .font(.headline.bold())
            +
            Text("\n추천이 가능해요!")
                .font(.headline)
            +
            Text("\n\n*추천시 포인트 지급")
                .foregroundColor(.moreHeavyGray)
        }
    }
}
