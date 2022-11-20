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
    
    @Environment(\.openURL) private var openURL
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var loginViewModel: LoginViewModel
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    
    @State private var isAgreementCheckComplete: Bool = false
    @State private var isTosAgreed: Bool = false
    @State private var isPrivacyAgreed: Bool = false
    
    @State private var temp: String = "010"
    @State private var nickname: String = ""
    @State private var phoneNumber: String = ""
    @State private var authNumber: String = ""
    @State private var isAutoLoginOn: Bool = true
    @State private var isSmsSent: Bool = false
    @State private var isSmsAuthed: Bool = false
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationTitle(
                title: isAgreementCheckComplete ? "본인인증" : "약관동의",
                leadingIconSystemName: "chevron.backward"
            ) {
                coreState.popUp()
            }
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    VerticalSpacer(.moreLarge)
                    
                    if !isAgreementCheckComplete {
                        Text("회원가입 전 카페자리의 약관을 확인해주세요")
                            .font(.headline)
                        
                        VerticalSpacer(40)
                        
                        VStack(spacing: .large) {
                            HStack {
                                Text("약관 전체 동의")
                                    .font(.headline.bold())
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                HStack {
                                    if isTosAgreed && isPrivacyAgreed {
                                        Image(systemName: "checkmark")
                                            .font(.caption2.bold())
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(width: 16, height: 16)
                                .border(Color.secondary, width: 1)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: .short)) {
                                        if isPrivacyAgreed && isTosAgreed {
                                            isTosAgreed = false
                                            isPrivacyAgreed = false
                                        } else {
                                            isTosAgreed = true
                                            isPrivacyAgreed = true
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, .medium)
                            
                            Divider()
                            
                            HStack(spacing: 17) {
                                Text("필수")
                                    .font(.headline.bold())
                                    .foregroundColor(.heavyGray)
                                HStack(spacing: .medium) {
                                    Text("위치정보기반 서비스 이용약관")
                                        .font(.headline)
                                        .foregroundColor(.heavyGray)
                                        .onTapGesture {
                                            openURL(URL(string: loginViewModel.httpRoute.tos())!)
                                        }
                                    Image(systemName: "chevron.forward")
                                        .font(.caption2)
                                        .foregroundColor(.heavyGray)
                                }
                                Spacer()
                                CheckBox(isChecked: $isTosAgreed)
                            }
                            .padding(.horizontal, .medium)
                            
                            HStack(spacing: 17) {
                                Text("필수")
                                    .font(.headline.bold())
                                    .foregroundColor(.heavyGray)
                                HStack(spacing: .medium) {
                                    Text("개인정보 수집 및 이용동의")
                                        .font(.headline)
                                        .foregroundColor(.heavyGray)
                                        .onTapGesture {
                                            openURL(URL(string: loginViewModel.httpRoute.privacyPolicyAgreement())!)
                                        }
                                    Image(systemName: "chevron.forward")
                                        .font(.caption2)
                                        .foregroundColor(.heavyGray)
                                }
                                Spacer()
                                CheckBox(isChecked: $isPrivacyAgreed)
                            }
                            .padding(.horizontal, .medium)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VerticalSpacer(80)
                        
                        FilledCtaButton(text: "다음", backgroundColor: .secondary.opacity(isTosAgreed && isPrivacyAgreed ? 1 : 0.5)) {
                            withAnimation {
                                isAgreementCheckComplete = true
                            }
                        }
                        .disabled(!(isTosAgreed && isPrivacyAgreed))
                    } else {
                        VStack(alignment: .leading) {
                            TextField("닉네임", text: $nickname)
                                .textFieldStyle(SingleLineTextFieldStyle())
                                .focused($focusedField, equals: Field.nickname)
                            VStack(alignment: .leading, spacing: .small) {
                                Text(nickname.isNicknameLengthValid() ? "닉네임 길이가 적당합니다" : "닉네임은 2~10자로 정해주세요")
                                    .foregroundColor(nickname.isNicknameLengthValid() ? .lightGray : .textSecondary)
                                Text(nickname.hasSpecialChar() || nickname.isEmpty ? "특수문자 및 공백이 허용되지 않습니다" : "닉네임 구성이 유효합니다")
                                    .foregroundColor(nickname.hasSpecialChar() || nickname.isEmpty ? .textSecondary : .lightGray)
                            }
                        }
                        
                        VerticalSpacer(.moreLarge)
                        
                        VStack(alignment: .leading) {
                            GeometryReader { geo in
                                HStack(spacing: .medium) {
                                    TextField("010", text: $temp)
                                        .textFieldStyle(SingleLineTextFieldStyle())
                                        .disabled(true)
                                        .frame(width: geo.size.width / 4 - CGFloat.medium * 2)
                                    
                                    TextField("전화번호", text: $phoneNumber)
                                        .textFieldStyle(SingleLineTextFieldStyle())
                                        .frame(width: geo.size.width / 2)
                                        .keyboardType(.numberPad)
                                        .focused($focusedField, equals: Field.phoneNumber)
                                        .onChange(of: phoneNumber) { newValue in
                                            if(newValue.count == 8){
                                                focusedField = nil
                                            }
                                        }
                                    
                                    Button {
                                        isSmsAuthed = false
                                        Task {
                                            await loginViewModel.sendSms(coreState: coreState, phoneNumber: phoneNumber) {
                                                isSmsSent = true
                                            }
                                        }
                                    } label: {
                                        Text(isSmsSent ? "재요청" : "인증요청")
                                            .font(.headline.bold())
                                            .foregroundColor(.white)
                                            .frame(width: geo.size.width / 4, height: 60)
                                            .background(Color.moreHeavyGray.opacity(phoneNumber.count == 8 ? 1 : 0.5))
                                            .cornerRadius(.small)
                                    }
                                    .disabled(phoneNumber.count != 8)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(height: 60)
                            
                            Text(phoneNumber.count == 8 ? "전화번호가 유효합니다" : "하이픈(-) 없이 뒷번호 8자리를 입력해주세요")
                                .foregroundColor(phoneNumber.count == 8 ? .lightGray : .textSecondary)
                        }
                        
                        VerticalSpacer(.moreLarge)
                        
                        VStack(alignment: .leading) {
                            GeometryReader { geo in
                                HStack(spacing: .medium) {
                                    TextField("인증번호", text: $authNumber)
                                        .textFieldStyle(SingleLineTextFieldStyle())
                                        .frame(width: geo.size.width * 0.75 - CGFloat.medium)
                                        .keyboardType(.numberPad)
                                        .focused($focusedField, equals: Field.authNumber)
                                        .onChange(of: authNumber) { newValue in
                                            if(newValue.count == 6) {
                                                focusedField = nil
                                            }
                                        }
                                    
                                    Button {
                                        Task {
                                            await loginViewModel.authSms(coreState: coreState, phoneNumber: phoneNumber,authNumber: authNumber) {
                                                isSmsAuthed = true
                                            }
                                        }
                                    } label: {
                                        Text(isSmsAuthed ? "인증성공" : "인증")
                                            .font(.headline.bold())
                                            .foregroundColor(.white)
                                            .frame(width: geo.size.width / 4, height: 60)
                                            .background(Color.moreHeavyGray.opacity(authNumber.count == 6 && !isSmsAuthed ? 1 : 0.5))
                                            .cornerRadius(.small)
                                    }
                                    .disabled(authNumber.count != 6 || isSmsAuthed)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(height: 60)
                            
                            Text(authNumber.count == 6 ? "인증번호가 유효합니다" : "인증번호는 6자리 숫자입니다")
                                .foregroundColor(authNumber.count == 6 ? .lightGray : .textSecondary)
                        }
                        
                        VerticalSpacer(40)
                        
                        FilledCtaButton(
                            text: "회원가입 완료",
                            backgroundColor: .secondary.opacity(isTosAgreed && isPrivacyAgreed && isAgreementCheckComplete && !nickname.hasSpecialChar() && nickname.isNicknameLengthValid() && phoneNumber.count == 8 && authNumber.count == 6 && isSmsSent && isSmsAuthed ? 1 : 0.5),
                            isProgress: loginViewModel.isAuthorizeLoading
                        ) {
                            Task {
                                await loginViewModel.authorize(coreState: coreState,nickname: nickname, phoneNumber: phoneNumber) {
                                    await cafeViewModel.getCafeInfos(coreState: coreState)
                                }
                            }
                        }
                        .disabled(!(isTosAgreed && isPrivacyAgreed && isAgreementCheckComplete && !nickname.hasSpecialChar() && nickname.isNicknameLengthValid() && phoneNumber.count == 8 && authNumber.count == 6 && isSmsSent && isSmsAuthed))
                    }
                }
                .padding(.moreLarge)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .scrollIndicators(.never)
        }
        .navigationBarBackButtonHidden()
        .addKeyboardDownButton {
            focusedField = nil
        }
    }
}
