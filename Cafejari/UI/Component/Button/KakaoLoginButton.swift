//
//  KakaoLoginButton.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/01.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

struct KakaoLoginButton: View {
    
    @Binding var isLoading: Bool
    
    let onSuccess: (String) -> Void
    let onFailure: (String) -> Void
    
    var body: some View {
        Button{
            isLoading = true
            if(UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                    if let error = error {
                        onFailure(error.localizedDescription)
                        isLoading = false
                    } else {
                        if let oauthToken = oauthToken {
                            onSuccess(oauthToken.accessToken)
                        }
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                    if let error = error {
                        onFailure(error.localizedDescription)
                        isLoading = false
                    } else {
                        if let oauthToken = oauthToken {
                            onSuccess(oauthToken.accessToken)
                        }
                    }
                }
            }
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .frame(height: 12)
                    HorizontalSpacer(.medium)
                } else {
                    Image("kakao_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 12)
                }
                Text(isLoading ? "카카오 로그인 진행중..." : "카카오 로그인")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.black.opacity(0.85))
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color(hexString: "FEE500"))
            .cornerRadius(.medium)
        }
        .background(.gray)
        .cornerRadius(.medium)
        .shadow(radius: 1)
    }
}
