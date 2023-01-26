//
//  CafeInquiryResultView.swift
//  Cafejari
//
//  Created by 안용우 on 2023/01/23.
//

import SwiftUI

struct CafeInquiryResultView: View {
    
    @EnvironmentObject private var informationViewModel: InformationViewModel
    @EnvironmentObject private var coreState: CoreState
    
    @State private var selectedInquiryId: Int = 0
    @State private var selectedDeleteInquiryId: Int = 0
    @State private var isDeleteDialogOpened: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavigationTitle(
                    title: "등록 요청한 카페",
                    leadingIconSystemName: "chevron.backward",
                    onLeadingIconClick: {
                        coreState.popUp()
                    }
                )
                
                if informationViewModel.myInquiryCafes.isEmpty {
                    EmptyImageView("등록 요청한 카페가 없어요")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(informationViewModel.myInquiryCafes, id: \.id) { inquiryCafe in
                                Button {
                                    if selectedInquiryId == inquiryCafe.id {
                                        selectedInquiryId = 0
                                    } else {
                                        selectedInquiryId = inquiryCafe.id
                                    }
                                } label: {
                                    VStack(alignment: .leading, spacing: .medium) {
                                        HStack(spacing: .small) {
                                            VStack(alignment: .leading, spacing: 0) {
                                                Text(inquiryCafe.requestDate)
                                                    .font(.body.bold())
                                                    .foregroundColor(.gray)
                                                VerticalSpacer(.medium)
                                                Text("\(inquiryCafe.name)")
                                                    .font(.headline.bold())
                                                VerticalSpacer(.small)
                                                Text("\(inquiryCafe.address)")
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            Image(systemName: selectedInquiryId == inquiryCafe.id ? "chevron.up" : "chevron.down")
                                                .font(.caption2.bold())
                                        }
                                        if selectedInquiryId == inquiryCafe.id {
                                            VerticalSpacer(.medium)
                                            Text(inquiryCafe.result.isEmpty ? "💬  아직 등록 요청을 확인하지 못했어요" : "[처리됨]  " + inquiryCafe.result)
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
                                            selectedDeleteInquiryId = inquiryCafe.id
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
            
            FullScreenLoadingView(loading: $informationViewModel.isMyInquiryCafeLoading, text: "로딩중..")
            
            Dialog(
                isDialogVisible: $isDeleteDialogOpened,
                positiveButtonText: "삭제",
                negativeButtonText: "취소",
                onPositivebuttonClick: {
                    Task {
                        await informationViewModel.deleteInquiryCafe(coreState: coreState, selectedInquiryCafeId: selectedInquiryId)
                    }
                    selectedDeleteInquiryId = 0
                },
                onNegativebuttonClick: { selectedDeleteInquiryId = 0 },
                onDismiss: { selectedDeleteInquiryId = 0 }
            ) {
                return Text("카페 등록요청 기록을\n")
                    .font(.headline)
                +
                Text("삭제하시겠습니까?")
                    .font(.headline)
                    .baselineOffset(-.small)
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            await informationViewModel.getMyInquiryCafes(coreState: coreState)
        }
    }
}
