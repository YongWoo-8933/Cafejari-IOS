//
//  PointResultView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/08.
//

import SwiftUI
import GoogleMobileAds

struct PointResultView: View {
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    
    @State private var animationTrigger = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: .medium) {
                VStack {
                    Image("coin")
                        .resizable()
                        .scaledToFit()
                        .offset(x: 0, y: animationTrigger ? -.moreLarge : -400)
                }
                .frame(height: 100)
                
                switch coreState.pointResultViewType {
                case .masterExpired:
                    Text("총 \(cafeViewModel.time.getPassingHourMinuteStringFromTo(timeStringFrom: coreState.masterRoomCafeLog.start, timeStringTo: coreState.masterRoomCafeLog.finish)) 활동")
                        .foregroundColor(.primary)
                    Text("\(coreState.pointResultPoint)P 획득")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                    VerticalSpacer(.small)
                    VStack(spacing: .small) {
                        Text("다음부턴 광고를 보고 종료해보세요")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("포인트가 1.5배!")
                            .font(.headline.bold())
                            .foregroundColor(.primary)
                    }
                case .masterExpiredWithAd:
                    Text("총 \(cafeViewModel.time.getPassingHourMinuteStringFromTo(timeStringFrom: coreState.masterRoomCafeLog.start, timeStringTo: coreState.masterRoomCafeLog.finish)) 활동")
                        .foregroundColor(.primary)
                    Text("\(coreState.pointResultPoint)P 획득")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                    VerticalSpacer(.small)
                    Text("광고를 보고 ")
                        .font(.headline)
                        .foregroundColor(.primary)
                    +
                    Text("\(coreState.pointResultPoint / 3)P")
                        .font(.headline.bold())
                        .foregroundColor(.primary)
                    +
                    Text(" 더 얻었어요!")
                        .font(.headline)
                        .foregroundColor(.primary)
                default:
                    Text("마스터 추천하고")
                        .foregroundColor(.primary)
                    Text("\(coreState.pointResultPoint)P 획득")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                    VerticalSpacer(.small)
                    VStack(spacing: .small) {
                        Text("광고보고 추천하시면 ")
                            .font(.headline)
                            .foregroundColor(.primary)
                        +
                        Text("최대 4번")
                            .font(.headline.bold())
                            .foregroundColor(.primary)
                        Text("포인트를 얻을 수 있어요!")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                
                VerticalSpacer(60)
                
                Text("지금까지 내가 모은 포인트: ")
                    .foregroundColor(.textSecondary)
                    .font(.headline)
                +
                Text("\(coreState.user.point)P")
                    .foregroundColor(.textSecondary)
                    .font(.headline.bold())
                
                VerticalSpacer(.small)
                
                if coreState.pointResultViewType == PointResultViewType.thumbsUp || coreState.pointResultViewType == PointResultViewType.thumbsUpWithAd {
                    FilledCtaButton(text: "포인트 상점으로 가기", backgroundColor: .primary) {
                        coreState.tapToShop()
                        coreState.clearStack()
                    }
                    BorderedCtaButton(text: "홈화면으로 가기") {
                        coreState.clearStack()
                    }
                } else {
                    FilledCtaButton(text: "마스터 랭크 보러가기", backgroundColor: .primary) {
                        coreState.tapToLeaderBoard()
                        coreState.clearStack()
                    }
                    BorderedCtaButton(text: "내 마스터 활동 보러가기") {
                        coreState.tapToProfile()
                        coreState.navigateWithClear(Screen.MasterDetail.route)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.moreLarge)
            .navigationBarBackButtonHidden()
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.4, blendDuration: 0.0)) {
                        animationTrigger.toggle()
                    }
                }
            }
        }
    }
}

