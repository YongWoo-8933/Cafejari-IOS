//
//  CafeInquiryView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/04.
//

import SwiftUI

struct CafeInquiryView: View {
    private enum Field {
        case name, address
    }
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var informationViewModel: InformationViewModel
    
    @State private var name = ""
    @State private var address = ""
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ScrollView {
            LazyVStack {
                Text("- 새로운 카페를 등록하기 위한 공간입니다 -")
                    .padding(.vertical, 30)
                HStack(spacing: 15) {
                    VStack {
                        Text("요청 카페이름")
                        Text("(지점명 포함)")
                    }
                    .frame(width: 100)
                    
                    TextField("ex) 스타벅스 신촌점", text: $name)
                        .frame(maxWidth: .infinity)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: Field.name)
                }
                HStack(spacing: 15) {
                    VStack {
                        Text("주소")
                        Text("(시, 구 포함)")
                    }
                    .frame(width: 100)
                    
                    TextField("ex) 서울특별시 서대문구 연세로 1-1", text: $address)
                        .frame(maxWidth: .infinity)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: Field.address)
                }
                VerticalSpacer(36)
                Button {
                    Task {
                        await informationViewModel.submitInquiryCafe(coreState: coreState, name: name, address: address) {
                            name = ""
                            address = ""
                            coreState.showSnackBar(message: "카페 등록 요청을 제출하였습니다. 결과는 알림을 통해 알려드립니다")
                        }
                    }
                } label: {
                    Text("카페등록 요청")
                        .foregroundColor(.white)
                        .padding()
                        .background(.brown)
                        .cornerRadius(5)
                }
            }
            .padding(.horizontal, 10)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle("카페 등록")
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
