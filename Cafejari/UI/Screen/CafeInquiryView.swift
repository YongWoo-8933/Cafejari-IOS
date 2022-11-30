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
                NavigationTitle(title: "카페 추가", leadingIconSystemName: "xmark") {
                    coreState.popUp()
                }
                ScrollView {
                    LazyVStack(spacing: 0) {
                        VerticalSpacer(.moreLarge)
                        
                        Text("새로운 카페를 등록해보세요")
                            .font(.headline.bold())
                        
                        VerticalSpacer(40)
                        
                        TextField("등록할 카페 이름(지점명 포함)", text: $name)
                            .textFieldStyle(SingleLineTextFieldStyle())
                            .focused($focusedField, equals: Field.name)
                        
                        VerticalSpacer(.moreLarge)
                        
                        TextField("주소(시, 구 포함)", text: $address)
                            .textFieldStyle(SingleLineTextFieldStyle())
                            .focused($focusedField, equals: Field.address)
                        
                        VerticalSpacer(40)
                        
                        FilledCtaButton(text: "카페등록 요청", backgroundColor: .primary) {
                            if name.isEmpty {
                                coreState.showSnackBar(message: "등록할 카페 지점명을 입력해주세요", type: .info)
                            } else if address.isEmpty {
                                coreState.showSnackBar(message: "등록할 카페의 주소를 입력해주세요", type: .info)
                            } else {
                                Task {
                                    await informationViewModel.submitInquiryCafe(coreState: coreState, name: name, address: address)
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
