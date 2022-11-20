//
//  BaseViewModel.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation
import SwiftUI
import CoreLocation
import GoogleMobileAds


class BaseViewModel: ObservableObject {
    
    @Inject var tokenRepository: TokenRepository
    @Inject var userRepository: UserRepository
    @Inject var time: Time
    @Inject var httpRoute: HttpRoute
    
    @Published var interstitial: GADInterstitial? = nil
    
    func getSavedRefreshToken() async throws -> String {
        return await tokenRepository.getSavedRefreshToken()
    }
    
    func saveRefreshToken(refreshToken: String) {
        tokenRepository.saveRefreshToken(refreshToken: refreshToken)
    }
    
    func deleteSavedRefreshToken() {
        tokenRepository.deleteSavedRefreshToken()
    }
    
    func refreshAccessToken(coreState: CoreState, jobWithNewAccessToken: (String) async throws -> Void) async {
        do {
            let accessTokenResponse = try await tokenRepository.refreshAccessToken(refreshToken: coreState.refreshToken)
            DispatchQueue.main.sync {
                coreState.accessToken = accessTokenResponse.access
            }
            try await jobWithNewAccessToken(accessTokenResponse.access)
        } catch CustomError.refreshTokenExpired {
            await self.logout(coreState: coreState)
            coreState.showSnackBar(message: "로그인 유효기간이 만료되었습니다. 다시 로그인해주세요!")
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func logout(coreState: CoreState) async {
        do {
            try await userRepository.logout(refreshToken: coreState.refreshToken)
            self.tokenRepository.deleteSavedRefreshToken()
            self.tokenRepository.deleteSavedFcmToken()
            
            _ = try await userRepository.putFcmToken(
                accessToken: coreState.accessToken,
                profileId: coreState.user.profileId,
                fcmToken: GlobalString.None.rawValue
            )
            
            DispatchQueue.main.sync {
                coreState.isLogedIn = false
                coreState.user = User.empty
                coreState.accessToken = ""
                coreState.refreshToken = ""
                coreState.mapType = MapType.crowded
                coreState.isMasterActivated = false
                coreState.masterRoomCafeLog = CafeLog.empty
                coreState.navigateWithClear(Screen.Login.route)
                coreState.tapToMap()
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: .error)
        } catch {
            print(error)
        }
    }
    
    func loadInterstitalAd() {
        interstitial = GADInterstitial(adUnitID: AdUnit.interstitial.id)
        interstitial?.load(GADRequest())
    }
}
