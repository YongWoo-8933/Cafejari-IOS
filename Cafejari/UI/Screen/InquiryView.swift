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
                NavigationTitle(
                    title: "1:1 문의",
                    leadingIconSystemName: "chevron.backward",
                    onLeadingIconClick: {
                        coreState.popUp()
                    },
                    trailingIconSystemName: "list.bullet.rectangle.portrait",
                    onTrailingIconClick: {
                        coreState.navigate(Screen.InquiryAnswer.route)
                    }
                )
                VStack(spacing: 0) {
                    VerticalSpacer(.moreLarge)
                    
                    TextField("문의하고 싶은 내용을 자세히 작성해주세요", text: $content, axis: .vertical)
                        .textFieldStyle(MultiLineTextFieldStyle())
                        .focused($focusedField, equals: Field.inquiryEtc)
                    
                    Spacer()
                    
                    FilledCtaButton(text: "문의하기", backgroundColor: .primary) {
                        focusedField = nil
                        if content.isEmpty {
                            coreState.showSnackBar(message: "문의할 내용을 입력해주세요", type: .info)
                        } else {
                            Task {
                                await informationViewModel.submitInquiryEtc(coreState: coreState, content: content)
                            }
                        }
                    }
                    
                    VerticalSpacer(.moreLarge)
                }
                .padding(.moreLarge)
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
