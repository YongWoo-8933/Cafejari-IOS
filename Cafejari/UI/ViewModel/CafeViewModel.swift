//
//  CafeViewModel.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/21.
//

import Foundation
import GooglePlaces
import NMapsMap
import SwiftUI

@MainActor
final class CafeViewModel: BaseViewModel {
    
    @Inject var cafeRepository: CafeRepository
    @Inject var informationRepository: InformationRepository
    
    private var cafeInfos: CafeInfos = []
    @Published var searchCafeInfos: CafeInfos = []
    @Published var markers: [NMFMarker] = []
    @Published var isMarkerUpdateTriggered: Bool = false
    @Published var selectedMarker: NMFMarker? = nil
    var lastCameraPosition: NMFCameraPosition = Locations.sinchon.cameraPosition
    @Published var cameraPosition: NMFCameraPosition = Locations.sinchon.cameraPosition
    @Published var isLongDCameraUpdateTriggered: Bool = false
    @Published var isShortDCameraUpdateTriggered: Bool = false
    
    @Published var cafeInfoLoading: Bool = false
    @Published var cafeInfoRefreshDisabled: Bool = false
    @Published var animateToLongDistance: NMFCameraPosition? = nil
    @Published var animateToShortDistance: NMGLatLng? = nil
    
    @Published var isBottomSheetOpened = false
    @Published var interstitialAdCounter = 0
    @Published var modalCafeInfo: CafeInfo = CafeInfo.empty
    @Published var modalCafe: Cafe = Cafe.empty
    @Published var modalCafePlace: GMSPlace? = nil
    
    @Published var modalPreviewImages: [UIImage] = []
    @Published var modalPreviewImagesLoading: Bool = true
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
    private var fetchImagesWork: DispatchWorkItem? = nil
    var associatedCafeDescriptionCloseWork: DispatchWorkItem? = nil
    var hideRefreshCafeInfoWork: DispatchWorkItem? = nil
    
    private let grayMarkerUIImage = UIImage(named: Crowded.crowdedNegative.image)
    private let blueMarkerUIImage = UIImage(named: Crowded.crowdedZero.image)
    private let greenMarkerUIImage = UIImage(named: Crowded.crowdedOne.image)
    private let yellowMarkerUIImage = UIImage(named: Crowded.crowdedTwo.image)
    private let orangeMarkerUIImage = UIImage(named: Crowded.crowdedThree.image)
    private let redMarkerUIImage = UIImage(named: Crowded.crowdedFour.image)
    
    
    // core
    func checkMasterActivated(coreState: CoreState) async {
        do {
            let logs = try await cafeRepository.fetchUnExpiredCafeLog(accessToken: coreState.accessToken)
            
            withAnimation(.easeInOut(duration: 0.1)) {
                coreState.isMasterActivated = !logs.isEmpty
                if !logs.isEmpty {
                    coreState.masterRoomCafeLog = logs[0].getCafeLog()
                }
            }
            
            await self.getNearbyCafeInfos(coreState: coreState)
            
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
        fetchImagesWork?.cancel()
        modalCafeInfo = CafeInfo.empty
        modalCafe = Cafe.empty
        modalCafePlace = nil
        modalPreviewImages.removeAll()
        modalPreviewImagesLoading = true
        modalAttributions = ""
        modalMoreImages.removeAll()
        modalImageMetaData.removeAll()
    }
    
    func collapseBottomSheet(_ onAnimationFinish: @escaping () -> Void = {}) {
        if self.isBottomSheetOpened {
            self.isBottomSheetOpened = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                onAnimationFinish()
            }
        } else {
            onAnimationFinish()
        }
    }
    
    func getNearbyCafeInfos(
        coreState: CoreState,
        cameraPosition: NMFCameraPosition? = nil,
        selectedCafeInfoId: Int = 0,
        onSuccess: () -> Void = {}
    ) async {
        do {
            cafeInfoLoading = true
            let lat = cameraPosition?.target.lat ?? lastCameraPosition.target.lat
            let lng = cameraPosition?.target.lng ?? lastCameraPosition.target.lng
            let zoom = cameraPosition?.zoom ?? lastCameraPosition.zoom
            let cafeInfoResponses = try await cafeRepository.fetchCafeInfos(
                accessToken: coreState.accessToken,
                latitude: lat,
                longitude: lng,
                zoomLevel: zoom.toZoomLevel()
            )
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
                        restroom: cafeInfoCafeResponse.restroom ?? "",
                        wallSocket: cafeInfoCafeResponse.wall_socket ?? "",
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
            await drawMarkers(cafeInfos: newCafeInfos, selectedCafeInfoId: selectedCafeInfoId)
            self.cafeInfoLoading = false
            onSuccess()
            
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState, jobWithNewAccessToken: { newAccessToken in
                await getNearbyCafeInfos(coreState: coreState)
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
    
    func cameraMoveToCafe(cafeInfoId: Int) {
        let connectedCafeInfo = self.cafeInfos.first { cafeInfo in
            cafeInfo.id == cafeInfoId
        }
        if let connectedCafeInfo = connectedCafeInfo {
            self.clearModal()
            self.modalCafeInfo = connectedCafeInfo
            self.modalCafe = connectedCafeInfo.cafes.first ?? Cafe.empty
            
            self.updateCameraPosition(NMFCameraPosition(
                NMGLatLng(lat: connectedCafeInfo.latitude, lng: connectedCafeInfo.longitude),
                zoom: Zoom.medium
            )) {
                self.getModalCafePlaceInfo(googlePlaceId: connectedCafeInfo.googlePlaceId)
            }
            self.isBottomSheetOpened = true
        }
    }
    
    func getCrowdedMarkerUIImage(crowded: Int) -> UIImage? {
        switch crowded {
        case Crowded.crowdedZero.value: return blueMarkerUIImage
        case Crowded.crowdedOne.value: return greenMarkerUIImage
        case Crowded.crowdedTwo.value: return yellowMarkerUIImage
        case Crowded.crowdedThree.value: return orangeMarkerUIImage
        case Crowded.crowdedFour.value: return redMarkerUIImage
        default: return grayMarkerUIImage
        }
    }
    
    func drawMarkers(cafeInfos: CafeInfos, selectedCafeInfoId: Int = 0) async {
        self.markers.forEach { marker in
            marker.mapView = nil
        }
        self.markers.removeAll()
        var newMarkerList: [NMFMarker] = []
        
        cafeInfos.forEach { cafeInfo in
            let newMarker = NMFMarker()
            if let markerIcon = getCrowdedMarkerUIImage(crowded: cafeInfo.getMinCrowded()) {
                newMarker.iconImage = NMFOverlayImage(image: markerIcon)
            }
            newMarker.position = NMGLatLng(lat: cafeInfo.latitude, lng: cafeInfo.longitude)
            newMarker.captionAligns = [.top]
            newMarker.height = 36.0
            newMarker.width = 31.0
            newMarker.captionOffset = 4.0
            newMarker.captionTextSize = 16.0
            newMarker.subCaptionTextSize = 15.0
            newMarker.subCaptionColor = cafeInfo.getMinCrowded().toCrowded().uiTextColor
            newMarker.subCaptionHaloColor = cafeInfo.getMinCrowded().toCrowded().uiColor
            
            if cafeInfo.id == selectedCafeInfoId {
                newMarker.captionText = cafeInfo.name
                newMarker.subCaptionText = cafeInfo.getMinCrowded().toCrowded().string
                newMarker.height = 48.0
                newMarker.width = 41.0
                newMarker.zIndex = 3
            }
            
            newMarker.touchHandler = { (overlay: NMFOverlay) -> Bool in
                if cafeInfo.id != self.modalCafeInfo.id {
                    self.interstitialAdCounter += 1
                }
                self.clearModal()
                self.modalCafeInfo = cafeInfo
                self.modalCafe = cafeInfo.cafes.first ?? Cafe.empty
                self.updateCameraPosition(
                    NMFCameraPosition(
                        NMGLatLng(lat: cafeInfo.latitude, lng: cafeInfo.longitude),
                        zoom: self.lastCameraPosition.zoom
                    ),
                    isShortD: true
                ) {
                    self.getModalCafePlaceInfo(googlePlaceId: cafeInfo.googlePlaceId)
                }
                if let selectedMarker = self.selectedMarker {
                    selectedMarker.captionText = ""
                    selectedMarker.subCaptionText = ""
                    selectedMarker.height = 36.0
                    selectedMarker.width = 31.0
                    selectedMarker.zIndex = 1
                }
                self.selectedMarker = newMarker
                newMarker.captionText = cafeInfo.name
                newMarker.subCaptionText = cafeInfo.getMinCrowded().toCrowded().string
                newMarker.height = 48.0
                newMarker.width = 41.0
                newMarker.zIndex = 3
                
                self.isBottomSheetOpened = true
                
                return true
            }
            newMarkerList.append(newMarker)
        }
        
        self.markers = newMarkerList
        self.isMarkerUpdateTriggered = true
    }
    
    func updateCameraPosition(_ cameraPosition: NMFCameraPosition, isShortD: Bool = false, onMoveFinish: @escaping () -> Void = {}) {
        self.cameraPosition = cameraPosition
        if isShortD {
            self.isShortDCameraUpdateTriggered = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onMoveFinish()
            }
        } else {
            self.isLongDCameraUpdateTriggered = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onMoveFinish()
            }
        }
    }
    
    func getModalCafePlaceInfo(googlePlaceId: String) {
        fetchImagesWork?.cancel()
        if googlePlaceId != String.None {
            self.googlePlaceClient.fetchPlace(
                fromPlaceID: googlePlaceId,
                placeFields: GMSPlaceField(
                    rawValue: UInt(GMSPlaceField.photos.rawValue) |
                    UInt(GMSPlaceField.openingHours.rawValue) |
                    UInt(GMSPlaceField.utcOffsetMinutes.rawValue) |
                    UInt(GMSPlaceField.businessStatus.rawValue)
                ),
                sessionToken: nil,
                callback: { place, error in
                    if let error = error {
                        print("An error occurred: \(error.localizedDescription)")
                        self.modalPreviewImagesLoading = false
                    }
                    if let place = place {
                        self.modalImageMetaData.removeAll()
                        self.modalPreviewImages.removeAll()
                        self.modalCafePlace = place
                        self.modalImageMetaData = place.photos ?? []
                        
                        if !self.modalImageMetaData.isEmpty {
                            self.fetchImagesWork = DispatchWorkItem(block: {
                                var photoNum = self.modalImageMetaData.count
                                photoNum = photoNum > 2 ? 3 : photoNum
                                self.modalImageMetaData[0 ..< photoNum].forEach { photoMetaData in
                                    self.googlePlaceClient.loadPlacePhoto(photoMetaData, callback: { photo, error in
                                        if let error = error {
                                            print("Error loading photo metadata: \(error.localizedDescription)")
                                        } else {
                                            if self.modalCafeInfo.googlePlaceId == googlePlaceId {
                                                self.modalPreviewImages.append(photo!)
                                                if let attributionString = photoMetaData.attributions?.string {
                                                    self.modalAttributions += attributionString + "님, "
                                                }
                                                self.modalPreviewImagesLoading = false
                                            }
                                        }
                                    })
                                }
                            })
                            if let work = self.fetchImagesWork {
                                DispatchQueue.main.asyncAfter(deadline: .now(), execute: work)
                            }
                        }
                    }
                }
            )
        } else {
            self.modalPreviewImagesLoading = false
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
        coreState.masterRoomCafeLog = CafeLog(
            id: 0,
            cafeId: self.modalCafe.id,
            name: self.modalCafeInfo.name,
            latitude: self.modalCafeInfo.latitude,
            longitude: self.modalCafeInfo.longitude,
            floor: self.modalCafe.floor,
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
    
    func searchCafe(coreState: CoreState, query: String) async {
        do {
            let cafeInfoRepresentationList = try await cafeRepository.search(query: query)
            var resList: CafeInfos = []
            cafeInfoRepresentationList.forEach { cafeInfoRepresentationResponse in
                resList.append(cafeInfoRepresentationResponse.getCafeInfo())
            }
            if !resList.isEmpty {
                if let userLastLocation = coreState.userLastLocation {
                    self.searchCafeInfos = resList.sorted(by: { cafeInfo1, cafeInfo2 in
                        let dis1 = userLastLocation.distance(from: CLLocation(latitude: cafeInfo1.latitude, longitude: cafeInfo1.longitude))
                        let dis2 = userLastLocation.distance(from: CLLocation(latitude: cafeInfo2.latitude, longitude: cafeInfo2.longitude))
                        return dis1 < dis2
                    })
                } else {
                    self.searchCafeInfos = resList
                }
            }
        } catch CustomError.errorMessage(let msg){
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
                accessToken: coreState.accessToken, cafeId: modalCafe.id, crowded: crowded
            ).getCafeLog()
            coreState.masterRoomCafeLog = cafeLog
            coreState.isMasterActivated = true
            await self.getNearbyCafeInfos(coreState: coreState)
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
            await self.getNearbyCafeInfos(coreState: coreState)
            isMasterRoomCtaProgress = false
            coreState.showSnackBar(message: "카페 혼잡도를 '\(crowded.toCrowded().string)'(으)로 변경하였습니다")
        } catch CustomError.masterExpired {
            isMasterRoomCtaProgress = false
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
            await self.getNearbyCafeInfos(coreState: coreState)
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
            await self.getNearbyCafeInfos(coreState: coreState)
            
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
    
    func addAdPoint(coreState: CoreState, cafeLogId: Int) async {
        do {
            coreState.user = try await cafeRepository.addAdPoint(accessToken: coreState.accessToken, cafeLogId: cafeLogId).getUser()
        } catch CustomError.accessTokenExpired {
            await self.refreshAccessToken(coreState: coreState, jobWithNewAccessToken: { newAccessToken in
                await addAdPoint(coreState: coreState, cafeLogId: cafeLogId)
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
                coreState.autoExpiredCafeLog = autoExpiredCafeLog
                coreState.isAutoExpiredDialogOpened = true
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
