//
//  CafeInquiryView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/04.
//

import SwiftUI
import GoogleMobileAds

struct CafeInquiryView: View {
    private enum Field {
        case name, address
    }
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var informationViewModel: InformationViewModel
    @EnvironmentObject private var adViewModel: AdViewModel
    
    @State private var name = ""
    @State private var address = ""
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                NavigationTitle(
                    title: "카페 추가",
                    leadingIconSystemName: "xmark",
                    onLeadingIconClick: {
                        coreState.popUp()
                    },
                    trailingIconSystemName: "list.bullet.rectangle.portrait",
                    onTrailingIconClick: {
                        coreState.navigate(Screen.CafeInquiryResult.route)
                    }
                )
                
                VStack(alignment: .leading, spacing: 0) {
                    VerticalSpacer(.moreLarge)

                    TextField("등록할 카페(지점명 포함)", text: $name)
                        .textFieldStyle(SingleLineTextFieldStyle())
                        .focused($focusedField, equals: Field.name)

                    VerticalSpacer(.moreLarge)

                    TextField("주소(시, 구 포함)", text: $address)
                        .textFieldStyle(SingleLineTextFieldStyle())
                        .focused($focusedField, equals: Field.address)

                    VerticalSpacer(.medium)

                    Text("카페 지점명이 정확하다면 주소 생략 가능\nex) 스타벅스 xx역점")
                        .foregroundColor(.lightGray)

                    Spacer()

                    FilledCtaButton(text: "카페등록 요청", backgroundColor: .primary) {
                        focusedField = nil
                        if name.isEmpty {
                            coreState.showSnackBar(message: "등록할 카페 지점명을 입력해주세요", type: .info)
                        } else {
                            if address.isEmpty {
                                address = "_none"
                            }
                            Task {
                                await informationViewModel.submitInquiryCafe(coreState: coreState, name: name, address: address)
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
