//
//  LoginViewModel.swift
//  Cafejari
//
//  Created by 안용우 on 2022/11/12.
//

import Foundation
import CoreLocation
import UIKit
import FirebaseMessaging

@MainActor
final class LoginViewModel: BaseViewModel {
    
    @Inject var loginRepogitory: LoginRepository
    
    @Published var kakaoAccessToken: String = ""
    @Published var googleEmail: String = ""
    @Published var googleCode: String = ""
    @Published var googleAccessToken: String = ""
    @Published var appleIdToken: String = ""
    @Published var appleCode: String = ""
    @Published var socialUserType: SocialUserType? = nil
    
    @Published var isGoogleLoginLoading: Bool = false
    @Published var isKakaoLoginLoading: Bool = false
    @Published var isAppleLoginLoading: Bool = false
    @Published var isAuthorizeLoading: Bool = false
    
    
    func loginWithKakao(coreState: CoreState, kakaoAccessToken: String, onSuccess: () async -> Void) async {
        do {
            let kakaoLoginRes = try await loginRepogitory.requestKakaoLogin(accessToken: kakaoAccessToken)
            
            if(kakaoLoginRes.is_user_exist) {
                let loginRes = try await loginRepogitory.requestKakaoLoginFinish(accessToken: kakaoAccessToken)
                coreState.isLogedIn = true
                coreState.accessToken = loginRes.access_token
                coreState.refreshToken = loginRes.refresh_token
                self.saveRefreshToken(refreshToken: loginRes.refresh_token)
                coreState.user = loginRes.user.getUser()
                await onSuccess()
                await self.updateFcmToken(coreState: coreState)
                isKakaoLoginLoading = false
                if !coreState.isPermissionCheckFinished() {
                    coreState.navigate(Screen.PermissionRequest.route)
                } else {
                    coreState.isPermissionChecked = true
                    coreState.clearStack()
                }
                coreState.showSnackBar(message: "로그인 성공")
            } else {
                self.kakaoAccessToken = kakaoAccessToken
                self.socialUserType = .kakao
                isKakaoLoginLoading = false
                coreState.navigate(Screen.Auth.route)
                coreState.showSnackBar(message: "카카오인증 성공! 닉네임 및 번호 등록후 모든 서비스를 이용해보세요")
            }
        } catch CustomError.errorMessage(let msg) {
            isKakaoLoginLoading = false
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            isKakaoLoginLoading = false
            print(error)
        }
    }
    
    func loginWithKakaoForAuth(coreState: CoreState, kakaoAccessToken: String) async -> Bool {
        do {
            let loginRes = try await loginRepogitory.requestKakaoLoginFinish(accessToken: kakaoAccessToken)
            coreState.isLogedIn = true
            coreState.accessToken = loginRes.access_token
            coreState.refreshToken = loginRes.refresh_token
            self.saveRefreshToken(refreshToken: loginRes.refresh_token)
            isKakaoLoginLoading = false
            coreState.showSnackBar(message: "인증 성공")
            return true
        } catch CustomError.errorMessage(let msg) {
            isKakaoLoginLoading = false
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
            return false
        } catch {
            isKakaoLoginLoading = false
            print(error)
            return false
        }
    }
    
    func loginWithGoogle(coreState: CoreState, email: String, code: String, onSuccess: () async -> Void) async {
        do {
            let googleLoginRes = try await loginRepogitory.requestGoogleLogin(email: email, code: code)
            
            if(googleLoginRes.is_user_exist){
                let loginRes = try await loginRepogitory.requestGoogleLoginFinish(
                    accessToken: googleLoginRes.access_token, code: googleLoginRes.code)
                coreState.isLogedIn = true
                coreState.accessToken = loginRes.access_token
                coreState.refreshToken = loginRes.refresh_token
                self.saveRefreshToken(refreshToken: loginRes.refresh_token)
                coreState.user = loginRes.user.getUser()
                await onSuccess()
                await self.updateFcmToken(coreState: coreState)
                isGoogleLoginLoading = false
                if !coreState.isPermissionCheckFinished() {
                    coreState.navigate(Screen.PermissionRequest.route)
                } else {
                    coreState.isPermissionChecked = true
                    coreState.clearStack()
                }
                coreState.showSnackBar(message: "로그인 성공")
            } else {
                self.googleCode = googleLoginRes.code
                self.googleEmail = email
                self.googleAccessToken = googleLoginRes.access_token
                self.socialUserType = .google
                isGoogleLoginLoading = false
                coreState.navigate(Screen.Auth.route)
                coreState.showSnackBar(message: "구글인증 성공! 닉네임 및 번호 등록후 모든 서비스를 이용해보세요")
            }
        } catch CustomError.errorMessage(let msg) {
            isGoogleLoginLoading = false
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            isGoogleLoginLoading = false
            print(error)
        }
    }
    
    func loginWithGoogleForAuth(coreState: CoreState, email: String, code: String) async -> Bool {
        do {
            let googleLoginRes = try await loginRepogitory.requestGoogleLogin(email: email, code: code)
            let loginRes = try await loginRepogitory.requestGoogleLoginFinish(
                accessToken: googleLoginRes.access_token, code: googleLoginRes.code)
            coreState.isLogedIn = true
            coreState.accessToken = loginRes.access_token
            coreState.refreshToken = loginRes.refresh_token
            self.saveRefreshToken(refreshToken: loginRes.refresh_token)
            isKakaoLoginLoading = false
            coreState.showSnackBar(message: "인증 성공")
            return true
        } catch CustomError.errorMessage(let msg) {
            isGoogleLoginLoading = false
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
            return false
        } catch {
            isGoogleLoginLoading = false
            print(error)
            return false
        }
    }
    
    func loginWithApple(coreState: CoreState, idToken: String, code: String, onSuccess: () async -> Void) async {
        do {
            let appleLoginRes = try await loginRepogitory.requestAppleLogin(idToken: idToken, code: code)
            
            if(appleLoginRes.is_user_exist){
                let loginRes = try await loginRepogitory.requestAppleLoginFinish(
                    idToken: appleLoginRes.id_token, code: appleLoginRes.code)
                coreState.isLogedIn = true
                coreState.accessToken = loginRes.access_token
                coreState.refreshToken = loginRes.refresh_token
                self.saveRefreshToken(refreshToken: loginRes.refresh_token)
                coreState.user = loginRes.user.getUser()
                await onSuccess()
                await self.updateFcmToken(coreState: coreState)
                isAppleLoginLoading = false
                if !coreState.isPermissionCheckFinished() {
                    coreState.navigate(Screen.PermissionRequest.route)
                } else {
                    coreState.isPermissionChecked = true
                    coreState.clearStack()
                }
                coreState.showSnackBar(message: "로그인 성공")
            } else {
                self.appleIdToken = appleLoginRes.id_token
                self.appleCode = appleLoginRes.code
                self.socialUserType = .apple
                isAppleLoginLoading = false
                coreState.navigate(Screen.Auth.route)
                coreState.showSnackBar(message: "애플인증 성공! 닉네임 및 번호 등록후 모든 서비스를 이용해보세요")
            }
        } catch CustomError.errorMessage(let msg) {
            isAppleLoginLoading = false
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            isAppleLoginLoading = false
            print(error)
        }
    }
    
    func loginWithAppleForAuth(coreState: CoreState, idToken: String, code: String) async -> Bool {
        do {
            let loginRes = try await loginRepogitory.requestAppleLoginFinish(idToken: idToken, code: code)
            
            coreState.isLogedIn = true
            coreState.accessToken = loginRes.access_token
            coreState.refreshToken = loginRes.refresh_token
            self.saveRefreshToken(refreshToken: loginRes.refresh_token)
            isKakaoLoginLoading = false
            coreState.showSnackBar(message: "인증 성공")
            return true
        } catch CustomError.errorMessage(let msg) {
            isAppleLoginLoading = false
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
            return false
        } catch {
            isAppleLoginLoading = false
            print(error)
            return false
        }
    }
    
    func sendSms(coreState: CoreState, phoneNumber: String, onSuccess: () -> Void) async {
        do {
            try await loginRepogitory.sendSms(phoneNumber: phoneNumber)
            onSuccess()
            coreState.showSnackBar(message: "인증번호를 발송하였습니다")
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: .error)
        } catch {
            print(error)
        }
    }
    
    func authSms(coreState: CoreState, phoneNumber: String, authNumber: String, onSuccess: () -> Void) async {
        do {
            try await loginRepogitory.authSms(authNumber: authNumber, phoneNumber: phoneNumber)
            onSuccess()
            coreState.showSnackBar(message: "인증번호가 일치합니다")
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: .error)
        } catch {
            print(error)
        }
    }
    
    func authorize(
        coreState: CoreState, nickname: String, phoneNumber: String, onSuccess: () async -> Void) async {
        do {
            isAuthorizeLoading = true
            let preAuthRes = try await loginRepogitory.postPreAuthorization(nickname: nickname, phoneNumber: phoneNumber)
            
            guard let socialUserType = self.socialUserType else {
                coreState.showSnackBar(message: "잘못된 접근입니다. 뒤로가기 후 소셜 인증부터 진행해주세요")
                return
            }
            
            var loginRes: LoginResponse? = nil
            
            switch socialUserType {
            case .kakao:
                loginRes = try await loginRepogitory.requestKakaoLoginFinish(accessToken: kakaoAccessToken)
            case .google:
                loginRes =  try await loginRepogitory.requestGoogleLoginFinish(
                    accessToken: self.googleAccessToken, code: self.googleCode)
            case .apple:
                loginRes =  try await loginRepogitory.requestAppleLoginFinish(idToken: appleIdToken, code: appleCode)
            }
            
            guard let loginRes = loginRes else {
                coreState.showSnackBar(message: "잘못된 접근입니다. 뒤로가기 후 소셜 인증부터 진행해주세요", type: .error)
                isAuthorizeLoading = false
                return
            }
            
            let fcmToken = await tokenRepository.getSavedFcmToken()
            
            let userRes = try await loginRepogitory.makeNewProfile(
                accessToken: loginRes.access_token,
                userId: loginRes.user.id,
                nickname: preAuthRes.nickname,
                phoneNumber: preAuthRes.phone_number,
                fcmToken: fcmToken.isEmpty ? GlobalString.None.rawValue : fcmToken
            )
            
            coreState.isLogedIn = true
            coreState.accessToken = loginRes.access_token
            coreState.refreshToken = loginRes.refresh_token
            self.saveRefreshToken(refreshToken: loginRes.refresh_token)
            coreState.user = userRes.getUser()
            await onSuccess()
            isAuthorizeLoading = false
            if !coreState.isPermissionCheckFinished() {
                coreState.navigate(Screen.PermissionRequest.route)
                coreState.showSnackBar(message: "가입이 완료되었습니다. 앱 사용을 위한 권한을 허용하고 서비스를 이용해보세요!")
            } else {
                coreState.isPermissionChecked = true
                coreState.clearStack()
                coreState.showSnackBar(message: "가입이 완료되었습니다. 카페자리의 모든 서비스를 이용해보세요!")
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
            isAuthorizeLoading = false
        } catch {
            print(error.localizedDescription)
            isAuthorizeLoading = false
        }
    }
    
    func getSocialUserType(coreState: CoreState) async {
        do {
            let socialUserTypeRes = try await loginRepogitory.fetchSocialUserType(accessToken: coreState.accessToken)
            switch socialUserTypeRes.type {
            case "kakao": self.socialUserType = SocialUserType.kakao
            case "google": self.socialUserType = SocialUserType.google
            case "apple": self.socialUserType = SocialUserType.apple
            default: self.socialUserType = nil
            }
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState) { newAccessToken in
                await getSocialUserType(coreState: coreState)
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error)
        }
    }
    
    func updateFcmToken(coreState: CoreState) async {
        do {
            let fcmToken = await tokenRepository.getSavedFcmToken()
            
            if !fcmToken.isEmpty && fcmToken != coreState.user.fcmToken {
                let userRes = try await userRepository.putFcmToken(
                    accessToken: coreState.accessToken,
                    profileId: coreState.user.profileId,
                    fcmToken: fcmToken
                )
                coreState.user = userRes.getUser()
            }
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState) { newAccessToken in
                await updateFcmToken(coreState: coreState)
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error)
        }
    }
}
