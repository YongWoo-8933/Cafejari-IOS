//
//  OnboardingDialog.swift
//  Cafejari
//
//  Created by 안용우 on 2022/12/18.
//

import SwiftUI

struct OnboardingUnit {
    let index: Int
    let title: String
    let content1: String
    let content2: String
    let content3: String
    let imageSystemName: String
}

extension OnboardingUnit {
    static let pages = [
        OnboardingUnit(
            index: 0,
            title: "혼잡도를 확인해보세요",
            content1: "지도에서 '혼잡도 확인' 버튼을 통해",
            content2: "실시간 혼잡도를 쉽게",
            content3: "확인하실 수 있습니다",
            imageSystemName: "onboarding_0"
        ),
        OnboardingUnit(
            index: 1,
            title: "혼잡도를 직접 공유하세요",
            content1: "지도에서 '혼잡도 공유' 버튼을 통해",
            content2: "이용하고 계시는 카페의",
            content3: "혼잡도를 공유할 수 있어요",
            imageSystemName: "onboarding_1"
        ),
        OnboardingUnit(
            index: 2,
            title: "포인트를 모아보세요",
            content1: "혼잡도를 직접 공유하시면",
            content2: "활동 시간에 따라",
            content3: "포인트를 지급해드려요",
            imageSystemName: "onboarding_2"
        ),
        OnboardingUnit(
            index: 3,
            title: "카페를 추가하세요",
            content1: "원하는 카페가 지도에 없다면",
            content2: "'카페추가' 버튼을 통해",
            content3: "등록 요청해보세요",
            imageSystemName: "onboarding_3"
        )
    ]
}

struct OnboardingDialog: View {
    @Binding var isDialogVisible: Bool
    
    @State private var currentPage = 0
    
    var body: some View {
        let width = UIScreen.main.bounds.size.width * 0.7
        ZStack {
            ZStack {
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black.opacity(0.5))
            .opacity(isDialogVisible ? 1 : 0)
            
            VStack(spacing: 0) {
                VerticalSpacer(.moreLarge)
                
                ZStack {
                    HStack(spacing: .small) {
                        ForEach(OnboardingUnit.pages, id: \.index) { unit in
                            if currentPage == unit.index {
                                Image("stamp_icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: .moreLarge)
                            } else {
                                Image(systemName: "circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: .large)
                            }
                        }
                    }
                    .animation(.easeInOut, value: currentPage)
                    if currentPage == 3 {
                        HStack {
                            Spacer()
                            Image(systemName: "xmark")
                                .font(.title.bold())
                                .onTapGesture {
                                    isDialogVisible = false
                                }
                        }
                    }
                }
                
                VerticalSpacer(.moreLarge)
                VerticalSpacer(.moreLarge)
                
                TabView(selection: $currentPage) {
                    ForEach(OnboardingUnit.pages, id: \.index) { unit in
                        VStack(spacing: 0) {
                            Text(unit.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            VerticalSpacer(28)
                            
                            Text(unit.content1)
                                .font(.headline)
                                .foregroundColor(.moreHeavyGray)
                            
                            VerticalSpacer(.small)
                            
                            Text(unit.content2)
                                .font(.headline)
                                .foregroundColor(.moreHeavyGray)
                            
                            VerticalSpacer(.small)
                            
                            Text(unit.content3)
                                .font(.headline)
                                .foregroundColor(.moreHeavyGray)
                            
                            VerticalSpacer(.large)
                            
                            Image(unit.imageSystemName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 360)
                        }
                        .tag(unit.index)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                .frame(height: 490)
            }
            .frame(width: width)
            .padding(.horizontal, .moreLarge)
            .background(.white)
            .cornerRadius(.moreLarge)
            .shadow(radius: 3)
            .opacity(isDialogVisible ? 1 : 0)
        }
        .edgesIgnoringSafeArea(.all)
        .animation(.easeInOut, value: isDialogVisible)
    }
    
}
