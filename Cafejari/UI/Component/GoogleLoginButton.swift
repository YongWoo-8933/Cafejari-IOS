//
//  GoogleLoginButton.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/01.
//

import SwiftUI
import GoogleSignIn
import FirebaseCore
import FirebaseAuth

struct GoogleLoginButton: View {
    
    @Binding var isLoading: Bool
    
    let onSuccess: (String, String) -> Void
    let onFailure: (String) -> Void
    
    var body: some View {
        Button{
            isLoading = true
            
            guard
                let clientID  = FirebaseApp.app()?.options.clientID,
                let serverClientID = Bundle.main.infoDictionary?["GOOGLE_SERVER_CLIENT_ID"]
            else {
                print("아이디 로드 에러")
                isLoading = false
                return
            }

            let config = GIDConfiguration(clientID: clientID, serverClientID: serverClientID as? String)

            GIDSignIn.sharedInstance.signIn(with: config, presenting: ApplicationUtility.rootViewController) {
                [self] user, error in

                if let error = error {
                    onFailure(error.localizedDescription)
                    isLoading = false
                }
                
                guard
                    let email = user?.profile?.email,
                    let code = user?.serverAuthCode
                else {
                    isLoading = false
                    return
                }
                
                onSuccess(email, code)
            }
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .frame(height: 12)
                    HorizontalSpacer(10)
                } else {
                    Image("google_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 12)
                }
                Text(isLoading ? "구글 로그인 진행중..." : "구글 로그인")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.black.opacity(0.54))
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(.white)
            .cornerRadius(8)
        }
        .background(.gray)
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}
