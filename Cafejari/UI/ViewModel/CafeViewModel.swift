//
//  CafeViewModel.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/21.
//

import Foundation
import GooglePlaces
import SwiftUI

@MainActor
final class CafeViewModel: BaseViewModel {
    
    @Inject var cafeRepository: CafeRepository
    @Inject var informationRepository: InformationRepository
    
    @Published var cafeInfos: CafeInfos = []
    @Published var cafeInfoLoading: Bool = false
    @Published var cafeInfoRefreshDisabled: Bool = false
    
    @Published var modalCafeInfo: CafeInfo = CafeInfo.empty
    @Published var modalCafeIndex: Int = 0
    @Published var modalCafePhoneNumber: String? = nil
    
    @Published var markerRefeshTrigger: Bool = false
    
    @Published var modalPreviewImages: [UIImage] = []
    @Published var modalAttributions: String = ""
    @Published var modalMoreImages: [UIImage] = []
    @Published var modalMoreImagesLoading: Bool = false
    @Published var modalImageMetaData: [GMSPlacePhotoMetadata] = []
    
    @Published var isModalSnackBarOpened: Bool = false
    @Published var modalSnackBarContent: String = ""
    @Published var modalSnackBarType: SnackBarType = .alert
    
    @Published var isThumbsUpDialogOpened: Bool = false
    @Published var thumbsUpRecentLog: RecentUpdatedLog = RecentUpdatedLog.empty
    
    @Published var isMasterRoomCtaProgress: Bool = false
    
    private let googlePlaceClient = GMSPlacesClient.shared()
    private var snackBarWork: DispatchWorkItem? = nil
    
    
    // core
    func checkMasterActivated(coreState: CoreState) async {
        do {
            let logs = try await cafeRepository.fetchUnExpiredCafeLog(accessToken: coreState.accessToken)
            
            withAnimation(.easeInOut(duration: 0.1)) {
                coreState.isMasterActivated = !logs.isEmpty
                if !logs.isEmpty {
                    coreState.mapType = MapType.crowded
                    coreState.masterRoomCafeLog = logs[0].getCafeLog()
                }
            }
            
            await self.getCafeInfos(coreState: coreState)
            
            await self.checkAutoExpiredCafeLog(coreState: coreState)
            
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState, jobWithNewAccessToken: { newAccessToken in
                await checkMasterActivated(coreState: coreState)
            })
        } catch CustomError.errorMessage(let msg){
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    // map
    func clearModal() {
       modalCafeInfo = CafeInfo.empty
       modalCafeIndex = 0
       modalCafePhoneNumber = nil
       modalPreviewImages = []
       modalAttributions = ""
       modalMoreImages = []
       modalImageMetaData = []
    }
    
    func getCafeInfos(coreState: CoreState) async {
        do {
            cafeInfoLoading = true
            let cafeInfoResponses = try await cafeRepository.fetchCafeInfos(accessToken: coreState.accessToken)
            var newCafeInfos: CafeInfos = []
            
            cafeInfoResponses.forEach { cafeInfoResponse in
                var cafes: Cafes = []
                
                cafeInfoResponse.cafe.forEach { cafeInfoCafeResponse in
                    var recentUpdatedLogs: RecentUpdatedLogs = []
                    
                    cafeInfoCafeResponse.recent_updated_log.forEach { recentUpdatedLogResponse in
                        let recentUpdatedLog = RecentUpdatedLog(
                            id: recentUpdatedLogResponse.id,
                            master: CafeMaster(
                                userId: recentUpdatedLogResponse.cafe_detail_log.cafe_log.master.id,
                                nickname: recentUpdatedLogResponse.cafe_detail_log.cafe_log.master.profile?.nickname ?? "",
                                grade: recentUpdatedLogResponse.cafe_detail_log.cafe_log.master.profile?.grade ?? 0
                            ),
                            update: recentUpdatedLogResponse.update,
                            crowded: recentUpdatedLogResponse.cafe_detail_log.crowded
                        )
                        recentUpdatedLogs.append(recentUpdatedLog)
                    }
                    
                    let cafe = Cafe(
                        id: cafeInfoCafeResponse.id,
                        crowded: recentUpdatedLogs.isEmpty ? -1 : recentUpdatedLogs[0].crowded,
                        master: CafeMaster(
                            userId: cafeInfoCafeResponse.master?.id ?? 0,
                            nickname: cafeInfoCafeResponse.master?.profile?.nickname ?? "",
                            grade: cafeInfoCafeResponse.master?.profile?.grade ?? 0
                        ),
                        floor: cafeInfoCafeResponse.floor,
                        recentUpdatedLogs: recentUpdatedLogs
                    )
                    cafes.append(cafe)
                }
                
                newCafeInfos.append(
                    CafeInfo(
                        id: cafeInfoResponse.id,
                        name: cafeInfoResponse.name,
                        city: cafeInfoResponse.city,
                        gu: cafeInfoResponse.gu,
                        address: cafeInfoResponse.address,
                        totalFloor: cafeInfoResponse.total_floor,
                        floor: cafeInfoResponse.floor,
                        latitude: cafeInfoResponse.latitude,
                        longitude: cafeInfoResponse.longitude,
                        googlePlaceId: cafeInfoResponse.google_place_id,
                        cafes: cafes,
                        moreInfo: cafeInfoResponse.more_info.isEmpty ? MoreInfo.empty : cafeInfoResponse.more_info[0]
                    )
                )
            }
            self.cafeInfoRefreshDisabled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                self.cafeInfoRefreshDisabled = false
            }
            self.cafeInfos = newCafeInfos
            self.cafeInfoLoading = false
            self.markerRefeshTrigger = true
            
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState, jobWithNewAccessToken: { newAccessToken in
                await getCafeInfos(coreState: coreState)
            })
            self.cafeInfoLoading = false
        } catch CustomError.errorMessage(let msg){
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
            self.cafeInfoLoading = false
        } catch {
            print(error.localizedDescription)
            self.cafeInfoLoading = false
        }
    }
    
    func getCafeInfoFromPlace(place: GMSPlace) -> CafeInfo? {
        let filteredCafeInfos = cafeInfos.filter { cafeInfo in
            place.placeID == cafeInfo.googlePlaceId
        }
        return filteredCafeInfos.isEmpty ? nil : filteredCafeInfos[0]
    }
    
    func getModalCafePlaceInfo(googlePlaceId: String) {
        
        if googlePlaceId != String.None {
            googlePlaceClient.fetchPlace(
                fromPlaceID: googlePlaceId,
                placeFields: GMSPlaceField(rawValue: UInt(GMSPlaceField.photos.rawValue) | UInt(GMSPlaceField.phoneNumber.rawValue)),
                sessionToken: nil,
                callback: { place, error in
                    if let error = error {
                        print("An error occurred: \(error.localizedDescription)")
                    }
                    if let place = place {
                        self.modalImageMetaData = place.photos ?? []
                        self.modalCafePhoneNumber = place.phoneNumber
                        var photoNum = self.modalImageMetaData.count
                        photoNum = photoNum > 2 ? 3 : photoNum
                        self.modalImageMetaData[0 ..< photoNum].forEach { photoMetaData in
                            self.googlePlaceClient.loadPlacePhoto(photoMetaData, callback: { photo, error in
                                if let error = error {
                                    print("Error loading photo metadata: \(error.localizedDescription)")
                                } else {
                                    self.modalPreviewImages.append(photo!)
                                    if let attributionString = photoMetaData.attributions?.string {
                                        self.modalAttributions += attributionString + "님, "
                                    }
                                }
                            })
                        }
                    }
                }
            )
        }
    }
    
    func getModalCafeMoreImages() {
        self.modalMoreImagesLoading = true
        if !self.modalPreviewImages.isEmpty && self.modalImageMetaData.count > 3 {
            let morePhotoData = self.modalImageMetaData[3 ..< self.modalImageMetaData.count]
            morePhotoData.enumerated().forEach { index, photoMetaData in
                self.googlePlaceClient.loadPlacePhoto(photoMetaData, callback: { photo, error in
                    if let error = error {
                        print("Error loading photo metadata: \(error.localizedDescription)")
                    } else {
                        self.modalMoreImages.append(photo!)
                        if let attributionString = photoMetaData.attributions?.string {
                            self.modalAttributions += attributionString + "님, "
                        }
                    }
                    if morePhotoData.count - 1 == index {
                        self.modalMoreImagesLoading = false
                    }
                })
            }
        }
    }
    
    func setCafeLogInfo(coreState: CoreState) {
        let cafeInfo = self.modalCafeInfo
        let cafe = cafeInfo.cafes[self.modalCafeIndex]
        coreState.masterRoomCafeLog = CafeLog(
            id: 0,
            cafeId: cafe.id,
            name: cafeInfo.name,
            latitude: cafeInfo.latitude,
            longitude: cafeInfo.longitude,
            floor: cafe.floor,
            start: "",
            finish: "",
            expired: true,
            point: 0,
            master: CafeMaster.empty,
            cafeDetailLogs: []
        )
    }
    
    func thumbsUp(
        coreState: CoreState, recentLogId: Int, isAdWatched: Bool, onSuccess: () -> Void) async {
        do {
            let userRes = try await cafeRepository.thumbsUp(
                accessToken: coreState.accessToken, recentLogId: recentLogId, isAdWatched: isAdWatched)
            coreState.user = userRes.getUser()
            onSuccess()
            coreState.pointResultPoint = 25
            coreState.pointResultViewType = isAdWatched ? PointResultViewType.thumbsUpWithAd : PointResultViewType.thumbsUp
            coreState.navigate(Screen.PointResult.route)
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState, jobWithNewAccessToken: { newAccessToken in
                await thumbsUp(
                    coreState: coreState, recentLogId: recentLogId, isAdWatched: isAdWatched, onSuccess: onSuccess)
            })
        } catch CustomError.errorMessage(let msg){
            self.showModalSnackBar(message: msg, type: SnackBarType.error)
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func clearModalSnackBar() {
        self.isModalSnackBarOpened = false
        self.modalSnackBarType = SnackBarType.alert
        self.modalSnackBarContent = ""
    }
    
    func showModalSnackBar(message: String, type: SnackBarType = SnackBarType.alert) {
        if let work = self.snackBarWork {
            work.cancel()
        }
        self.snackBarWork = DispatchWorkItem(block: {
            self.clearModalSnackBar()
        })
        self.modalSnackBarType = type
        self.modalSnackBarContent = message
        self.isModalSnackBarOpened = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: self.snackBarWork!)
    }
    
    
    // master room
    func registerMaster(coreState: CoreState, crowded: Int) async {
        isMasterRoomCtaProgress = true
        do {
            let cafeLog = try await cafeRepository.registerMaster(
                accessToken: coreState.accessToken, cafeId: modalCafeInfo.cafes[modalCafeIndex].id, crowded: crowded
            ).getCafeLog()
            coreState.masterRoomCafeLog = cafeLog
            coreState.isMasterActivated = true
            coreState.mapType = MapType.crowded
            await self.getCafeInfos(coreState: coreState)
            isMasterRoomCtaProgress = false
            coreState.showSnackBar(message: "마스터등록 성공! 주기적으로 혼잡도를 업데이트 해주세요")
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState, jobWithNewAccessToken: { newAccessToken in
                await registerMaster(coreState: coreState, crowded: crowded)
            })
        } catch CustomError.errorMessage(let msg) {
            isMasterRoomCtaProgress = false
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            isMasterRoomCtaProgress = false
            print(error.localizedDescription)
        }
    }
    
    func updateCrowded(coreState: CoreState, crowded: Int) async {
        isMasterRoomCtaProgress = true
        do {
            let cafeLog = try await cafeRepository.putCrowded(
                accessToken: coreState.accessToken, cafeLogId: coreState.masterRoomCafeLog.id, crowded: crowded
            ).getCafeLog()
            coreState.masterRoomCafeLog = cafeLog
            coreState.mapType = MapType.crowded
            await self.getCafeInfos(coreState: coreState)
            isMasterRoomCtaProgress = false
            coreState.showSnackBar(message: "카페 혼잡도를 '\(crowded.toCrowded().string)'(으)로 변경하였습니다")
        } catch CustomError.masterExpired {
            coreState.isMasterActivated = false
            await checkAutoExpiredCafeLog(coreState: coreState)
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState, jobWithNewAccessToken: { newAccessToken in
                await updateCrowded(coreState: coreState, crowded: crowded)
            })
        } catch CustomError.errorMessage(let msg){
            isMasterRoomCtaProgress = false
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            isMasterRoomCtaProgress = false
            print(error.localizedDescription)
        }
    }
    
    func deleteCafeDetailLog(coreState: CoreState, cafeDetailLogId: Int) async {
        do {
            let cafeLog = try await cafeRepository.deleteCafeDetailLog(
                accessToken: coreState.accessToken, cafeDetailLogId: cafeDetailLogId
            ).getCafeLog()
            coreState.masterRoomCafeLog = cafeLog
            await self.getCafeInfos(coreState: coreState)
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState, jobWithNewAccessToken: { newAccessToken in
                await deleteCafeDetailLog(coreState: coreState, cafeDetailLogId: cafeDetailLogId)
            })
        } catch CustomError.errorMessage(let msg){
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func expireMaster(coreState: CoreState, adWatched: Bool) async {
        do {
            let cafeLog = try await cafeRepository.expireMaster(
                accessToken: coreState.accessToken, cafeLogId: coreState.masterRoomCafeLog.id, adWatched: adWatched
            ).getCafeLog()
            coreState.masterRoomCafeLog = cafeLog
            coreState.mapType = MapType.crowded
            await self.getCafeInfos(coreState: coreState)
            
            coreState.isMasterActivated = false
            
            coreState.pointResultViewType = adWatched ? PointResultViewType.masterExpiredWithAd : PointResultViewType.masterExpired
            coreState.pointResultPoint = cafeLog.point
            coreState.navigateWithClear(Screen.PointResult.route)
        } catch CustomError.masterExpired {
            coreState.isMasterActivated = false
            await checkAutoExpiredCafeLog(coreState: coreState)
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState, jobWithNewAccessToken: { newAccessToken in
                await expireMaster(coreState: coreState, adWatched: adWatched)
            })
        } catch CustomError.errorMessage(let msg){
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    // core
    func checkAutoExpiredCafeLog(coreState: CoreState) async {
        do {
            let autoExpiredCafeLogRes = try await cafeRepository.fetchAutoExpiredCafeLog(accessToken: coreState.accessToken)
            
            guard let cafeLogRes = autoExpiredCafeLogRes.cafe_log,
                  let expiredTime = autoExpiredCafeLogRes.time
            else { return }
            
            if autoExpiredCafeLogRes.id != 0 {
                let autoExpiredCafeLog = AutoExpiredCafeLog(
                    id: autoExpiredCafeLogRes.id, time: expiredTime, cafeLog: cafeLogRes.getCafeLog()
                )
                if coreState.masterRoomCafeLog.id == autoExpiredCafeLog.cafeLog.id {
                    coreState.autoExpiredCafeLog = autoExpiredCafeLog
                    coreState.isAutoExpiredDialogOpened = true
                } else {
                    await self.deleteAutoExpiredCafeLog(coreState: coreState, autoExpiredCafeLogId: autoExpiredCafeLog.id)
                }
            }
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState, jobWithNewAccessToken: { newAccessToken in
                await checkAutoExpiredCafeLog(coreState: coreState)
            })
        } catch CustomError.errorMessage(let msg){
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteAutoExpiredCafeLog(coreState: CoreState, autoExpiredCafeLogId: Int) async {
        do {
            try await cafeRepository.deleteAutoExpiredCafeLog(
                accessToken: coreState.accessToken, autoExpiredCafeLogId: autoExpiredCafeLogId)
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState, jobWithNewAccessToken: { newAccessToken in
                await deleteAutoExpiredCafeLog(coreState: coreState, autoExpiredCafeLogId: autoExpiredCafeLogId)
            })
        } catch CustomError.errorMessage(let msg) {
            coreState.showSnackBar(message: msg, type: SnackBarType.error)
        } catch {
            print(error.localizedDescription)
        }
    }
}
