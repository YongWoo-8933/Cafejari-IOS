//
//  UserViewModel.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/18.
//

import Foundation
import CoreLocation
import UIKit
import FirebaseMessaging

@MainActor
final class UserViewModel: BaseViewModel {
    
    @Inject var cafeRepository: CafeRepository
    
    @Published var dateCafeLogs: DateCafeLogs = []
    @Published var selectedDate: Date = Date()
    @Published var isDateCafeLogsLoading: Bool = true
    @Published var isProfileEditLoading: Bool = false
    
    @Published var weekLeaders: Leaders = []
    @Published var monthLeaders: Leaders = []
    @Published var isLeaderLoading: Bool = true
    
    func appInit(coreState: CoreState) async {
        do {
            let savedtoken = await tokenRepository.getSavedRefreshToken()
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
                await self.updateFcmToken(coreState: coreState)
                
                coreState.isLogedIn = true
                coreState.isAppInitiated = true
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
            coreState.isAppInitiated = true
        } catch {
            print(error)
            coreState.isAppInitiated = true
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
    
    func getLeaders(coreState: CoreState) async {
        self.isLeaderLoading = true
        do {
            let weekLeaderResList = try await userRepository.fetchWeekLeader(accessToken: coreState.accessToken).sorted(by: {$0.ranking < $1.ranking})
            var leaders: Leaders = []
            weekLeaderResList.forEach { leaderRes in
                leaders.append(Leader(
                    nickname: leaderRes.user.profile?.nickname ?? "",
                    image: leaderRes.user.profile?.image ?? "",
                    ranking: leaderRes.ranking,
                    activity: leaderRes.activity
                ))
            }
            self.weekLeaders = leaders
            
            let monthLeaderResList = try await userRepository.fetchMonthLeader(accessToken: coreState.accessToken).sorted(by: {$0.ranking < $1.ranking})
            leaders = []
            monthLeaderResList.forEach { leaderRes in
                leaders.append(Leader(
                    nickname: leaderRes.user.profile?.nickname ?? "",
                    image: leaderRes.user.profile?.image ?? "",
                    ranking: leaderRes.ranking,
                    activity: leaderRes.activity
                ))
            }
            self.monthLeaders = leaders
            self.isLeaderLoading = false
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState) { newAccessToken in
                await getLeaders(coreState: coreState)
            }
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
            self.isLeaderLoading = false
        } catch {
            print(error)
            self.isLeaderLoading = false
        }
    }
}
