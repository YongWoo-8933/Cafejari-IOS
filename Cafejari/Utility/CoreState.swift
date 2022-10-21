//
//  CoreState.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/19.
//

import Foundation
import SwiftUI

class CoreState: ObservableObject {
    
    @Published var isAppInitiated: Bool = false
    @Published var isSplashFinished: Bool = false
    
    @Published var navigationPath: NavigationPath = NavigationPath()
    @Published var selectedBottomBarItem: String = BottomTab.Home.name
    
    @Published var isLogedIn: Bool = false
    @Published var accessToken: String = ""
    @Published var refreshToken: String = ""
    @Published var user: User = User.empty
    
    init(){
        navigationPath = NavigationPath()
        selectedBottomBarItem = BottomTab.Home.name
    }
    
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
    
    func navBarVisible() -> Bool {
        selectedBottomBarItem == BottomTab.Home.name
    }
    
    func tapToUserMap() {
        selectedBottomBarItem = BottomTab.UserMap.name
    }
    
    func tapToHome() {
        selectedBottomBarItem = BottomTab.Home.name
    }
    
    func tapToMasterMap() {
        selectedBottomBarItem = BottomTab.MasterMap.name
    }
}
