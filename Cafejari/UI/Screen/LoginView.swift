//
//  LoginView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var loginViewModel: LoginViewModel
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    
    @State private var isTouchTextVisible = false
    @State private var isScreenTouched = false
    
    var body: some View {
        ZStack {
            Image("login_background")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                .clipped()
            ZStack {
                Text("아무곳이나 터치해보세요!")
                    .font(.title.bold())
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.4))
            .opacity(!isScreenTouched && isTouchTextVisible ? 1 : 0)
            .onTapGesture {
                withAnimation(.easeInOut(duration: .long)) {
                    isScreenTouched = true
                }
            }
            ZStack {
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.5))
            .opacity(isScreenTouched ? 1 : 0)
            
            if isScreenTouched {
                VStack(spacing: .large) {
                    Text("카페 혼잡도 확인하고 싶다면?")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    Text("10초 만에 회원가입 하세요")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    VerticalSpacer(.medium)
                    
                    KakaoLoginButton(isLoading: $loginViewModel.isKakaoLoginLoading) { accessToken in
                        Task{
                            await loginViewModel.loginWithKakao(
                                coreState: coreState,
                                kakaoAccessToken: accessToken
                            ) {
                                await cafeViewModel.checkMasterActivated(coreState: coreState)
                            }
                        }
                    } onFailure: { errorMessage in
                        print(errorMessage)
                    }
                    
                    GoogleLoginButton(isLoading: $loginViewModel.isGoogleLoginLoading) { email, code in
                        Task{
                            await loginViewModel.loginWithGoogle(coreState: coreState, email: email, code:code) {
                                await cafeViewModel.checkMasterActivated(coreState: coreState)
                            }
                        }
                    } onFailure: { errorMessage in
                        print(errorMessage)
                    }
                    
                    AppleLoginButton(isLoading: $loginViewModel.isAppleLoginLoading) { idToken, code in
                        Task {
                            await loginViewModel.loginWithApple(coreState: coreState, idToken: idToken, code: code) {
                                await cafeViewModel.checkMasterActivated(coreState: coreState)
                            }
                        }
                    } onFailure: { errorMessage in
                        print(errorMessage)
                    }
                }
                .padding(.moreLarge)
                .padding(.vertical, .moreLarge)
                .frame(width: UIScreen.main.bounds.size.width * 0.75)
                .background(Color.primary)
                .cornerRadius(.moreLarge)
            }
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                isTouchTextVisible.toggle()
            }
        }
    }
}
