//
//  AuthView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI

struct AuthView: View {
    
    private enum Field: Int, CaseIterable {
        case nickname, phoneNumber, authNumber
    }
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var userViewModel: UserViewModel
    
    @State private var nickname: String = ""
    @State private var phoneNumber: String = ""
    @State private var authNumber: String = ""
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(alignment: .leading){
            TextField("닉네임", text: $nickname)
                .textFieldStyle(.roundedBorder)
                .focused($focusedField, equals: Field.nickname)
            
            Text("  닉네임 유효성 코멘트")
                .font(.footnote)
                .foregroundColor(.gray)
            
            HStack{
                Text("010")
                
                TextField("전화번호", text: $phoneNumber)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 180)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: Field.phoneNumber)
                    .onChange(of: phoneNumber) { newValue in
                        if(newValue.count == 8){
                            focusedField = nil
                        }
                    }
                Button{
                    Task {
                        await userViewModel.sendSms(coreState: coreState, phoneNumber: phoneNumber)
                    }
                }label: {
                    Text("전송")
                        .foregroundColor(.white)
                        .padding(8)
                }
                .background(.gray)
                .cornerRadius(5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("  전화번호 유효성 코멘트")
                .font(.footnote)
                .foregroundColor(.gray)
            
            HStack{
                TextField("인증번호", text: $authNumber)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 180)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: Field.authNumber)
                    .onChange(of: authNumber) { newValue in
                        if(newValue.count == 6){
                            focusedField = nil
                        }
                    }
                Button{
                    Task {
                        await userViewModel.authSms(
                            coreState: coreState, phoneNumber: phoneNumber, authNumber: authNumber
                        )
                    }
                }label: {
                    Text("인증")
                        .foregroundColor(.white)
                        .padding(8)
                }
                .background(.gray)
                .cornerRadius(5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("  인증번호 유효성 코멘트")
                .font(.footnote)
                .foregroundColor(.gray)
            
            Button{
                Task {
                    await userViewModel.authorize(coreState: coreState, nickName: nickname, phoneNumber: phoneNumber)
                }
            }label: {
                Text("등록")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
            .background(.brown)
            .cornerRadius(8)
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationTitle("인증")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button{
                    focusedField = nil
                }label: {
                    HStack{
                        Text("완료")
                        Image(systemName: "chevron.down")
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
