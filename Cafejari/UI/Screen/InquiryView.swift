//
//  InquiryView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/05.
//

import SwiftUI
import GoogleMobileAds

struct InquiryView: View {
    
    private enum Field {
        case inquiryEtc
    }
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var informationViewModel: InformationViewModel
    @EnvironmentObject private var adViewModel: AdViewModel
    
    @State private var content = ""
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                NavigationTitle(title: "1:1 문의", leadingIconSystemName: "chevron.backward") {
                    coreState.popUp()
                }
                ScrollView {
                    LazyVStack(spacing: 0) {
                        VerticalSpacer(.moreLarge)
                        
                        Text("궁금한 점이 생기면 언제든 문의하세요")
                            .font(.headline.bold())
                        
                        VerticalSpacer(40)
                        
                        TextField("문의하고 싶은 내용을 자세히 작성해주세요", text: $content, axis: .vertical)
                            .textFieldStyle(MultiLineTextFieldStyle())
                            .focused($focusedField, equals: Field.inquiryEtc)
                        
                        VerticalSpacer(40)
                        
                        FilledCtaButton(text: "문의하기", backgroundColor: .primary) {
                            if content.isEmpty {
                                coreState.showSnackBar(message: "문의할 내용을 입력해주세요", type: .info)
                            } else {
                                Task {
                                    await informationViewModel.submitInquiryEtc(coreState: coreState, content: content)
                                }
                            }
                        }
                    }
                    .padding(.moreLarge)
                }
                .navigationBarBackButtonHidden()
                .addKeyboardDownButton {
                    focusedField = nil
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            AdBannerView()
                .frame(width: UIScreen.main.bounds.width, height: GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width).size.height)
                .offset(x: 0, y: .moreLarge)
        }
        .task {
            adViewModel.loadBanner()
        }
    }
}
