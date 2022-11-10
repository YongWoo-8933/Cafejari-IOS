//
//  CoreState.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/19.
//

import Foundation
import SwiftUI
import CoreLocation

class CoreState: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var isAppInitiated: Bool = false
    @Published var isSplashFinished: Bool = false
    
    @Published var navigationPath: NavigationPath = NavigationPath()
    @Published var selectedBottomBarItem: String = BottomTab.Map.name
    
    @Published var isLogedIn: Bool = false
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

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationAuthorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedAlways ||  manager.authorizationStatus == .authorizedWhenInUse {
            self.startLocationTracking()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLastLocation = locations.first
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
