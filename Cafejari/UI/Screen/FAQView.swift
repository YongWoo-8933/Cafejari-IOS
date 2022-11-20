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
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationTitle(title: "FAQ", leadingIconSystemName: "chevron.backward") {
                    coreState.popUp()
                }
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 56) {
                        Text("자주 물어보시는 질문 및 서비스에 대한 여러가지 정보를 확인해보세요.")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 28) {
                            ForEach(informationViewModel.faqs, id: \.content) { paragraph in
                                VStack(alignment: .leading, spacing: .large) {
                                    Text("Q. \(paragraph.title)")
                                        .font(.body.bold())
                                    Text("\(paragraph.content)")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 28) {
                            ForEach(informationViewModel.pointPolicies, id: \.content) { paragraph in
                                VStack(alignment: .leading, spacing: .large) {
                                    Text("◼︎ \(paragraph.title)")
                                        .font(.body.bold())
                                    if let image = paragraph.image {
                                        CachedAsyncImage(url: URL(string: image)!) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxWidth: .infinity)
                                        } placeholder: {
                                            Color.white
                                        }
                                    }
                                    Text("\(paragraph.content)")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 28) {
                            ForEach(informationViewModel.cautions, id: \.content) { paragraph in
                                VStack(alignment: .leading, spacing: .large) {
                                    Text("◼︎ \(paragraph.title)")
                                        .font(.body.bold())
                                    Text("\(paragraph.content)")
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.moreLarge)
                }
            }
            .frame(maxWidth: .infinity)
            
            FullScreenLoadingView(loading: $informationViewModel.isInformationLoading, text: "로딩중..")
        }
        .navigationBarBackButtonHidden()
        .task {
            informationViewModel.isInformationLoading = true
            await informationViewModel.getInfomations(coreState: coreState)
        }
    }
}

