//
//  InquiryView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/05.
//

import SwiftUI

struct InquiryView: View {
    
    private enum Field {
        case inquiryEtc
    }
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var informationViewModel: InformationViewModel
    
    @State private var content = ""
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ScrollView {
            LazyVStack {
                Text("- 기타 문의를 위한 공간입니다 -")
                    .padding(.vertical, 30)
                HStack {
                    Text("문의 내용")
                        .frame(width: 80)
                    TextField("여러줄 작성이 가능합니다", text: $content, axis: .vertical)
                        .frame(maxWidth: .infinity)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: Field.inquiryEtc)
                }
                VerticalSpacer(36)
                Button {
                    Task {
                        await informationViewModel.submitInquiryEtc(coreState: coreState, content: content) {
                            content = ""
                            coreState.showSnackBar(message: "문의를 제출하였습니다. 가입하신 이메일로 빠른 시일내에 답변드리겠습니다")
                        }
                    }
                } label: {
                    Text("문의하기")
                        .foregroundColor(.white)
                        .padding()
                        .background(.brown)
                        .cornerRadius(5)
                }
            }
            .padding(.horizontal, 10)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("문의")
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button{
                    focusedField = nil
                } label: {
                    HStack{
                        Text("완료")
                        Image(systemName: "chevron.down")
                    }
                    .frame(width: 600)
                }
            }
        }
    }
}
