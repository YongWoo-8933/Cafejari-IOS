//
//  CoreState.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/19.
//

import Foundation
import SwiftUI
import CoreLocation
import AppTrackingTransparency
import PhotosUI

class CoreState: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var isAppInitiated: Bool = false
    @Published var isSplashFinished: Bool = false
    
    @Published var navigationPath: NavigationPath = NavigationPath()
    @Published var selectedBottomBarItem: String = BottomTab.Map.name
    
    @Published var isLogedIn: Bool = false
    @Published var isPermissionChecked: Bool = false
    @Published var accessToken: String = ""
    @Published var refreshToken: String = ""
    @Published var user: User = User.empty
    @Published var locationAuthorizationStatus: CLAuthorizationStatus
    @Published var userLastLocation: CLLocation?
    
    @Published var isSnackBarOpened: Bool = false
    @Published var snackBarContent: String = ""
    @Published var snackBarType: SnackBarType = .alert
    
    @Published var mapType: MapType = .crowded
    @Published var isMasterActivated: Bool = false
    @Published var masterRoomCafeLog: CafeLog = CafeLog.empty
    @Published var isAutoExpiredDialogOpened = false
    @Published var autoExpiredCafeLog: AutoExpiredCafeLog? = nil
    
    @Published var pointResultPoint: Int = 0
    @Published var pointResultViewType: PointResultViewType = PointResultViewType.masterExpired
        
    private let locationManager: CLLocationManager
    private var isPermissionRequestTriggered: Bool = false
    private var snackBarWork: DispatchWorkItem? = nil
    
    
    override init() {
        locationManager = CLLocationManager()
        locationAuthorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // location
    func startLocationTracking() {
        locationManager.startUpdatingLocation()
    }
    
    func requestPermissions() {
        isPermissionRequestTriggered = true
        locationManager.requestWhenInUseAuthorization()
    }
    
    func isPermissionCheckFinished() -> Bool {
        return locationAuthorizationStatus != .notDetermined ||
        ATTrackingManager.trackingAuthorizationStatus != .notDetermined ||
        PHPhotoLibrary.authorizationStatus() != .notDetermined
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationAuthorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedAlways ||  manager.authorizationStatus == .authorizedWhenInUse {
            self.startLocationTracking()
        }
        
        if isPermissionRequestTriggered {
            let notiCenter = UNUserNotificationCenter.current()
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                switch settings.alertSetting {
                case .enabled:
                    DispatchQueue.main.sync {
                        self.isPermissionChecked = true
                    }
                    return
                default:
                    notiCenter.requestAuthorization(
                        options: [.alert, .sound, .badge], completionHandler: { didAllow, Error in
                            switch ATTrackingManager.trackingAuthorizationStatus {
                            case .authorized:
                                DispatchQueue.main.sync {
                                    self.isPermissionChecked = true
                                }
                                return
                            default:
                                DispatchQueue.main.asyncAfter(deadline: .now() + .long) {
                                    ATTrackingManager.requestTrackingAuthorization { _ in
                                        if PHPhotoLibrary.authorizationStatus() != .authorized {
                                            PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in
                                                DispatchQueue.main.sync {
                                                    self.tapToMap()
                                                    self.clearStack()
                                                    self.isPermissionChecked = true
                                                    self.showSnackBar(message: "권한 설정이 완료되었습니다. 카페자리 서비스를 모두 활용해보세요!")
                                                }
                                            }
                                        } else {
                                            DispatchQueue.main.sync {
                                                self.isPermissionChecked = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    )
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLastLocation = locations.first
    }
    
    func isNearBy(latitude: Double, longitude: Double) -> Bool {
//        if let userLocation = self.userLastLocation {
//            return userLocation.coordinate.latitude < latitude + 0.00023 && userLocation.coordinate.latitude > latitude - 0.00023 && userLocation.coordinate.longitude < longitude + 0.00027 && userLocation.coordinate.longitude > longitude - 0.00027
//        } else {
//            return false
//        }
        return true
    }
    
    
    
    // main
    func clearStack() {
        navigationPath = NavigationPath()
    }
    
    func popUp() {
        navigationPath.removeLast()
    }
    
    func navigate(_ route: String) {
        navigationPath.append(route)
    }
    
    func navigateWithClear(_ route: String) {
        navigationPath = NavigationPath()
        navigationPath.append(route)
    }
    
    func tapToMap() {
        selectedBottomBarItem = BottomTab.Map.name
    }
    
    func tapToLeaderBoard() {
        selectedBottomBarItem = BottomTab.LeaderBoard.name
    }
    
    func tapToShop() {
        selectedBottomBarItem = BottomTab.Shop.name
    }
    
    func tapToProfile() {
        selectedBottomBarItem = BottomTab.Profile.name
    }
    
    
    
    // snack bar
    func clearSnackBar() {
        self.isSnackBarOpened = false
        self.snackBarType = SnackBarType.alert
        self.snackBarContent = ""
    }
    
    func showSnackBar(message: String, type: SnackBarType = SnackBarType.alert) {
        if let work = self.snackBarWork {
            work.cancel()
        }
        self.snackBarWork = DispatchWorkItem(block: {
            self.clearSnackBar()
        })
        self.snackBarType = type
        self.snackBarContent = message
        self.isSnackBarOpened = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: self.snackBarWork!)
    }
}
