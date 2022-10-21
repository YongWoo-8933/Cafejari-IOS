//
//  UserViewModel.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation

@MainActor
final class UserViewModel: BaseViewModel {
    
    @Inject var userRepository: UserRepository
    
    func appInit(coreState: CoreState) async throws {
        let savedtoken = try await tokenRepository.getSavedRefreshToken()
        if savedtoken.isEmpty {
            coreState.isLogedIn = false
            coreState.isAppInitiated = true
            if(coreState.isSplashFinished) {
                coreState.navigate(Screen.Login.route)
            }
        } else {
            coreState.refreshToken = savedtoken
            coreState.accessToken = try await self.refreshAccessToken(refreshToken: savedtoken)
            try await self.getUser(coreState: coreState)
            coreState.isLogedIn = true
            coreState.isAppInitiated = true
            
            if coreState.isSplashFinished && !coreState.user.authorization {
                coreState.navigate(Screen.Login.route)
            }
        }
    }
    
    func getUser(coreState: CoreState) async throws {
        
        do {
            let userRes = try await userRepository.fetchUser(accessToken: coreState.accessToken)
            coreState.user = userRes.getUser()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loginWithKakao(coreState: CoreState, kakaoAccessToken: String) async {
        do {
            let kakaoLoginRes = try await userRepository.requestKakaoLogin(accessToken: kakaoAccessToken)
            let loginRes = try await userRepository.requestKakaoLoginFinish(accessToken: kakaoAccessToken)
            coreState.isLogedIn = true
            coreState.accessToken = loginRes.access_token
            coreState.refreshToken = loginRes.refresh_token
            self.saveRefreshToken(refreshToken: loginRes.refresh_token)
            
            if(kakaoLoginRes.is_user_exist){
                coreState.user = loginRes.user.getUser()
                if(loginRes.user.authorization){
                    coreState.clearStack()
                }else{
                    coreState.navigate(Screen.Auth.route)
                }
            }else{
                let newUserRes = try await userRepository.makeNewProfile(accessToken: loginRes.access_token, userId: loginRes.user.id)
                coreState.user = newUserRes.getUser()
                coreState.navigate(Screen.Auth.route)
            }
        } catch {
            print(error)
        }
    }
    
    func sendSms(coreState: CoreState, phoneNumber: String) async {
        do {
            try await userRepository.sendSms(accessToken: coreState.accessToken, phoneNumber: phoneNumber)
        } catch {
            print(error)
        }
    }
    
    func authSms(coreState: CoreState, phoneNumber: String, authNumber: String) async {
        do {
            try await userRepository.authSms(accessToken: coreState.accessToken, authNumber: authNumber, phoneNumber: phoneNumber)
        } catch {
            print(error)
        }
    }
    
    func authorize(coreState: CoreState, nickName: String, phoneNumber: String) async {
        do {
            let userRes = try await userRepository.authorize(
                accessToken: coreState.accessToken, profileId: coreState.user.profileId, nickname: nickName, phoneNumber: phoneNumber
            )
            coreState.user = userRes.getUser()
            coreState.isLogedIn = true
            coreState.clearStack()
        } catch {
            print(error)
        }
    }
}
