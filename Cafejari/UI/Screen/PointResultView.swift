//
//  PointResultView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/08.
//

import SwiftUI

struct PointResultView: View {
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    
    @State private var animationTrigger = false
    
    var body: some View {
        ZStack {
            HStack {
                Button {
                    coreState.tapToMap()
                    coreState.clearStack()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline.bold())
                        .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(20)
            
            VStack {
                VStack {
                    Image("money")
                        .resizable()
                        .scaledToFit()
                        .offset(x: 0, y: animationTrigger ? 0 : -400)
                }
                .frame(height: 160)
                
                switch coreState.pointResultViewType {
                case .masterExpired:
                    Text("다음부턴 광고를 보고 종료해보세요. 포인트가 1.5배!")
                        .foregroundColor(.gray)
                        .font(.caption)
                case .masterExpiredWithAd:
                    Text("광고를 보고 \(coreState.pointResultPoint / 3)P 더 얻었어요!")
                        .foregroundColor(.gray)
                        .font(.caption)
                default:
                    Text("광고보고 추천하시면 최대 4번까지 포인트를 얻을 수 있어요!")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                
                Text("\(coreState.pointResultPoint)P 획득")
                    .font(.title)
                
                if coreState.pointResultViewType != PointResultViewType.thumbsUp && coreState.pointResultViewType != PointResultViewType.thumbsUpWithAd {
                    Text("총 \(cafeViewModel.time.getPassingHourMinuteStringFromTo(timeStringFrom: coreState.masterRoomCafeLog.start, timeStringTo: coreState.masterRoomCafeLog.finish)) 활동")
                    .foregroundColor(.gray)
                    .font(.caption)
                }
                
                VerticalSpacer(60)
                
                Text("지금까지 내가 모은 포인트: \(coreState.user.point)P")
                    .foregroundColor(.gray)
                    .font(.caption)
                
                if coreState.pointResultViewType == PointResultViewType.thumbsUp || coreState.pointResultViewType == PointResultViewType.thumbsUpWithAd {
                    Button {
                        coreState.tapToShop()
                        coreState.clearStack()
                    } label: {
                        HStack {
                            Text("포인트 상점으로 가기")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.black)
                    }
                    Button {
                        coreState.clearStack()
                    } label: {
                        HStack {
                            Text("홈화면으로 가기")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.black)
                    }
                } else {
                    Button {
                        coreState.navigateWithClear(Screen.MasterDetail.route)
                        coreState.tapToProfile()
                    } label: {
                        HStack {
                            Text("내 마스터 활동 보러가기")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.black)
                    }
                    Button {
                        coreState.tapToLeaderBoard()
                        coreState.clearStack()
                    } label: {
                        HStack {
                            Text("마스터 랭크 보러가기")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.black)
                    }
                }
            }
            .padding(20)
        }
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

