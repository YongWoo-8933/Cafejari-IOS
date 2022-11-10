//
//  FAQView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/05.
//

import SwiftUI
import CachedAsyncImage

struct FAQView: View {
    
    @EnvironmentObject private var informationViewModel: InformationViewModel
    @EnvironmentObject private var coreState: CoreState
    
    @State private var selectedTabBarIndex = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    CustomTapCell(
                        selectedTabBarIndex: $selectedTabBarIndex,
                        name: "Q&A",
                        tabIntValue: 0
                    )
                    Spacer()
                    CustomTapCell(
                        selectedTabBarIndex: $selectedTabBarIndex,
                        name: "포인트 정책",
                        tabIntValue: 1
                    )
                    Spacer()
                    CustomTapCell(
                        selectedTabBarIndex: $selectedTabBarIndex,
                        name: "TMI",
                        tabIntValue: 2
                    )
                }
                .padding()
                
                TabView(selection: $selectedTabBarIndex) {
                    
                    InformationPage(
                        intro: "자주 물어보시는 질문입니다.",
                        paragraphs: informationViewModel.faqs,
                        symbol: "Q."
                    )
                    .tag(0)
                    
                    InformationPage(
                        intro: "저희 카페자리는 카페 혼잡도 정보를 제공해준 카페 마스터분들께 보상으로 포인트를 지급해 드리고 있으며, 구체적인 선정방식과 포인트의 사용 방법은 다음과 같습니다. 마스터 활동에 참고하시길 바랍니다 :)",
                        paragraphs: informationViewModel.pointPolicies,
                        symbol: "◼︎"
                    )
                    .tag(1)
                    
                    InformationPage(
                        intro: "물어보시진 않았지만 알려드리고 싶은 내용입니다 ☻",
                        paragraphs: informationViewModel.cautions,
                        symbol: "◼︎"
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("FAQ")
            }
            FullScreenLoadingView(loading: $informationViewModel.isInformationLoading, text: "로딩중..")
        }
        .task {
            informationViewModel.isInformationLoading = true
            await informationViewModel.getInfomations(coreState: coreState)
        }
    }
}


struct InformationPage: View {
    
    let intro: String
    let paragraphs: Paragraphs
    let symbol: String
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                Text("\(intro)".useNonBreakingSpace())
                
                VerticalSpacer(30)
                
                ForEach(paragraphs, id: \.content) { paragraph in
                    Text(symbol)
                    +
                    Text(" \(paragraph.title)")
                    
                    VerticalSpacer(15)
                    
                    if let image = paragraph.image {
                        CachedAsyncImage(url: URL(string: image)!) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                        } placeholder: {
                            Color.white
                        }
                        VerticalSpacer(15)
                    }
                    
                    Text(paragraph.content.useNonBreakingSpace())
                    
                    VerticalSpacer(30)
                }
            }
            .padding(10)
        }
        .scrollIndicators(.never)
    }
}

struct CustomTapCell: View {
    
    @Binding var selectedTabBarIndex: Int
    
    let name: String
    let tabIntValue: Int
    
    var body: some View {
        VStack(spacing: 5) {
            Text(name)
                .foregroundColor(selectedTabBarIndex == tabIntValue ? Color.black : Color.gray)
            if selectedTabBarIndex == tabIntValue {
                Rectangle()
                    .fill(.black)
                    .frame(maxWidth: 100)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                selectedTabBarIndex = tabIntValue
            }
        }
    }
}
