//
//  LoginView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var cafeViewModel: CafeViewModel
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("login_background")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width)
                VStack {
                    Text("카페자리에 오신것을 환영함돠\n로그인하고 활용해보십쇼")
                        .font(.title3)
                        .foregroundColor(.white)
                    KakaoLoginButton(isLoading: $userViewModel.isKakaoLoginLoading) { accessToken in
                        Task{
                            await userViewModel.loginWithKakao(
                                coreState: coreState,
                                kakaoAccessToken: accessToken
                            ) {
                                await cafeViewModel.checkMasterActivated(coreState: coreState)
                            }
                        }
                        coreState.navigate(Screen.Auth.route)
                    } onFailure: { errorMessage in
                        print(errorMessage)
                    }
                    
                    GoogleLoginButton(isLoading: $userViewModel.isGoogleLoginLoading) { email, code in
                        Task{
                            await userViewModel.loginWithGoogle(coreState: coreState, email: email, code:code) {
                                await cafeViewModel.checkMasterActivated(coreState: coreState)
                            }
                        }
                    } onFailure: { errorMessage in
                        print(errorMessage)
                    }
                    
                    AppleLoginButton(isLoading: $userViewModel.isAppleLoginLoading) { idToken, code in
                        Task {
                            await userViewModel.loginWithApple(coreState: coreState, idToken: idToken, code: code) {
                                await cafeViewModel.checkMasterActivated(coreState: coreState)
                            }
                        }
                    } onFailure: { errorMessage in
                        print(errorMessage)
                    }
                }
                .padding(15)
                .frame(maxWidth: .infinity)
                .background(.black.opacity(0.6))
                .padding(40)
            }
            .navigationBarBackButtonHidden()
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
