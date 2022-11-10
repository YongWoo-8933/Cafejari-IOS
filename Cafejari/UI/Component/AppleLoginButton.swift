//
//  AppleLoginButton.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/01.
//

import SwiftUI
import AuthenticationServices

struct AppleLoginButton: View {
    
    @Binding var isLoading: Bool
    
    let onSuccess: (String, String) -> Void
    let onFailure: (String) -> Void
    
    var body: some View {
        if isLoading {
            HStack{
                ProgressView()
                    .frame(height: 12)
                HorizontalSpacer(10)
                Text("애플 로그인 진행중...")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(.white)
            .cornerRadius(8)
        } else {
            SignInWithAppleButton { request in
                request.requestedScopes = [.email]
            } onCompletion: { result in
                isLoading = true
                switch result {
                case .success(let authResults):
                    switch authResults.credential {
                        // Apple ID
                    case let appleIDCredential as ASAuthorizationAppleIDCredential:
                        // accessToken (Data -> 아스키 인코딩 -> 스트링)
                        let idToken = String(data: appleIDCredential.identityToken!, encoding: .utf8) ?? ""
                        let code = String(data: appleIDCredential.authorizationCode!, encoding: .utf8) ?? ""
                        onSuccess(idToken, code)
                    default:
                        break
                    }
                case .failure(let error):
                    onFailure(error.localizedDescription)
                    isLoading = false
                }
            }
            .signInWithAppleButtonStyle(.white)
            .frame(height: 44)
            .cornerRadius(8)
            .shadow(radius: 1)
        }
    }
}
