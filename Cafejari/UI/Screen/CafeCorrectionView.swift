//
//  CafeCorrectionView.swift
//  Cafejari
//
//  Created by 안용우 on 2023/02/23.
//

import SwiftUI

struct CafeCorrectionView: View {
    
    private enum Field {
        case storeInfo
        case openingHour
        case wallSocket
        case restroom
    }
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var informationViewModel: InformationViewModel
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    
    @State private var storeInfoContent = ""
    @State private var openingHourContent = ""
    @State private var wallSocketContent = ""
    @State private var restroomContent = ""
    
    @State private var isDialogOpened = false
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationTitle(
                    title: "카페정보 제보하기",
                    leadingIconSystemName: "chevron.backward",
                    onLeadingIconClick: {
                        coreState.popUp()
                    }
                )
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        VerticalSpacer(.medium)

                        HStack(spacing: .large) {
                            Image("coffee_bean_marker")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24)

                            Text(cafeViewModel.modalCafeInfo.name)
                                .font(.headline.bold())
                                .foregroundColor(.primary)
                        }
                        .padding(.moreLarge)

                        VStack(alignment: .leading, spacing: .small) {
                            TextField("영업 여부", text: $storeInfoContent, axis: .vertical)
                                .textFieldStyle(ThreeLineTextFieldStyle())
                                .focused($focusedField, equals: Field.storeInfo)

                            Text("ex-1) 이 카페는 현재 영업중이 아니에요")
                                .foregroundColor(.lightGray)
                                .font(.caption)

                            Text("ex-2) 이 자리에 다른 이름을 가진 카페가 생겼어요")
                                .foregroundColor(.lightGray)
                                .font(.caption)

                            VerticalSpacer(32)
                        }
                        .padding(.horizontal, .moreLarge)

                        VStack(alignment: .leading, spacing: .small) {
                            TextField("영업 시간", text: $openingHourContent, axis: .vertical)
                                .textFieldStyle(ThreeLineTextFieldStyle())
                                .focused($focusedField, equals: Field.openingHour)

                            Text("ex-1) 매일 9-22시")
                                .foregroundColor(.lightGray)
                                .font(.caption)

                            Text("ex-2) 평일: 9-22시, 주말: 10-18시")
                                .foregroundColor(.lightGray)
                                .font(.caption)

                            VerticalSpacer(32)
                        }
                        .padding(.horizontal, .moreLarge)

                        VStack(alignment: .leading, spacing: .small) {
                            TextField("콘센트 정보", text: $wallSocketContent, axis: .vertical)
                                .textFieldStyle(ThreeLineTextFieldStyle())
                                .focused($focusedField, equals: Field.wallSocket)

                            Text("ex-1) 테이블 대비 80%정도 보급됨")
                                .foregroundColor(.lightGray)
                                .font(.caption)

                            Text("ex-2) 1층: 테이블 대비 70%, 2층: 테이블 대비 90%")
                                .foregroundColor(.lightGray)
                                .font(.caption)

                            VerticalSpacer(32)
                        }
                        .padding(.horizontal, .moreLarge)

                        VStack(alignment: .leading, spacing: .small) {
                            TextField("화장실 정보", text: $restroomContent, axis: .vertical)
                                .textFieldStyle(ThreeLineTextFieldStyle())
                                .focused($focusedField, equals: Field.restroom)

                            Text("ex-1) 1층에 공용화장실이 있어요")
                                .foregroundColor(.lightGray)
                                .font(.caption)

                            Text("ex-2) 1층에 남자화장실, 2층에 여자화장실 있음")
                                .foregroundColor(.lightGray)
                                .font(.caption)

                            VerticalSpacer(32)
                        }
                        .padding(.horizontal, .moreLarge)

                        VerticalSpacer(.moreLarge)

                        FilledCtaButton(text: "제보하기", backgroundColor: .primary) {
                            focusedField = nil
                            if storeInfoContent.isEmpty && openingHourContent.isEmpty && wallSocketContent.isEmpty && restroomContent.isEmpty {
                                coreState.showSnackBar(message: "적어도 하나의 내용을 작성해주세요", type: .error)
                            } else {
                                if storeInfoContent.isEmpty {
                                    storeInfoContent = "_none"
                                }
                                if openingHourContent.isEmpty {
                                    openingHourContent = "_none"
                                }
                                if wallSocketContent.isEmpty {
                                    wallSocketContent = "_none"
                                }
                                if restroomContent.isEmpty {
                                    restroomContent = "_none"
                                }
                                isDialogOpened = true
                            }
                        }
                        .padding(.moreLarge)

                        VerticalSpacer(40)
                    }
                }
                .scrollIndicators(.never)
            }
            .navigationBarBackButtonHidden()
            .addKeyboardDownButton {
                focusedField = nil
            }

            Dialog(
                isDialogVisible: $isDialogOpened,
                positiveButtonText: "제보하기",
                negativeButtonText: "",
                onPositivebuttonClick: {
                    Task {
                        await informationViewModel.submitInquiryCafeAdditionalInfo(
                            coreState: coreState,
                            cafeInfoIndex: cafeViewModel.modalCafeInfo.id,
                            storeInfoContent: storeInfoContent,
                            openingHourContent: openingHourContent,
                            wallSocketContent: wallSocketContent,
                            restroomContent: restroomContent
                        )
                    }
                },
                onNegativebuttonClick: {},
                onDismiss: {}
            ) {
                Text("제보하신 정보가 적용되면\n")
                    .font(.headline)
                +
                Text("100P")
                    .font(.headline.bold())
                    .baselineOffset(-.small)
                +
                Text("를 지급해드립니다!\n")
                    .font(.headline)
                    .baselineOffset(-.small)
                +
                Text("적용 여부는 알림으로 알려드리고,\n")
                    .font(.headline)
                    .baselineOffset(-.small)
                +
                Text("포인트 내역에서도 확인 가능합니다")
                    .font(.headline)
                    .baselineOffset(-.small)
            }
        }
    }
}
