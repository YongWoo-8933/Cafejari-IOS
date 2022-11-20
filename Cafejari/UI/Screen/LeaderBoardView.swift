//
//  LeaderBoardView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/04.
//

import SwiftUI

struct LeaderBoardView: View {
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var userViewModel: UserViewModel
    
    @State private var isMonthLeaderOn: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                NavigationTitle(title: "마스터 랭크", leadingIconSystemName: "", onLeadingIconClick: {})
                
                VStack(spacing: 0) {
                    VerticalSpacer(.medium)
                    
                    Text("명예의 카페지기")
                        .font(.headline.bold())
                    
                    VerticalSpacer(30)
                    
                    HStack(alignment: .bottom, spacing: .medium) {
                        if userViewModel.isLeaderLoading {
                            ProgressView()
                                .frame(height: 80)
                        } else {
                            let leaders = isMonthLeaderOn ? userViewModel.monthLeaders : userViewModel.weekLeaders
                            
                            if leaders.count >= 3 {
                                VStack(spacing: .small) {
                                    let secondLeader = leaders[1]
                                    Text("TOP2")
                                        .font(.system(size: 14, weight: .heavy))
                                        .foregroundColor(.primary)
                                    
                                    RoundProfileImage(image: secondLeader.image, size: 80)
                                        .roundBorder(cornerRadius: 40, lineWidth: 1.5, borderColor: .primary)
                                    
                                    VerticalSpacer(.small)
                                    
                                    Text(secondLeader.nickname)
                                    Text("\(userViewModel.time.getPassingHourMinuteStringFromSeconds(seconds: secondLeader.activity)) 활동")
                                        .font(.caption.bold())
                                }
                                .frame(width: 85)
                                Spacer()
                                VStack(spacing: .small) {
                                    let firstLeader = leaders[0]
                                    Text("TOP1")
                                        .font(.system(size: 16, weight: .heavy))
                                        .foregroundColor(.primary)
                                    
                                    RoundProfileImage(image: firstLeader.image, size: 100)
                                        .roundBorder(cornerRadius: 50, lineWidth: 1.5, borderColor: .primary)
                                    
                                    VerticalSpacer(.small)
                                    
                                    Text(firstLeader.nickname)
                                    Text("\(userViewModel.time.getPassingHourMinuteStringFromSeconds(seconds: firstLeader.activity)) 활동")
                                        .font(.caption.bold())
                                }
                                .frame(width: 105)
                                Spacer()
                                VStack(spacing: .small) {
                                    let thirdLeader = leaders[2]
                                    Text("TOP3")
                                        .font(.system(size: 14, weight: .heavy))
                                        .foregroundColor(.primary)
                                    
                                    RoundProfileImage(image: thirdLeader.image, size: 80)
                                        .roundBorder(cornerRadius: 40, lineWidth: 1.5, borderColor: .primary)
                                    
                                    VerticalSpacer(.small)
                                    
                                    Text(thirdLeader.nickname)
                                    Text("\(userViewModel.time.getPassingHourMinuteStringFromSeconds(seconds: thirdLeader.activity)) 활동")
                                        .font(.caption.bold())
                                }
                                .frame(width: 85)
                            } else {
                                Text(isMonthLeaderOn ? "이번달 랭커가 아직 없습니다" : "이번주 랭커가 아직 없습니다")
                                    .foregroundColor(.primary)
                                    .frame(height: 80)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                }
                .padding(.moreLarge)
                
                HStack(spacing: 0) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isMonthLeaderOn = false
                        }
                    } label: {
                        Text("주간")
                            .font(.headline.bold())
                            .foregroundColor(isMonthLeaderOn ? .heavyGray : .primary)
                            .frame(width: geo.size.width / 2, height: 40)
                    }
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isMonthLeaderOn = true
                        }
                    } label: {
                        Text("월간")
                            .font(.headline.bold())
                            .foregroundColor(isMonthLeaderOn ? .primary : .heavyGray)
                            .frame(width: geo.size.width / 2, height: 40)
                    }
                }
                .frame(maxWidth: .infinity)
                
                HStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Color.primary
                    }
                    .frame(width: geo.size.width / 2, height: .small)
                }
                .frame(width: geo.size.width, height: .small, alignment: isMonthLeaderOn ? .trailing : .leading)
                
                if userViewModel.isLeaderLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            let leaders = isMonthLeaderOn ? userViewModel.monthLeaders : userViewModel.weekLeaders
                            ForEach(leaders, id: \.nickname) { leader in
                                if leader.ranking > 3 {
                                    HStack(spacing: 0) {
                                        Text(String(leader.ranking))
                                            .font(.headline.bold())
                                        HorizontalSpacer(.moreLarge)
                                        RoundProfileImage(image: leader.image, size: 40)
                                        HorizontalSpacer(.large)
                                        Text(leader.nickname)
                                            .font(.headline)
                                        Spacer()
                                        Text("\(userViewModel.time.getPassingHourMinuteStringFromSeconds(seconds: leader.activity))")
                                            .font(.body.bold())
                                    }
                                    .padding(.horizontal, .moreLarge)
                                    .padding(.vertical, .medium)
                                }
                            }
                        }
                        .padding(.vertical, .large)
                    }
                    .background(Color.backgroundGray)
                }
            }
            .animation(.easeInOut(duration: .short), value: isMonthLeaderOn)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .task {
                if userViewModel.weekLeaders.isEmpty || userViewModel.monthLeaders.isEmpty {
                    await userViewModel.getLeaders(coreState: coreState)
                }
            }
        }
    }
}
