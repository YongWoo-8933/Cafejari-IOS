//
//  LoginView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/10.
//

import AuthenticationServices
import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

struct LoginView: View {
    
    @EnvironmentObject private var coreState: CoreState
    @EnvironmentObject private var userViewModel: UserViewModel
    
    
    var body: some View {
        VStack{
            Button{
                if(UserApi.isKakaoTalkLoginAvailable()) {
                    UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                        if let error = error {
                            print(error)
                        }
                        else {
                            if oauthToken != nil {
                                print("\(oauthToken?.accessToken ?? "")")
                                Task{
                                    await userViewModel.loginWithKakao(
                                        coreState: coreState,
                                        kakaoAccessToken: oauthToken?.accessToken ?? ""
                                    )
                                }
                            }
                        }
                    }
                }else{
                    UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                        if let error = error {
                            print(error)
                        }
                        else {
                            print("loginWithKakaoAccount() success.")

                            //do something
                            if oauthToken != nil {
                                print("\(oauthToken?.accessToken ?? "")")
                                Task{
                                    await userViewModel.loginWithKakao(
                                        coreState: coreState,
                                        kakaoAccessToken: oauthToken?.accessToken ?? ""
                                    )
                                }
                            }
                        }
                    }
                }
            }label: {
                HStack{
                    Image("kakao_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                    Spacer()
                    Text("카카오 로그인")
                        .font(.system(size: 18))
                        .foregroundColor(.black.opacity(0.85))
                    Spacer()
                }
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hexString: "FEE500"))
                .cornerRadius(8)
            }
            
            Button{
                coreState.clearStack()
            }label: {
                HStack{
                    Image("google_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                    Spacer()
                    Text("구글 로그인")
                        .font(.system(size: 18))
                        .foregroundColor(.black.opacity(0.54))
                    Spacer()
                }
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white)
                .cornerRadius(8)
            }
            
            Button{
                coreState.clearStack()
            }label: {
                HStack{
                    Image("apple_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                    Spacer()
                    Text("애플 로그인")
                        .font(.system(size: 18))
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white)
                .cornerRadius(8)
            }
            
        }
        .frame(maxHeight: .infinity)
        .padding(15)
        .background(.brown)
        .navigationTitle("로그인")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
