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
    
    @State private var selectedFaqOrder: Int = -1
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationTitle(
                    title: "FAQ",
                    leadingIconSystemName: "chevron.backward",
                    onLeadingIconClick: {
                        coreState.popUp()
                    }
                )
                
                if informationViewModel.faqs.isEmpty {
                    EmptyImageView("등록된 질문/답변이 없어요")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(informationViewModel.faqs, id: \.content) { paragraph in
                                VStack(alignment: .leading, spacing: .medium) {
                                    HStack(spacing: .small) {
                                        Text("Q. ")
                                            .font(.subtitle.bold())
                                        Text("\(paragraph.title)")
                                            .font(.headline.bold())
                                        Spacer()
                                        Image(systemName: selectedFaqOrder == paragraph.order ? "chevron.up" : "chevron.down")
                                            .font(.caption2.bold())
                                    }
                                    if selectedFaqOrder == paragraph.order {
                                        VerticalSpacer(.medium)
                                        Text(paragraph.content)
                                            .foregroundColor(.moreHeavyGray)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.moreLarge)
                                .onTapGesture {
                                    if selectedFaqOrder == paragraph.order {
                                        selectedFaqOrder = -1
                                    } else {
                                        selectedFaqOrder = paragraph.order
                                    }
                                }
                                Divider()
                            }
                        }
                        .animation(.easeInOut, value: selectedFaqOrder)
                    }
                    .scrollIndicators(.never)
                }
            }
            .frame(maxWidth: .infinity)
            
            FullScreenLoadingView(loading: $informationViewModel.isFaqsLoading, text: "로딩중..")
        }
        .navigationBarBackButtonHidden()
        .task {
            informationViewModel.isFaqsLoading = true
            await informationViewModel.getFaqs(coreState: coreState)
        }
    }
}

