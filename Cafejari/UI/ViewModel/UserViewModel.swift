//
//  UserViewModel.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation
import CoreLocation
import UIKit

@MainActor
final class UserViewModel: BaseViewModel {
    
    @Inject var cafeRepository: CafeRepository
    
    @Published var kakaoAccessToken: String = ""
    @Published var googleEmail: String = ""
    @Published var googleCode: String = ""
    @Published var appleIdToken: String = ""
    @Published var appleCode: String = ""
    @Published var socialUserType: SocialUserType? = nil
    
    @Published var dateCafeLogs: DateCafeLogs = []
    @Published var selectedDate: Date = Date()
    @Published var isDateCafeLogsLoading: Bool = true
    @Published var isProfileEditLoading: Bool = false
    
    @Published var isGoogleLoginLoading: Bool = false
    @Published var isKakaoLoginLoading: Bool = false
    @Published var isAppleLoginLoading: Bool = false
    
    func appInit(coreState: CoreState) async {
        do {
            let savedtoken = try await tokenRepository.getSavedRefreshToken()
            try await Task.sleep(nanoseconds: 100_000_000)
            
            if savedtoken.isEmpty {
                coreState.isLogedIn = false
                if(coreState.isSplashFinished) {
                    coreState.navigate(Screen.Login.route)
                }
                coreState.isAppInitiated = true
            } else {
                coreState.refreshToken = savedtoken
                await self.refreshAccessToken(coreState: coreState, jobWithNewAccessToken: { newAccessToken in
                    coreState.accessToken = newAccessToken
                })
                try await Task.sleep(nanoseconds: 100_000_000)
                await self.getUser(coreState: coreState)
                
                try await Task.sleep(nanoseconds: 100_000_000)
                coreState.isLogedIn = true
                
                if coreState.isSplashFinished && !coreState.user.authorization {
                    coreState.navigate(Screen.Login.route)
                }
                coreState.isAppInitiated = true
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error)
        }
    }
    
    func getUser(coreState: CoreState) async {
        do {
            coreState.user = try await userRepository.fetchUser(accessToken: coreState.accessToken).getUser()
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState, jobWithNewAccessToken: { newAccessToken in
                await getUser(coreState: coreState)
            })
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error)
        }
    }
    
    func loginWithKakao(coreState: CoreState, kakaoAccessToken: String, onSuccess: () async -> Void) async {
        do {
            let kakaoLoginRes = try await userRepository.requestKakaoLogin(accessToken: kakaoAccessToken)
            
            if(kakaoLoginRes.is_user_exist) {
                let loginRes = try await userRepository.requestKakaoLoginFinish(accessToken: kakaoAccessToken)
                coreState.isLogedIn = true
                coreState.accessToken = loginRes.access_token
                coreState.refreshToken = loginRes.refresh_token
                self.saveRefreshToken(refreshToken: loginRes.refresh_token)
                coreState.user = loginRes.user.getUser()
                await onSuccess()
                isKakaoLoginLoading = false
                coreState.clearStack()
                coreState.showSnackBar(message: "로그인 성공")
            } else {
                self.kakaoAccessToken = kakaoAccessToken
                self.socialUserType = .kakao
                isKakaoLoginLoading = false
                coreState.navigate(Screen.Auth.route)
                coreState.showSnackBar(message: "카카오인증 성공! 닉네임/번호 등록후 모든 서비스를 이용해보세요")
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
            let loginRes = try await userRepository.requestKakaoLoginFinish(accessToken: kakaoAccessToken)
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
            let googleLoginRes = try await userRepository.requestGoogleLogin(email: email, code: code)
            
            if(googleLoginRes.is_user_exist){
                let loginRes = try await userRepository.requestGoogleLoginFinish(
                    accessToken: googleLoginRes.access_token, code: googleLoginRes.code)
                coreState.isLogedIn = true
                coreState.accessToken = loginRes.access_token
                coreState.refreshToken = loginRes.refresh_token
                self.saveRefreshToken(refreshToken: loginRes.refresh_token)
                coreState.user = loginRes.user.getUser()
                await onSuccess()
                isGoogleLoginLoading = false
                coreState.clearStack()
                coreState.showSnackBar(message: "로그인 성공")
            } else {
                self.googleCode = googleLoginRes.code
                self.googleEmail = email
                self.socialUserType = .google
                isGoogleLoginLoading = false
                coreState.navigate(Screen.Auth.route)
                coreState.showSnackBar(message: "구글인증 성공! 닉네임/번호 등록후 모든 서비스를 이용해보세요")
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
            let googleLoginRes = try await userRepository.requestGoogleLogin(email: email, code: code)
            let loginRes = try await userRepository.requestGoogleLoginFinish(
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
            let appleLoginRes = try await userRepository.requestAppleLogin(idToken: idToken, code: code)
            
            if(appleLoginRes.is_user_exist){
                let loginRes = try await userRepository.requestAppleLoginFinish(
                    idToken: appleLoginRes.id_token, code: appleLoginRes.code)
                coreState.isLogedIn = true
                coreState.accessToken = loginRes.access_token
                coreState.refreshToken = loginRes.refresh_token
                self.saveRefreshToken(refreshToken: loginRes.refresh_token)
                coreState.user = loginRes.user.getUser()
                await onSuccess()
                isAppleLoginLoading = false
                coreState.clearStack()
                coreState.showSnackBar(message: "로그인 성공")
            } else {
                self.appleIdToken = appleLoginRes.id_token
                self.appleCode = appleLoginRes.code
                self.socialUserType = .apple
                isAppleLoginLoading = false
                coreState.navigate(Screen.Auth.route)
                coreState.showSnackBar(message: "애플인증 성공! 닉네임/번호 등록후 모든 서비스를 이용해보세요")
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
            let loginRes = try await userRepository.requestAppleLoginFinish(idToken: idToken, code: code)
            
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
    
    func sendSms(coreState: CoreState, phoneNumber: String) async {
        do {
            try await userRepository.sendSms(phoneNumber: phoneNumber)
            coreState.showSnackBar(message: "인증번호를 발송하였습니다")
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg)
        } catch {
            print(error)
        }
    }
    
    func authSms(coreState: CoreState, phoneNumber: String, authNumber: String) async {
        do {
            try await userRepository.authSms(authNumber: authNumber, phoneNumber: phoneNumber)
            coreState.showSnackBar(message: "인증번호가 일치합니다")
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg)
        } catch {
            print(error)
        }
    }
    
    func authorize(
        coreState: CoreState, nickname: String, phoneNumber: String, onSuccess: () async -> Void) async {
        do {
            let preAuthRes = try await userRepository.postPreAuthorization(nickname: nickname, phoneNumber: phoneNumber)
            
            guard let socialUserType = self.socialUserType else {
                coreState.showSnackBar(message: "잘못된 접근입니다. 뒤로가기 후 소셜 인증부터 진행해주세요")
                return
            }
            
            var loginRes: LoginResponse? = nil
            
            switch socialUserType {
            case .kakao:
                loginRes = try await userRepository.requestKakaoLoginFinish(accessToken: kakaoAccessToken)
            case .google:
                let googleLoginRes = try await userRepository.requestGoogleLogin(email: googleEmail, code: googleCode)
                loginRes =  try await userRepository.requestGoogleLoginFinish(accessToken: googleLoginRes.access_token, code: googleLoginRes.code)
            case .apple:
                loginRes =  try await userRepository.requestAppleLoginFinish(idToken: appleIdToken, code: appleCode)
            }
            
            guard let loginRes = loginRes else {
                coreState.showSnackBar(message: "잘못된 접근입니다. 뒤로가기 후 소셜 인증부터 진행해주세요")
                return
            }
            
            let userRes = try await userRepository.makeNewProfile(
                accessToken: loginRes.access_token,
                userId: loginRes.user.id,
                nickname: preAuthRes.nickname,
                phoneNumber: preAuthRes.phone_number
            )
            
            coreState.isLogedIn = true
            coreState.accessToken = loginRes.access_token
            coreState.refreshToken = loginRes.refresh_token
            self.saveRefreshToken(refreshToken: loginRes.refresh_token)
            coreState.user = userRes.getUser()
            await onSuccess()
            coreState.clearStack()
            coreState.showSnackBar(message: "가입이 완료되었습니다. 카페자리의 모든 서비스를 이용해보세요!")
        } catch CustomError.errorMessage(let msg){
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func logout(coreState: CoreState, appReset: () -> Void) async {
        do {
            try await userRepository.logout(refreshToken: coreState.refreshToken)
            self.tokenRepository.deleteSavedToken()
            
            coreState.isLogedIn = false
            coreState.user = User.empty
            coreState.accessToken = ""
            coreState.refreshToken = ""
            appReset()
            self.dateCafeLogs = []
            self.selectedDate = Date()
            coreState.navigateWithClear(Screen.Login.route)
            coreState.tapToMap()
            coreState.showSnackBar(message: "로그아웃 하였습니다")
        } catch CustomError.errorMessage(let msg){
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getDateCafeLogs(coreState: CoreState) async {
        do {
            var dateCafeLogs: DateCafeLogs = []
            let cafeLogResponses = try await cafeRepository.fetchExpiredCafeLogs(accessToken: coreState.accessToken)
            
            var year = "0000"
            var month = "00"
            var day = "00"
            var cafeLogs: CafeLogs = []
            
            cafeLogResponses.enumerated().forEach { index, cafeLogResponse in
                let isYearSame = time.parseYearFrom(timeString: cafeLogResponse.start) == year
                let isMonthSame = time.parseMonthFrom(timeString: cafeLogResponse.start) == month
                let isDaySame = time.parseDayFrom(timeString: cafeLogResponse.start) == day
                
                if !isYearSame || !isMonthSame || !isDaySame {
                    if index != 0 {
                        dateCafeLogs.append(
                            DateCafeLog(
                                date: time.translateFromStringToDate(timeString: cafeLogResponses[index - 1].start),
                                cafeLogs: cafeLogs
                            )
                        )
                        cafeLogs = []
                    }
                }
                
                year = time.parseYearFrom(timeString: cafeLogResponse.start)
                month = time.parseMonthFrom(timeString: cafeLogResponse.start)
                day = time.parseDayFrom(timeString: cafeLogResponse.start)
                cafeLogs.append(cafeLogResponse.getCafeLog())
                
                if index == cafeLogResponses.count - 1 {
                    dateCafeLogs.append(
                        DateCafeLog(
                            date: time.translateFromStringToDate(timeString: cafeLogResponse.start),
                            cafeLogs: cafeLogs
                        )
                    )
                }
            }
            
            self.dateCafeLogs = dateCafeLogs
            isDateCafeLogsLoading = false
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState) { newAccessToken in
                await getDateCafeLogs(coreState: coreState)
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
            self.isDateCafeLogsLoading = false
        } catch {
            print(error)
            self.isDateCafeLogsLoading = false
        }
    }
    
    func getSocialUserType(coreState: CoreState) async {
        do {
            let socialUserTypeRes = try await userRepository.fetchSocialUserType(accessToken: coreState.accessToken)
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
    
    func updateProfile(coreState: CoreState, nickname: String?, image: UIImage?) async {
        do {
            let userRes = try await userRepository.putProfile(
                accessToken: coreState.accessToken,
                profileId: coreState.user.profileId,
                nickname: nickname,
                image: image
            )
            coreState.user = userRes.getUser()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isProfileEditLoading = false
                coreState.popUp()
                coreState.showSnackBar(message: "프로필 정보를 수정하였습니다")
            }
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState) { newAccessToken in
                await updateProfile(coreState: coreState, nickname: nickname, image: image)
            }
        } catch CustomError.errorMessage(let msg) {
            isProfileEditLoading = false
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            isProfileEditLoading = false
            print(error)
        }
    }
}
