//
//  InquiryAnswerView.swift
//  Cafejari
//
//  Created by 안용우 on 2023/01/23.
//

import SwiftUI

struct InquiryAnswerView: View {
    @EnvironmentObject private var informationViewModel: InformationViewModel
    @EnvironmentObject private var coreState: CoreState
    
    @State private var selectedInquiryId: Int = 0
    @State private var selectedDeleteInquiryId: Int = 0
    @State private var isDeleteDialogOpened: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationTitle(
                    title: "내 문의 내용",
                    leadingIconSystemName: "chevron.backward",
                    onLeadingIconClick: {
                        coreState.popUp()
                    }
                )
                
                if informationViewModel.myInquiryEtcs.isEmpty {
                    EmptyImageView("문의한 내용이 없어요")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(informationViewModel.myInquiryEtcs, id: \.id) { inquiryEtc in
                                Button {
                                    if selectedInquiryId == inquiryEtc.id {
                                        selectedInquiryId = 0
                                    } else {
                                        selectedInquiryId = inquiryEtc.id
                                    }
                                } label: {
                                    VStack(alignment: .leading, spacing: .medium) {
                                        HStack(spacing: .small) {
                                            VStack(alignment: .leading, spacing: 0) {
                                                Text(inquiryEtc.requestDate)
                                                    .font(.body.bold())
                                                    .foregroundColor(.gray)
                                                VerticalSpacer(.medium)
                                                Text("\(inquiryEtc.content)")
                                                    .multilineTextAlignment(.leading)
                                            }
                                            .frame(width: UIScreen.main.bounds.size.width * 0.85, alignment: .leading)
                                            Image(systemName: selectedInquiryId == inquiryEtc.id ? "chevron.up" : "chevron.down")
                                                .font(.caption2.bold())
                                        }
                                        if selectedInquiryId == inquiryEtc.id {
                                            VerticalSpacer(.medium)
                                            Text(inquiryEtc.answer.isEmpty ? "💬  아직 문의를 확인하지 못했어요" : "[답변]  " + inquiryEtc.answer)
                                                .foregroundColor(.moreHeavyGray)
                                                .multilineTextAlignment(.leading)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.moreLarge)
                                }
                                .simultaneousGesture(
                                    LongPressGesture()
                                        .onEnded { _ in
                                            selectedDeleteInquiryId = inquiryEtc.id
                                            isDeleteDialogOpened = true
                                        }
                                )
                                Divider()
                            }
                        }
                        .animation(.easeInOut, value: selectedInquiryId)
                    }
                    .scrollIndicators(.never)
                }
            }
            .frame(maxWidth: .infinity)
            
            FullScreenLoadingView(loading: $informationViewModel.isMyInquiryEtcLoading, text: "로딩중..")
            
            Dialog(
                isDialogVisible: $isDeleteDialogOpened,
                positiveButtonText: "삭제",
                negativeButtonText: "취소",
                onPositivebuttonClick: {
                    Task {
                        await informationViewModel.deleteInquiryEtc(coreState: coreState, selectedInquiryEtcId: selectedInquiryId)
                    }
                    selectedDeleteInquiryId = 0
                },
                onNegativebuttonClick: { selectedDeleteInquiryId = 0 },
                onDismiss: { selectedDeleteInquiryId = 0 }
            ) {
                return Text("문의 내역을 삭제하시겠습니까?")
                    .font(.headline)
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            await informationViewModel.getMyInquiryEtcs(coreState: coreState)
        }
    }
}
